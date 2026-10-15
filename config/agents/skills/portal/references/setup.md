# Connect Portal

Connect the user's AI client to `https://mcp.product.studio/mcp`.

Make the configuration changes yourself when you have access to the target
machine. Leave account sign-in and consent to the user. If the client or target
machine is unclear, ask before editing configuration; a remote agent's home
folder may not belong to the user's desktop.

## Claude Code

1. Run `claude mcp get portal`. If the command is unavailable, give the user the
   add command below to run where Claude Code is installed.
2. If the entry already uses the Portal URL, keep it. If `portal` points
   elsewhere, show the conflict and ask whether to replace it. Preserve other
   MCP servers.
3. If no entry exists, add Portal at user scope so it works in every project:

   ```sh
   claude mcp add --transport http --scope user portal https://mcp.product.studio/mcp
   ```

4. Have the user open `/mcp`, select Portal, and sign in.
5. Run `claude mcp list`. If Portal is connected but its tools are missing from
   the session, have the user restart it.

## Codex

1. Run `codex mcp get portal`. Keep an entry that already uses the Portal URL;
   ask before replacing one that points elsewhere.
2. If no entry exists:

   ```sh
   codex mcp add portal --url https://mcp.product.studio/mcp
   codex mcp login portal
   ```

3. Have the user complete sign-in in the browser, then start a new session.

## Cursor

Merge this entry into `mcpServers` in `~/.cursor/mcp.json`, preserving other
entries. Create the file if it is missing. If the file does not parse, report
the error before changing it.

```json
{
  "mcpServers": {
    "portal": { "url": "https://mcp.product.studio/mcp" }
  }
}
```

Have the user sign in to Portal from Cursor's MCP settings.

## Claude Desktop or claude.ai

1. Open **Settings → Connectors → Add custom connector**.
2. Enter `portal` as the name and `https://mcp.product.studio/mcp` as the URL.
3. Connect and sign in. If Portal is already listed, open it instead of adding
   another.

If the option is unavailable, ask the organization admin.

## Verify

The user signs in with their `@product.studio` account. A collaborator uses the
account a Portal admin approved. Then run one read-only call, such as
`portal_list_servers`.

Report the client, what changed, and what you verified. Saved configuration,
completed sign-in, and a successful tool call are separate milestones; say which
are still pending.

## When setup fails

- If sign-in is rejected, check which account the user signed in with. Refer
  access questions to a Portal admin.
- If Portal connects but a service is missing, ask a Portal admin for access.
  Reinstalling Portal does not grant it.
- If the connection or a tool call fails, record the client, the failing step,
  and the error, without tokens. An empty tool list alone does not show the
  cause.

Client docs: [Claude Code](https://code.claude.com/docs/en/mcp),
[Cursor](https://prod.cursor.com/help/customization/mcp),
[Claude connectors](https://support.claude.com/en/articles/11175166-get-started-with-custom-connectors-using-remote-mcp).
