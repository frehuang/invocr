## Why

生成的 UBL XML 缺少正确的头部标识字段，且无法验证转换结果的完整性和合规性。需要修正 UBL 头部节点、提供内容完整性检查，并集成国家级校验规则（如新加坡 PINT-SG）。

## What Changes

- 修正 UBL XML 输出中的三个头部节点：`UBLVersionID`、`CustomizationID`、`ProfileID`
- 在前端页面新增"内容完整性检查"功能：对比 PDF 原始字段与 XML 输出字段，列出缺失或未转换的内容
- 新增"国家校验"功能：根据所选国家规则（如 `pint-sg`）对 XML 进行 Schematron 校验，并在页面列出校验错误

## Capabilities

### New Capabilities

- `ubl-header-fields`: 修正 UBL XML 头部三个标准节点的值
- `pdf-to-xml-completeness-check`: 检查 PDF 提取字段是否完整映射到 XML，列出缺失项
- `xml-country-validation`: 调用国家校验规则（Schematron）校验 XML，返回错误列表

### Modified Capabilities

## Impact

- `invocr/services/ubl.py` — 修改头部字段生成逻辑
- `invocr/services/gemini.py` / `invocr/models/invoice.py` — 可能需要扩展字段以支持完整性检查
- `invocr/api/routes/invoice.py` — 新增校验接口
- `invocr/static/index.html` — 前端展示完整性检查结果和校验错误
- `invocr/static/` 或新目录 — 存放 Schematron 规则文件（`pint-sg` 等）
