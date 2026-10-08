#!/usr/bin/env python3
"""Extract user-facing English UI string literals from Compositor sources.

Writes:
  scripts/pending_keys.txt        plain keys not yet in scripts/zh-Hans.tsv
  scripts/pending_interpolated.txt  keys containing \\(…) interpolation (need
                                  manual mapping to their catalog form after
                                  the build normalizes them)
"""
import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
SRC = ROOT / "Compositor"
TSV = ROOT / "scripts" / "zh-Hans.tsv"

# Literal first-argument call sites whose strings auto-localize or will be
# wrapped in loc() by the refactor.
LITERAL_CALL = re.compile(
    r'\b(?:Text|Button|Toggle|Label|Menu|Picker|TextField|SecureTextField'
    r'|Stepper|Slider|TextEditor)\(\s*"((?:[^"\\]|\\.)*)"'
)
MODIFIER = re.compile(
    r'\.(?:help|alert|accessibilityLabel|accessibilityHint|accessibilityValue'
    r'|confirmationDialog|navigationTitle)\(\s*"((?:[^"\\]|\\.)*)"'
)
LOC_WRAP = re.compile(r'\bloc\(\s*"((?:[^"\\]|\\.)*)"')
# Explicit enum raw values ("case x = \"Raw Value\""), incl. multi-case lines.
RAW_VALUE = re.compile(
    r'(?:case|,)\s*\w+\s*=\s*"((?:[^"\\]|\\.)*)"', re.MULTILINE
)

SKIP_FILES = {"Localization.swift"}


def interesting(key: str) -> bool:
    if not key or len(key) > 220:
        return False
    if not re.search(r"[A-Za-z]{2,}", key):  # symbols/format-only
        return False
    if key.startswith(("CI", "NS", "com.")):  # filter names, class names, UTIs
        return False
    if re.fullmatch(r"[#%@\.\d\s°×—–\-–+/()]+", key):
        return False
    return True


def main() -> None:
    done: set[str] = set()
    for line in TSV.read_text(encoding="utf-8").splitlines():
        if line.strip() and not line.startswith("#"):
            done.add(line.partition("\t")[0])

    plain: set[str] = set()
    interpolated: set[str] = set()
    for path in sorted(SRC.rglob("*.swift")):
        if path.name in SKIP_FILES:
            continue
        text = path.read_text(encoding="utf-8")
        for rx in (LITERAL_CALL, MODIFIER, LOC_WRAP, RAW_VALUE):
            for m in rx.finditer(text):
                key = m.group(1)
                if not interesting(key):
                    continue
                if "\\(" in key or "%@" in key or "%lld" in key:
                    interpolated.add(key)
                else:
                    plain.add(key)

    pending_plain = sorted(k for k in plain if k not in done)
    pending_interp = sorted(k for k in interpolated if k not in done)
    out = ROOT / "scripts"
    (out / "pending_keys.txt").write_text(
        "\n".join(pending_plain) + "\n", encoding="utf-8"
    )
    (out / "pending_interpolated.txt").write_text(
        "\n".join(pending_interp) + "\n", encoding="utf-8"
    )
    print(f"pending plain: {len(pending_plain)}  interpolated: {len(pending_interp)}  already done: {len(done)}")


if __name__ == "__main__":
    main()
