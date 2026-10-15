"""Write ~/.agents/mcp/servers.json into each agent's own MCP config (tokens stay per tool)."""

import json
import os
import shutil
import subprocess
import sys
from pathlib import Path

import tomlkit

HOME = Path.home()
REGISTRY = HOME / ".agents/mcp/servers.json"
DRY_RUN = "--dry-run" in sys.argv


def load_registry():
    reg = json.loads(REGISTRY.read_text())
    return reg["servers"], reg.get("unmanaged", {})


def for_harness(servers, harness):
    out = {}
    for name, s in servers.items():
        if harness not in s.get("only", [harness]):
            continue
        s = dict(s)
        if "args" in s:
            s["args"] = [a.replace("{harness}", harness) for a in s["args"]]
        out[name] = s
    return out


def report(harness, added, changed, removed, skipped=()):
    parts = [f"+{n}" for n in added] + [f"~{n}" for n in changed] + [f"-{n}" for n in removed]
    parts += [f"skip {n}" for n in skipped]
    print(f"{harness}: {' '.join(parts) if parts else 'in sync'}")


def diff(current, desired, unmanaged):
    added = [n for n in desired if n not in current]
    changed = [n for n in desired if n in current and current[n] != desired[n]]
    removed = [n for n in current if n not in desired and n not in unmanaged]
    return added, changed, removed


def write_json(path, data):
    if DRY_RUN:
        return
    tmp = path.with_suffix(path.suffix + ".tmp")
    tmp.write_text(json.dumps(data, indent=2) + "\n")
    os.replace(tmp, path)


def claude_entry(s):
    if "url" in s:
        e = {"type": "http", "url": s["url"]}
        if "headersHelper" in s:
            e["headersHelper"] = s["headersHelper"]
        return e
    return {"type": "stdio", "command": s["command"], "args": s.get("args", []), "env": s.get("env", {})}


def sync_claude(servers, unmanaged):
    claude = shutil.which("claude") or str(HOME / ".local/bin/claude")
    current = json.loads((HOME / ".claude.json").read_text()).get("mcpServers", {})
    desired = {n: claude_entry(s) for n, s in for_harness(servers, "claude").items()}
    added, changed, removed = diff(current, desired, unmanaged)
    if not DRY_RUN:
        for n in changed + removed:
            subprocess.run([claude, "mcp", "remove", "-s", "user", n], check=True, capture_output=True)
        for n in added + changed:
            subprocess.run([claude, "mcp", "add-json", "-s", "user", n, json.dumps(desired[n])], check=True, capture_output=True)
    report("claude", added, changed, removed)

    # Claude has no per-server tool switch; deny the tool in user settings instead.
    settings_path = HOME / ".claude/settings.json"
    settings = json.loads(settings_path.read_text())
    deny = settings.setdefault("permissions", {}).setdefault("deny", [])
    wanted = [f"mcp__{n}__{t}" for n, s in servers.items() for t in s.get("disabledTools", [])]
    missing = [r for r in wanted if r not in deny]
    if missing:
        deny.extend(missing)
        write_json(settings_path, settings)
        print(f"claude: denied {' '.join(missing)}")


def codex_entry(s):
    e = {"url": s["url"]} if "url" in s else {"command": s["command"]}
    if "args" in s:
        e["args"] = s["args"]
    if "env" in s:
        e["env"] = s["env"]
    if "headersHelper" in s:
        e["http_headers_helper"] = s["headersHelper"]
    if "disabledTools" in s:
        e["disabled_tools"] = s["disabledTools"]
    e.update(s.get("codex", {}))
    return e


def sync_codex(servers, unmanaged):
    path = HOME / ".codex/config.toml"
    doc = tomlkit.parse(path.read_text())
    table = doc.setdefault("mcp_servers", tomlkit.table(is_super_table=True))
    current = {n: table[n].unwrap() for n in table}
    desired = {n: codex_entry(s) for n, s in for_harness(servers, "codex").items()}
    added, changed, removed = diff(current, desired, unmanaged)
    for n in removed:
        del table[n]
    for n in added + changed:
        table[n] = desired[n]
    if (added or changed or removed) and not DRY_RUN:
        tmp = path.with_suffix(".toml.tmp")
        tmp.write_text(tomlkit.dumps(doc))
        os.replace(tmp, path)
    report("codex", added, changed, removed)


def sync_cursor(servers, unmanaged):
    path = HOME / ".cursor/mcp.json"
    data = json.loads(path.read_text()) if path.exists() else {}
    current = data.get("mcpServers", {})
    desired, skipped = {}, []
    for n, s in for_harness(servers, "cursor").items():
        # Cursor can't fetch headers or disable single tools, so skip servers that need either.
        if "headersHelper" in s or "disabledTools" in s:
            skipped.append(n)
        elif "url" in s:
            desired[n] = {"url": s["url"]}
        else:
            desired[n] = {"command": s["command"], "args": s.get("args", []), "env": s.get("env", {})}
    added, changed, removed = diff(current, desired, unmanaged)
    if added or changed or removed:
        data["mcpServers"] = {**{n: v for n, v in current.items() if n in unmanaged}, **desired}
        write_json(path, data)
    report("cursor", added, changed, removed, skipped)


def sync_opencode(servers, unmanaged):
    path = HOME / ".config/opencode/opencode.json"
    data = json.loads(path.read_text())
    current = data.get("mcp", {})
    desired, skipped = {}, []
    for n, s in for_harness(servers, "opencode").items():
        if "headersHelper" in s:
            skipped.append(n)
        elif "url" in s:
            desired[n] = {"type": "remote", "url": s["url"], "enabled": True}
        else:
            desired[n] = {"type": "local", "command": [s["command"], *s.get("args", [])], "environment": s.get("env", {}), "enabled": True}
    added, changed, removed = diff(current, desired, unmanaged)
    if added or changed or removed:
        data["mcp"] = {**{n: v for n, v in current.items() if n in unmanaged}, **desired}
        write_json(path, data)
    disabled = {f"{n}_{t}": False for n, s in servers.items() for t in s.get("disabledTools", [])}
    if any(data.get("tools", {}).get(k) is not False for k in disabled):
        data.setdefault("tools", {}).update(disabled)
        write_json(path, data)
    report("opencode", added, changed, removed, skipped)


def main():
    servers, unmanaged = load_registry()
    syncs = {"claude": sync_claude, "codex": sync_codex, "cursor": sync_cursor, "opencode": sync_opencode}
    failed = False
    for harness, sync in syncs.items():
        try:
            sync(servers, set(unmanaged.get(harness, [])))
        except Exception as e:  # one broken harness must not block the others
            print(f"{harness}: FAILED {e}", file=sys.stderr)
            failed = True
    sys.exit(1 if failed else 0)


if __name__ == "__main__":
    main()
