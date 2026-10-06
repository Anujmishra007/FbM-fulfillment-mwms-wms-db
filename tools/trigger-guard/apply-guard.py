#!/usr/bin/env python3
"""
apply-guard.py — WMS FN839 Phase 2 dual-run trigger-guard codegen.

Inserts (or verifies) the canonical WMS-MIGRATION GUARD as the first *business*
statement of each enrolled trigger — placed immediately AFTER the trigger's
`IF @@ROWCOUNT = 0 ... END` preamble so that rowcount check still sees the row
count untouched. The guard is DORMANT until a `wms.skip.<name>` flag is set for a
MODERN connection (see WM.lsp_SetTriggerOwner + memory dual-run-trigger-routing),
so applying it changes nothing for legacy or current modern behavior.

Encoding is detected and preserved PER FILE (this repo mixes ASCII, UTF-8, and
UTF-8-with-BOM; UTF-16LE is also handled if encountered). We never assume one
encoding — matching the "detect per file" rule in memory sql-files-utf16-null-bytes.

Usage:
  python3 apply-guard.py --check            # verify guard presence + drift (default)
  python3 apply-guard.py --apply            # insert guard where missing
  python3 apply-guard.py --apply --only ntrLotUpdate
Exit codes: 0 = all good / applied; 1 = drift or a trigger could not be anchored.
"""
import argparse
import hashlib
import re
import sys
from pathlib import Path

# Repo-root-relative; this script lives in tools/trigger-guard/ (parents[2] = the DB repo root).
REPO_ROOT = Path(__file__).resolve().parents[2]
ENROLLED = Path(__file__).resolve().parent / "enrolled-triggers.txt"

GUARD_BEGIN = "/* ---- WMS-MIGRATION GUARD (FN839 Phase 2 dual-run)"
GUARD_END = "/* ---- END WMS-MIGRATION GUARD ---- */"

# The canonical guard block. The ACTIVE statement (the two CONVERT(...) lines) is what
# drift-checking hashes; the comment is uniform but not part of the drift hash.
GUARD_ACTIVE = (
    "IF CONVERT(NVARCHAR(20), SESSION_CONTEXT(N'wms.app_source')) = N'MODERN'\n"
    "   AND CONVERT(INT, ISNULL(SESSION_CONTEXT(CONCAT(N'wms.skip.', OBJECT_NAME(@@PROCID))), 0)) = 1\n"
    "BEGIN\n"
    "   RETURN\n"
    "END"
)

GUARD_BLOCK = (
    GUARD_BEGIN + " - codegen-managed, do not hand-edit. ----\n"
    "   Skip this trigger's body ONLY when the request is from the MODERN app AND this trigger is\n"
    "   already migrated to Java (its wms.skip.<name> flag is set for the session). Every other case\n"
    "   - legacy caller, or trigger not yet migrated - falls through and runs the body as today.\n"
    "   Placed AFTER the @@ROWCOUNT check so that check still sees the row count untouched.\n"
    "   Signals are set once per connection by WM.lsp_SetTriggerOwner. See memory dual-run-trigger-routing. */\n"
    + GUARD_ACTIVE + "\n"
    + GUARD_END
)

# Anchor: the AS line, then the first `IF @@ROWCOUNT = 0 [BEGIN] RETURN END` preamble.
# Whitespace/indentation and an optional BEGIN wrapper vary between triggers, so keep it flexible.
ANCHOR_RE = re.compile(
    r"(?P<anchor>^[ \t]*IF[ \t]+@@ROWCOUNT[ \t]*=[ \t]*0[ \t]*\r?\n"
    r"(?:[ \t]*BEGIN[ \t]*\r?\n)?"
    r"[ \t]*RETURN[ \t]*\r?\n"
    r"(?:[ \t]*END[ \t]*\r?\n)?)",
    re.IGNORECASE | re.MULTILINE,
)


def guard_active_hash() -> str:
    return hashlib.sha256(GUARD_ACTIVE.encode("utf-8")).hexdigest()[:12]


def detect_encoding(raw: bytes) -> str:
    if raw.startswith(b"\xff\xfe"):
        return "utf-16-le-bom"
    if raw.startswith(b"\xfe\xff"):
        return "utf-16-be-bom"
    if raw.startswith(b"\xef\xbb\xbf"):
        return "utf-8-bom"
    if b"\x00" in raw[:64]:
        # No BOM but interleaved NULs => raw UTF-16LE. NEVER let these hit stdout as-is.
        return "utf-16-le"
    return "utf-8"


def decode(raw: bytes, enc: str) -> str:
    return {
        "utf-16-le-bom": lambda: raw[2:].decode("utf-16-le"),
        "utf-16-be-bom": lambda: raw[2:].decode("utf-16-be"),
        "utf-8-bom": lambda: raw[3:].decode("utf-8"),
        "utf-16-le": lambda: raw.decode("utf-16-le"),
        "utf-8": lambda: raw.decode("utf-8"),
    }[enc]()


def encode(text: str, enc: str) -> bytes:
    return {
        "utf-16-le-bom": lambda: b"\xff\xfe" + text.encode("utf-16-le"),
        "utf-16-be-bom": lambda: b"\xfe\xff" + text.encode("utf-16-be"),
        "utf-8-bom": lambda: b"\xef\xbb\xbf" + text.encode("utf-8"),
        "utf-16-le": lambda: text.encode("utf-16-le"),
        "utf-8": lambda: text.encode("utf-8"),
    }[enc]()


def read_enrolled():
    """Yield (trigger_name, abs_path) for each non-comment line: 'name<whitespace>relpath'."""
    for ln in ENROLLED.read_text(encoding="utf-8").splitlines():
        ln = ln.strip()
        if not ln or ln.startswith("#"):
            continue
        parts = ln.split(None, 1)
        if len(parts) != 2:
            print(f"  ! malformed enrolled line: {ln!r}", file=sys.stderr)
            continue
        name, rel = parts
        yield name, (REPO_ROOT / rel).resolve()


def has_guard(text: str) -> bool:
    return GUARD_BEGIN in text


def guard_matches_canonical(text: str) -> bool:
    # Normalize CRLF and compare the active statement, ignoring surrounding whitespace.
    norm = text.replace("\r\n", "\n")
    return GUARD_ACTIVE in norm


def apply_to_text(text: str) -> str:
    m = ANCHOR_RE.search(text)
    if not m:
        raise ValueError("could not locate `IF @@ROWCOUNT = 0 ... END` anchor")
    # Preserve the file's dominant newline style.
    nl = "\r\n" if "\r\n" in text else "\n"
    block = GUARD_BLOCK.replace("\n", nl)
    insert_at = m.end("anchor")
    return text[:insert_at] + nl + block + nl + text[insert_at:]


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--apply", action="store_true", help="write the guard where missing (default: check only)")
    ap.add_argument("--check", action="store_true", help="verify guard presence + drift (this is the default)")
    ap.add_argument("--only", help="restrict to a single trigger name")
    args = ap.parse_args()

    print(f"guard active-statement hash: {guard_active_hash()}")
    problems = 0
    for name, path in read_enrolled():
        if args.only and name != args.only:
            continue
        if not path.exists():
            print(f"  ! {name}: FILE NOT FOUND at {path}")
            problems += 1
            continue
        raw = path.read_bytes()
        enc = detect_encoding(raw)
        text = decode(raw, enc)

        if has_guard(text):
            if guard_matches_canonical(text):
                print(f"  = {name}: guard present, canonical ({enc})")
            else:
                print(f"  ! {name}: guard present but DRIFTED from canonical ({enc})")
                problems += 1
            continue

        if not args.apply:
            print(f"  - {name}: guard MISSING ({enc}) — run with --apply")
            problems += 1
            continue

        try:
            new_text = apply_to_text(text)
        except ValueError as e:
            print(f"  ! {name}: {e} — INSERT BY HAND, do not force ({enc})")
            problems += 1
            continue
        path.write_bytes(encode(new_text, enc))
        print(f"  + {name}: guard inserted ({enc})")

    if problems:
        print(f"\n{problems} problem(s). See lines marked '!' or '-'.")
        return 1
    print("\nAll enrolled triggers OK.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
