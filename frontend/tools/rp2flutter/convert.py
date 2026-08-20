#!/usr/bin/env python3
"""Convert a Mockplus RP offline prototype package into Flutter widgets.

The generated output follows the conventions used by the rest of the
RuoQi Flutter monorepo (pixel-positioned Stacks, icon fonts, assets/images).
"""

from __future__ import annotations

import argparse
import json
import math
import os
import re
import shutil
import subprocess
import sys
from dataclasses import dataclass, field
from typing import Any, Dict, List, Optional, Tuple


# ---------------------------------------------------------------------------
# Small helpers
# ---------------------------------------------------------------------------

def fnum(x: Any) -> str:
    """Format a number the way Dart accepts it (int when integral)."""
    if isinstance(x, bool):
        return "true" if x else "false"
    if isinstance(x, int):
        return str(x)
    try:
        x = float(x)
    except (TypeError, ValueError):
        return "0"
    if math.isnan(x) or math.isinf(x):
        return "0"
    if abs(x - round(x)) < 1e-6:
        return str(int(round(x)))
    s = f"{x:.4f}".rstrip("0").rstrip(".")
    if s in ("", "-"):
        s = "0"
    return s


def dart_str(s: str) -> str:
    """Escape a string for a Dart single-quoted literal."""
    if s is None:
        s = ""
    s = (
        s.replace("\\", "\\\\")
        .replace("'", "\\'")
        .replace("\r", "")
        .replace("\n", "\\n")
        .replace("$", "\\$")
    )
    return f"'{s}'"


def color(r: Any, g: Any, b: Any, a: Any = 1) -> str:
    r, g, b = int(round(float(r))) & 0xFF, int(round(float(g))) & 0xFF, int(round(float(b))) & 0xFF
    alpha = int(round(float(a) * 255)) & 0xFF
    return f"Color(0x{alpha:02X}{r:02X}{g:02X}{b:02X})"


def color_of(c: Any) -> Optional[str]:
    if not isinstance(c, dict):
        return None
    a = c.get("a", 1)
    if a is not None and float(a) <= 0:
        return None
    return color(c.get("r", 0), c.get("g", 0), c.get("b", 0), a if a is not None else 1)


def parse_color_str(s: str) -> Optional[str]:
    s = s.strip()
    m = re.match(r"rgba?\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*(?:,\s*([\d.]+)\s*)?\)", s, re.I)
    if m:
        a = float(m.group(4)) if m.group(4) else 1
        return color(int(m.group(1)), int(m.group(2)), int(m.group(3)), a)
    m = re.match(r"#([0-9a-fA-F]{6})\b", s)
    if m:
        h = m.group(1)
        return color(int(h[0:2], 16), int(h[2:4], 16), int(h[4:6], 16))
    m = re.match(r"#([0-9a-fA-F]{3})\b", s)
    if m:
        h = m.group(1)
        return color(int(h[0] * 2, 16), int(h[1] * 2, 16), int(h[2] * 2, 16))
    return None


def parse_style_attr(attr: str) -> Dict[str, Any]:
    out: Dict[str, Any] = {}
    for key, val in re.findall(r"([a-zA-Z-]+)\s*:\s*([^;]+);?", attr):
        key = key.strip().lower()
        val = val.strip()
        if key == "font-weight" and val.lower() in ("bold", "700"):
            out["bold"] = True
        elif key == "font-style" and val.lower() == "italic":
            out["italic"] = True
        elif key == "text-decoration":
            if "underline" in val.lower():
                out["underline"] = True
            if "line-through" in val.lower() or "linethrough" in val.lower():
                out["strike"] = True
        elif key == "color":
            c = parse_color_str(val)
            if c:
                out["color"] = c
    return out


ENTITIES = {
    "&quot;": '"',
    "&apos;": "'",
    "&#39;": "'",
    "&amp;": "&",
    "&lt;": "<",
    "&gt;": ">",
    "&nbsp;": "\u00a0",
    "&ldquo;": "\u201c",
    "&rdquo;": "\u201d",
    "&lsquo;": "\u2018",
    "&rsquo;": "\u2019",
    "&middot;": "\u00b7",
    "&times;": "\u00d7",
    "&mdash;": "\u2014",
    "&ndash;": "\u2013",
}


def _unescape(s: str) -> str:
    for k, v in ENTITIES.items():
        s = s.replace(k, v)
    return s


TOKEN_RE = re.compile(r"<[^>]*>|[^<&]+|&[^;]+;|&")


def parse_html(value: str) -> List[Tuple[str, Dict[str, Any]]]:
    """Split an HTML snippet into (text, style) segments.

    ``style`` carries bold/italic/underline/strike booleans plus an optional
    ``color`` Dart literal.  Divs and <br> turn into line breaks.
    """
    if not value:
        return [("", {})]
    base = {"bold": False, "italic": False, "underline": False, "strike": False, "color": None}
    stack = [dict(base)]
    segs: List[Tuple[str, Dict[str, Any]]] = []
    cur = ""

    def flush() -> None:
        nonlocal cur
        if cur:
            segs.append((cur, dict(stack[-1])))
            cur = ""

    for m in TOKEN_RE.finditer(value):
        tok = m.group(0)
        if tok.startswith("<"):
            inner = tok[1:-1].strip()
            name = re.match(r"([a-zA-Z]+)", inner)
            if not name:
                continue
            tag = name.group(1).lower()
            attr = inner[name.end():]
            if tag in ("br",):
                cur += "\n"
            elif tag in ("div", "p", "li", "tr"):
                st = dict(stack[-1])
                st.update(parse_style_attr(attr))
                stack.append(st)
            elif tag in ("/div", "/p", "/li", "/tr"):
                cur += "\n"
                if len(stack) > 1:
                    stack.pop()
            elif tag == "span":
                st = dict(stack[-1])
                st.update(parse_style_attr(attr))
                stack.append(st)
            elif tag == "/span":
                if len(stack) > 1:
                    stack.pop()
            elif tag in ("b", "strong"):
                st = dict(stack[-1])
                st["bold"] = True
                stack.append(st)
            elif tag in ("/b", "/strong"):
                if len(stack) > 1:
                    stack.pop()
            elif tag == "i":
                st = dict(stack[-1])
                st["italic"] = True
                stack.append(st)
            elif tag == "/i":
                if len(stack) > 1:
                    stack.pop()
            elif tag == "u":
                st = dict(stack[-1])
                st["underline"] = True
                stack.append(st)
            elif tag == "/u":
                if len(stack) > 1:
                    stack.pop()
            elif tag in ("s", "strike", "del"):
                st = dict(stack[-1])
                st["strike"] = True
                stack.append(st)
            elif tag in ("/s", "/strike", "/del"):
                if len(stack) > 1:
                    stack.pop()
            # other tags (font, a, ...) ignored
        else:
            cur += _unescape(tok)
    flush()

    # merge adjacent segments with identical style
    merged: List[Tuple[str, Dict[str, Any]]] = []
    for text, st in segs:
        if merged and merged[-1][1] == st:
            merged[-1] = (merged[-1][0] + text, st)
        else:
            merged.append((text, st))
    if not merged:
        merged = [("", dict(base))]
    return merged


def text_plain(value: str) -> str:
    return "".join(t for t, _ in parse_html(value))


# ---------------------------------------------------------------------------
# Context / ref resolution
# ---------------------------------------------------------------------------

class Ctx:
    """Parent chain used to resolve ``@value`` / ``@properties.*`` refs."""

    def __init__(self, parent: Optional["Ctx"] = None, node: Optional[Dict[str, Any]] = None):
        self.parent = parent
        self.node = node or {}

    def resolve(self, ref: Any) -> Any:
        if not isinstance(ref, str) or not ref.startswith("@"):
            return ref
        if ref == "@value":
            if "value" in self.node and isinstance(self.node["value"], str):
                return self.node["value"]
            return "" if self.parent is None else self.parent.resolve("@value")
        if ref.startswith("@properties."):
            key = ref[len("@properties."):]
            props = self.node.get("properties", {})
            if isinstance(props, dict) and key in props:
                return props[key]
            if self.parent is not None:
                return self.parent.resolve(ref)
        return ref


# ---------------------------------------------------------------------------
# Dart emission
# ---------------------------------------------------------------------------

@dataclass
class PageData:
    pid: str
    title: str
    path: str
    width: int
    height: int
    out_dir: str
    file_base: str = ""


@dataclass
class PathDef:
    points: List[Tuple[float, float]]
    handles_in: List[Tuple[float, float]]
    handles_out: List[Tuple[float, float]]
    closed: bool
    fill: Optional[str]
    stroke: Optional[str]
    stroke_width: float


class Writer:
    def __init__(self) -> None:
        self.lines: List[str] = []
        self.level = 0

    def w(self, s: str = "") -> None:
        self.lines.append("  " * self.level + s)

    def block_open(self, s: str) -> None:
        self.w(s)
        self.level += 1

    def block_close(self, s: str = "") -> None:
        self.level -= 1
        self.w(s)


def text_align(tf: Dict[str, Any]) -> Optional[str]:
    a = (tf or {}).get("textAlign")
    return {"left": "TextAlign.left", "center": "TextAlign.center", "right": "TextAlign.right"}.get(a)


def text_style_expr(
    tf: Dict[str, Any],
    overrides: Optional[Dict[str, Any]] = None,
    *,
    color_override: Optional[str] = None,
) -> str:
    parts: List[str] = []
    fs = tf.get("fontSize")
    if fs:
        parts.append(f"fontSize: {fnum(fs)}")
    col = color_override or (overrides or {}).get("color") or color_of(tf.get("color"))
    if col:
        parts.append(f"color: {col}")
    st = dict(tf.get("fontStyle") or {})
    if overrides:
        st.update({k: v for k, v in overrides.items() if v is not None})
    if st.get("bold"):
        parts.append("fontWeight: FontWeight.w700")
    if st.get("italic"):
        parts.append("fontStyle: FontStyle.italic")
    deco: List[str] = []
    if st.get("underline"):
        deco.append("TextDecoration.underline")
    if st.get("strike"):
        deco.append("TextDecoration.lineThrough")
    if len(deco) == 1:
        parts.append(f"decoration: {deco[0]}")
    elif len(deco) == 2:
        parts.append("decoration: TextDecoration.combine([TextDecoration.underline, TextDecoration.lineThrough])")
    if fs:
        lhe = tf.get("lineHeightEx")
        if lhe:
            parts.append(f"height: {fnum(float(lhe) / float(fs))}")
    ls = tf.get("letterSpace")
    if ls:
        parts.append(f"letterSpacing: {fnum(ls)}")
    if not parts:
        return "TextStyle()"
    return "TextStyle(" + ", ".join(parts) + ")"


def alignment_expr(tf: Dict[str, Any]) -> Optional[str]:
    if not tf:
        return None
    va = tf.get("verticalAlign", "middle")
    ha = tf.get("textAlign", "left")
    if va == "top":
        return {"left": "Alignment.topLeft", "center": "Alignment.topCenter", "right": "Alignment.topRight"}.get(ha)
    if va == "bottom":
        return {"left": "Alignment.bottomLeft", "center": "Alignment.bottomCenter", "right": "Alignment.bottomRight"}.get(ha)
    return {"left": "Alignment.centerLeft", "center": "Alignment.center", "right": "Alignment.centerRight"}.get(ha)


def radius_expr(radius: Any, w: float, h: float) -> str:
    r = radius or {}
    tl = r.get("topLeft", 0)
    tr = r.get("topRight", 0)
    bl = r.get("bottomLeft", 0)
    br = r.get("bottomRight", 0)
    if r.get("isPercent"):
        m = min(w, h) if w and h else 0
        tl, tr, bl, br = (v / 100.0 * m for v in (tl, tr, bl, br))
    tl, tr, bl, br = (float(v or 0) for v in (tl, tr, bl, br))
    if tl == tr == bl == br:
        return f"BorderRadius.circular({fnum(tl)})"
    return (
        f"BorderRadius.only(topLeft: Radius.circular({fnum(tl)}), "
        f"topRight: Radius.circular({fnum(tr)}), "
        f"bottomLeft: Radius.circular({fnum(bl)}), "
        f"bottomRight: Radius.circular({fnum(br)}))"
    )


def border_expr(stroke: Any, border_flags: Any) -> Optional[str]:
    if not isinstance(stroke, dict):
        return None
    if stroke.get("disabled"):
        return None
    thickness = stroke.get("thickness", 1)
    col = color_of(stroke.get("color"))
    if not col or not thickness:
        return None
    flags = border_flags if isinstance(border_flags, dict) else {}
    sides = {
        "left": flags.get("left", True),
        "top": flags.get("top", True),
        "right": flags.get("right", True),
        "bottom": flags.get("bottom", True),
    }
    if all(sides.values()):
        return f"border: Border.all(color: {col}, width: {fnum(thickness)})"
    parts = []
    for name in ("left", "top", "right", "bottom"):
        if sides.get(name):
            parts.append(f"{name}: BorderSide(color: {col}, width: {fnum(thickness)})")
    if not parts:
        return None
    return "border: Border(" + ", ".join(parts) + ")"


def shadow_expr(shadow: Any) -> Optional[str]:
    if not isinstance(shadow, dict):
        return None
    if shadow.get("disabled") or shadow.get("hidden"):
        return None
    col = color_of(shadow.get("color", {"r": 0, "g": 0, "b": 0, "a": 0.15}))
    blur = shadow.get("blur", 0)
    x = shadow.get("x", 0)
    y = shadow.get("y", 0)
    return f"boxShadow: [BoxShadow(color: {col}, blurRadius: {fnum(blur)}, offset: Offset({fnum(x)}, {fnum(y)}))]"


def decoration_parts(
    comp: Dict[str, Any],
    *,
    force_radius: bool = True,
    ellipse: bool = False,
) -> List[str]:
    p = comp.get("properties", {})
    parts: List[str] = []
    if ellipse:
        parts.append("shape: BoxShape.circle")
    fill = p.get("fill")
    if isinstance(fill, dict) and not fill.get("disabled"):
        c = color_of(fill.get("color"))
        if c:
            parts.append(f"color: {c}")
    w = comp.get("size", {}).get("width", 0)
    h = comp.get("size", {}).get("height", 0)
    if force_radius and not ellipse:
        parts.append(f"borderRadius: {radius_expr(p.get('radius'), w, h)}")
    be = border_expr(p.get("stroke"), p.get("border"))
    if be:
        parts.append(be)
    se = shadow_expr(p.get("shadow"))
    if se:
        parts.append(se)
    return parts


def decoration_expr(comp: Dict[str, Any], *, ellipse: bool = False) -> str:
    parts = decoration_parts(comp, ellipse=ellipse)
    return "BoxDecoration(" + ", ".join(parts) + ")"


def padding_expr(pad: Any) -> Optional[str]:
    if not isinstance(pad, dict):
        return None
    if pad.get("disabled"):
        return None
    l = pad.get("left", 0)
    t = pad.get("top", 0)
    r = pad.get("right", 0)
    b = pad.get("bottom", 0)
    if not any((l, t, r, b)):
        return None
    return f"EdgeInsets.only(left: {fnum(l)}, right: {fnum(r)}, top: {fnum(t)}, bottom: {fnum(b)})"


def wrap_rotate_opacity(comp: Dict[str, Any], inner: str) -> str:
    out = inner
    rot = comp.get("rotate")
    if rot:
        rad = float(rot) * math.pi / 180.0
        out = f"Transform.rotate(angle: {fnum(rad)}, child: {out})"
    op = comp.get("opacity")
    if op is not None and op != 100:
        out = f"Opacity(opacity: {fnum(float(op) / 100.0)}, child: {out})"
    return out


# ---------------------------------------------------------------------------
# Component -> widget
# ---------------------------------------------------------------------------

def is_blank_text(value: Any) -> bool:
    if value is None:
        return True
    if not isinstance(value, str):
        return True
    return text_plain(value).strip() == ""


def text_widget(value: str, tf: Dict[str, Any], *, ellipsis: bool = False) -> str:
    ta = text_align(tf)
    ta_s = f"textAlign: {ta}, " if ta else ""
    overflow = "overflow: TextOverflow.ellipsis" if ellipsis else "overflow: TextOverflow.visible"
    segs = parse_html(value)
    if len(segs) == 1:
        text, st = segs[0]
        ov = {
            "bold": st.get("bold") or None,
            "italic": st.get("italic") or None,
            "underline": st.get("underline") or None,
            "strike": st.get("strike") or None,
        }
        if st.get("color"):
            ov["color"] = st["color"]
        style = text_style_expr(tf, ov if any(ov.values()) else None)
        return f"Text({dart_str(text)}, {ta_s}style: {style}, {overflow})"
    # rich text with span-level styling
    spans = []
    for text, st in segs:
        ov = {}
        if st.get("bold"):
            ov["bold"] = True
        if st.get("italic"):
            ov["italic"] = True
        if st.get("underline"):
            ov["underline"] = True
        if st.get("strike"):
            ov["strike"] = True
        if st.get("color"):
            ov["color"] = st["color"]
        if ov:
            spans.append(f"TextSpan(text: {dart_str(text)}, style: {text_style_expr(tf, ov)})")
        else:
            spans.append(f"TextSpan(text: {dart_str(text)})")
    return (
        f"Text.rich(TextSpan(style: {text_style_expr(tf)}, children: [{', '.join(spans)}]), "
        f"{ta_s}{overflow})"
    )


def rect_widget(comp: Dict[str, Any], ctx: Ctx) -> str:
    p = comp.get("properties", {})
    tf = p.get("textFormat") or {}
    text = comp.get("text", "")
    dec = decoration_expr(comp)
    args = [f"decoration: {dec}"]
    align = alignment_expr(tf)
    if align:
        args.append(f"alignment: {align}")
    pad = padding_expr(p.get("padding"))
    if pad:
        args.append(f"padding: {pad}")
    if not is_blank_text(text):
        args.append(f"child: {text_widget(text, tf)}")
    return "Container(" + ", ".join(args) + ")"


def ellipse_widget(comp: Dict[str, Any], ctx: Ctx) -> str:
    p = comp.get("properties", {})
    tf = p.get("textFormat") or {}
    text = comp.get("text", "")
    args = [f"decoration: {decoration_expr(comp, ellipse=True)}"]
    if not is_blank_text(text):
        args.append("alignment: Alignment.center")
        args.append(f"child: {text_widget(text, tf)}")
    return "Container(" + ", ".join(args) + ")"


def line_widget(comp: Dict[str, Any], ctx: Ctx) -> str:
    p = comp.get("properties", {})
    stroke = p.get("stroke") or {}
    col = color_of(stroke.get("color")) or "Color(0xFFD7D7D7)"
    thickness = float(stroke.get("thickness", 1))
    w = float(comp.get("size", {}).get("width", 0))
    h = float(comp.get("size", {}).get("height", 0))
    horizontal = w >= h
    if horizontal:
        return (
            f"Container(width: {fnum(w)}, height: {fnum(max(h, thickness))}, "
            f"decoration: BoxDecoration(border: Border(top: BorderSide(color: {col}, width: {fnum(thickness)}))))"
        )
    return (
        f"Container(width: {fnum(max(w, thickness))}, height: {fnum(h)}, "
        f"decoration: BoxDecoration(border: Border(left: BorderSide(color: {col}, width: {fnum(thickness)}))))"
    )


def image_widget(comp: Dict[str, Any], ctx: Ctx) -> str:
    v = comp.get("value", "") or ""
    filename = v.replace("./data/", "").replace("data/", "")
    if not filename:
        return "SizedBox.shrink()"
    w = comp.get("size", {}).get("width", 0)
    h = comp.get("size", {}).get("height", 0)
    p = comp.get("properties", {})
    radius = p.get("radius") or {}
    has_radius = any(
        radius.get(k)
        for k in ("topLeft", "topRight", "bottomLeft", "bottomRight")
    )
    img = (
        f"Image.asset({dart_str('assets/images/' + filename)}, fit: BoxFit.contain, "
        f"width: {fnum(w)}, height: {fnum(h)})"
    )
    if has_radius and not radius.get("disabled"):
        r = radius.get("topLeft", 0)
        img = f"ClipRRect(borderRadius: BorderRadius.circular({fnum(r)}), child: {img})"
    return img


def icon_widget(comp: Dict[str, Any], ctx: Ctx) -> str:
    v = comp.get("value") or {}
    if not isinstance(v, dict):
        v = {}
    font = v.get("fontName", "boldIconFont")
    code = v.get("iconCode", 0xE8B2)
    w = comp.get("size", {}).get("width", 0)
    h = comp.get("size", {}).get("height", 0)
    try:
        size = max(float(w), float(h))
    except (TypeError, ValueError):
        size = 16
    p = comp.get("properties", {})
    col = color_of(p.get("icon", {}).get("color")) or "Color(0xFF000000)"
    return (
        f"Icon(IconData(0x{int(code):X}, fontFamily: {dart_str(font)}), "
        f"size: {fnum(size)}, color: {col})"
    )


def input_widget(comp: Dict[str, Any], ctx: Ctx) -> str:
    p = comp.get("properties", {})
    args = [f"decoration: {decoration_expr(comp)}"]
    align = alignment_expr(p.get("textStyle"))
    if align:
        args.append(f"alignment: {align}")
    pad = padding_expr(p.get("padding"))
    if pad:
        args.append(f"padding: {pad}")
    value = comp.get("value") or ""
    tf = p.get("textStyle") or {}
    if not value:
        value = p.get("placeholder", {}).get("value", "") if isinstance(p.get("placeholder"), dict) else ""
        phs = p.get("placeHolderStyle") or {}
        col = color_of(phs.get("value") if isinstance(phs, dict) else phs)
        if col:
            tf = dict(tf)
            tf["color"] = col
    if value:
        args.append(f"child: {text_widget(str(value), tf, ellipsis=True)}")
    return "Container(" + ", ".join(args) + ")"


def select_widget(comp: Dict[str, Any], ctx: Ctx, path_reg: Dict[Any, int]) -> str:
    """A select/multipleSelect rendered as a bordered box with its main canvas."""
    p = comp.get("properties", {})
    args = [f"decoration: {decoration_expr(comp)}"]
    align = alignment_expr(p.get("textStyle"))
    if align:
        args.append(f"alignment: {align}")
    pad = padding_expr(p.get("padding"))
    if not pad:
        pad = "EdgeInsets.only(left: 8, right: 24)"
    args.append(f"padding: {pad}")
    tf = p.get("textStyle") or {}
    value = comp.get("value") or ""
    if not value:
        value = p.get("placeholder", {}).get("value", "") if isinstance(p.get("placeholder"), dict) else ""
    value_text = text_widget(str(value), tf, ellipsis=True)
    # find the "main" canvas children (chevron + value text)
    kids: List[Dict[str, Any]] = []
    for ch in comp.get("components", []):
        if isinstance(ch, dict) and ch.get("type") == "canvas-panel" and ch.get("alias") in ("main", None):
            if ch.get("alias") == "main":
                kids = ch.get("components", [])
                break
    if not kids:
        args.append(f"child: {value_text}")
        return "Container(" + ", ".join(args) + ")"
    # Render visible main children (value text + chevron path) inside the box
    sub_ctx = Ctx(parent=ctx, node=comp)
    w = float(comp.get("size", {}).get("width", 0))
    h = float(comp.get("size", {}).get("height", 0))
    child_lines = []
    for k in kids:
        if k.get("hidden"):
            continue
        child_lines.append(positioned_expr(k, sub_ctx, w, h, path_reg=path_reg))
    if not child_lines:
        args.append(f"child: {value_text}")
        return "Container(" + ", ".join(args) + ")"
    return "Container(decoration: " + decoration_expr(comp) + ", child: Stack(children: [" + ", ".join(child_lines) + "]))"


def panel_widget(comp: Dict[str, Any], ctx: Ctx, path_reg: Dict[Any, int]) -> str:
    """canvas-panel / stack-panel / group / list-layout-panel / grid-panel."""
    p = comp.get("properties", {})
    dec_parts = decoration_parts(comp)
    kids = comp.get("components", [])
    w = float(comp.get("size", {}).get("width", 0))
    h = float(comp.get("size", {}).get("height", 0))
    default_tf = None
    if comp.get("type") in ("list-layout-panel", "grid-panel"):
        props = comp.get("properties", {})
        if isinstance(props.get("textStyle"), dict):
            default_tf = ctx.resolve(props["textStyle"].get("ref")) if props["textStyle"].get("ref") else props["textStyle"]
            if not isinstance(default_tf, dict):
                default_tf = props["textStyle"]
    child_lines = []
    for k in kids:
        if k.get("hidden"):
            continue
        child_lines.append(
            positioned_expr(k, Ctx(parent=ctx, node=comp), w, h, default_tf=default_tf, path_reg=path_reg)
        )
    if dec_parts and child_lines:
        dec = "BoxDecoration(" + ", ".join(dec_parts) + ")"
        return (
            "Container(decoration: " + dec + ", child: Stack(children: ["
            + ", ".join(child_lines) + "]))"
        )
    if dec_parts:
        return "Container(decoration: " + "BoxDecoration(" + ", ".join(dec_parts) + "))"
    if child_lines:
        return "Stack(children: [" + ", ".join(child_lines) + "])"
    return "SizedBox.shrink()"


def text_component_widget(comp: Dict[str, Any], ctx: Ctx, default_tf: Optional[Dict[str, Any]]) -> str:
    p = comp.get("properties", {})
    tf = p.get("textStyle") or {}
    if isinstance(tf, dict):
        resolved = ctx.resolve(tf.get("ref"))
        if isinstance(resolved, dict):
            tf = resolved
    if default_tf:
        merged = dict(default_tf)
        merged.update({k: v for k, v in tf.items() if v is not None and k != "ref"})
        tf = merged
    value = comp.get("value") or ""
    if isinstance(value, str) and value.startswith("@"):
        value = str(ctx.resolve(value))
    return text_widget(str(value), tf)


def table_widget(comp: Dict[str, Any], ctx: Ctx) -> str:
    p = comp.get("properties", {})
    stroke = p.get("stroke") or {}
    line_color = color_of(stroke.get("color")) or "Color(0xFFD8D8D8)"
    line_w = float(stroke.get("thickness", 1))
    cells = [c for c in comp.get("components", []) if c.get("type") == "text"]
    rows: Dict[int, float] = {}
    cols: Dict[int, float] = {}
    for c in cells:
        row, col = int(c.get("row", 0)), int(c.get("column", 0))
        cw = float(c.get("size", {}).get("width", 0))
        ch = float(c.get("size", {}).get("height", 20))
        cols[col] = max(cols.get(col, 0), cw)
        rows[row] = max(rows.get(row, 0), ch)
    if not cols:
        return "SizedBox.shrink()"
    row_keys = sorted(rows)
    col_keys = sorted(cols)
    row_y: Dict[int, float] = {}
    col_x: Dict[int, float] = {}
    y = 0.0
    for r in row_keys:
        row_y[r] = y
        y += max(rows[r], 20)
    x = 0.0
    for c in col_keys:
        col_x[c] = x
        x += max(cols[c], 20)
    child_lines = []
    for c in cells:
        row, col = int(c.get("row", 0)), int(c.get("column", 0))
        if row not in row_y or col not in col_x:
            continue
        cw = max(cols[col], 20)
        ch = max(rows[row], 20)
        tf = c.get("properties", {}).get("textFormat") or {}
        # cell border right/bottom except on the last column/row
        border_parts = []
        if col != col_keys[-1]:
            border_parts.append(f"right: BorderSide(color: {line_color}, width: {fnum(line_w)})")
        if row != row_keys[-1]:
            border_parts.append(f"bottom: BorderSide(color: {line_color}, width: {fnum(line_w)})")
        dec = "BoxDecoration("
        if border_parts:
            dec += "border: Border(" + ", ".join(border_parts) + "), "
        dec += ")"
        align = alignment_expr(tf)
        align_s = f"alignment: {align}, " if align else ""
        text = c.get("value") or ""
        cell = (
            f"Positioned(left: {fnum(col_x[col])}, top: {fnum(row_y[row])}, width: {fnum(cw)}, height: {fnum(ch)}, "
            f"child: Container(decoration: {dec}, {align_s}padding: EdgeInsets.all(8), "
            f"child: {text_widget(str(text), tf)}))"
        )
        child_lines.append(cell)
    if not child_lines:
        return "SizedBox.shrink()"
    return (
        "Container(decoration: BoxDecoration(border: Border.all(color: "
        + line_color
        + ", width: "
        + fnum(line_w)
        + ")), child: Stack(children: ["
        + ", ".join(child_lines)
        + "]))"
    )


def time_picker_widget(comp: Dict[str, Any], ctx: Ctx) -> str:
    p = comp.get("properties", {})
    args = [f"decoration: {decoration_expr(comp)}"]
    tf = p.get("textStyle") or {}
    align = alignment_expr(tf)
    if align:
        args.append(f"alignment: {align}")
    pad = padding_expr(p.get("padding"))
    if not pad:
        pad = "EdgeInsets.only(left: 6, right: 6)"
    args.append(f"padding: {pad}")
    text = comp.get("text") or ""
    if not text:
        text = p.get("placehoder", {}).get("value", "") if isinstance(p.get("placehoder"), dict) else ""
    ic = p.get("iconColor") or {}
    icon_color = color_of(ic.get("value") if isinstance(ic, dict) else ic) or "Color(0xFF333333)"
    icon_size = 14
    isz = p.get("iconSize")
    if isinstance(isz, dict) and isinstance(isz.get("value"), dict):
        icon_size = float(isz["value"].get("value", 14))
    child = (
        "Row(children: [Expanded(child: "
        + text_widget(str(text), tf)
        + "), Icon(Icons.access_time, size: "
        + fnum(icon_size)
        + ", color: "
        + icon_color
        + ")])"
    )
    args.append(f"child: {child}")
    return "Container(" + ", ".join(args) + ")"


def textarea_widget(comp: Dict[str, Any], ctx: Ctx) -> str:
    p = comp.get("properties", {})
    args = [f"decoration: {decoration_expr(comp)}"]
    align = alignment_expr(p.get("textStyle"))
    if align:
        args.append(f"alignment: {align}")
    pad = padding_expr(p.get("padding"))
    if pad:
        args.append(f"padding: {pad}")
    value = comp.get("value") or ""
    tf = p.get("textStyle") or {}
    if not value:
        value = p.get("placeholder", {}).get("value", "") if isinstance(p.get("placeholder"), dict) else ""
    if value:
        args.append(f"child: {text_widget(str(value), tf)}")
    return "Container(" + ", ".join(args) + ")"


def path_widget(comp: Dict[str, Any], ctx: Ctx, path_reg: Dict[int, PathDef]) -> str:
    p = comp.get("properties", {})
    fill = p.get("fill") or {}
    stroke = p.get("stroke") or {}
    fill_col = color_of(fill.get("color")) if not fill.get("disabled") else None
    stroke_col = color_of(stroke.get("color")) if not stroke.get("disabled") else None
    stroke_w = float(stroke.get("thickness", 1))
    w = float(comp.get("size", {}).get("width", 0))
    h = float(comp.get("size", {}).get("height", 0))
    value = comp.get("value") or {}
    data = (value.get("data") or []) if isinstance(value, dict) else []
    closed = value.get("closed", False) if isinstance(value, dict) else False
    points = []
    ins = []
    outs = []
    for pt in data:
        points.append((float(pt.get("point", {}).get("x", 0)), float(pt.get("point", {}).get("y", 0))))
        ins.append((float(pt.get("handleIn", {}).get("x", 0)), float(pt.get("handleIn", {}).get("y", 0))))
        outs.append((float(pt.get("handleOut", {}).get("x", 0)), float(pt.get("handleOut", {}).get("y", 0))))
    key = (tuple(points), tuple(ins), tuple(outs), closed, fill_col, stroke_col, stroke_w)
    idx = path_reg.setdefault(key, len(path_reg))
    return f"CustomPaint(size: Size({fnum(w)}, {fnum(h)}), painter: _Path{idx}Painter())"


def component_widget(
    comp: Dict[str, Any],
    ctx: Ctx,
    default_tf: Optional[Dict[str, Any]] = None,
    path_reg: Optional[Dict[Any, int]] = None,
) -> str:
    if path_reg is None:
        path_reg = {}
    t = comp.get("type")
    if t == "rect":
        return rect_widget(comp, ctx)
    if t == "ellipse":
        return ellipse_widget(comp, ctx)
    if t == "line":
        return line_widget(comp, ctx)
    if t == "image":
        return image_widget(comp, ctx)
    if t == "icon":
        return icon_widget(comp, ctx)
    if t == "input":
        return input_widget(comp, ctx)
    if t in ("select", "multipleSelect"):
        return select_widget(comp, ctx, path_reg)
    if t == "timePicker":
        return time_picker_widget(comp, ctx)
    if t == "textarea":
        return textarea_widget(comp, ctx)
    if t == "tabel":
        return table_widget(comp, ctx)
    if t == "TableCell":
        return "SizedBox.shrink()"
    if t == "path":
        return path_widget(comp, ctx, path_reg)
    if t in ("text", "pureText"):
        return text_component_widget(comp, ctx, default_tf)
    if t in ("canvas-panel", "stack-panel", "group", "list-layout-panel", "grid-panel"):
        return panel_widget(comp, ctx, path_reg)
    # unknown types degrade to a plain stack of children
    kids = [k for k in comp.get("components", []) if not k.get("hidden")]
    if kids:
        w = float(comp.get("size", {}).get("width", 0))
        h = float(comp.get("size", {}).get("height", 0))
        return "Stack(children: [" + ", ".join(
            positioned_expr(k, Ctx(parent=ctx, node=comp), w, h, path_reg=path_reg) for k in kids
        ) + "])"
    return "SizedBox.shrink()"


def positioned_expr(
    comp: Dict[str, Any],
    ctx: Ctx,
    parent_w: float,
    parent_h: float,
    default_tf: Optional[Dict[str, Any]] = None,
    path_reg: Optional[Dict[Any, int]] = None,
) -> str:
    if comp.get("hidden"):
        return "SizedBox.shrink()"
    pos = comp.get("position") or {}
    size = comp.get("size") or {}
    x = float(pos.get("x", 0))
    y = float(pos.get("y", 0))
    w = float(size.get("width", 0))
    h = float(size.get("height", 0))
    inner = component_widget(comp, ctx, default_tf=default_tf, path_reg=path_reg)
    inner = wrap_rotate_opacity(comp, inner)
    if (
        abs(x - 0) < 1e-6
        and abs(y - 0) < 1e-6
        and abs(w - parent_w) < 1e-6
        and abs(h - parent_h) < 1e-6
        and not comp.get("rotate")
    ):
        return f"Positioned.fill(child: {inner})"
    return f"Positioned(left: {fnum(x)}, top: {fnum(y)}, width: {fnum(w)}, height: {fnum(h)}, child: {inner})"


# ---------------------------------------------------------------------------
# Page generation
# ---------------------------------------------------------------------------

def class_name(pid: str) -> str:
    name = re.sub(r"[^0-9a-zA-Z]", "", pid)
    if not name:
        name = "Page"
    if name[0].isdigit():
        name = "P" + name
    return name + "Page"


def page_file(page: PageData, comps: List[Dict[str, Any]]) -> str:
    w = Writer()
    w.w("// Generated by tools/rp2flutter/convert.py — do not edit by hand.")
    w.w("// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables")
    w.w("// ignore_for_file: use_key_in_widget_constructors")
    w.w("// ignore_for_file: file_names, camel_case_types")
    w.w("import 'package:flutter/material.dart';")
    w.w()
    w.w(f"/// {page.title} ({page.path})")
    w.w(f"class {class_name(page.pid)} extends StatelessWidget {{")
    w.w(f"  const {class_name(page.pid)}({{super.key}});")
    w.w()
    w.w("  @override")
    w.w("  Widget build(BuildContext context) {")
    w.w(f"return SizedBox(width: {fnum(page.width)}, height: {fnum(page.height)}, child: Stack(children: [")
    path_reg: Dict[Any, int] = {}
    child_lines = []
    for c in comps:
        if c.get("hidden"):
            continue
        child_lines.append("  " + positioned_expr(c, Ctx(), float(page.width), float(page.height), path_reg=path_reg))
    w.w(",\n".join(child_lines))
    w.w("]));")
    w.w("  }")
    w.w("}")
    for key, idx in sorted(path_reg.items(), key=lambda kv: kv[1]):
        points, ins, outs, closed, fill_col, stroke_col, stroke_w = key
        w.w()
        w.w(f"class _Path{idx}Painter extends CustomPainter {{")
        w.w(f"  const _Path{idx}Painter();")
        w.w()
        w.w("  @override")
        w.w("  void paint(Canvas canvas, Size size) {")
        w.w("    final path = Path();")
        if not points:
            w.w("    return;")
        else:
            w.w(f"    path.moveTo({fnum(points[0][0])}, {fnum(points[0][1])});")
            n = len(points)
            for i in range(n):
                j = (i + 1) % n
                ox, oy = outs[i]
                ix, iy = ins[j]
                if abs(ox) < 1e-6 and abs(oy) < 1e-6 and abs(ix) < 1e-6 and abs(iy) < 1e-6:
                    if j == 0 and not closed:
                        continue
                    w.w(f"    path.lineTo({fnum(points[j][0])}, {fnum(points[j][1])});")
                else:
                    w.w(
                        f"    path.cubicTo({fnum(points[i][0] + ox)}, {fnum(points[i][1] + oy)}, "
                        f"{fnum(points[j][0] + ix)}, {fnum(points[j][1] + iy)}, "
                        f"{fnum(points[j][0])}, {fnum(points[j][1])});"
                    )
            if closed:
                w.w("    path.close();")
            if fill_col:
                w.w(f"    canvas.drawPath(path, Paint()..color = {fill_col});")
            if stroke_col and stroke_w > 0:
                w.w(
                    f"    canvas.drawPath(path, Paint()..color = {stroke_col}..style = PaintingStyle.stroke"
                    f"..strokeWidth = {fnum(stroke_w)});"
                )
        w.w("  }")
        w.w()
        w.w("  @override")
        w.w(f"  bool shouldRepaint(_Path{idx}Painter oldDelegate) => false;")
        w.w("}")
    return "\n".join(w.lines) + "\n"


# ---------------------------------------------------------------------------
# Project parsing
# ---------------------------------------------------------------------------

def load_js(path: str) -> Any:
    with open(path, encoding="utf-8") as f:
        s = f.read()
    m = re.search(r"window\[\'[^\']+\'\]=(\{.*\}|\[.*\]);?\s*$", s, re.S)
    if not m:
        m = re.search(r"window\['[^']+'\]\s*=\s*(\{.*\}|\[.*\]);?\s*$", s, re.S)
    if not m:
        raise ValueError(f"cannot parse {path}")
    return json.loads(m.group(1))


def build_tree(project: Dict[str, Any]) -> Dict[str, Dict[str, Any]]:
    nodes: Dict[str, Dict[str, Any]] = {}

    def walk(n: Dict[str, Any]) -> None:
        if n.get("_id"):
            nodes[n["_id"]] = n
        for c in n.get("children", []):
            walk(c)

    walk(project)
    return nodes


def module_pages(project: Dict[str, Any], module_id: str) -> List[Tuple[Dict[str, Any], str]]:
    """Return (node, full path string) for every page under module_id."""
    nodes = build_tree(project)
    prefix = None
    module_node = None
    for n in project.get("children", []):
        if n.get("_id") == module_id:
            prefix = n.get("path", "ROOT") + "," + module_id
            module_node = n
            break
    out: List[Tuple[Dict[str, Any], str]] = []
    for nid, n in nodes.items():
        if n.get("type") != "page":
            continue
        path = n.get("path", "")
        if prefix and not path.startswith(prefix):
            continue
        parts = [p for p in path.split(",") if p not in ("ROOT", "")]
        parts.append(nid)
        names = []
        for p in parts:
            node = nodes.get(p)
            if node:
                names.append(node.get("name", p))
        if module_node is not None:
            mn = module_node.get("name")
            if mn in names:
                names = names[names.index(mn) + 1:]
        out.append((n, "/".join(names)))
    out.sort(key=lambda t: (t[1], t[0].get("name", "")))
    return out


SECTIONS = {
    "设置": "设置",
    "用户": "用户",
    "权限": "权限",
    "菜单": "菜单",
    "基础": "基础",
    "语言": "语言",
    "日志": "日志",
}


def section_for(path: str) -> str:
    first = path.split("/")[0]
    return SECTIONS.get(first, "")


SECTION_MENUS = {
    # 每个板块侧栏的完整菜单（由原型中该板块各页面侧栏项的并集整理而来）
    "设置": ["通用", "本土化", "电子邮件", "编码规则", "短信", "auth登录", "验证消息"],
    "用户": ["用户", "角色"],
    "菜单": ["菜单"],
    "基础": ["世界地理规划", "地区&国家", "导入地区", "UTC", "时区数据库", "货币", "历史汇率"],
    "语言": ["多语言", "翻译", "导入", "导出"],
    "日志": ["验证日志", "操作日志", "登录日志", "支付日志"],
}


def complete_sidebar(comps: List[Dict[str, Any]], section: str) -> None:
    """把原型页面中不完整的左侧菜单补全为该板块的完整菜单。

    Mockplus 原型中每个页面只内联了侧栏菜单的局部切片，这里以页面内已有的
    菜单项为模板（位置/尺寸/样式），按 42px 行距补齐该板块的全部菜单项。
    """
    menu = SECTION_MENUS.get(section)
    if not menu:
        return

    # 1. 定位侧栏面板：位于 (8,145) 附近、宽 220、EFF1F3 填充的 canvas-panel
    def find_panel(comp: Dict[str, Any], ox: float, oy: float):
        pos = comp.get("position") or {}
        x = float(pos.get("x", 0)) + ox
        y = float(pos.get("y", 0)) + oy
        if comp.get("type") == "canvas-panel" and 0 <= x <= 20 and 140 <= y <= 160:
            size = comp.get("size") or {}
            if 200 <= float(size.get("width", 0)) <= 240 and float(size.get("height", 0)) >= 400:
                fill = comp.get("properties", {}).get("fill") or {}
                col = fill.get("color") or {}
                if not fill.get("disabled") and (col.get("r"), col.get("g"), col.get("b")) == (239, 241, 243):
                    return comp, x, y
        for c in comp.get("components", []):
            r = find_panel(c, x, y)
            if r:
                return r
        return None

    panel = None
    for c in comps:
        panel = find_panel(c, 0, 0)
        if panel:
            break
    if not panel:
        return
    panel_node, panel_x, panel_y = panel

    # 2. 收集侧栏面板内已有的菜单项（含父链，便于移除/插入）
    items: List[Tuple[float, float, Dict[str, Any], List[Tuple[Dict[str, Any], int]]]] = []

    def collect(node: Dict[str, Any], rx: float, ry: float, chain: List[Tuple[Dict[str, Any], int]]) -> None:
        kids = node.get("components", [])
        for i, k in enumerate(kids):
            pos = k.get("position") or {}
            kx = rx + float(pos.get("x", 0))
            ky = ry + float(pos.get("y", 0))
            if k.get("type") == "pureText" and ky >= 20:
                v = k.get("value")
                if isinstance(v, str) and not v.startswith("@"):
                    items.append((kx, ky, k, chain + [(node, i)]))
            collect(k, kx, ky, chain + [(node, i)])

    collect(panel_node, 0.0, 0.0, [])
    if not items:
        return
    items.sort(key=lambda t: (t[1], t[0]))
    tpl_x, tpl_y, tpl_node, tpl_chain = items[0]
    tpl_size = tpl_node.get("size") or {}
    tpl_props = tpl_node.get("properties") or {}

    # 3. 移除已有的局部菜单项
    for _, _, node, chain in items:
        parent, idx = chain[-1]
        kids = parent.get("components", [])
        if idx < len(kids) and kids[idx] is node:
            del kids[idx]

    # 4. 找到插入目标容器：菜单项所在 list-layout-panel 或侧栏面板本身
    host = panel_node
    host_rx = host_ry = 0.0
    for parent, _ in reversed(tpl_chain):
        if parent.get("type") == "list-layout-panel":
            host = parent
            break
    # 计算模板项相对 host 的坐标（chain[0] 即侧栏面板，坐标基准就是面板原点）
    rx, ry = tpl_x, tpl_y
    host_idx = next(i for i, (p, _) in enumerate(tpl_chain) if p is host)
    for parent, _ in tpl_chain[1 : host_idx + 1]:
        pos = parent.get("position") or {}
        rx -= float(pos.get("x", 0))
        ry -= float(pos.get("y", 0))
    host.setdefault("components", [])

    # 5. 生成完整菜单
    for i, label in enumerate(menu):
        node: Dict[str, Any] = {
            "type": "pureText",
            "value": label,
            "position": {"x": rx, "y": ry + i * 42.0},
            "size": dict(tpl_size),
            "properties": {"textStyle": dict(tpl_props.get("textStyle") or {})},
        }
        host["components"].append(node)


INVALID_FILENAME_RE = re.compile(r'[\\/:*?"<>|\x00-\x1f]')


def chinese_filename(title: str) -> str:
    """Turn a prototype page title into a cross-platform Dart file base name."""
    name = INVALID_FILENAME_RE.sub("-", title)
    name = re.sub(r"\s+", "", name)
    name = name.strip(" .")
    if not name:
        name = "页面"
    return name


def assign_chinese_names(pages: List[PageData]) -> None:
    """Assign unique Chinese file base names to every page.

    Plain titles are preferred; when several pages in the same output
    directory share a title, every one of them is prefixed with its parent
    page/folder name so the names stay readable and unambiguous.
    """
    from collections import Counter

    counts = Counter((p.out_dir, chinese_filename(p.title)) for p in pages)
    used: "set[str]" = set()
    for pd in pages:
        base = chinese_filename(pd.title)
        if counts[(pd.out_dir, base)] == 1:
            name = base
        else:
            name = None
            parts = pd.path.split("/")
            for i in range(len(parts) - 2, -1, -1):
                candidate = chinese_filename(parts[i]) + "-" + base
                if candidate not in used:
                    name = candidate
                    break
            if name is None:
                n = 2
                while f"{base}-{n}" in used:
                    n += 1
                name = f"{base}-{n}"
        pd.file_base = name
        used.add(name)


def main() -> int:
    parser = argparse.ArgumentParser(description="Convert Mockplus RP pages to Flutter widgets")
    parser.add_argument("--prototype", default=None, help="path to the extracted prototype package (containing data/project.js)")
    parser.add_argument("--out-lib", default=None, help="target Flutter lib directory")
    parser.add_argument("--module", default="一账通(IDaaS/IAM)-运营管理后台", help="prototype folder to convert")
    parser.add_argument("--module-dir", default="管理后台", help="output directory name under lib")
    args = parser.parse_args()

    cwd = os.getcwd()
    default_proto = os.path.join(cwd, "frontend/apps/pc/platform/lib/管理后台/管理后台")
    default_lib = os.path.join(cwd, "frontend/apps/pc/platform/lib")
    proto_root = args.prototype or default_proto
    lib_root = args.out_lib or default_lib
    data_dir = os.path.join(proto_root, "data")
    pages_dir = os.path.join(data_dir, "pages")

    project = load_js(os.path.join(data_dir, "project.js"))
    # locate the module folder id by name
    module_id = None
    for child in project.get("children", []):
        if child.get("name") == args.module and child.get("type") == "folder":
            module_id = child.get("_id")
            break
    if not module_id:
        print(f"module '{args.module}' not found", file=sys.stderr)
        return 1

    pages = module_pages(project, module_id)
    if not pages:
        print("no pages found", file=sys.stderr)
        return 1

    out_root = os.path.join(lib_root, args.module_dir)
    os.makedirs(out_root, exist_ok=True)

    used_images: Dict[str, bool] = {}
    page_data: List[PageData] = []

    for node, path in pages:
        pid = node["_id"]
        size = node.get("size") or {}
        width = int(round(float(size.get("width", 1920))))
        height = int(round(float(size.get("height", 1080))))
        section = section_for(path)
        out_dir = os.path.join(out_root, section) if section else out_root
        os.makedirs(out_dir, exist_ok=True)
        pd = PageData(pid=pid, title=node.get("name", pid), path=path, width=width, height=height, out_dir=out_dir)
        page_data.append(pd)
    assign_chinese_names(page_data)

    # collect images + write page files
    image_re = re.compile(r"\./data/([0-9a-zA-Z-]+\.(?:png|jpg|jpeg|gif|svg))")

    for pd in page_data:
        src = os.path.join(pages_dir, pd.pid + ".js")
        if not os.path.exists(src):
            print(f"missing page file: {src}", file=sys.stderr)
            continue
        page = load_js(src)
        comps = page if isinstance(page, list) else page.get("components", [])
        complete_sidebar(comps, section_for(pd.path))
        code = page_file(pd, comps)
        dst = os.path.join(pd.out_dir, pd.file_base + ".dart")
        with open(dst, "w", encoding="utf-8") as f:
            f.write(code)
        # scan for images in the raw JSON
        raw = open(src, encoding="utf-8").read()
        for m in image_re.finditer(raw):
            used_images[m.group(1)] = True

    # copy used images into assets/images
    assets_dir = os.path.normpath(os.path.join(lib_root, "..", "assets", "images"))
    os.makedirs(assets_dir, exist_ok=True)
    copied = 0
    for name in sorted(used_images):
        s = os.path.join(data_dir, name)
        d = os.path.join(assets_dir, name)
        if os.path.exists(s):
            shutil.copyfile(s, d)
            copied += 1
        else:
            print(f"missing image asset: {s}", file=sys.stderr)

    # write registry
    write_registry(page_data, os.path.join(lib_root, "prototype_registry.dart"), args.module_dir)

    # 尽量用 dart format 把生成代码格式化成可读的多行样式
    dart = shutil.which("dart")
    if dart:
        subprocess.run(
            [dart, "format", out_root, os.path.join(lib_root, "prototype_registry.dart")],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )
    else:
        print("提示：未找到 dart 命令，跳过代码格式化（可手动执行 dart format）", file=sys.stderr)
    print(f"generated {len(page_data)} pages, copied {copied} images")
    return 0


def write_registry(pages: List[PageData], dst: str, module_dir: str) -> None:
    lines: List[str] = []
    lines.append("// Generated by tools/rp2flutter/convert.py — do not edit by hand.")
    lines.append("// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables")
    lines.append("import 'package:flutter/material.dart';")
    lines.append("")
    for pd in pages:
        rel = os.path.relpath(os.path.join(pd.out_dir, pd.file_base + ".dart"), os.path.dirname(dst))
        lines.append(f"import {dart_str(rel.replace(os.sep, '/'))};")
    lines.append("")
    lines.append("class PrototypeFolder {")
    lines.append("  const PrototypeFolder(this.name, this.children);")
    lines.append("  final String name;")
    lines.append("  final List<Object> children;")
    lines.append("}")
    lines.append("")
    lines.append("class PrototypeEntry {")
    lines.append("  const PrototypeEntry(this.id, this.title, this.path, this.width, this.height, this.builder);")
    lines.append("  final String id;")
    lines.append("  final String title;")
    lines.append("  final String path;")
    lines.append("  final double width;")
    lines.append("  final double height;")
    lines.append("  final WidgetBuilder builder;")
    lines.append("}")
    lines.append("")
    lines.append("final List<PrototypeEntry> prototypePages = [")
    for pd in pages:
        rel_path = "管理后台/" + pd.path
        lines.append(
            f"  PrototypeEntry({dart_str(pd.pid)}, {dart_str(pd.title)}, {dart_str(rel_path)}, "
            f"{fnum(pd.width)}, {fnum(pd.height)}, (_) => {class_name(pd.pid)}()),"
        )
    lines.append("];")
    lines.append("")
    lines.append("final Map<String, PrototypeEntry> prototypePageById = {")
    lines.append("  for (final e in prototypePages) e.id: e,")
    lines.append("};")
    lines.append("")
    with open(dst, "w", encoding="utf-8") as f:
        f.write("\n".join(lines))


if __name__ == "__main__":
    sys.exit(main())
