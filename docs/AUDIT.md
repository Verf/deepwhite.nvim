# DeepWhite 审计与优化方案

- 审计日期：2026-11-06
- 基线提交：`ff997aafbb722c423f6f59d2e846f64311b6157c`
- 范围：全部 Lua 源码、5 份 extras、README、现有截图、仓库中的工程配置。
- 对标：TokyoNight Day、Catppuccin Latte、Kanagawa Lotus、Rosé Pine Dawn 的官方资料；不是下载量排名，也不是同环境性能横评。
- 原始审计交付：审计结果与实施方案；审计时没有修改主题实现或配色。

> **后续实施状态：阶段 1、2 的代码修复已落地；阶段 3 按实际工作流推进。** 已修复 MiniDiff、四类 LSP 链接、阴影背景、lualine 选项副作用、Windows Terminal 色槽及配置顺序，新增可读信息前景、覆盖回调和默认关闭的 Neovim 终端色。以下问题清单和运行数据保留为原始审计基线，不表示这些问题仍全部存在。
>
> **P2-03 当前范围：** mini.pick / mini.files 导航、mini.completion / LSP 浮窗、mini.diff 已有真实模块 UI 检查；本轮进一步验证了 CodeDiff、render-markdown、multicursor、which-key modern 和 mini.cmdline。修复共享 `Visual` 的选中注释对比度，以及 CodeDiff 可选 gutter 标记／行号的浅色前景。CodeDiff 默认派生背景仍会降低注释可读性，已提供并验证公开 `highlights` 配置方案；**该部分需要合并 README 中的配置，不是主题自动修复**。当前个人配置已主动应用该方案，并验证原有按键、延迟加载及主题重载保持正常。其他已检插件场景沿用合适的默认链接，无需新增覆盖。未使用的 Blink / Telescope / fzf-lua / Neo-tree / Noice / Trouble / Lazy / Mason 不列为本轮目标。
>
> **维护与验收：** 已有最低版本 0.7.0／最新 stable 的核心 CI；提交 `37cfd73` 的[两个远端作业均已确认成功](https://github.com/Verf/deepwhite.nvim/actions/runs/42795989440)。现新增 Luacheck 语法／全局变量检查、`doc/deepwhite.txt`、`CONTRIBUTING.md`，并将帮助标签／跳转测试加入同一版本矩阵。另已按现有 `.stylua.toml` 统一 Lua 格式，固定 StyLua 2.6.0 的 pre-commit 自动格式化与 AST 校验，并增加全仓格式 CI 门禁。真实提交测试确认：格式化会暂停提交，不自动暂存，原有未暂存修改得到保留。格式整理后重新验证：Luacheck 1.1.2 检查 15 个 Lua 文件无告警；0.12.6 核心 56 项、附加 UI 66 项，0.7.0 核心 52 项，以及两个版本各 13 项帮助检查全部通过。新增维护／格式作业的远端执行结果以对应提交的 CI 状态为准。命令、插件固定版本和边界见 [README](../README.md) 与贡献说明。
>
> **Extras 生成与扩展：** 已新增纯 Lua 生成器 `scripts/generate_extras.lua`，从默认 palette／ANSI 映射生成全部 11 份 extras，不加载用户配置或回调；`--check` 能只读检测缺失和漂移。原有五份文件的解析语义保持不变，新增 Ghostty、Alacritty、Rio、Warp、foot 1.26+、iTerm2，现覆盖 10 类终端配置及 vivid。格式按[官方规范与安装说明](TERMINALS.md)核对，尤其保留 vivid 的三处有意背景差异，采用 foot 新的 `[colors-light]`，不向 Warp 输出未支持的独立选区字段。JSON/TOML/YAML/INI/plist 独立解析共 11 项通过；核心检查更新为 0.12.6 的 58 项、0.7.0 的 54 项，帮助测试各 13 项，Luacheck 检查 16 个 Lua 文件无告警，格式检查通过。66 项插件 UI 的既有结果继续有效，本轮未重复运行未受影响的场景。生成检查和独立格式验证已加入 CI 配置，远端执行结果以对应提交的工作流状态为准。
>
> **剩余边界：** 初始 Luacheck 范围不包括未使用变量、table 字段名或字符串内的 Lua；样式由独立的 StyLua 门禁负责。没有逐一验证所有中间 Neovim 版本。新增终端预设已完成文件格式和颜色语义验证，但未在各应用二进制／GUI 中逐一验收。实验性 UI2、CodeDiff 完整 Git／冲突操作，以及用户实际终端字体与图标的人工截图验收仍未覆盖。

## 一、结论

DeepWhite 最值得保留的不是配置数量，而是**纸白背景、深色正文、淡色块语法、偏极简的界面**。无需为了对标主流主题而增加暗色变体、编译缓存或插件自动探测框架。

当前主要短板依次是：

1. 存在可复现的高亮定义错误和模块导入副作用。
2. 一部分文字、诊断和 Git 标记对浅色背景的对比度不足。
3. 用户只有一个正式配置项，缺少稳定的颜色/高亮覆盖入口。
4. 插件适配偏重 mini.nvim，现代补全与查找器的显式覆盖不均衡。
5. 没有提交到仓库的自动测试、CI 或编辑器内帮助；extras 已出现颜色语义不一致。

**建议先修正确性和可读性，再补少量扩展接口，最后扩展插件和工具生态。** 本轮未发现阻止基础主题加载的 P0 问题；不能据此声称所有插件及历史 Neovim 版本都兼容。

## 二、现状与已存在的优势

| 方面 | 观察 |
| --- | --- |
| 实现规模 | 7 个 Lua 文件；`scheme.lua` 672 行；运行时生成 527 个显式高亮组 |
| 加载链 | `colors/deepwhite.lua` → `deepwhite.load()` → palette → groups → `nvim_set_hl` |
| 默认体验 | 无需调用 `setup()` 就能加载；显式选择浅色背景和 truecolor |
| 配色机制 | `low_blue_light=false` 使用 `#FAF2EB`，开启后使用 `#FAFAFA` |
| Neovim 原生覆盖 | 已包含 Treesitter、LSP、诊断、inlay hint、virtual lines、浮窗、补全菜单等；不是只有传统 syntax 的旧主题 |
| 插件覆盖 | mini.nvim 覆盖较广；另有 cmp、barbar、notify、DAP UI、GitSigns、Markdown 等 |
| 可维护性 | palette 和 highlight 生成分离，链接组与普通组分开设置，逻辑短且无运行时第三方依赖 |
| 周边主题 | Kitty、WezTerm、Windows Terminal、Xresources、vivid |

主截图能展示独特的色块语法，但内容对应较旧实现，只能用于理解风格，不能当作当前版本所有高亮正确的证据。

## 三、运行验证及边界

### 3.1 环境和方法

PATH 中没有 `nvim`，但系统已有 `/opt/nvim-linux-x86_64/bin/nvim`，版本为 **0.12.6**。未下载安装软件。使用临时 Lua 探针执行：

```sh
/opt/nvim-linux-x86_64/bin/nvim --headless -u NONE -i NONE -n -l /tmp/<audit-dir>/probe.lua
```

探针将项目根目录加入 runtimepath，实际加载主题，通过 `nvim_get_hl(..., link=false, create=false)` 检查解析后的属性，测试背景切换及 lualine 导入前后的选项。探针仅用于本次审计，未作为正式测试提交；上述临时路径不是项目提供的可用脚本。

### 3.2 实际结果

**13 项检查：4 项通过，9 项失败，进程退出码为 1。** 这是缺陷复现结果，不是测试通过或修复完成。

| 检查 | 结果 |
| --- | --- |
| 默认 `colorscheme deepwhite` 加载 | 通过 |
| 默认 Normal 背景为 `#FAF2EB` | 通过 |
| `MiniDiffOverContextBuf` 有预期背景 | 失败：解析后为空属性表 |
| `MiniDiffOverDelete` 有预期背景 | 失败：解析后为空属性表 |
| LSP macro 链接解析到当前语法颜色 | 失败：没有前景色 |
| LSP namespace 链接解析到当前语法颜色 | 失败：没有前景色 |
| LSP parameter 链接解析到当前语法颜色 | 失败：没有前景色 |
| LSP struct 链接解析到当前语法颜色 | 失败：没有前景色 |
| `FloatShadow` 有背景属性 | 失败：只有 fg 与 blend |
| `FloatShadowThrough` 有背景属性 | 失败：只有 fg 与 blend |
| `setup({low_blue_light=true})` 后重新加载 | 通过：Normal 为 `#FAFAFA` |
| 设置 false，切换到 default 再切回 | 通过：恢复 `#FAF2EB` |
| 导入 lualine 主题不改变用户 fillchars | 失败：用户设置被改成 `stl:─,stlnc:─` |

另用 Python 标准库解析了 Windows Terminal JSON、WezTerm TOML，均成功；颜色字段的语义问题不等于格式解析失败。

**未验证：** Neovim 0.7/0.8/0.9/0.10/0.11、真实语言服务器和 Treesitter parser 的叠加显示、安装各插件后的 UI、终端/GUI 的实际阴影与下卷线渲染、字体与色觉模拟、启动性能横评。没有运行 StyLua 或 luacheck。下面的视觉影响预测与已检查的 API 属性分开描述。

## 四、按优先级排列的问题

优先级：P1 为首轮应修复的正确性或可读性问题；P2 为体验和维护改进。P1 不代表整个插件无法使用。

### P1-01：MiniDiff 两处颜色引用遗漏前缀

- 位置：`lua/deepwhite/scheme.lua:364-365`。
- 当前：`bg = light_orange`、`bg = light_red`，读取未定义的全局变量；通常为 nil，最终生成空表，而不是 Lua 语法错误。
- 证据：两组在干净 Neovim 中解析后均无背景。
- 修复：使用 `c.light_orange`、`c.light_red`，不需要新增抽象。
- 验收：两个组的 `bg` 分别等于 palette 中对应值；MiniDiff 删除/上下文 overlay 的实际显示随后进行人工验收。

### P1-02：四类 LSP token 指向旧 capture 名称

- 位置：`lua/deepwhite/scheme.lua:240-245`。
- 失效链接：`@macro`、`@namespace`、`@parameter`、`@structure`。
- 证据：干净环境中对应 LSP 组解析后均无颜色；项目没有为这些旧名称定义别名。
- 建议映射：macro → `@constant.macro` 或 `Macro`；namespace → `@module`；parameter → `@variable.parameter`；struct → `@type`。
- 验收：解析后的属性符合当前语法组；带/不带 semantic tokens 的同一段代码保持一致的视觉语义。

不要把“所有目标必须在本文件显式定义”作为测试规则：

- `@function.call` 本次可以通过分层 fallback 解析到 `@function`，不是已确认的断链。
- `DapUIWatchesEmpty`、`NeogitHunkHeaderHighlight` 在未安装插件的环境也为空，但可能由相应插件提供，应进行插件加载后的验证，不能直接当成主题内生错误。

### P1-03：lualine 主题模块有编辑器选项副作用

- 位置：`lua/lualine/themes/deepwhite.lua:4-23`。
- 当前：仅 `require('lualine.themes.deepwhite')` 就修改当前窗口及全局 `fillchars`。
- 证据：探针中自定义的 `stl` / `stlnc` 被替换为横线。
- 修复：主题模块只返回颜色表；横线装饰改为 README 中用户主动选择的配置片段。
- 验收：分别通过 `vim.opt_global`、`vim.opt_local` 比较导入前后的值，均保持不变。
- 非阻塞建议：现有各模式使用相同颜色并非错误；若增加区分，可复用 mini.statusline 的模式色，不再另建 palette。

### P1-04：浅色背景上混用了背景装饰色与信息前景色

- 位置：`scheme.lua:84,96,265-268,359,377,496,641-643` 及终端 ANSI 配色。
- 证据：按 W3C 的 sRGB 相对亮度公式直接计算；假设背景为主题 Normal，无透明、无终端额外滤镜。显示值保留两位小数，未来自动断言应使用未舍入结果。

| 场景 | 前景 | 默认背景 `#FAF2EB` | 冷白背景 `#FAFAFA` |
| --- | --- | --- | --- |
| 正文 | `#1A1918` | 15.86:1 | 16.82:1 |
| 注释 / InlayHint | `#999791` | 2.64:1 | 2.80:1 |
| 行号 | `#807E79` | 3.66:1 | 3.89:1 |
| 警告 / Tag | `#F27900` | 2.53:1 | 2.68:1 |
| DiagnosticHint | `#00A6A6` | 2.71:1 | 2.87:1 |
| DiagnosticOk / MiniDiff 新增 sign | `#00A600` | 2.94:1 | 3.12:1 |
| GitSignsAdd | `#64FA64` | 1.23:1 | 1.31:1 |
| GitSignsChange | `#FAAF64` | 1.67:1 | 1.77:1 |
| GitSignsDelete | `#FA6464` | 2.68:1 | 2.85:1 |
| 彩虹黄色括号 / 部分终端黄色 | `#F2F200` | 1.09:1 | 1.15:1 |

另外：`MiniDiffOverChange` 的橙色字与浅橙底只有 **2.22:1**；`MiniHipatternsHack` 的浅色字与橙底只有 **2.53:1**。

建议：

1. 保留 `light_*` 作为语法色块和 overlay 背景，不要为提高对比度而全局加深所有色块。
2. 为 comment、warning、hint、success、Git sign、黄色括号选更深的前景；仅把 GitSigns 改成现有 `c.green` / `c.orange` 仍不足以解决默认背景下的对比度问题。
3. 首轮目标：信息性普通文字（含注释、诊断）≥ 4.5:1；关键 UI 标记以 ≥ 3:1 作为工程目标；无信息的装饰性空白、分隔纹理不机械套用文字标准。
4. Git 同时使用 `+` / `~` / `-` 等形状，避免只用红绿表达状态。
5. 两种背景都要验收；透明背景由用户实际底色决定，不宣称同样达标。

这里借用 WCAG 作为可读性设计基准，**不是对 Neovim 主题作网页合规认证**；没有实测其他主题的颜色，不声称它们全部达标。最终颜色应通过真实代码审阅确定，不凭公式批量改变风格。

### P1-05：浮窗阴影只设置前景色

- 位置：`lua/deepwhite/scheme.lua:52-53`。
- 证据：两个 shadow 组均只有 `fg` 与 `blend`，没有 `bg`；Neovim 自带 `vim` 配色使用 `bg` 定义此阴影。
- 修复方向：改为适当的背景色并保留需要的 blend。
- 验收：API 属性检查通过，并打开 `border='shadow'` 的浮窗确认阴影、穿透区域和文字均正常。本轮没有进行真实 UI 阴影截图验证。

### P1-06：Windows Terminal 的 cyan / purple 互换

- 位置：`extra/deepwhite_windows_terminal.json:7,9,14,18`。
- 当前：cyan / brightCyan 为 `#6F00A6`，purple / brightPurple 为 `#00A6A6`，与 Lua palette、Kitty、Xresources 的颜色语义相反。
- 修复：交换这四个字段的值。
- 验收：以规范化的 ANSI 槽位验证颜色，而不仅检查 JSON 是否能解析。

### P1-07：文档未把 setup 与加载顺序串成完整配置

- 位置：`README.md:11-56`、`lua/deepwhite/config.lua:7`。
- 当前：安装示例先加载主题；另一节单独展示 `setup()`，但它只保存配置，不主动重新应用高亮。
- 风险：按章节组合配置时，选项可能没有作用于已加载的主题。
- 修复：提供单段 lazy.nvim 示例，明确“先 setup，后 colorscheme”；不必为了文档缺口增加自动重载行为。

以下**使用现有接口即可运行**，不依赖任何计划中的新功能：

```lua
{
    'Verf/deepwhite.nvim',
    lazy = false,
    priority = 1000,
    opts = { low_blue_light = false },
    config = function(_, opts)
        require('deepwhite').setup(opts)
        vim.cmd('colorscheme deepwhite')
    end,
}
```

说明 `low_blue_light` 是对外部暖色滤镜的冷白补偿，不是主题自身减少蓝光或提供医学护眼保证。保留原选项名称，避免没有必要的兼容迁移。

### P2：非阻塞改进

| 编号 | 现状 / 证据 | 建议 |
| --- | --- | --- |
| P2-01 | `config.lua` 仅一个正式选项，没有颜色/高亮覆盖 hook | 增加两个小型覆盖入口，详见第六节 |
| P2-02 | 源码没有 `terminal_color_*` 设置 | 复用统一 ANSI palette，提供可选 terminal colors；尊重用户自定义终端配色 |
| P2-03 | 没有 BlinkCmp、Telescope、FzfLua、NeoTree、Noice、Trouble、Lazy、Mason 的显式定义；Snacks 仅一个目录组 | 代表性场景优先适配；没有显式组不代表插件一定不可用，需先观察默认链接 |
| P2-04 | `Storage` 应为标准组名 `StorageClass`（`scheme.lua:122`） | 修正名字；本次核心默认链接已经让 StorageClass 指向 Type，故未算作高亮丢失 |
| P2-05 | `CmpItemAbbrDeprecated` 链接 Visual（`scheme.lua:522`） | 使用删除线或 DiagnosticDeprecated，区分“弃用”与“选中”语义 |
| P2-06 | WezTerm 的 ANSI 黑/黄/白与 Kitty 不同；vivid 的 base8/light_yellow/light_cyan 与 Lua 不同 | 先区分有意的终端适配与漂移，再建立统一来源；不要盲目逐字同步 |
| P2-07 | 无仓库内测试、CI、`doc/deepwhite.txt`、贡献说明 | 加小型 headless 测试、静态检查、最小帮助与版本策略；避免引入重测试框架 |
| P2-08 | `init.lua` 声明最低 0.7，README 未说明；实际仅测 0.12.6 | 明确支持范围，在最低版本和 stable 上验证；nightly 可以作为非阻塞检查 |

## 五、主流主题对照

以下为审计时官方 README / 源码可确认的能力，不代表在本机实际运行了这些主题。项目版本会变化，发布前需要复核官方要求。

| 维度 | DeepWhite 当前 | TokyoNight Day [1] | Catppuccin Latte [2] | Kanagawa Lotus [3] | Rosé Pine Dawn [4] |
| --- | --- | --- | --- | --- | --- |
| 浅色定位 | 专注浅色，淡色块语法 | Day，兼有暗色变体 | Latte，四种 flavour 之一 | Lotus，三种变体之一 | Dawn，三种变体之一 |
| 定制入口 | low_blue_light | on_colors / on_highlights | color_overrides / custom_highlights | palette / theme / overrides | palette / groups / highlight_groups |
| 透明 / 样式 | 无专门开关，可手改高亮 | 有透明、语法和浮窗样式 | 有透明、语法与 LSP 样式 | 有透明和语法样式 | 有透明、粗体和斜体控制 |
| Neovim 内终端色 | 未设置 | 有 | 有可选设置 | 有 | 有 |
| 插件生态 | mini 较强，其余不均衡 | 分模块，支持 blink / snacks 等 | 多 integration，可显式控制及自动识别 | 广泛插件支持 | 多类插件，源码含 blink / snacks 等 |
| 性能机制 | 直接生成并设置高亮 | 可缓存 | 编译配置 | 可选编译 | 本轮未评估缓存机制 |
| 文档结构 | README，缺支持边界和完整配置链 | 默认配置、覆盖、插件清单、贡献文档 | 配置、覆盖、integrations 说明 | palette/theme 分工、覆盖示例 | 配置、颜色角色、wiki recipes |
| 官方兼容要求 | 源码检查 ≥0.7，缺矩阵验证 | README ≥0.8 | README ≥0.8 | README 写 neovim latest | 本轮查阅的 README 未明确最低版本 |

### 应借鉴与不必照搬

- **TokyoNight**：覆盖 hook、插件适配边界；不必照搬缓存与插件管理器自动检测。
- **Catppuccin**：明确的用户定制和 integration 文档；不必追求同量级的配置与生态覆盖。
- **Kanagawa**：区分原始色值与用途，防止浅色背景色被拿去做文字；无需复制完整多主题系统。
- **Rosé Pine**：语义颜色角色、统一浮窗和面板、弃用文字等状态语义；无需添加暗色变体。

竞争方向应是“**可靠、可读、低维护成本的极简浅色主题**”，不是“配置项最多”。

## 六、建议的最小技术方案

### 6.1 保留现有加载链

保留 palette → groups → set_hl 的结构。为实际复用的角色增加一小张映射表，例如 `fg`、`bg`、`comment`、`warning`、`hint`、`git_add`、`git_change`、`git_delete`。原始 `base*` / `light_*` 仍可使用，不为单个颜色新增多层包装。

### 6.2 只增加必要的覆盖能力

建议先增加：

- `on_colors(colors)`：在生成 groups 前调整 palette / 角色色。
- `on_highlights(groups, colors)`：在应用 groups 前覆盖高亮。
- `terminal_colors`：控制是否设置 Neovim 的 ANSI palette，默认值应在发布说明明确。

执行顺序固定为：默认 palette → 背景选项 → on_colors → 默认 groups → on_highlights → 应用。覆盖组含 `link` 时遵循 Neovim 的 link 语义，不同时合并会被忽略的 fg/bg。

配置只检查现有选项与新入口的类型；回调出错保留清晰的异常上下文，不静默吞掉。明确 `setup()` 是更新配置还是重置配置，保持现有调用习惯并测试两次 setup 的效果。

首轮不必同时新增 `transparent`、`styles`、`dim_inactive` 等大量开关：透明或单组风格可以先通过覆盖入口满足。若后续提供正式透明选项，应覆盖 Normal/NormalNC/Float/Pmenu/SignColumn/StatusLine/TabLine，并单独验收；不能只清空 Normal 就宣称完整支持。

### 6.3 插件扩展按用户工作流排序

1. **补全**：blink.cmp 的 label、匹配、弃用、菜单/文档/签名帮助；保持 cmp 风格一致。
2. **查找器**：在 Snacks picker、Telescope、fzf-lua 中先做代表性界面验证，补确有风格偏差的组。
3. **Git / 诊断**：GitSigns、MiniDiff 的颜色角色对齐，virtual text/lines/浮窗一致。
4. **侧栏 / 管理界面**：再补 Neo-tree、Lazy、Mason、Trouble、Noice 的可见缺口。

不添加插件运行时依赖，也不为了设置高亮主动 require 插件。现有 672 行还不要求全面重构；适配明显增多时可把核心与插件定义拆成两个文件，不预建通用注册系统。

### 6.4 Extras 采用单一数据源，但保留用途差异

先确定可读的 ANSI 16 色映射。用一个简单的导出脚本生成各终端文件并提供检查模式，统一 cyan/magenta 等槽位；vivid 的文件类别映射保留其专用结构，仅同步共享 palette。避免新建模板框架或执行用户配置回调来生成发布文件。

同一 ANSI 槽位在不同工具中若必须不同，要有注释和测试；不能用“生成一致”替代可读性设计。文档补上每个 extra 的安装路径、引用方式和冷白选项是否有导出版本。

### 6.5 测试与发布边界

建议的最低集合：

- Lua 静态检查能发现未定义的 `light_orange` / `light_red`；允许 Neovim 的 `vim` 全局，而不是允许任意全局。
- StyLua 与现有 `.stylua.toml` 一致；格式调整独立提交，不掩盖语义 diff。
- 基础加载、默认/冷白背景、重复加载、主题切换、两次 setup、lualine 无选项副作用。
- 关键 LSP 链接解析结果、MiniDiff 背景、FloatShadow 背景；不要把全部未定义插件组或故意的空组都判错。
- 关键文字与 Git sign 对比度检查，两种背景均覆盖；装饰色使用明确的小型豁免表。
- JSON/TOML 解析与 ANSI 槽位检查，extras 生成检查。
- 最低受支持 Neovim 与当前 stable 的 CI。若要把最低版本提高到 0.10，应作为兼容性决策说明，不能默默删掉源码中已有的 0.7 承诺；本轮不修改该承诺。

人工视觉验收用固定的小场景，而非全插件排列组合：Lua/Python/TypeScript/Markdown、LSP 开/关、Visual 与诊断叠加、Git diff、一个补全菜单、一个 picker、分屏、普通与 shadow 浮窗、状态栏。记录字体、终端、Neovim 和相关插件版本，使截图可比较。

当前没有性能退化证据。先保持直接设置高亮的实现；只有实际启动剖析显示主题是瓶颈时，才考虑缓存或减少设置操作，不承诺未经测量的毫秒目标。

## 七、分阶段交付与验收

| 阶段 | 改动范围 | 完成条件 |
| --- | --- | --- |
| PR 1：可靠性修复 | P1-01/02/03/05/06；同步补回归测试；修正文档加载顺序 | 本次 9 个失败断言全部通过；默认加载与背景切换不回归；ANSI cyan/purple 语义正确；lualine 不改全局/窗口选项 |
| PR 2：可读性与定制 | 深色信息前景、语义角色、小型覆盖 hook、可选终端色 | 两种背景的关键文字/标记满足目标；保留淡色语法块；用户覆盖不被重载覆盖；截图人工认可 |
| PR 3：现代工作流 | blink 与一个主要 picker 优先，按场景补插件组 | 安装实际插件后验证匹配/选中/弃用/边框/诊断；不以“设置了组名”代替 UI 验收 |
| PR 4：维护与发行 | extras 单一来源、CI 矩阵、help、贡献说明、更新截图 | 生成检查及 CI 通过；支持范围、配置顺序、截图环境和 extras 用法有文档 |

可从 PR 1 开始独立交付，不等待插件扩展或完整文档工程。每个阶段保持可审阅、可撤回；颜色调整与结构移动不要放在同一个大提交中。

最终验收标准：**能正确加载、信息清楚可读、无无关选项副作用、覆盖入口稳定、支持范围真实可验证，并保持 DeepWhite 的浅色块风格。**

## 八、资料来源

以下均已阅读官方正文或源码；主流主题资料取自当日分支，未固定到提交，因此是本次对照依据而非长期兼容性保证。

1. [TokyoNight README](https://github.com/folke/tokyonight.nvim/blob/main/README.md)；[blink 适配源码](https://github.com/folke/tokyonight.nvim/blob/main/lua/tokyonight/groups/blink.lua)。
2. [Catppuccin README](https://github.com/catppuccin/nvim/blob/main/README.md)。
3. [Kanagawa README](https://github.com/rebelot/kanagawa.nvim/blob/master/README.md)，含 palette/theme 区分及其可访问性说明；这里未独立验证它的对比度承诺。
4. [Rosé Pine README](https://github.com/rose-pine/neovim/blob/main/README.md)；[主题源码](https://github.com/rose-pine/neovim/blob/main/lua/rose-pine.lua)，检查了其中的角色、补全和插件高亮定义。
5. [W3C：Contrast (Minimum)](https://www.w3.org/WAI/WCAG22/Understanding/contrast-minimum.html)，用于亮度公式与普通文字对比度设计基准。
6. [Neovim v0.11.5 自带 vim 主题](https://github.com/neovim/neovim/blob/v0.11.5/runtime/colors/vim.lua)，用于核对 FloatShadow 的背景写法；另查阅本机 0.12.6 runtime 中 `treesitter.txt` 的 capture fallback 说明和 `syntax.txt` 的 shadow 高亮说明。
