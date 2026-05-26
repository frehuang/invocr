## 1. UBL 头部字段修正

- [x] 1.1 在 `invocr/services/ubl.py` 中将 `UBLVersionID` 设为 `2.1`，`CustomizationID` 设为 `urn:piaozone.com:ubl-2.1-customizations:v1.0`，`ProfileID` 设为 `urn:piaozone.com:profile:bill:v1.0`

## 2. PDF 完整性检查

- [x] 2.1 在 `invocr/models/invoice.py` 中新增 `ExtractionResult` 响应模型，包含 `xml` 字段和 `missing_fields` 数组
- [x] 2.2 在 `invocr/api/routes/invoice.py` 的 `extract_invoice` 中，提取后遍历 `InvoiceData` 字段，收集值为 `None` 或空字符串的字段名，写入 `missing_fields`
- [x] 2.3 修改 `extract_invoice` 返回 JSON（含 `xml` 和 `missing_fields`），而非直接返回 XML

## 3. 国家校验接口

- [x] 3.1 确认 `staticverification/pint-sg/` 目录结构，找到 Schematron 入口文件
- [x] 3.2 在 `pyproject.toml` 中添加 `lxml` 依赖（如未有），确认 Schematron 支持
- [x] 3.3 在 `invocr/services/` 中新增 `validation.py`，实现 `validate_xml(xml_str, country_code)` 函数，加载对应 Schematron 规则并返回错误列表
- [x] 3.4 在 `invocr/api/routes/invoice.py` 中新增 `POST /invoices/validate` 接口，接收 `xml` 和 `country` 参数，调用 `validate_xml`，返回 `{"errors": [...]}`

## 4. 前端更新

- [x] 4.1 修改 `invocr/static/index.html`，将提取响应从纯 XML 改为解析 JSON，从 `xml` 字段取 XML 内容渲染
- [x] 4.2 在 XML 展示区块下方新增完整性检查区块，当 `missing_fields` 非空时列出缺失字段，否则显示"所有字段已成功提取"
- [x] 4.3 在完整性检查区块下方新增国家校验区块，包含国家下拉框（含 `sg` 选项）和"校验"按钮
- [x] 4.4 实现校验按钮点击逻辑：调用 `POST /invoices/validate`，展示错误列表或"校验通过"提示

## 5. 测试

- [x] 5.1 更新或新增单元测试，验证 UBL XML 头部三个节点值正确
- [x] 5.2 新增测试验证 `missing_fields` 在字段缺失时正确返回
- [x] 5.3 新增测试验证 `/invoices/validate` 接口对 `sg` 规则的校验行为
