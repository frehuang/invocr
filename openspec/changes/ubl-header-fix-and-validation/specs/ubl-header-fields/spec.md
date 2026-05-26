## ADDED Requirements

### Requirement: UBL XML 头部节点使用规定值
生成的 UBL XML SHALL 包含以下固定头部节点值：
- `cbc:UBLVersionID` = `2.1`
- `cbc:CustomizationID` = `urn:piaozone.com:ubl-2.1-customizations:v1.0`
- `cbc:ProfileID` = `urn:piaozone.com:profile:bill:v1.0`

#### Scenario: 提取发票后 XML 包含正确头部
- **WHEN** 用户上传 PDF 并调用 `POST /invoices/extract`
- **THEN** 返回的 XML 中 `cbc:UBLVersionID` 值为 `2.1`，`cbc:CustomizationID` 值为 `urn:piaozone.com:ubl-2.1-customizations:v1.0`，`cbc:ProfileID` 值为 `urn:piaozone.com:profile:bill:v1.0`
