# MCP setup — Linear

Connects Linear to Claude Code and OpenCode so `/linear` can create issues and post comments directly.

---

## 1. get a Linear API key

1. Go to https://linear.app → Settings → API → Personal API keys
2. Create a new key with a descriptive label (e.g. `claude-code`)
3. Copy the key — it won't be shown again

---

## 2. configure Claude Code

Add to `~/.claude/settings.json` (create the file if it doesn't exist):

```json
{
  "mcpServers": {
    "linear": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-linear"],
      "env": {
        "LINEAR_API_KEY": "lin_api_your_key_here"
      }
    }
  }
}
```

If `mcpServers` already exists, add the `"linear"` block inside it.

---

## 3. configure OpenCode

Add to `~/.config/opencode/opencode.json` inside the `"mcp"` block:

```json
{
  "mcp": {
    "linear": {
      "type": "local",
      "command": ["npx", "-y", "@modelcontextprotocol/server-linear"],
      "environment": {
        "LINEAR_API_KEY": "lin_api_your_key_here"
      }
    }
  }
}
```

---

## 4. test the connection

In a Claude Code session:
```
/mcp
```
Confirm `linear` appears as connected. Then test:
```
List my assigned Linear issues.
```

---

## notes

- API keys are personal — each machine / person needs their own
- Keep keys out of dotfiles — use environment variables or a secrets manager if sharing this repo
- The MCP supports: creating issues, adding comments, updating status, listing teams and projects
