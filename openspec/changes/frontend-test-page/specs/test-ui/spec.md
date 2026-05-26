## ADDED Requirements

### Requirement: PDF 文件上传
页面 SHALL 提供一个上传区域，支持点击选择或拖拽 PDF 文件。上传区域 SHALL 仅接受 `application/pdf` 类型文件。

#### Scenario: 点击上传
- **WHEN** 用户点击上传区域
- **THEN** 系统打开文件选择对话框，仅显示 PDF 文件

#### Scenario: 拖拽上传
- **WHEN** 用户将 PDF 文件拖入上传区域
- **THEN** 系统接受文件并显示文件名

#### Scenario: 非 PDF 文件被拒绝
- **WHEN** 用户选择或拖入非 PDF 文件
- **THEN** 系统显示错误提示"请上传 PDF 文件"，不发起请求

### Requirement: 调用提取接口
页面 SHALL 在文件选择后自动调用 `POST /invoices/extract`，并在请求期间显示加载状态。

#### Scenario: 请求进行中
- **WHEN** 文件已选择，请求正在进行
- **THEN** 页面显示加载指示器，上传区域禁用

#### Scenario: 请求成功
- **WHEN** 服务端返回 200 和 XML 内容
- **THEN** 页面在代码区域展示带语法高亮的 XML，并显示下载按钮

#### Scenario: 请求失败
- **WHEN** 服务端返回非 200 状态码
- **THEN** 页面显示错误信息，包含 HTTP 状态码和服务端返回的 detail 字段

### Requirement: XML 展示与下载
页面 SHALL 在代码区域展示返回的 XML，并提供下载功能。

#### Scenario: XML 语法高亮
- **WHEN** XML 内容渲染到页面
- **THEN** 使用 highlight.js 对 XML 进行语法高亮展示

#### Scenario: 下载 XML
- **WHEN** 用户点击"下载 XML"按钮
- **THEN** 浏览器下载文件，文件名为 `invoice.xml`，内容为完整 XML 字符串
