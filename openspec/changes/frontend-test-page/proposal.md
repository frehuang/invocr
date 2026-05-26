## Why

目前 invocr 服务只有 REST API，开发和测试时需要借助 curl 或 Postman，缺乏直观的验证方式。提供一个内嵌的测试页面，可以让开发者和业务人员直接上传发票 PDF，实时查看 UBL 2.1 XML 输出并下载，降低集成验证门槛。

## What Changes

- 新增静态 HTML 测试页面，由 FastAPI 直接 serve
- 页面支持拖拽或点击上传 PDF 文件
- 上传后调用 `POST /invoices/extract`，展示返回的 XML（语法高亮）
- 提供"下载 XML"按钮，将结果保存为 `.xml` 文件
- 显示加载状态和错误信息

## Capabilities

### New Capabilities

- `test-ui`: 内嵌前端测试页面，上传 PDF 并展示/下载 UBL XML 结果

### Modified Capabilities

- `invoice-extract-api`: 新增 `GET /` 路由 serve 测试页面，以及静态资源挂载

## Impact

- `invocr/api/app.py` — 挂载静态文件目录，添加根路由返回 HTML 页面
- `invocr/static/` — 新增目录，存放 `index.html`（纯 HTML + 内联 CSS/JS，无构建步骤）
- 新增依赖：`aiofiles`（FastAPI StaticFiles 需要）
