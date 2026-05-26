# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Setup

```bash
uv sync --extra dev   # install all dependencies including dev
cp .env.example .env  # fill in GEMINI_API_KEY
```

## Commands

```bash
uv run python main.py              # start dev server (hot reload on :8000)
uv run uvicorn invocr.api.app:app  # start without reload
uv run pytest                      # run all tests
uv run pytest tests/test_invoice_routes.py::test_health  # run a single test
```

## Architecture

Two-stage pipeline: **Gemini (OCR + extraction) → UBL 2.1 XML**

- **API layer** (`invocr/api/`) — FastAPI app and route handlers. `app.py` mounts `/static` (StaticFiles), serves `GET /` (test UI), and includes the invoice router. `routes/invoice.py` validates file type/size, calls Gemini, serializes to XML, returns `application/xml`.
- **Service layer** (`invocr/services/`):
  - `gemini.py` — sends the raw file bytes (base64-encoded inline_data) directly to `gemini-2.0-flash`. The model performs OCR, extracts structured invoice fields, normalizes dates/amounts/currency, translates non-English text, and returns a JSON object parsed into `InvoiceData`.
  - `ubl.py` — serializes `InvoiceData` to a UBL 2.1 compliant XML document using `lxml`. Covers invoice header, supplier/customer parties with addresses, tax totals, legal monetary totals, and line items.
- **Models** (`invocr/models/invoice.py`) — Pydantic models: `InvoiceData`, `Party`, `Address`, `LineItem`.
- **Frontend** (`invocr/static/index.html`) — single-file test UI. Drag-and-drop PDF upload, calls `POST /invoices/extract`, renders XML with highlight.js, provides download button.

Config is in `invocr/core/config.py` via `pydantic-settings`.

## Required environment variables

| Variable | Description |
|---|---|
| `GEMINI_API_KEY` | Gemini API key from Google AI Studio |
| `GEMINI_MODEL` | Model name (default: `gemini-2.0-flash`) |

## Accepted file types

`image/jpeg`, `image/png`, `image/tiff`, `image/webp`, `application/pdf` — max 10 MB (configurable via `MAX_FILE_SIZE_MB`).
