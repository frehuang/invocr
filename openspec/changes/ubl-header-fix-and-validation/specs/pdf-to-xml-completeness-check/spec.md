## ADDED Requirements

### Requirement: 提取响应包含缺失字段列表
`POST /invoices/extract` 的响应 SHALL 包含 `missing_fields` 数组，列出所有在 `InvoiceData` 中为 `null` 或空字符串的字段名。

#### Scenario: PDF 字段完整时返回空列表
- **WHEN** Gemini 成功提取所有 `InvoiceData` 字段
- **THEN** 响应中 `missing_fields` 为空数组 `[]`

#### Scenario: PDF 字段缺失时列出缺失项
- **WHEN** Gemini 提取结果中部分字段为 `null` 或空字符串
- **THEN** 响应中 `missing_fields` 包含这些字段的名称列表

### Requirement: 前端展示缺失字段
前端页面 SHALL 在 XML 输出下方展示完整性检查区块，当 `missing_fields` 非空时列出所有缺失字段名称。

#### Scenario: 有缺失字段时前端显示警告列表
- **WHEN** 响应中 `missing_fields` 包含字段名
- **THEN** 页面显示"以下字段未能从 PDF 中提取"标题及字段列表

#### Scenario: 无缺失字段时前端显示通过提示
- **WHEN** 响应中 `missing_fields` 为空数组
- **THEN** 页面显示"所有字段已成功提取"提示
