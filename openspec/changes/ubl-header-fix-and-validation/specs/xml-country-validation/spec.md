## ADDED Requirements

### Requirement: 提供国家校验接口
系统 SHALL 提供 `POST /invoices/validate` 接口，接收 XML 字符串和国家代码，使用对应 Schematron 规则校验 XML，返回校验错误列表。

#### Scenario: 校验通过时返回空错误列表
- **WHEN** 提交合规的 XML 和有效国家代码（如 `sg`）
- **THEN** 响应返回 `{"errors": []}`

#### Scenario: 校验失败时返回错误详情
- **WHEN** 提交不合规的 XML 和有效国家代码
- **THEN** 响应返回 `{"errors": [{"id": "...", "message": "..."}]}` 列表

#### Scenario: 不支持的国家代码返回 400
- **WHEN** 提交不存在规则文件的国家代码
- **THEN** 响应返回 HTTP 400 及错误说明

### Requirement: 前端提供国家校验操作区块
前端页面 SHALL 在完整性检查区块下方提供国家校验区块，包含国家选择下拉框（至少含 `sg` 选项）和"校验"按钮，点击后展示校验错误列表。

#### Scenario: 用户触发校验并有错误
- **WHEN** 用户选择国家并点击"校验"按钮
- **THEN** 页面展示每条校验错误的 ID 和描述信息

#### Scenario: 用户触发校验且无错误
- **WHEN** 用户选择国家并点击"校验"按钮，XML 合规
- **THEN** 页面显示"校验通过"提示
