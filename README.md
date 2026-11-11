# coffee-agents

Глобальные настройки OpenCode: агенты, навыки и правила с префиксом `coffee-`.
Копируются в конфиг пользователя одним скриптом. Проектные `.opencode/` не входят.

## Что внутри

```text
opencode/
├── coffee-AGENTS.md              # правила, ставятся блоком в AGENTS.md
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

| Компонент | Назначение |
| --- | --- |
| `coffee-architect` | планирование, интервью, контракты, матрица отказов, ТЗ |
| `coffee-developer` | реализация по ТЗ, Go и Python |
| `coffee-qa` | независимая проверка по ТЗ, чёрный ящик |
| `coffee-golang-dev` | стиль Go, ошибки, линтер |
| `coffee-go-layout` | слои сервиса, репозиторий, Makefile |
| `coffee-gin-swagger` | HTTP на gin, swag-аннотации |
| `coffee-go-calls` | внешние вызовы, повторы, идемпотентность |
| `coffee-contract-first` | контракты SQL/OpenAPI/Proto |
| `coffee-failure-modes` | FMEA и матрица отказов |
| `coffee-adr` | Architecture Decision Records |
| `coffee-grill-me` | допрос перед проектированием |
| `coffee-python-dev` | стандарты Python |
| `coffee-qa-blackbox` | протокол проверки без чтения реализации |

## Установка

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

По умолчанию ставится в `~/.config/opencode` (`%USERPROFILE%\.config\opencode` на Windows).
Переопределить: `OPENCODE_CONFIG_DIR=/path` или `$env:OPENCODE_CONFIG_DIR`.

## Флаги

| `install.sh` | `install.ps1` | Действие |
| --- | --- | --- |
| `--dry-run` | `-DryRun` | показать план, ничего не писать |
| `--force` | `-Force` | без подтверждения |
| `--uninstall` | `-Uninstall` | удалить `coffee-*` и вернуть последний бэкап |

## Как это сосуществует со старыми настройками

- Копируются только файлы с префиксом `coffee-`: `agents/coffee-*.md` и `skills/coffee-*`.
- Агенты и навыки адресуются по ID, ID берётся из имени файла и каталога. `golang-dev` и `coffee-golang-dev` — разные ID, они не перезаписывают друг друга.
- Файлы без префикса не читаются installer'ом и не изменяются.
- Единственное исключение — `AGENTS.md`: у OpenCode он один. Наши правила живут внутри маркеров:

  ```markdown
  <!-- coffee:begin -->
  # Coffee: глобальные правила (системный промпт)
  ...
  <!-- coffee:end -->
  ```

  Повторная установка меняет только этот блок. Если файла нет — создаётся. Если в файле уже были чужие правила — наш блок дописывается в конец.
- Перед любой записью затронутые файлы копируются в `~/.config/opencode/.coffee-backup/<дата>/`.

## Проверки при установке

Скрипт падает, если:

- у навыка нет `SKILL.md`;
- агент ссылается на навык, которого нет в репозитории;
- внутри репозитория осталась ссылка на старое имя навыка без префикса.

## Что не ставится

- `service.json` — секрет, создаётся OpenCode на машине.
- `opencode.json`, `cli.json` — тема и клиентские настройки не входят.
- `~/.local/share/opencode` — база, логи, снапшоты.
- Проектные `.opencode/` и `AGENTS.md` репозиториев.

## Обновление

```sh
git pull
./install.sh
```

## Добавить навык

1. Каталог `opencode/skills/coffee-<id>/SKILL.md`.
2. `name: Coffee <Имя>` в frontmatter.
3. Переустановить: `./install.sh`.

Ссылки внутри файлов — только на `coffee-<id>`.
