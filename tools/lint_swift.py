#!/usr/bin/env python3
"""
Cross-reference linter for the FreshHarvest SwiftUI sources.

SwiftUI cannot be type-checked on Linux (no iOS SDK), so this performs the
checks that actually catch real bugs in this codebase:

  1. Every `Palette.x`, `TypeScale.x`, `Spacing.x`, `Radius.x`, `Metrics.x`,
     `Elevation.x`, `IconFont.x` reference resolves to a declaration.
  2. Every `MaterialIcon` case used as `.caseName` in an `Icon(...)` call exists.
  3. Every image name passed to `Image("...")` exists in Assets.xcassets.
  4. Every font PostScript name referenced in Swift exists as a bundled .ttf.
  5. No duplicate type declarations across files.
  6. Every `.swift` file has balanced braces / parens.
"""
import json
import os
import re
import sys
from collections import defaultdict

BASE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))  # project root
SRC = os.path.join(BASE, "FreshHarvest")                            # app target sources
ROOT = SRC
ASSETS = os.path.join(SRC, "Resources", "Assets.xcassets")
FONTS = os.path.join(SRC, "Resources", "Fonts")

errors, warnings, notes = [], [], []


def read_all():
    out = {}
    for base, _, files in os.walk(SRC):
        for f in files:
            if f.endswith(".swift"):
                p = os.path.join(base, f)
                out[os.path.relpath(p, ROOT)] = open(p, encoding="utf-8").read()
    return out


FILES = read_all()
ALL = "\n".join(FILES.values())


def strip_comments_and_strings(src):
    """Remove // and /* */ comments plus string literals, keeping line count."""
    out = []
    i, n = 0, len(src)
    while i < n:
        c = src[i]
        if c == "/" and i + 1 < n and src[i + 1] == "/":
            j = src.find("\n", i)
            j = n if j < 0 else j
            out.append(" " * (j - i))
            i = j
        elif c == "/" and i + 1 < n and src[i + 1] == "*":
            j = src.find("*/", i + 2)
            j = n if j < 0 else j + 2
            out.append(re.sub(r"[^\n]", " ", src[i:j]))
            i = j
        elif c == '"':
            # Skip a string literal, honouring escapes and interpolation depth.
            j = i + 1
            depth = 0
            while j < n:
                if src[j] == "\\":
                    j += 2
                    continue
                if src[j] == "(" and src[j - 1] == "\\":
                    depth += 1
                elif src[j] == ")" and depth:
                    depth -= 1
                elif src[j] == '"' and depth == 0:
                    break
                j += 1
            out.append('""' if depth == 0 else '"' + " " * (j - i - 1) + '"')
            i = j + 1
        else:
            out.append(c)
            i += 1
    return "".join(out)


CLEAN = {k: strip_comments_and_strings(v) for k, v in FILES.items()}
ALL_CLEAN = "\n".join(CLEAN.values())

# ---------------------------------------------------------------- 1. namespaces

NAMESPACES = {
    "Palette": os.path.join(SRC, "DesignSystem", "Palette.swift"),
    "TypeScale": os.path.join(SRC, "DesignSystem", "Typography.swift"),
    "Spacing": os.path.join(SRC, "DesignSystem", "Layout.swift"),
    "Radius": os.path.join(SRC, "DesignSystem", "Layout.swift"),
    "Metrics": os.path.join(SRC, "DesignSystem", "Layout.swift"),
    "Elevation": os.path.join(SRC, "DesignSystem", "Layout.swift"),
    "IconFont": os.path.join(SRC, "DesignSystem", "Icons.swift"),
    "AppFont": os.path.join(SRC, "DesignSystem", "Typography.swift"),
    "PriceFormatter": os.path.join(SRC, "Models", "Models.swift"),
    "SampleData": os.path.join(SRC, "Data", "SampleData.swift"),
    "AppTab": os.path.join(SRC, "Data", "SampleData.swift"),
}

declared = {}
for ns, path in NAMESPACES.items():
    src = open(path, encoding="utf-8").read()
    # `static let foo` / `static var foo` inside the enum/struct
    body = src
    members = set(re.findall(r"\bstatic\s+(?:let|var)\s+([A-Za-z_][A-Za-z0-9_]*)", body))
    funcs = set(re.findall(r"\bstatic\s+func\s+([A-Za-z_][A-Za-z0-9_]*)", body))
    # `case foo` for enums (AppTab, DeliveryMode, MaterialIcon)
    cases = set(re.findall(r"^\s*case\s+([a-zA-Z_][A-Za-z0-9_]*)", body, re.M))
    # Nested type declarations — e.g. `enum Weight` inside `AppFont`,
    # `struct Promo` inside `SampleData` — which are valid as `AppFont.Weight`.
    nested = set(re.findall(r"^\s*(?:public\s+|private\s+|internal\s+)?(?:final\s+)?"
                            r"(?:struct|class|enum|actor|typealias)\s+([A-Za-z_][A-Za-z0-9_]*)",
                            body, re.M))
    # `allCases` is synthesised by CaseIterable rather than written out.
    declared[ns] = members | funcs | cases | nested | {"allCases"}

# Also collect enum cases declared inside AppTab (SampleData.swift holds it)
tab_src = open(os.path.join(SRC, "Data", "SampleData.swift"), encoding="utf-8").read()
m = re.search(r"enum AppTab[^{]*\{(.*?)\n\}", tab_src, re.S)
if m:
    declared["AppTab"] = set(re.findall(r"^\s*case\s+([a-zA-Z_][A-Za-z0-9_]*)", m.group(1), re.M))
# `allCases` is synthesised by CaseIterable, not written in the source.
declared["AppTab"].add("allCases")

# MaterialIcon cases
icon_src = open(os.path.join(SRC, "DesignSystem", "Icons.swift"), encoding="utf-8").read()
mi = re.search(r"enum MaterialIcon[^{]*\{(.*?)\n\s*/// Private-Use-Area", icon_src, re.S)
icon_cases = set(re.findall(r"^\s*case\s+([a-zA-Z_][a-zA-Z0-9_]*)", mi.group(1), re.M)) if mi else set()

# ------------------------------------------------- 2. namespace member usage

for ns, members in declared.items():
    for m in re.finditer(r"\b%s\.([A-Za-z_][A-Za-z0-9_]*)" % ns, ALL_CLEAN):
        member = m.group(1)
        if member not in members:
            errors.append(f"{ns}.{member} referenced but not declared")

# ------------------------------------------------------ 3. MaterialIcon usage

# `Icon(.someCase` and `icon: .someCase` and `case .someCase:` in switch
for m in re.finditer(r"\bIcon\(\s*\.([a-zA-Z][A-Za-z0-9_]*)", ALL_CLEAN):
    if m.group(1) not in icon_cases:
        errors.append(f"Icon(.{m.group(1)}) — MaterialIcon case not declared")
for m in re.finditer(r"\bicon:\s*\.([a-zA-Z][A-Za-z0-9_]*)", ALL_CLEAN):
    if m.group(1) not in icon_cases:
        errors.append(f"icon: .{m.group(1)} — MaterialIcon case not declared")
# `return .someCase` inside MaterialIcon-typed properties
for m in re.finditer(r"\breturn\s+\.([a-zA-Z][A-Za-z0-9_]*)\b", ALL_CLEAN):
    pass  # ambiguous (also matches Palette etc.); handled by declared-namespace pass

# -------------------------------------------------------- 4. image asset names

asset_names = set()
if os.path.isdir(ASSETS):
    for d in os.listdir(ASSETS):
        if d.endswith(".imageset"):
            asset_names.add(d[: -len(".imageset")])

used_images = set(re.findall(r'Image\(\s*"([^"]+)"', ALL))
for name in sorted(used_images):
    if name not in asset_names:
        errors.append(f'Image("{name}") — no matching .imageset in Assets.xcassets')

# SampleData imageName strings
for m in re.finditer(r'imageName:\s*"([^"]+)"', ALL):
    if m.group(1) not in asset_names:
        errors.append(f'imageName: "{m.group(1)}" — no matching .imageset')

# --------------------------------------------------------------- 5. font names

bundled_ps = set()
if os.path.isdir(FONTS):
    sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
    try:
        from fontTools.ttLib import TTFont

        for f in os.listdir(FONTS):
            if f.endswith(".ttf"):
                bundled_ps.add(TTFont(os.path.join(FONTS, f))["name"].getDebugName(6))
    except ImportError:
        warnings.append("fontTools unavailable — skipped PostScript name check")

for m in re.finditer(r'"?([A-Za-z][A-Za-z0-9-]*)"?\s*=\s*"([A-Za-z][A-Za-z0-9-]*)"', ALL):
    pass
# explicit string literals that look like PostScript names
for lit in set(re.findall(r'"([A-Z][A-Za-z]+(?:Jakarta|Symbols)[A-Za-z-]*)"', ALL)):
    if bundled_ps and lit not in bundled_ps:
        errors.append(f'font "{lit}" referenced but not among bundled faces {sorted(bundled_ps)}')

# ------------------------------------------------- 6. duplicate declarations

types = defaultdict(list)
for rel, src in CLEAN.items():
    for m in re.finditer(r"^(?:@\w+(?:\([^)]*\))?\s+)*(?:public\s+|private\s+|internal\s+)?"
                         r"(?:final\s+)?(struct|class|enum|actor|protocol)\s+([A-Za-z_][A-Za-z0-9_]*)",
                         src, re.M):
        types[m.group(2)].append(rel)
for name, where in types.items():
    if len(where) > 1:
        errors.append(f"duplicate declaration of `{name}` in {where}")

# ------------------------------------------------------- 7. brace/paren balance

for rel, src in CLEAN.items():
    for open_c, close_c, label in (("{", "}", "braces"), ("(", ")", "parens"), ("[", "]", "brackets")):
        if src.count(open_c) != src.count(close_c):
            errors.append(f"{rel}: unbalanced {label} "
                          f"({src.count(open_c)} {open_c} vs {src.count(close_c)} {close_c})")

# ------------------------------------------------------ 8. files without preview

for rel, src in FILES.items():
    if "Features/" in rel and "#Preview" not in src:
        warnings.append(f"{rel}: no #Preview")
    if "DesignSystem/Components/" in rel and "#Preview" not in src:
        warnings.append(f"{rel}: no #Preview")

# ------------------------------------------------------------------- report

print(f"Scanned {len(FILES)} Swift files\n")
print(f"MaterialIcon cases declared : {len(icon_cases)}")
print(f"Asset imagesets found       : {len(asset_names)} -> {sorted(asset_names)}")
print(f"Bundled PostScript names    : {sorted(bundled_ps)}\n")

if notes:
    print("NOTES")
    for n in notes:
        print("  -", n)
    print()
if warnings:
    print(f"WARNINGS ({len(warnings)})")
    for w in warnings:
        print("  !", w)
    print()
if errors:
    print(f"ERRORS ({len(errors)})")
    for e in errors:
        print("  X", e)
    sys.exit(1)

print("No errors. Cross-references are consistent.")
