# coffee-agents

[English](README.md) | [Русский](README.ru.md) | **中文**

OpenCode 的全局配置：3 个 agent、10 个 skill，以及带 `coffee-` 前缀的规则块。
通过复制到用户配置目录安装；不包含项目级 `.opencode/`。

## 安装 coffee-agents

macOS、Linux、WSL、Git Bash：

```sh
git clone https://github.com/coffeebreak-ai/coffee-agents.git
cd coffee-agents
./install.sh
```

Windows PowerShell：

```powershell
git clone https://github.com/coffeebreak-ai/coffee-agents.git
cd coffee-agents
./install.ps1
```

需要先安装 OpenCode — 见[环境要求](#环境要求)。

默认安装到 `~/.config/opencode`（Windows 为 `%USERPROFILE%\.config\opencode`）。
可用 `OPENCODE_CONFIG_DIR=/path` 或 `$env:OPENCODE_CONFIG_DIR` 覆盖。

| `install.sh` | `install.ps1` | 作用 |
| --- | --- | --- |
| `--dry-run` | `-DryRun` | 只打印计划，不写文件 |
| `--force` | `-Force` | 不再确认 |
| `--uninstall` | `-Uninstall` | 删除 `coffee-*` 并恢复最近的备份 |

## 为什么要安装

全新的 OpenCode 每次会话都从零开始：它不知道你的技术栈、技术方案格式，以及合并前要检查什么。
本仓库把这些规则固定一次，在所有项目中复用。

```text
opencode/
├── coffee-AGENTS.md              # 规则，以块的形式写入 AGENTS.md
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

| 组件 | 用途 |
| --- | --- |
| `coffee-architect` | 规划、访谈、契约、故障矩阵、含 Mermaid 图的方案 |
| `coffee-developer` | 按方案实现，Go 与 Python |
| `coffee-qa` | 独立黑盒验收 |
| `coffee-golang-dev` | Go 风格、错误处理、linter |
| `coffee-go-layout` | 服务分层、repository、Makefile |
| `coffee-gin-swagger` | gin handler、swag 注解 |
| `coffee-go-calls` | 外部调用、重试、幂等 |
| `coffee-contract-first` | SQL / OpenAPI / Proto 契约 |
| `coffee-failure-modes` | FMEA 与故障矩阵 |
| `coffee-adr` | Architecture Decision Records |
| `coffee-grill-me` | 设计前质询 |
| `coffee-python-dev` | Python 规范 |
| `coffee-qa-blackbox` | 不读实现的验收流程 |

## 环境要求

原因：agent、skill 和规则都是普通文件，由 OpenCode 从配置目录读取。安装脚本只负责复制，
所以机器上必须先有 OpenCode。

```sh
curl -fsSL https://opencode.ai/v2/install | bash
# 或
brew install anomalyco/tap/opencode-v2
# 或
npm install -g @opencode/cli
```

Windows：不支持包管理器，请下载
[独立二进制文件](https://opencode.ai/update/api/latest/cli/opencode/opencode-windows-x64.zip)，
解压后把目录加入 `PATH`。

启动 `opencode`，用 `/connect` 连接模型。

## 为什么不破坏现有配置

原因：大多数机器上已经有自己的 agent、skill 和 `AGENTS.md`。覆盖它们会在所有项目中
悄悄改变行为。

做法：

- 只复制带 `coffee-` 前缀的文件：`agents/coffee-*.md` 和 `skills/coffee-*`；
- ID 来自文件名或目录名，因此 `golang-dev` 与 `coffee-golang-dev` 可以共存；
- 没有前缀的文件不会被读取或修改；
- `AGENTS.md` 是唯一的共用文件。我们的规则放在标记之间：

  ```markdown
  <!-- coffee:begin -->
  # Coffee: 全局规则
  ...
  <!-- coffee:end -->
  ```

  重复安装只替换该块。文件不存在时创建；已有其他规则时保留，并把我们的块追加到末尾。
- 写入前，受影响的文件会备份到 `~/.config/opencode/.coffee-backup/<日期>/`。

## 为什么安装前要检查

原因：缺少 `SKILL.md` 或引用了改名后的 skill，问题会在调用 agent 时暴露，而不是安装时。
提前失败比事后排查更便宜。

出现以下情况脚本会停止：

- skill 缺少 `SKILL.md`；
- agent 引用了仓库中不存在的 skill；
- 仓库内仍存在不带前缀的旧 skill 名称引用。

## 可选：context7 MCP

原因：获取 Go 与 Python 库的最新文档，而不是依赖训练数据中的猜测。

```sh
opencode mcp add context7 --global --url https://mcp.context7.com/mcp
```

需要更高额度时，通过环境变量传入密钥：

```sh
opencode mcp add context7 --global --url https://mcp.context7.com/mcp \
  --header 'CONTEXT7_API_KEY={env:CONTEXT7_API_KEY}'
```

安装脚本不修改 MCP。删除服务器时，从 `mcp.servers` 中移除对应条目。

## 为什么要翻译规则

原因：规则、prompt 和 skill 文本都是俄语，模型会跟随指令语言。团队使用其他语言时，
这会浪费上下文，并与工单和代码评审中的术语不一致。

做法：

1. **只改回答语言。** 修改 `opencode/coffee-AGENTS.md` 中的一行：

   ```markdown
   - **语言：** 始终只用中文回答。
   ```

   重新安装。规则不变，回答语言改变。

2. **完整翻译。** 让 agent 执行：

   ```text
   把 opencode/ 翻译成中文。保持文件名、ID、frontmatter 键、代码块、命令、路径
   以及 coffee:begin/coffee:end 标记不变。只翻译正文，列出修改过的文件。
   ```

   然后再运行 `./install.sh`。

完整翻译后：

- 所有 `coffee-` ID 保持不变，否则 agent 会指向不存在的 skill；
- 不要改动 `<!-- coffee:begin -->` 和 `<!-- coffee:end -->` 标记，否则安装脚本会追加第二个块；
- 代码、命令、路径和技术标识符保持原样；
- 用 `./install.sh --dry-run` 检查结果。

## 更新

原因：重复安装是幂等的，同一条命令即可更新 agent、skill 和规则块。

```sh
git pull
./install.sh
```

## 不会安装什么

原因：密钥和机器数据必须留在本地，项目配置属于各自的仓库。

- `service.json` — 密钥，由 OpenCode 在本机生成。
- `opencode.json`、`cli.json` — MCP 和客户端设置由你自己管理。
- `~/.local/share/opencode` — 数据库、日志、快照。
- 项目级 `.opencode/` 和仓库的 `AGENTS.md`。
