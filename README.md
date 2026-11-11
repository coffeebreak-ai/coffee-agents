# coffee-agents

**English** | [Русский](README.ru.md) | [中文](README.zh.md)

Global OpenCode settings: three agents, ten skills and a rules block with the `coffee-` prefix.
Installed by copying into the user config; project-level `.opencode/` is not included.

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

OpenCode must be installed first — see [Requirements](#requirements).

Default target is `~/.config/opencode` (`%USERPROFILE%\.config\opencode` on Windows).
Override with `OPENCODE_CONFIG_DIR=/path` or `$env:OPENCODE_CONFIG_DIR`.

| `install.sh` | `install.ps1` | Action |
| --- | --- | --- |
| `--dry-run` | `-DryRun` | print the plan, write nothing |
| `--force` | `-Force` | no confirmation |
| `--uninstall` | `-Uninstall` | remove `coffee-*`, restore the last backup |

## Why install it

A bare OpenCode starts every session from zero: it does not know your stack, how you write specs,
or what you check before merging. This repo packages that once and reuses it in every project.

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
| `coffee-architect` | planning, interview, contracts, failure matrix, spec with Mermaid diagrams |
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

## Requirements

Why: agents, skills and rules are plain files that OpenCode reads from its config directory.
The installer only copies them, so OpenCode itself has to be present.

```sh
curl -fsSL https://opencode.ai/v2/install | bash
# or
brew install anomalyco/tap/opencode-v2
# or
npm install -g @opencode/cli
```

Windows: package managers are not supported — see the
[installation guide](https://opencode.ai/v2/docs/#cli), download the binary for your platform,
unpack it and add the folder to `PATH`.

Then start `opencode` and connect a model with `/connect`.

## Why existing settings survive

Why: most machines already have their own agents, skills and `AGENTS.md`. An install that
overwrites them would silently change behavior in every project.

How:

- only files with the `coffee-` prefix are copied: `agents/coffee-*.md` and `skills/coffee-*`;
- IDs come from file and directory names, so `golang-dev` and `coffee-golang-dev` coexist;
- files without the prefix are never read or modified;
- `AGENTS.md` is the only shared file. Our rules live between markers:

  ```markdown
  <!-- coffee:begin -->
  # Coffee: global rules
  ...
  <!-- coffee:end -->
  ```

  Reinstalling replaces only that block. A missing file is created; foreign rules are kept and
  our block is appended.
- before writing, touched files are copied to `~/.config/opencode/.coffee-backup/<date>/`.

## Why the installer checks before writing

Why: a missing `SKILL.md` or a reference to a renamed skill fails when an agent is invoked,
not when it is installed. Failing early is cheaper than debugging an agent that cannot load a skill.

The script stops when:

- a skill has no `SKILL.md`;
- an agent references a skill that is absent from the repository;
- an unprefixed skill ID is still referenced inside the repository.

## Optional: context7 MCP

Why: fresh documentation for Go and Python libraries instead of guesses from training data.

```sh
opencode mcp add context7 --global --url https://mcp.context7.com/mcp
```

For a higher rate limit, pass the key through an environment variable:

```sh
opencode mcp add context7 --global --url https://mcp.context7.com/mcp \
  --header 'CONTEXT7_API_KEY={env:CONTEXT7_API_KEY}'
```

The installer does not touch MCP. To remove the server, delete its entry from `mcp.servers`.

## Why translate the rules

Why: the rules, prompts and skill texts are written in Russian, and the model mirrors the
language of its instructions. For a team working in another language that costs extra context
and drifts from the terms used in tickets and code review.

How:

1. **Only responses.** Change one line in `opencode/coffee-AGENTS.md`:

   ```markdown
   - **Language:** always answer in English.
   ```

   Reinstall. The rules stay, the output language changes.

2. **Full translation.** Ask an agent:

   ```text
   Translate opencode/ into English. Keep file names, IDs, frontmatter keys, code blocks,
   commands, paths and the coffee:begin/coffee:end markers unchanged. Translate prose only.
   List changed files.
   ```

   Then run `./install.sh` again.

After a full translation:

- keep every `coffee-` ID, otherwise agents point at missing skills;
- keep the `<!-- coffee:begin -->` and `<!-- coffee:end -->` markers, otherwise the installer
  appends a second block;
- do not translate code, commands, paths and technical identifiers;
- check the result with `./install.sh --dry-run`.

## Update

Why: reinstalling is idempotent, so the same command updates agents, skills and the rules block.

```sh
git pull
./install.sh
```

## What is not installed

Why: secrets and machine data must stay local, and project configs belong to their repositories.

- `service.json` — a secret, OpenCode creates its own.
- `opencode.json`, `cli.json` — MCP and client settings are yours.
- `~/.local/share/opencode` — database, logs, snapshots.
- Project `.opencode/` folders and repository `AGENTS.md`.
