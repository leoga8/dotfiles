# ticket state machine

> States, transitions, and who may trigger each. The current state is the ticket note's `status` frontmatter; every transition appends a line to `## log`.

---

## states

| status | meaning |
|--------|---------|
| `new` | ticket note exists, no plan yet |
| `planned` | `## plan` written by a planner |
| `awaiting_approval` | plan (or a step's approval point) shown to the user, waiting |
| `approved` | user approved the plan; ready to run |
| `running` | steps are executing |
| `blocked` | needs a human — missing input, `needs_human: true`, or a step stopped at an approval point |
| `failed` | a step failed; see `## log` |
| `done` | all steps succeeded; outbound updates may still be pending in `## drafts` |
| `reported` | approved drafts were sent to the external system (or there was nothing to send) |
| `cancelled` | dropped by the user |

---

## transitions

| from | to | actor | when |
|------|----|-------|------|
| — | `new` | planner / user | ticket note created (template, ticket mode, or fetched by orchestration) |
| `new` | `planned` | planner | `## plan` written |
| `planned` | `awaiting_approval` | orchestration | plan included in a run's approval summary |
| `awaiting_approval` | `approved` | **user** | explicit approval |
| `awaiting_approval` | `planned` | **user** | user asks for a re-plan (planner rewrites `## plan`) |
| `approved` | `running` | orchestration | first step starts |
| `running` | `running` | orchestration | a step finishes and the next starts |
| `running` | `blocked` | orchestration | approval point reached, missing input, or needs human |
| `running` | `failed` | orchestration | a step failed |
| `running` | `done` | orchestration | last step succeeded |
| `blocked` | `approved` | **user** | blocker resolved — resume from the next unfinished step |
| `failed` | `planned` | **user** | re-plan |
| `failed` | `approved` | **user** | retry the failed step as-is |
| `done` | `reported` | orchestration, after **user** approval | drafts sent, or nothing to send |
| any | `cancelled` | **user** | — |

Any transition not in this table is not allowed. Transitions marked **user** require an explicit instruction from the user in the current session.

---

## log line format

Append under `## log`, newest last:

```
- YYYY-MM-DD HH:MM | <from> → <to> | <actor> | <note>
```

`actor` is `user`, `orchestration`, or the planner name. Keep notes to one line; put detail in `## outputs`.

---

## dry-run policy

Orchestration never sends anything outside the vault on its own.

- Comments, replies and status changes for external systems are written under `## drafts` as:
  ```
  - [ ] <source>: <action> — <content or target status>
  ```
- Only drafts the user explicitly approves are sent (tick the box or approve in chat), per `~/Documents/code/planner/sources.md`. After sending, change `- [ ]` to `- [x]` and add the time.
- This stays in place until the user explicitly changes this policy.
