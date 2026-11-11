# coffee-agents

**English** | [Русский](README.ru.md) | [中文](README.zh.md)

Global OpenCode settings: agents, skills and rules with the `coffee-` prefix.
Copied into the user config by a single script. Project-level `.opencode/` folders are not included.

## Install OpenCode first

macOS / Linux:

```sh
curl -fsSL https://opencode.ai/v2/install | bash
# or
brew install anomalyco/tap/opencode-v2
```

npm / bun / pnpm:

```sh
npm install -g @opencode/cli
```

Windows: package managers are not supported, download the
[standalone binary](https://opencode.ai/update/api/latest/cli/opencode/opencode-windows-x64.zip),
unpack it and add the folder to `PATH`.

Then start `opencode` and connect a model with `/connect`.

## What is inside

```text
opencode/
├── coffee-AGENTS.md              # rules, installed as a block into AGENTS.md
├── agents/
│   ├── coffee-architect.md       # Coffee Architect
│   ├── coffee-developer.md       # Coffee Developer
│   └── coffee-qa.md              # Coffee QA
└── skills/
    ├── coffee-adr/
    ├── coffee-contract-first/
    ├── coffee-failure-modes/
    ├── coffee-gin-swagger/
    ├── coffee-go-calls/
    ├── coffee-go-layout/
    ├── coffee-golang-dev/
    ├── coffee-grill-me/
    ├── coffee-python-dev/
    └── coffee-qa-blackbox/
```

| Component | Purpose |
| --- | --- |
| `coffee-architect` | planning, interview, contracts, failure matrix, spec |
| `coffee-developer` | implementation from a spec, Go and Python |
| `coffee-qa` | independent black-box review |
| `coffee-golang-dev` | Go style, errors, linter |
| `coffee-go-layout` | service layers, repository, Makefile |
| `coffee-gin-swagger` | gin handlers, swag annotations |
| `coffee-go-calls` | outbound calls, retries, idempotency |
| `coffee-contract-first` | SQL / OpenAPI / Proto contracts |
| `coffee-failure-modes` | FMEA and failure matrix |
| `coffee-adr` | Architecture Decision Records |
| `coffee-grill-me` | pre-design interrogation |
| `coffee-python-dev` | Python standards |
| `coffee-qa-blackbox` | review protocol without reading implementation |

## Install coffee-agents

macOS, Linux, WSL, Git Bash:

```sh
git clone https://github.com/coffeebreak-ai/coffee-agents.git
cd coffee-agents
./install.sh
```

Windows PowerShell:

```powershell
git clone https://github.com/coffeebreak-ai/coffee-agents.git
cd coffee-agents
./install.ps1
```

Default target is `~/.config/opencode` (`%USERPROFILE%\.config\opencode` on Windows).
Override with `OPENCODE_CONFIG_DIR=/path` or `$env:OPENCODE_CONFIG_DIR`.

## Flags

| `install.sh` | `install.ps1` | Action |
| --- | --- | --- |
| `--dry-run` | `-DryRun` | print the plan, write nothing |
| `--force` | `-Force` | no confirmation |
| `--uninstall` | `-Uninstall` | remove `coffee-*`, restore the last backup |

## How it coexists with existing settings

- Only files with the `coffee-` prefix are copied: `agents/coffee-*.md` and `skills/coffee-*`.
- Agents and skills are addressed by ID, and the ID comes from the file or directory name.
  `golang-dev` and `coffee-golang-dev` are different IDs and do not overwrite each other.
- Files without the prefix are never read or modified by the installer.
- The only exception is `AGENTS.md`: OpenCode has exactly one. Our rules live between markers:

  ```markdown
  <!-- coffee:begin -->
  # Coffee: global rules
  ...
  <!-- coffee:end -->
  ```

  Reinstalling replaces only that block. If the file is missing, it is created. If it already
  holds foreign rules, our block is appended at the end.
- Before writing, touched files are copied to `~/.config/opencode/.coffee-backup/<date>/`.

## Install-time checks

The script fails when:

- a skill has no `SKILL.md`;
- an agent references a skill that is absent from the repository;
- an unprefixed skill ID is still referenced inside the repository.

## Not installed

- `service.json` — a secret, OpenCode creates its own.
- `opencode.json`, `cli.json` — theme and client settings are not included.
- `~/.local/share/opencode` — database, logs, snapshots.
- Project `.opencode/` folders and repository `AGENTS.md`.

## Recommended MCP servers (optional)

The installer does not configure MCP: `opencode.json(c)` is shared, and the servers below
either need secrets or belong to a project. Add them manually.

| Server | Level | Access |
| --- | --- | --- |
| context7 | global | no authorization |
| sentry | project | OAuth via `/mcps` |
| github | project | PAT in `{env:GITHUB_TOKEN}` |
| postgres | project | `{env:DATABASE_URL}` |

Why not global: postgres, github and sentry depend on the repository and its secrets.
The global config must work on any machine without extra variables.

### context7 — library documentation

Global:

```sh
opencode mcp add context7 --global --url https://mcp.context7.com/mcp
```

Personal key (for a higher limit) — keep it out of the config:

```sh
opencode mcp add context7 --global --url https://mcp.context7.com/mcp \
  --header 'CONTEXT7_API_KEY={env:CONTEXT7_API_KEY}'
```

### sentry — project errors

From the project root, without `--global`:

```sh
opencode mcp add sentry --url https://mcp.sentry.dev/mcp
```

Then `/mcps` → `sentry` → sign in in the browser. Tokens are stored outside the config.

### github — issues and PRs

```sh
opencode mcp add github --url https://api.githubcopilot.com/mcp/ \
  --header 'Authorization=Bearer {env:GITHUB_TOKEN}'
```

Keep `GITHUB_TOKEN` in `~/.zshrc`, `.envrc` or `{file:~/.secrets/github}`.
Check the current endpoint in the GitHub MCP documentation.

### postgres — database schema

```sh
opencode mcp add postgres --env DATABASE_URL='{env:DATABASE_URL}' \
  -- npx -y <postgres-mcp-server>
```

The reference `@modelcontextprotocol/server-postgres` is archived and unmaintained —
pick a maintained server. Never put the connection string in the config, only `{env:...}`.

### Check and remove

```sh
opencode mcp list        # connected / needs authentication
```

`/mcps` — connect, disconnect, sign in. `opencode mcp logout <name>` — switch accounts.
There is no remove command: delete the entry from `mcp.servers` in `opencode.json(c)`.

## Update

```sh
git pull
./install.sh
```

## Switch to another language

The rules, prompts and skill texts are written in Russian, so the model answers in Russian and
follows Russian wording. If your team works in another language, that costs extra context and
drifts from the terms you use in tickets and code review.

Two options:

1. **Only responses.** Change one line in `opencode/coffee-AGENTS.md`:

   ```markdown
   - **Language:** always answer in English.
   ```

   Reinstall. Rules stay as they are, output language changes.

2. **Full translation.** Install first, then ask an agent:

   ```text
   Translate opencode/ into English. Keep file names, IDs, frontmatter keys, code blocks,
   commands, paths and the coffee:begin/coffee:end markers unchanged. Translate prose only.
   List changed files.
   ```

   Then run `./install.sh` again.

After a full translation:

- keep every `coffee-` ID as is, otherwise agents will point at missing skills;
- keep the `<!-- coffee:begin -->` and `<!-- coffee:end -->` markers, otherwise the installer
  appends a second block;
- keep code, commands, paths and technical identifiers untouched;
- check the result with `./install.sh --dry-run`: it validates skills and references.
