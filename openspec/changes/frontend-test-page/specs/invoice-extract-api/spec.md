## ADDED Requirements

### Requirement: 根路由返回测试页面
服务 SHALL 在 `GET /` 路由返回 `index.html` 测试页面。

#### Scenario: 访问根路由
- **WHEN** 客户端发送 `GET /` 请求
- **THEN** 服务返回 `invocr/static/index.html`，Content-Type 为 `text/html`

### Requirement: 静态资源挂载
服务 SHALL 将 `invocr/static/` 目录挂载到 `/static` 路径，供页面引用静态资源。

#### Scenario: 静态文件可访问
- **WHEN** 客户端请求 `/static/<filename>`
- **THEN** 服务返回对应文件内容
