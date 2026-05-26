## Context

当前 `invocr/services/ubl.py` 生成的 UBL XML 头部三个节点使用了错误或默认值。前端页面仅展示 XML 输出，无法告知用户 PDF 内容是否完整转换。此外，生成的 XML 没有经过任何国家级合规校验，无法保证符合如新加坡 PINT-SG 等电子发票标准。

## Goals / Non-Goals

**Goals:**
- 修正 UBL XML 头部 `UBLVersionID`、`CustomizationID`、`ProfileID` 三个节点的值
- 在前端展示 PDF 字段与 XML 字段的完整性对比，列出缺失项
- 提供基于 Schematron 的国家校验接口，支持 `pint-sg` 规则，在前端列出校验错误

**Non-Goals:**
- 不支持自动修复校验错误
- 不支持多国规则的自动检测（用户手动选择国家）
- 不修改 Gemini 提取逻辑

## Decisions

**1. 头部字段硬编码为常量**
`UBLVersionID`、`CustomizationID`、`ProfileID` 值固定，直接在 `ubl.py` 中作为常量写入，不通过配置或参数传入。理由：这些值是规范要求，不应因环境而变化。

**2. 完整性检查在后端实现**
在 `POST /invoices/extract` 响应中新增 `missing_fields` 字段，列出 Gemini 返回为 `null`/空的 `InvoiceData` 字段。前端直接渲染该列表。理由：后端已有完整的 `InvoiceData` 模型，字段完整性判断在后端最准确。

**3. Schematron 校验通过独立接口暴露**
新增 `POST /invoices/validate` 接口，接收 XML 字符串和国家代码，返回校验错误列表。使用 `lxml` + `lxml-isoschematron` 执行 Schematron 校验。规则文件存放在项目 `staticverification/` 目录下（已有 `pint-sg`）。理由：校验与提取解耦，前端可在提取后单独触发校验。

**4. 前端顺序展示三个阶段结果**
页面分三个区块：① XML 输出，② 完整性检查结果，③ 国家校验结果。校验区块提供国家选择下拉框和"校验"按钮。

## Risks / Trade-offs

- [Schematron 依赖] `lxml` 内置 XSLT 支持，但 `lxml-isoschematron` 需要额外安装 → 在 `pyproject.toml` 中添加依赖
- [规则文件路径] `staticverification/pint-sg` 目录结构需确认入口文件名 → 实现前先检查目录结构
- [完整性检查粒度] 仅检查顶层 `InvoiceData` 字段，不深入 `LineItem` 子字段 → 后续可扩展
