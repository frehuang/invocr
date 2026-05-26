from fastapi import FastAPI
from fastapi.responses import FileResponse
from fastapi.staticfiles import StaticFiles

from invocr.api.routes import invoice
from invocr.core.config import settings

app = FastAPI(
    title="invocr",
    description="Invoice OCR API powered by Google Cloud Document AI and Gemini",
    version="0.1.0",
    debug=settings.debug,
)

app.mount("/static", StaticFiles(directory="invocr/static"), name="static")
app.include_router(invoice.router)


@app.get("/", include_in_schema=False)
def index():
    return FileResponse("invocr/static/index.html")


@app.get("/health")
def health():
    return {"status": "ok"}
