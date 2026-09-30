#!/usr/bin/env python3
import json
import plistlib
import subprocess
import sys
from pathlib import Path


def restore(config):
    shared = Path.home() / (
        "Library/Group Containers/group.com.apple.controlcenter/"
        "Library/Preferences/group.com.apple.controlcenter.plist"
    )
    tracked = None
    try:
        shared.stat()
    except FileNotFoundError:
        pass
    else:
        preferences = plistlib.loads(
            subprocess.check_output(["/usr/bin/defaults", "export", str(shared), "-"])
        )
        if "trackedApplications" in preferences:
            tracked = plistlib.loads(preferences["trackedApplications"])
            if not isinstance(tracked, list) or len(tracked) % 2:
                raise ValueError("Unrecognized Control Center trackedApplications format")

    changed = False
    if tracked is not None:
        # macOS encodes this dictionary as alternating key and value records.
        for key, value in zip(tracked[::2], tracked[1::2]):
            if not isinstance(key, dict) or not isinstance(value, dict):
                raise ValueError("Unrecognized Control Center application record")
            bundle = key.get("bundle", {}).get("_0")
            if bundle in config["applications"]:
                allowed = config["applications"][bundle]
                if type(allowed) is not bool or type(value.get("isAllowed")) is not bool:
                    raise ValueError(f"Invalid menu bar permission for {bundle}")
                if value["isAllowed"] != allowed:
                    value["isAllowed"] = allowed
                    changed = True

    for section, flags in [("currentHost", ["-currentHost"]), ("defaults", [])]:
        for domain, values in config[section].items():
            for key, value in values.items():
                kind = {bool: "-bool", int: "-int", float: "-float"}[type(value)]
                subprocess.run(
                    ["/usr/bin/defaults", *flags, "write", domain, key, kind, str(value)],
                    check=True,
                )

    if changed:
        subprocess.run(
            [
                "/usr/bin/defaults", "write", str(shared), "trackedApplications",
                "-data", plistlib.dumps(tracked, fmt=plistlib.FMT_BINARY).hex(),
            ],
            check=True,
        )
    if tracked is None:
        print("Menu bar settings restored. Launch menu bar apps, then rebuild again to restore their visibility permissions.")
    else:
        print("Menu bar settings restored. Some apps may need relaunching to adopt their saved positions.")


if __name__ == "__main__":
    restore(json.loads(Path(sys.argv[1]).read_text()))
