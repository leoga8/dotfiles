# MCP setup — Slack

Connects Slack to Claude Code and OpenCode so `/slack` can post messages directly.

---

## 1. get a bot token

Go to https://api.slack.com/apps:
- Create an app → OAuth & Permissions
- Add bot scopes: `channels:read`, `chat:write`, `chat:write.public`, `files:write`
- Install to workspace → copy the `xoxb-...` bot token
- Find your workspace ID in the Slack URL: `https://app.slack.com/client/T0123ABCDEF/`

## 2. export tokens in your shell profile

Add to `~/.zshrc` (or `~/.bashrc`) — **never put raw tokens in committed config files**:

```bash
export SLACK_BOT_TOKEN="xoxb-your-token-here"
export SLACK_TEAM_ID="T0123ABCDEF"
```

Then reload: `source ~/.zshrc`

---

## 3. configure Claude Code

Add to `~/.claude/settings.json` (create the file if it doesn't exist):

```json
{
  "mcpServers": {
    "slack": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-slack"],
      "env": {
        "SLACK_BOT_TOKEN": "${SLACK_BOT_TOKEN}",
        "SLACK_TEAM_ID": "${SLACK_TEAM_ID}"
      }
    }
  }
}
```

If `mcpServers` already exists, add the `"slack"` block inside it.

---

## 4. configure OpenCode

Add to `~/.config/opencode/opencode.json` inside the `"mcp"` block:

```json
{
  "mcp": {
    "slack": {
      "type": "local",
      "command": ["npx", "-y", "@modelcontextprotocol/server-slack"],
      "environment": {
        "SLACK_BOT_TOKEN": "${SLACK_BOT_TOKEN}",
        "SLACK_TEAM_ID": "${SLACK_TEAM_ID}"
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
Confirm `slack` appears as connected. Then test:
```
List the channels I have access to in Slack.
```

---

## notes

- The bot must be invited to any private channel before it can post there: `/invite @your-bot-name`
- On machines without the env vars set, the MCP silently fails to connect — everything else keeps working
