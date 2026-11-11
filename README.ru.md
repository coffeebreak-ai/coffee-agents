# coffee-agents

[English](README.md) | **Русский** | [中文](README.zh.md)

Глобальные настройки OpenCode: агенты, навыки и правила с префиксом `coffee-`.
Копируются в конфиг пользователя одним скриптом. Проектные `.opencode/` не входят.

## Сначала установите OpenCode

macOS / Linux:

```sh
curl -fsSL https://opencode.ai/v2/install | bash
# или
brew install anomalyco/tap/opencode-v2
```

npm / bun / pnpm:

```sh
npm install -g @opencode/cli
```

Windows: пакетные менеджеры не поддерживаются, скачайте
[готовый бинарник](https://opencode.ai/update/api/latest/cli/opencode/opencode-windows-x64.zip),
распакуйте и добавьте каталог в `PATH`.

Затем запустите `opencode` и подключите модель командой `/connect`.

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

## Установка coffee-agents

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
- Агенты и навыки адресуются по ID, ID берётся из имени файла и каталога. `golang-dev` и
  `coffee-golang-dev` — разные ID, они не перезаписывают друг друга.
- Файлы без префикса не читаются installer'ом и не изменяются.
- Единственное исключение — `AGENTS.md`: у OpenCode он один. Наши правила живут внутри маркеров:

  ```markdown
  <!-- coffee:begin -->
  # Coffee: глобальные правила (системный промпт)
  ...
  <!-- coffee:end -->
  ```

  Повторная установка меняет только этот блок. Если файла нет — создаётся. Если в файле уже были
  чужие правила — наш блок дописывается в конец.
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

## Переход на другой язык

Правила, промпты и тексты навыков написаны по-русски. Модель отвечает на языке инструкций,
поэтому на другом языке команды она тратит лишний контекст и расходится с терминами из тикетов
и ревью.

Два варианта:

1. **Только ответы.** Поменяйте одну строку в `opencode/coffee-AGENTS.md`:

   ```markdown
   - **Язык:** всегда отвечай только на английском языке.
   ```

   Переустановите. Правила остаются, язык ответов меняется.

2. **Полный перевод.** Сначала установите, затем попросите агента:

   ```text
   Переведи opencode/ на английский. Сохрани имена файлов, ID, ключи frontmatter, блоки кода,
   команды, пути и маркеры coffee:begin/coffee:end без изменений. Переводи только текст.
   Покажи список изменённых файлов.
   ```

   Затем снова `./install.sh`.

После полного перевода:

- все ID `coffee-` оставить как есть, иначе агенты будут ссылаться на отсутствующие навыки;
- маркеры `<!-- coffee:begin -->` и `<!-- coffee:end -->` не трогать, иначе установщик добавит
  второй блок;
- код, команды, пути и технические идентификаторы не переводить;
- проверить результат через `./install.sh --dry-run`: он валидирует навыки и ссылки.
