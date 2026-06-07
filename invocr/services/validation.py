import pathlib

from saxonche import PySaxonProcessor

_STATIC_DIR = pathlib.Path(__file__).parent.parent / "staticverification"

_COUNTRY_XSLT: dict[str, pathlib.Path] = {
    "sg": _STATIC_DIR / "pint-sg" / "Invoice" / "PINT-UBL-validation-preprocessed-inv.xslt",
    "my": _STATIC_DIR / "pint-my" / "Invoice" / "Pint-MY-validation.xslt",
    "bis30": _STATIC_DIR / "bis30" / "Invoice" / "EN16931-UBL-validation.xslt",
}

_SVRL_NS = "http://purl.oclc.org/dsdl/svrl"

# Module-level cache: country_code → compiled Saxon executable
_XSLT_CACHE: dict[str, object] = {}
_SAXON_PROC: PySaxonProcessor | None = None


def _get_executable(country_code: str):
    global _SAXON_PROC
    if country_code not in _XSLT_CACHE:
        if _SAXON_PROC is None:
            _SAXON_PROC = PySaxonProcessor(license=False)
        xslt_path = _COUNTRY_XSLT[country_code]
        xslt_proc = _SAXON_PROC.new_xslt30_processor()
        _XSLT_CACHE[country_code] = xslt_proc.compile_stylesheet(stylesheet_file=str(xslt_path))
    return _XSLT_CACHE[country_code]


def validate_xml(xml_str: str, country_code: str) -> list[dict]:
    xslt_path = _COUNTRY_XSLT.get(country_code.lower())
    if xslt_path is None or not xslt_path.exists():
        raise ValueError(f"No validation rules found for country: {country_code}")

    try:
        executable = _get_executable(country_code.lower())
        proc = _SAXON_PROC
        result = executable.transform_to_string(xdm_node=proc.parse_xml(xml_text=xml_str))
    except Exception:
        # Fall back to fresh processor if cached one fails
        with PySaxonProcessor(license=False) as proc:
            xslt_proc = proc.new_xslt30_processor()
            executable = xslt_proc.compile_stylesheet(stylesheet_file=str(xslt_path))
            result = executable.transform_to_string(xdm_node=proc.parse_xml(xml_text=xml_str))

    if not result:
        return []

    from lxml import etree
    svrl = etree.fromstring(result.encode("utf-8"))
    errors = []
    for failed in svrl.iter(f"{{{_SVRL_NS}}}failed-assert"):
        error_id = failed.get("id", "")
        text_el = failed.find(f"{{{_SVRL_NS}}}text")
        message = text_el.text.strip() if text_el is not None and text_el.text else ""
        errors.append({"id": error_id, "message": message})

    return errors
