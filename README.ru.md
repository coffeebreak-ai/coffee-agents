# coffee-agents

[English](README.md) | **Русский** | [中文](README.zh.md)

Глобальные настройки OpenCode: три агента, семнадцать навыков и блок правил с префиксом `coffee-`.
Ставятся копированием в конфиг пользователя; проектные `.opencode/` не входят.

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

Сначала должен быть установлен OpenCode — см. [Требования](#требования).

По умолчанию ставится в `~/.config/opencode` (`%USERPROFILE%\.config\opencode` на Windows).
Переопределить: `OPENCODE_CONFIG_DIR=/path` или `$env:OPENCODE_CONFIG_DIR`.

| `install.sh` | `install.ps1` | Действие |
| --- | --- | --- |
| `--dry-run` | `-DryRun` | показать план, ничего не писать |
| `--force` | `-Force` | без подтверждения |
| `--uninstall` | `-Uninstall` | удалить `coffee-*` и вернуть последний бэкап |

## Установка стороннего скилла

Устанавливай любой скилл из GitHub глобально так же, как в `skills` CLI:

```sh
npx skills add wheresryan22/anatomy -g
```

Из репозитория — выбери скилл:

```sh
npx skills add owner/repo --skill <name> -g
```

Установщик поддерживает тот же формат источника:

```sh
./install.sh --skill wheresryan22/anatomy
```

## Зачем это ставить

Чистый OpenCode каждую сессию начинает с нуля: он не знает стек, формат ТЗ и что проверять
перед мержем. Репозиторий один раз фиксирует эти правила и переиспользует их во всех проектах.

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
    ├── coffee-csharp-dev/
    ├── coffee-failure-modes/
    ├── coffee-gin-swagger/
    ├── coffee-go-calls/
    ├── coffee-go-layout/
    ├── coffee-golang-dev/
    ├── coffee-grill-me/
    ├── coffee-javascript-dev/
    ├── coffee-lua-dev/
    ├── coffee-python-api/
    ├── coffee-python-db/
    ├── coffee-python-dev/
    ├── coffee-python-layout/
    ├── coffee-qa-blackbox/
    └── coffee-typescript-dev/
```

| Компонент | Назначение |
| --- | --- |
| `coffee-architect` | планирование, интервью, контракты, матрица отказов, ТЗ с Mermaid-схемами |
| `coffee-developer` | реализация по ТЗ, Go, Python, JavaScript, TypeScript, C# и Lua (emilua) |
| `coffee-qa` | независимая проверка по ТЗ, чёрный ящик |
| `coffee-golang-dev` | стиль Go, интерфейсы, дженерики, конкурентность, линтер |
| `coffee-go-layout` | слои сервиса, репозиторий, Makefile |
| `coffee-gin-swagger` | HTTP на gin, swag-аннотации |
| `coffee-go-calls` | внешние вызовы, повторы, идемпотентность |
| `coffee-contract-first` | контракты SQL/OpenAPI/Proto |
| `coffee-failure-modes` | FMEA и матрица отказов |
| `coffee-adr` | Architecture Decision Records |
| `coffee-grill-me` | допрос перед проектированием |
| `coffee-python-dev` | стиль Python, типизация, стандартная библиотека, pytest, ошибки, внешние вызовы |
| `coffee-python-layout` | слои Flask-сервиса, фабрика, Makefile |
| `coffee-python-api` | эндпоинты, схемы, OpenAPI, ошибки HTTP |
| `coffee-python-db` | SQLAlchemy, сессия, репозиторий, Alembic |
| `coffee-javascript-dev` | стиль JS, ESM, async, ошибки, линтер |
| `coffee-typescript-dev` | строгие типы, `unknown` вместо `any`, discriminated unions, tsc |
| `coffee-csharp-dev` | .NET, nullable, async и CancellationToken, decimal, EF Core |
| `coffee-lua-dev` | файберы emilua, каналы, отмена, неблокирующий ввод-вывод |
| `coffee-qa-blackbox` | протокол проверки без чтения реализации |

## Требования

Зачем: агенты, навыки и правила — обычные файлы, которые OpenCode читает из своего конфига.
Установщик их только копирует, поэтому сам OpenCode должен быть на машине.

```sh
curl -fsSL https://opencode.ai/v2/install | bash
# или
brew install anomalyco/tap/opencode-v2
# или
npm install -g @opencode/cli
```

Windows: пакетные менеджеры не поддерживаются — скачайте бинарник по
[инструкции по установке](https://opencode.ai/v2/docs/#cli), распакуйте и добавьте каталог в `PATH`.

Нужен OpenCode 2.x, проверено на 2.2.7. Все интерфейсы читают один конфиг,
поэтому `coffee-agents` работают в любом из них.

| Интерфейс | Версия | Установка |
| --- | --- | --- |
| CLI, `opencode` | 2.2.7 | команды выше |
| Desktop, macOS / Windows / Linux | 2.2.7 | [страница установки](https://opencode.ai/v2/docs/#desktop) |
| Web | входит в CLI, `opencode pair` | — |
| Mobile, iPhone / Android | клиент к серверу 2.x | iOS — TestFlight, Android — Google Play |

Mobile — пульт к OpenCode на компьютере: сессии идут на машине, телефон их направляет
(`opencode pair --remote`).

Затем запустите `opencode` и подключите модель командой `/connect`.

## Почему старые настройки не ломаются

Зачем: на большинстве машин уже есть свои агенты, навыки и `AGENTS.md`. Установка, которая их
перезапишет, молча изменит поведение во всех проектах.

Как:

- копируются только файлы с префиксом `coffee-`: `agents/coffee-*.md` и `skills/coffee-*`;
- ID берётся из имени файла и каталога, поэтому `golang-dev` и `coffee-golang-dev` сосуществуют;
- файлы без префикса не читаются и не изменяются;
- `AGENTS.md` — единственный общий файл. Наши правила живут внутри маркеров:

  ```markdown
  <!-- coffee:begin -->
  # Coffee: глобальные правила (системный промпт)
  ...
  <!-- coffee:end -->
  ```

  Повторная установка меняет только этот блок. Если файла нет — он создаётся; чужие правила
  сохраняются, наш блок дописывается в конец.
- перед записью затронутые файлы копируются в `~/.config/opencode/.coffee-backup/<дата>/`.

## Зачем проверки перед установкой

Зачем: отсутствующий `SKILL.md` или ссылка на переименованный навык проявятся при вызове агента,
а не при установке. Упасть сразу дешевле, чем разбираться, почему агент не загрузил навык.

Скрипт останавливается, если:

- у навыка нет `SKILL.md`;
- агент ссылается на навык, которого нет в репозитории;
- внутри репозитория осталась ссылка на старое имя навыка без префикса.

## Дополнительно: MCP context7

Зачем: актуальная документация Go- и Python-библиотек вместо догадок из обучающих данных.

```sh
opencode mcp add context7 --global --url https://mcp.context7.com/mcp
```

Если нужен больший лимит, ключ передаётся через переменную окружения:

```sh
opencode mcp add context7 --global --url https://mcp.context7.com/mcp \
  --header 'CONTEXT7_API_KEY={env:CONTEXT7_API_KEY}'
```

Установщик MCP не трогает. Удалить сервер — убрать запись из `mcp.servers`.

## Зачем переводить правила

Зачем: правила, промпты и тексты навыков написаны по-русски, а модель повторяет язык инструкций.
Для команды на другом языке это лишний расход контекста и расхождение с терминами из тикетов
и код-ревью.

Как:

1. **Только ответы.** Поменяйте одну строку в `opencode/coffee-AGENTS.md`:

   ```markdown
   - **Язык:** всегда отвечай только на английском языке.
   ```

   Переустановите. Правила остаются, язык ответов меняется.

2. **Полный перевод.** Попросите агента:

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
- проверить результат через `./install.sh --dry-run`.

## Обновление

Зачем: повторная установка идемпотентна, поэтому одна команда обновляет агентов, навыки и блок правил.

```sh
git pull
./install.sh
```

## Что не ставится

Зачем: секреты и данные машины должны оставаться локально, а проектные конфиги — в своих репозиториях.

- `service.json` — секрет, создаётся OpenCode на машине.
- `opencode.json`, `cli.json` — MCP и клиентские настройки остаются за вами.
- `~/.local/share/opencode` — база, логи, снапшоты.
- Проектные `.opencode/` и `AGENTS.md` репозиториев.
