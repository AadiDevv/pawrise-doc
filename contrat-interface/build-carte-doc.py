"""Injecte la doc de chaque endpoint d'openapi.yaml dans carte-contrat.html.

Usage : python3 build-carte-doc.py (depuis contrat-interface/), après chaque modification d'openapi.yaml.
Remplace le bloc entre /* DOC:START */ et /* DOC:END */ par `const DOC = {...}`,
indexé par "VERBE /chemin" avec les paramètres normalisés en {id} (comme sur la carte).
"""
import json
import re
from pathlib import Path

import yaml

HERE = Path(__file__).parent
spec = yaml.safe_load((HERE / "openapi.yaml").read_text())
schemas = spec["components"]["schemas"]


def resolve(schema):
    while "$ref" in schema:
        schema = schemas[schema["$ref"].split("/")[-1]]
    return schema


def type_label(prop):
    prop = prop or {}
    if "$ref" in prop:
        target = resolve(prop)
        if "enum" in target:
            return " | ".join(target["enum"])
        return prop["$ref"].split("/")[-1]
    if "oneOf" in prop:
        return " | ".join(type_label(p) for p in prop["oneOf"])
    if "enum" in prop:
        return " | ".join(str(v) for v in prop["enum"])
    t = prop.get("type", "object")
    if isinstance(t, list):
        t = " | ".join(t)
    if t == "array":
        return type_label(prop.get("items")) + "[]"
    if prop.get("format") and prop["format"] not in ("binary",):
        t += f" ({prop['format']})"
    return t


def clean(text):
    # Pas de tiret cadratin dans les textes visibles de la carte.
    return (text or "").replace(" — ", " : ").replace("—", ":").strip()


def body_fields(op):
    content = op.get("requestBody", {}).get("content", {})
    out = []
    for media, body in content.items():
        schema = resolve(body.get("schema", {}))
        required = set(schema.get("required", []))
        for name, prop in schema.get("properties", {}).items():
            out.append({
                "name": name,
                "type": type_label(prop),
                "required": name in required,
                "desc": clean(prop.get("description", "")),
                "media": media,
            })
    return out


def normalize(path):
    return re.sub(r"\{[^}]+\}", "{id}", path)


doc = {}
for path, item in spec["paths"].items():
    for verb in ("get", "post", "put", "patch", "delete"):
        op = item.get(verb)
        if not op:
            continue
        doc[f"{verb.upper()} {normalize(path)}"] = {
            "path": path,
            "summary": clean(op.get("summary")),
            "description": clean(op.get("description")),
            "status": op.get("x-status", ""),
            "dependsOn": op.get("x-depends-on", []),
            "auth": bool(op.get("security", spec.get("security"))),
            "params": [
                {"name": p["name"], "in": p["in"], "type": type_label(p.get("schema"))}
                for p in op.get("parameters", []) if p.get("in") == "query"
            ],
            "body": body_fields(op),
            "responses": [
                {"code": code, "desc": clean(r.get("description", ""))}
                for code, r in op.get("responses", {}).items()
            ],
        }

carte = HERE / "carte-contrat.html"
html = carte.read_text()
block = "/* DOC:START */\nconst DOC=" + json.dumps(doc, ensure_ascii=False, separators=(",", ":")) + ";\n/* DOC:END */"
html, n = re.subn(r"/\* DOC:START \*/.*?/\* DOC:END \*/", lambda _: block, html, flags=re.S)
if n != 1:
    raise SystemExit("Marqueurs DOC:START / DOC:END introuvables dans carte-contrat.html")
carte.write_text(html)
print(f"{len(doc)} opérations injectées")
