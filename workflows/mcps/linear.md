# MCP setup — Linear

Connects Linear to Claude Code and OpenCode so `/linear` can create issues and post comments directly.

---

## 1. get an API key

1. Go to https://linear.app → Settings → API → Personal API keys
2. Create a new key with a descriptive label (e.g. `claude-code`)
3. Copy the key — it won't be shown again

## 2. export the key in your shell profile

Add to `~/.zshrc` (or `~/.bashrc`) — **never put raw tokens in committed config files**:

```bash
export LINEAR_API_KEY="lin_api_your_key_here"
```

Then reload: `source ~/.zshrc`

---

## 3. configure Claude Code

Add to `~/.claude/settings.json` (create the file if it doesn't exist):

```json
{
  "mcpServers": {
    "linear": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-linear"],
      "env": {
        "LINEAR_API_KEY": "${LINEAR_API_KEY}"
      }
    }
  }
}
```

If `mcpServers` already exists, add the `"linear"` block inside it.

---

## 4. configure OpenCode

Add to `~/.config/opencode/opencode.json` inside the `"mcp"` block:

```json
{
  "mcp": {
    "linear": {
      "type": "local",
      "command": ["npx", "-y", "@modelcontextprotocol/server-linear"],
      "environment": {
        "LINEAR_API_KEY": "${LINEAR_API_KEY}"
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
Confirm `linear` appears as connected. Then test:
```
List my assigned Linear issues.
```

---

## notes

- API keys are personal — each machine needs its own key exported in the shell profile
- On machines without the env var set, the MCP silently fails to connect — everything else keeps working
- The MCP supports: creating issues, adding comments, updating status, listing teams and projects
