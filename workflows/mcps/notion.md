# MCP setup — Notion

Connects Notion to Claude Code and OpenCode so `/notion` can create pages and post updates directly.

---

## 1. create a Notion integration

1. Go to https://www.notion.so/profile/integrations → New integration
2. Name it (e.g. `claude-code`), select your workspace
3. Set capabilities: Read content, Update content, Insert content
4. Copy the **Internal Integration Token** (`secret_...`)
5. Share the databases or pages you want the integration to access:
   - Open the page in Notion → `...` menu → Connections → select your integration

## 2. export the token in your shell profile

Add to `~/.zshrc` (or `~/.bashrc`) — **never put raw tokens in committed config files**:

```bash
export NOTION_API_KEY="secret_your_token_here"
```

Then reload: `source ~/.zshrc`

---

## 3. configure Claude Code

Add to `~/.claude/settings.json` (create the file if it doesn't exist):

```json
{
  "mcpServers": {
    "notion": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-notion"],
      "env": {
        "NOTION_API_KEY": "${NOTION_API_KEY}"
      }
    }
  }
}
```

If `mcpServers` already exists, add the `"notion"` block inside it.

---

## 4. configure OpenCode

Add to `~/.config/opencode/opencode.json` inside the `"mcp"` block:

```json
{
  "mcp": {
    "notion": {
      "type": "local",
      "command": ["npx", "-y", "@modelcontextprotocol/server-notion"],
      "environment": {
        "NOTION_API_KEY": "${NOTION_API_KEY}"
      }
    }
  }
}
```

---

## 5. test the connection

In a Claude Code session:
```
/mcp
```
Confirm `notion` appears as connected. Then test:
```
List the Notion pages I have access to.
```

---

## notes

- The integration only sees pages explicitly shared with it — if a database or page isn't showing up, check Connections in the Notion UI
- On machines without the env var set, the MCP silently fails to connect — everything else keeps working
- The MCP supports: reading pages, creating pages, appending blocks, querying databases
