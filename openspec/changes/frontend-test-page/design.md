## Context

invocr 是一个 FastAPI 服务，`POST /invoices/extract` 接收发票文件并返回 UBL 2.1 XML。目前没有任何前端界面，测试需要通过 curl 或 API 客户端。目标是在不引入前端构建工具的前提下，内嵌一个轻量测试页面。

## Goals / Non-Goals

**Goals:**
- 单个 `index.html` 文件，无需构建步骤，由 FastAPI StaticFiles 直接 serve
- 支持 PDF 文件上传（拖拽 + 点击）
- 调用 `POST /invoices/extract`，展示返回 XML（语法高亮）
- 提供下载按钮，将 XML 保存为文件
- 显示加载状态和错误信息

**Non-Goals:**
- 不支持多文件批量上传
- 不做用户认证
- 不支持非 PDF 格式（测试页面只限 PDF，API 本身支持更多格式）
- 不引入 React/Vue 等框架或 npm 构建流程

## Decisions

**1. 纯 HTML + 内联 CSS/JS，无构建步骤**
- 备选：Vite + React 单页应用
- 选择原因：这是一个开发测试工具，不需要组件化架构。单文件方案零依赖、零构建，部署即用。

**2. FastAPI StaticFiles 挂载 + 根路由重定向**
- `app.mount("/static", StaticFiles(directory="invocr/static"), name="static")`
- `GET /` 返回 `FileResponse("invocr/static/index.html")`
- 备选：将 HTML 内嵌为字符串直接在路由中返回
- 选择原因：StaticFiles 方案更易维护，后续可添加 CSS/JS 文件。

**3. XML 语法高亮使用 `highlight.js` CDN**
- 备选：手写正则高亮
- 选择原因：highlight.js 体积小、CDN 加载，无需本地安装，XML 高亮效果好。

**4. 新增 `aiofiles` 依赖**
- FastAPI `StaticFiles` 和 `FileResponse` 在异步环境下需要 `aiofiles`。

## Risks / Trade-offs

- [CDN 依赖] highlight.js 从 CDN 加载，离线环境无高亮 → 降级为纯文本展示，不影响功能
- [文件大小限制] 浏览器端无大小预校验，超限由服务端返回 413 → 前端展示错误信息即可
