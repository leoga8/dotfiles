# MCP setup — Slack

Connects Slack to Claude Code and OpenCode so `/slack` can post messages directly.

---

## 1. install the MCP server

```bash
npm install -g @modelcontextprotocol/server-slack
```

Get a Slack bot token from https://api.slack.com/apps:
- Create an app → OAuth & Permissions
- Add bot scopes: `channels:read`, `chat:write`, `chat:write.public`, `files:write`
- Install to workspace → copy the `xoxb-...` bot token

---

## 2. configure Claude Code

Add to `~/.claude/settings.json` (create the file if it doesn't exist):

```json
{
  "mcpServers": {
    "slack": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-slack"],
      "env": {
        "SLACK_BOT_TOKEN": "xoxb-your-token-here",
        "SLACK_TEAM_ID": "T0123ABCDEF"
      }
    }
  }
}
```

If `mcpServers` already exists, add the `"slack"` block inside it.

---

## 3. configure OpenCode

Add to `~/.config/opencode/opencode.json` inside the `"mcp"` block:

```json
{
  "mcp": {
    "slack": {
      "type": "local",
      "command": ["npx", "-y", "@modelcontextprotocol/server-slack"],
      "environment": {
        "SLACK_BOT_TOKEN": "xoxb-your-token-here",
        "SLACK_TEAM_ID": "T0123ABCDEF"
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
Confirm `slack` appears as connected. Then test:
```
List the channels I have access to in Slack.
```

---

## notes

- `SLACK_TEAM_ID` is the workspace ID — find it in your Slack URL: `https://app.slack.com/client/T0123ABCDEF/`
- The bot must be invited to any private channel before it can post there: `/invite @your-bot-name`
- Keep tokens out of dotfiles — use environment variables or a secrets manager if sharing this repo
