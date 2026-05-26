## 1. 依赖与配置

- [x] 1.1 在 `pyproject.toml` 中添加 `aiofiles` 依赖
- [x] 1.2 创建 `invocr/static/` 目录

## 2. FastAPI 集成

- [x] 2.1 在 `invocr/api/app.py` 挂载 `StaticFiles`（`/static` → `invocr/static/`）
- [x] 2.2 在 `invocr/api/app.py` 添加 `GET /` 路由，返回 `FileResponse("invocr/static/index.html")`

## 3. 前端页面

- [x] 3.1 创建 `invocr/static/index.html`，包含上传区域（点击 + 拖拽）、加载状态、XML 展示区、下载按钮
- [x] 3.2 实现拖拽上传逻辑（dragover / drop 事件）
- [x] 3.3 实现文件类型校验（仅接受 `application/pdf`），非 PDF 显示错误提示
- [x] 3.4 实现调用 `POST /invoices/extract` 的 fetch 逻辑，请求期间禁用上传区域并显示加载指示器
- [x] 3.5 实现成功响应处理：用 highlight.js 渲染 XML 语法高亮
- [x] 3.6 实现错误响应处理：展示 HTTP 状态码和 detail 字段
- [x] 3.7 实现"下载 XML"按钮，触发浏览器下载 `invoice.xml`

## 4. 测试

- [x] 4.1 在 `tests/test_invoice_routes.py` 中添加 `GET /` 返回 200 且 Content-Type 为 `text/html` 的测试
