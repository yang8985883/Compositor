#!/usr/bin/env python3
"""Generate Compositor/Localizable.xcstrings from scripts/zh-Hans.tsv.

The TSV holds `english<TAB>chinese` pairs (one per line, UTF-8, no header).
English literals are the localization keys; the source language falls back
to the key itself, so only zh-Hans needs explicit values.
"""
import json
import pathlib
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
TSV = ROOT / "scripts" / "zh-Hans.tsv"
OUT = ROOT / "Compositor" / "Localizable.xcstrings"


def main() -> None:
    # Merge with the existing catalog so keys auto-extracted by Xcode at build
    # time survive regeneration; TSV translations always win.
    strings: dict[str, dict] = {}
    if OUT.exists():
        try:
            strings = json.loads(OUT.read_text(encoding="utf-8")).get("strings", {})
        except (json.JSONDecodeError, OSError):
            strings = {}

    seen: set[str] = set()
    for line_no, line in enumerate(TSV.read_text(encoding="utf-8").splitlines(), 1):
        if not line.strip() or line.startswith("#"):
            continue
        key, sep, value = line.partition("\t")
        if not sep:
            sys.exit(f"{TSV.name}:{line_no}: missing tab separator")
        if key in seen:
            sys.exit(f"{TSV.name}:{line_no}: duplicate key {key!r}")
        seen.add(key)
        strings[key] = {
            "localizations": {
                "zh-Hans": {
                    "stringUnit": {"state": "translated", "value": value}
                }
            }
        }

    catalog = {
        "sourceLanguage": "en",
        "strings": dict(sorted(strings.items())),
        "version": "1.0",
    }
    OUT.write_text(
        json.dumps(catalog, ensure_ascii=False, indent=2, sort_keys=False) + "\n",
        encoding="utf-8",
    )
    print(f"wrote {len(strings)} strings to {OUT.relative_to(ROOT)} ({len(seen)} from TSV)")


if __name__ == "__main__":
    main()
