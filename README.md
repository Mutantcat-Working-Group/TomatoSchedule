<div align=center>
<img src="icon.png" style="width:100px;" width="100"/>
<h2>TomatoSchedule</h2>
</div>

[English](README.en.md) | 简体中文

### 一、产品概述

- AI 驱动的跨平台日程规划工具：日历视图 + 自然语言对话 + AI 自动排期，支持 Android、iOS、Windows、macOS、Linux。
- 日历管理：月/周/日视图，事件创建、编辑、删除，优先级标记，本地 SQLite 存储。
- AI 智能规划：用自然语言描述需求和待办事项，AI 自动生成日程安排并写入日历。
- MCP Server 内置：Claude、Cursor、Windsurf 等 AI 编程助手可直接通过 MCP 协议管理日程。
- 跨平台一致体验：Flutter 构建，一套代码覆盖移动端与桌面端。
- **发行方** 由异猫工作群（mutantcat.org）发行，GitHub: https://github.com/Mutantcat-Working-Group

核心价值：

- AI 原生：日程规划不靠手动拖拽，对话即可生成合理日程。
- 开放集成：内置 MCP Server，AI 助手可直接读写日程，无需手动同步。
- 轻量本地：SQLite 本地存储，数据不出设备，隐私可控。
- 全平台覆盖：手机、平板、电脑同一份体验，开源免费。

### 二、功能说明

#### 日历管理

- 月视图、周视图、日视图切换。
- 事件创建、编辑、删除，支持标题、描述、时间、地点、优先级。
- 优先级标记：低 / 中 / 高 / 紧急，颜色区分。
- 本地 SQLite 持久化存储，离线可用。

#### AI 智能规划

- 自然语言输入需求，例如"下周三前完成项目报告，每天工作 2 小时"。
- AI 自动分析已有日程和待办事项，生成合理的时间安排。
- 支持 OpenAI GPT-4o 及兼容端点。

#### MCP Server

- 内置 MCP 协议服务器，AI 编程助手可直接管理日程。
- 支持工具：创建事件、更新事件、删除事件、查询事件、获取单个事件。
- 支持 SSE 实时通知。

### 三、安装与下载

1. 从 [Releases](https://github.com/Mutantcat-Working-Group/TomatoSchedule/releases/latest) 下载最新安装包。
   - Android：下载 `.apk` 直接安装。
   - Windows：下载 `.exe` 安装。
   - macOS：下载 `.dmg` 安装。
   - Linux：下载 `.AppImage` 或 `.deb` 安装。
2. 源码构建：
   ```bash
   git clone https://github.com/Mutantcat-Working-Group/TomatoSchedule.git
   cd TomatoSchedule
   flutter pub get
   flutter run
   ```

### 四、快速上手

1. 打开应用，进入日历视图，点击右下角 `+` 手动添加事件。
2. 点击右上角聊天图标，进入 AI 对话界面。
3. 输入你的需求和待办事项，例如：
   ```
   下周一要交项目报告，每天最多工作 3 小时，帮我安排一下
   ```
4. AI 会自动生成日程并写入日历，你可以在日历中查看和调整。

#### MCP 集成

1. 进入设置界面，启动 MCP Server。
2. 在 AI 编程助手（如 Claude Desktop）中添加 MCP 配置：
   ```json
   {
     "mcpServers": {
       "tomato-schedule": {
         "url": "http://localhost:8080/mcp"
       }
     }
   }
   ```
3. 现在你可以直接对 AI 说"帮我创建一个明天下午 2 点的会议"，AI 会通过 MCP 直接操作你的日程。

### 五、开发者集成

#### MCP Server

- 说明：为 MCP 兼容的 AI 编程助手提供日程管理能力，服务运行在 `http://<设备IP>:8080/mcp`。
- 端口：默认 8080，可在设置中修改。
- 协议：支持 MCP JSON-RPC 2.0 和 SSE。

#### 可用工具

| 工具 | 说明 |
|------|------|
| `create_event` | 创建新日程事件 |
| `update_event` | 更新已有事件 |
| `delete_event` | 删除事件 |
| `query_events` | 查询日期范围内的事件 |
| `get_event` | 获取单个事件详情 |

#### 配置示例

**Claude Desktop** (`claude_desktop_config.json`):
```json
{
  "mcpServers": {
    "tomato-schedule": {
      "url": "http://localhost:8080/mcp"
    }
  }
}
```

**Cursor** (`.cursor/mcp.json`):
```json
{
  "mcpServers": {
    "tomato-schedule": {
      "url": "http://localhost:8080/mcp"
    }
  }
}
```

### 六、开发进度

- [X] 日历视图（月/周/日）
- [X] 事件 CRUD 操作
- [X] AI 智能规划
- [X] MCP Server
- [X] 跨平台构建（Android/iOS/Windows/macOS/Linux）
- [X] CI/CD 自动打包与发布
- [ ] 用户偏好学习
- [ ] 冲突检测与提醒
- [ ] 数据同步（多设备）

[MIT](LICENSE)

---

## 致谢

本项目由异猫工作群（Mutantcat Working Group）开发与维护。
