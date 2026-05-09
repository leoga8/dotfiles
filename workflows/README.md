# workflows

Reusable AI workflow definitions. Tool-agnostic — works with Claude Code, OpenCode, or any AI tool that reads markdown.

---

## purpose

This folder is a portable library of AI workflows. Each workflow is a self-contained unit: a prompt file that tells the AI what to do, optional tool scripts it can call, and a reference data file with all templates and conventions it needs.

**Key design principles:**
- The `workflows/` folder is the single source of truth — not any specific AI tool's config directory
- Tool-specific activation (slash commands, skill files) are thin shims that point here — they are never the source of truth
- Workflows are self-contained — each one carries everything it needs in its own `data/` folder, with no dependency on external vault or project files
- Obsidian workflows are vault-aware but not vault-bound — tool scripts accept the vault path as an argument so they work whether this folder lives inside the vault or in a dotfiles repo

---

## structure

Each workflow follows this pattern:

```
workflows/
└── <domain>/
    └── <workflow-name>/
        ├── prompts/   — markdown prompt files (the main instruction)
        ├── tools/     — scripts and helper utilities
        └── data/      — input templates, output logs, reference data
```

Current workflows:

```
workflows/
├── obsidian/
│   ├── vault-setup/    — bootstrap or migrate a vault to this structure
│   │   ├── prompts/vault-setup.md    suggested command: /vault-setup
│   │   ├── tools/scaffold-vault.sh
│   │   └── data/reference.md
│   ├── vault-update/   — wrap-up routine: sync me.md, AGENTS.md, inbox
│   │   └── prompts/update.md         suggested command: /wrap-up
│   ├── daily-open/     — session-opening routine: daily note, agenda, loose ends
│   │   ├── prompts/hello.md          suggested command: /hello
│   │   └── tools/
│   │       ├── check-daily-exists.sh
│   │       └── create-daily-note.sh
│   ├── inbox-process/  — classify and file notes from add/ inbox
│   │   ├── prompts/inbox.md          suggested command: /inbox
│   │   └── tools/
│   │       ├── list-inbox.sh
│   │       └── move-note.sh
│   └── bills/          — monthly bill note creation
│       ├── prompts/bills.md          suggested command: /bills
│       ├── tools/
│       │   ├── check-existing-bills.sh
│       │   └── create-bill-note.sh
│       └── data/vendors.txt
├── code/
│   ├── project-setup/  — bootstrap a new coding project with AI conventions
│   │   ├── prompts/project-setup.md    suggested command: /project-setup
│   │   ├── tools/scaffold-project.sh
│   │   ├── tools/init-git.sh
│   │   └── data/reference.md
│   ├── database/       — SQL workflows backed by Snowflake schema exports
│   │   ├── data/<something>-schema.csv  source of truth — export from Snowflake information_schema
│   │   ├── data/<something>-erd.md      auto-generated DBML — run /refresh-erd to produce or update
│   │   └── data/example-query.sql       style reference — fill in with a representative query
│   │   ├── query/
│   │   │   └── prompts/query.md         suggested command: /query
│   │   ├── optimize/
│   │   │   └── prompts/optimize.md      suggested command: /optimize
│   │   └── refresh-erd/
│   │       └── prompts/refresh-erd.md   suggested command: /refresh-erd
│   ├── review-code/    — code review against project conventions
│   │   └── prompts/review-code.md    suggested command: /review-code
│   ├── test/           — generate tests for existing code
│   │   └── prompts/test.md           suggested command: /test
│   └── refactor/       — safe refactoring without behavior changes
│       └── prompts/refactor.md       suggested command: /refactor
├── cellular/
│   ├── cellular/       — debug AT command and modem logs
│   │   ├── prompts/cellular.md            suggested command: /cellular
│   │   └── data/<device-name>.md          saved device config (copy example-device.md)
│   └── trace/          — analyze PCAP and network traces with tshark
│       ├── prompts/trace.md               suggested command: /trace
│       ├── data/<project-name>.md         saved project config (copy example-project.md)
│       └── data/reference.md              tshark command reference
├── solutions/
│   ├── data/
│   │   ├── config.md              machine-specific paths (gitignored — set on first use)
│   │   └── context-template.md    template for CONTEXT.md in each inc/ or sr/ folder
│   ├── new/
│   │   └── prompts/new.md         suggested command: /new
│   ├── log/
│   │   └── prompts/log.md         suggested command: /log
│   ├── email/
│   │   └── prompts/email.md       suggested command: /email
│   ├── slack/
│   │   └── prompts/slack.md       suggested command: /slack
│   ├── linear/
│   │   └── prompts/linear.md      suggested command: /linear
│   └── notion/
│       └── prompts/notion.md      suggested command: /notion
└── mcps/
    ├── slack.md     — install + configure Slack MCP for Claude Code and OpenCode
    ├── linear.md    — install + configure Linear MCP for Claude Code and OpenCode
    └── notion.md    — install + configure Notion MCP for Claude Code and OpenCode
```

---

## activation

Workflows are activated differently per tool, but the source of truth is always the prompt file in `workflows/`.

**Claude Code** — create `.claude/commands/<name>.md` with a single line:
```
@/path/to/workflows/<domain>/<workflow-name>/prompts/<file>.md
```
Then run `/name` in any Claude Code session.

**OpenCode** — create `.opencode/commands/<name>.md` with the same one-liner.
Then run `/name` in any OpenCode session.

Neither `.claude/` nor `.opencode/` directories are committed here — they live in the project root where the tool is invoked and are created on demand. See the "per-project setup" section below.

### current slash commands

| command          | prompt file                                                    | description                               |
|------------------|----------------------------------------------------------------|-------------------------------------------|
| /hello           | obsidian/daily-open/prompts/hello.md                           | session opener: inbox, daily note, agenda |
| /wrap-up         | obsidian/vault-update/prompts/update.md                        | session closer: inbox, notes, drift check |
| /inbox           | obsidian/inbox-process/prompts/inbox.md                        | classify and file notes from add/         |
| /bills           | obsidian/bills/prompts/bills.md                                | monthly bill note creation                |
| /vault-setup     | obsidian/vault-setup/prompts/vault-setup.md                    | bootstrap or migrate a vault              |
| /project-setup   | code/project-setup/prompts/project-setup.md                    | bootstrap a new coding project            |
| /query           | code/database/query/prompts/query.md                           | build SQL queries from natural language   |
| /optimize        | code/database/optimize/prompts/optimize.md                     | analyze and optimize an existing query    |
| /refresh-erd     | code/database/refresh-erd/prompts/refresh-erd.md               | regenerate DBML ERDs from schema CSVs     |
| /review-code     | code/review-code/prompts/review-code.md                        | review code against project conventions   |
| /test            | code/test/prompts/test.md                                      | generate tests for existing code          |
| /refactor        | code/refactor/prompts/refactor.md                              | safe refactoring without behavior changes |
| /cellular        | cellular/cellular/prompts/cellular.md                          | debug AT command and modem logs           |
| /trace           | cellular/trace/prompts/trace.md                                | analyze PCAP and network traces           |
| /new             | solutions/new/prompts/new.md                                   | scaffold a new INC or SR folder           |
| /log             | solutions/log/prompts/log.md                                   | append update to Obsidian note            |
| /email           | solutions/email/prompts/email.md                               | draft update, escalation, or resolution   |
| /slack           | solutions/slack/prompts/slack.md                               | draft or post Slack thread message        |
| /linear          | solutions/linear/prompts/linear.md                             | create or update a Linear issue           |
| /notion          | solutions/notion/prompts/notion.md                             | post or update a Notion page              |

> This table is kept in sync automatically by /wrap-up. When adding a new workflow, add its suggested command here and run /wrap-up to confirm.

---

## dotfiles setup (recommended)

Keep this `workflows/` folder in a personal dotfiles or standalone git repo so it is version-controlled, shareable, and available on any machine without manual copying.

**One-time setup per machine:**

```bash
# 1. Clone your workflows repo to a permanent location (run once per machine)
git clone git@github.com:yourname/workflows.git ~/workflows

# 2. Create global command directories for your AI tools (run once per machine)
mkdir -p ~/.claude/commands
mkdir -p ~/.opencode/commands

# 3. Register slash commands globally (run once per machine, repeat for each command)
echo "@$HOME/workflows/obsidian/daily-open/prompts/hello.md"        > ~/.claude/commands/hello.md
echo "@$HOME/workflows/obsidian/vault-update/prompts/update.md"     > ~/.claude/commands/wrap-up.md
echo "@$HOME/workflows/obsidian/inbox-process/prompts/inbox.md"     > ~/.claude/commands/inbox.md
echo "@$HOME/workflows/obsidian/bills/prompts/bills.md"             > ~/.claude/commands/bills.md
echo "@$HOME/workflows/obsidian/vault-setup/prompts/vault-setup.md" > ~/.claude/commands/vault-setup.md
echo "@$HOME/workflows/code/project-setup/prompts/project-setup.md" > ~/.claude/commands/project-setup.md
echo "@$HOME/workflows/solutions/new/prompts/new.md"                > ~/.claude/commands/new.md
echo "@$HOME/workflows/solutions/log/prompts/log.md"                > ~/.claude/commands/log.md
echo "@$HOME/workflows/solutions/email/prompts/email.md"            > ~/.claude/commands/email.md
echo "@$HOME/workflows/solutions/slack/prompts/slack.md"            > ~/.claude/commands/slack.md
echo "@$HOME/workflows/solutions/linear/prompts/linear.md"          > ~/.claude/commands/linear.md
echo "@$HOME/workflows/solutions/notion/prompts/notion.md"          > ~/.claude/commands/notion.md
```

After this, `~/workflows/` sits permanently on the machine — it is never copied into individual projects. It is the recipe; projects are the output.

**Obsidian workflows and the vault path** — the tool scripts in `obsidian/*/tools/` all accept `<vault-root>` as their first argument. When the AI calls them from within the vault this can be `.`, but when the workflows folder lives outside the vault (e.g. in `~/workflows/`), the AI must pass the full vault path explicitly:

```bash
# from inside the vault (workflows/ is a subfolder)
./workflows/obsidian/daily-open/tools/check-daily-exists.sh .

# from dotfiles (workflows/ lives outside the vault)
./check-daily-exists.sh /path/to/your/vault
```

The workflow prompts handle this automatically — they resolve the vault path at runtime and pass it to the tools.

**Solutions workflows and machine-specific paths** — `solutions/data/config.md` stores the `solutions_root` and `vault_path` for each machine. This file is gitignored. On first use of any solutions command (`/new`, `/log`, etc.) the AI will prompt for these values and save them automatically.

**MCP connectors** — to enable `/slack`, `/linear`, and `/notion` to post directly (rather than draft-only mode), set up the relevant MCP on each machine. See `workflows/mcps/` for step-by-step instructions for each connector.

**MCP tokens and dotfiles safety** — never hardcode API tokens directly in `opencode.json` or `~/.claude/settings.json`. Both tools inherit the shell environment, so export tokens in your shell profile instead and reference them as `${VAR_NAME}` in config files. This way the config is safe to commit and tokens stay machine-local:

```bash
# in ~/.zshrc (or ~/.bashrc) — never in a committed config file
export SLACK_BOT_TOKEN="xoxb-..."
export SLACK_TEAM_ID="T0123ABCDEF"
export LINEAR_API_KEY="lin_api_..."
export NOTION_API_KEY="secret_..."
```

Config files then reference them as `"${SLACK_BOT_TOKEN}"` — if the var isn't set on a machine, the MCP silently fails to connect but everything else keeps working.

---

## per-project setup

### code projects

Every new code project bootstrapped with `/project-setup` gets its own `AGENTS.md` and `CLAUDE.md` in the project root. These files are project-specific and are committed to the project repo — they are not shared with this workflows folder.

```
my-project/
├── AGENTS.md    ← AI operating rules for this specific project (committed)
├── CLAUDE.md    ← single line: @AGENTS.md (Claude Code entry point, committed)
└── ...
```

`CLAUDE.md` always contains a single line: `@AGENTS.md`. This tells Claude Code to load the project's AGENTS.md at session start, giving it the project's conventions and context without any manual setup.

The slash command (`.claude/commands/project-setup.md`) is **not** committed to the project repo — it lives in your global `~/.claude/commands/` and is available across all projects.

### obsidian vaults

Each Obsidian vault has its own `AGENTS.md` (operating rules + structure) and `me.md` (personal context). These live in the vault root and are vault-specific — they are not part of this workflows folder.

```
vault/
├── AGENTS.md    ← vault operating rules and structure
├── CLAUDE.md    ← single line: @AGENTS.md
├── me.md        ← personal context for AI
└── ...
```

The workflows folder does not need to be inside the vault. If it lives in dotfiles, the vault's `AGENTS.md` simply references it in the vault tree for documentation purposes.

---

## conventions

- Prompt files follow the **operating rules first** convention: constraints before context
- No HTML comments or hidden content in any prompt file — all instructions must be visible in rendered markdown
- Keep prompt files self-contained — do not rely on external file pointers that may not be available in all environments
- Tool scripts always accept `<vault-root>` or `<project-root>` as their first argument — never hardcode paths
- When a workflow is added or updated, reflect it in the tree above, in the slash commands table, and in the vault `AGENTS.md`
