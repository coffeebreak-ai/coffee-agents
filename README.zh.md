# coffee-agents

[English](README.md) | [Русский](README.ru.md) | **中文**

OpenCode 的全局配置：带 `coffee-` 前缀的 agent、skill 和规则。
用一个脚本复制到用户配置目录。不包含项目级 `.opencode/`。

## 先安装 OpenCode

macOS / Linux：

```sh
curl -fsSL https://opencode.ai/v2/install | bash
# 或
brew install anomalyco/tap/opencode-v2
```

npm / bun / pnpm：

```sh
npm install -g @opencode/cli
```

Windows：不支持包管理器，请下载
[独立二进制文件](https://opencode.ai/update/api/latest/cli/opencode/opencode-windows-x64.zip)，
解压后把目录加入 `PATH`。

启动 `opencode`，用 `/connect` 连接模型。

## 内容

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
| `coffee-architect` | 规划、访谈、契约、故障矩阵、技术方案 |
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

默认目标是 `~/.config/opencode`（Windows 为 `%USERPROFILE%\.config\opencode`）。
可用 `OPENCODE_CONFIG_DIR=/path` 或 `$env:OPENCODE_CONFIG_DIR` 覆盖。

## 参数

| `install.sh` | `install.ps1` | 作用 |
| --- | --- | --- |
| `--dry-run` | `-DryRun` | 只打印计划，不写文件 |
| `--force` | `-Force` | 不再确认 |
| `--uninstall` | `-Uninstall` | 删除 `coffee-*` 并恢复最近的备份 |

## 与已有配置共存

- 只复制带 `coffee-` 前缀的文件：`agents/coffee-*.md` 和 `skills/coffee-*`。
- agent 和 skill 按 ID 定位，ID 来自文件名或目录名。`golang-dev` 和 `coffee-golang-dev`
  是两个不同的 ID，不会互相覆盖。
- 安装脚本不读取、不修改没有前缀的文件。
- 唯一例外是 `AGENTS.md`：OpenCode 只认这一个。我们的规则放在标记之间：

  ```markdown
  <!-- coffee:begin -->
  # Coffee: 全局规则
  ...
  <!-- coffee:end -->
  ```

  重复安装只替换该块。文件不存在时会创建；已存在其他规则时，我们的块追加到末尾。
- 写入前，受影响的文件会备份到 `~/.config/opencode/.coffee-backup/<日期>/`。

## 安装时检查

出现以下情况脚本会失败：

- skill 缺少 `SKILL.md`；
- agent 引用了仓库中不存在的 skill；
- 仓库内仍存在不带前缀的旧 skill 名称引用。

## 不会安装

- `service.json` — 密钥，由 OpenCode 在本机生成。
- `opencode.json`、`cli.json` — 主题和客户端设置不包含在内。
- `~/.local/share/opencode` — 数据库、日志、快照。
- 项目级 `.opencode/` 和仓库的 `AGENTS.md`。

## 推荐的 MCP 服务器（可选）

安装脚本不配置 MCP：`opencode.json(c)` 是共用文件，而下面的服务器要么需要密钥，
要么属于具体项目。需要手动添加。

| 服务器 | 层级 | 访问方式 |
| --- | --- | --- |
| context7 | 全局 | 无需授权 |
| sentry | 项目 | 通过 `/mcps` 的 OAuth |
| github | 项目 | `{env:GITHUB_TOKEN}` 中的 PAT |
| postgres | 项目 | `{env:DATABASE_URL}` |

为什么不放全局：postgres、github 和 sentry 依赖仓库及其密钥。全局配置必须在任何机器上
无需额外变量即可工作。

### context7 — 库文档

全局：

```sh
opencode mcp add context7 --global --url https://mcp.context7.com/mcp
```

个人密钥（更高额度）不要写进配置：

```sh
opencode mcp add context7 --global --url https://mcp.context7.com/mcp \
  --header 'CONTEXT7_API_KEY={env:CONTEXT7_API_KEY}'
```

### sentry — 项目错误

在项目根目录执行，不带 `--global`：

```sh
opencode mcp add sentry --url https://mcp.sentry.dev/mcp
```

然后在 `/mcps` → `sentry` 中通过浏览器登录。令牌存放在配置之外。

### github — issues 与 PR

```sh
opencode mcp add github --url https://api.githubcopilot.com/mcp/ \
  --header 'Authorization=Bearer {env:GITHUB_TOKEN}'
```

`GITHUB_TOKEN` 放在 `~/.zshrc`、`.envrc` 或 `{file:~/.secrets/github}` 中。
实际 endpoint 以 GitHub MCP 文档为准。

### postgres — 数据库结构

```sh
opencode mcp add postgres --env DATABASE_URL='{env:DATABASE_URL}' \
  -- npx -y <postgres-mcp-server>
```

参考实现 `@modelcontextprotocol/server-postgres` 已归档且不再维护，请选择仍在维护的服务器。
连接串不要写入配置，只用 `{env:...}`。

### 检查与删除

```sh
opencode mcp list        # connected / needs authentication
```

`/mcps` — 连接、断开、登录。`opencode mcp logout <name>` — 切换账号。
没有删除命令：从 `opencode.json(c)` 的 `mcp.servers` 中手动删除条目。

## 更新

```sh
git pull
./install.sh
```

## 切换到其他语言

规则、prompt 和 skill 文本都是俄语，模型会按指令语言回答。若团队使用其他语言，这会浪费
上下文，并与工单、代码评审中的术语不一致。

两种做法：

1. **只改回答语言。** 修改 `opencode/coffee-AGENTS.md` 中的一行：

   ```markdown
   - **语言：** 始终只用中文回答。
   ```

   重新安装即可，规则本身不变。

2. **完整翻译。** 先安装，然后让 agent 执行：

   ```text
   把 opencode/ 翻译成中文。保持文件名、ID、frontmatter 键、代码块、命令、路径
   以及 coffee:begin/coffee:end 标记不变。只翻译正文，列出修改过的文件。
   ```

   之后再运行 `./install.sh`。

完整翻译后：

- 所有 `coffee-` ID 保持不变，否则 agent 会指向不存在的 skill；
- 不要改动 `<!-- coffee:begin -->` 和 `<!-- coffee:end -->` 标记，否则安装脚本会追加第二个块；
- 代码、命令、路径和技术标识符保持原样；
- 用 `./install.sh --dry-run` 检查结果，它会校验 skill 和引用。
