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

## Update

```sh
git pull
./install.sh
```

## Add a skill

1. Directory `opencode/skills/coffee-<id>/SKILL.md`.
2. `name: Coffee <Name>` in the frontmatter.
3. Reinstall: `./install.sh`.

References inside files must point only to `coffee-<id>`.

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
