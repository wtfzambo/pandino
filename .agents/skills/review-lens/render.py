"""Render review.json and patch.diff as one self-contained HTML page.

Usage: render.py --work DIR [--output FILE]   (default output: DIR/review.html)
"""

import argparse
import hashlib
import json
import re
import sys
from pathlib import Path

from outline import hunk_crumbs
from prepare import PrepareError, count_changes, split_patch

HERE = Path(__file__).parent
PRIORITIES = ("high", "mid", "low", "skip")
PRIORITY_OF_CATEGORY = {"contract": "high", "behavior": "mid", "interface": "low", "support": "low", "mechanical": "skip"}
SEVERITIES = ("high", "medium", "low")
PRIORITY_MEANING = {
    "high": "read first: significant behavior change or consequences for data, access or callers",
    "mid": "read next: implementation change with local effects",
    "low": "skim: small, peripheral effect",
    "skip": "mechanical change with no separate effect to assess",
}

MAX_WORDS = {"overview": 220, "explanation": 200, "note": 40, "finding": 70, "glossary": 45}

EXPLANATION_PARTS = 4
MAX_STEP_FILES = 20


class ReviewError(ValueError):
    pass


def read_json(path: Path) -> dict:
    if not path.exists():
        raise ReviewError(f"{path.name} is missing")
    try:
        return json.loads(path.read_text())
    except json.JSONDecodeError as error:
        raise ReviewError(f"{path}: {error}") from error


def words(html: str) -> int:
    return len(re.sub(r"<[^>]+>", " ", html or "").split())


def check_length(kind: str, where: str, html: str) -> None:
    count = words(html)
    if count > MAX_WORDS[kind]:
        raise ReviewError(f"{where}: {count} words, over the {kind} limit of {MAX_WORDS[kind]}")


def check_explanation(step: dict) -> None:
    where = f"step {step['title']!r}"
    parts = len(re.findall(r"<p[\s>]", step["explanation"]))
    if parts != EXPLANATION_PARTS:
        raise ReviewError(f"{where}: the explanation has {parts} paragraphs; write {EXPLANATION_PARTS}: where it starts, how it connects, concepts, how to read it")


def build(review: dict, patch: str, texts: dict[str, dict[str, str | None]]) -> dict:
    blocks = split_patch(patch)
    seen: dict[str, str] = {}
    if not (review.get("overview") or "").strip():
        raise ReviewError("The review needs an overview: what the change is for and how it is built")
    check_length("overview", "overview", review["overview"])
    for term, definition in review.get("glossary", {}).items():
        check_length("glossary", f"glossary {term!r}", definition)
    titles = [step.get("title") for step in review["steps"]]
    repeated = sorted({t for t in titles if titles.count(t) > 1})
    if repeated:
        raise ReviewError(f"Step titles must differ, so the reader can tell steps apart: {', '.join(repeated)}")
    for si, step in enumerate(review["steps"]):
        for key in ("title", "level", "explanation", "files"):
            if not step.get(key):
                raise ReviewError(f"steps[{si}] lacks '{key}'")
        step.setdefault("findings", [])
        check_length("explanation", f"step {step['title']!r}", step["explanation"])
        check_explanation(step)
        if len(step["files"]) > MAX_STEP_FILES:
            raise ReviewError(f"step {step['title']!r} has {len(step['files'])} files; split it by sub-area into steps of at most {MAX_STEP_FILES}")
        for f in step["files"]:
            path = f.get("path")
            if path not in blocks:
                raise ReviewError(f"steps[{si}]: {path!r} is not in the patch")
            if path in seen:
                raise ReviewError(f"{path!r} is in both '{seen[path]}' and '{step['title']}'")
            if f.get("category") not in PRIORITY_OF_CATEGORY:
                raise ReviewError(f"{path}: category must be one of {tuple(PRIORITY_OF_CATEGORY)}")
            f["priority"] = PRIORITY_OF_CATEGORY[f["category"]]
            if not words(f.get("note") or ""):
                raise ReviewError(f"{path}: every file needs a context note")
            check_length("note", path, f["note"])
            seen[path] = step["title"]
            f["diff"] = blocks[path]
            text = texts.get(path, {"old": None, "new": None})
            f["old"], f["new"] = text["old"], text["new"]
            f["crumbs"] = hunk_crumbs(blocks[path], text["old"], text["new"])
            f["added"], f["deleted"] = count_changes(blocks[path])
        step["files"].sort(key=lambda f: PRIORITIES.index(f["priority"]))
        step_paths = {f["path"] for f in step["files"]}
        for fd in step["findings"]:
            if fd.get("severity") not in SEVERITIES:
                raise ReviewError(f"finding {fd.get('title')!r}: severity must be one of {SEVERITIES}")
            if fd.get("file") not in step_paths:
                raise ReviewError(f"finding {fd['title']!r}: {fd.get('file')} is not a file of step '{step['title']}'")
            check_length("finding", f"finding {fd.get('title')!r}", fd.get("body", ""))
            if fd.get("side", "new") not in ("old", "new"):
                raise ReviewError(f"finding {fd['title']!r}: side must be 'old' or 'new'")
    missing = [p for p in blocks if p not in seen]
    if missing:
        raise ReviewError("Files missing from every step: " + ", ".join(missing))
    review["priorities"] = PRIORITY_MEANING
    review["id"] = hashlib.sha1(patch.encode()).hexdigest()[:12]
    return review


def unmarked_terms(review: dict, glossary: dict[str, str]) -> list[str]:
    """Name each step or file note that writes a glossary term as plain text and never in <code>, so it opens no definition."""
    texts = [(f"step {s['title']!r}", s["explanation"]) for s in review["steps"]]
    texts += [(f["path"], f["note"]) for s in review["steps"] for f in s["files"]]
    found = []
    for where, html in texts:
        marked = {m.strip() for m in re.findall(r"<code>(.*?)</code>", html)}
        plain = re.sub(r"<code>.*?</code>", " ", html)
        found += [f"{where}: {t}" for t in glossary if t not in marked and re.search(rf"(?<!\w){re.escape(t)}(?!\w)", plain)]
    return found


def render(review: dict, patch: str, texts: dict[str, dict[str, str | None]], known_terms: dict[str, str]) -> str:
    """Validate the review and return the page; the page's glossary is the stored one plus the review's terms."""
    data = build(review, patch, texts)
    data["new_terms"] = sorted(set(data.get("glossary", {})) - set(known_terms))
    data["glossary"] = {**known_terms, **data.get("glossary", {})}
    vendor = HERE / "vendor"
    css = (vendor / "diff2html.min.css").read_text()
    # The base highlight.js theme covers rare token classes; the template's palettes colour the common ones.
    css += (vendor / "github.min.css").read_text()
    payload = json.dumps(data, ensure_ascii=False).replace("<", "\\u003c")
    icons = {}
    for svg in sorted((vendor / "icons").glob("*.svg")):
        body = re.sub(r"<!--.*?-->", "", svg.read_text(), flags=re.DOTALL).strip()
        icons[svg.stem] = re.sub(r'class="[^"]*"', 'class="i"', body, count=1)
    slots = {
        "__TITLE__": escape_html(data["title"]),
        "__VENDOR_CSS__": css,
        "__VENDOR_JS__": inline_script((vendor / "diff2html-ui.min.js").read_text()),
        "__DATA__": payload,
        "__ICONS__": json.dumps(icons).replace("</", "<\\/"),
    }
    # One pass over the template, so a slot name inside vendor code is never replaced.
    template = (HERE / "template.html").read_text()
    template = re.sub(r"\{\{([a-z0-9-]+)\}\}", lambda m: icons[m.group(1)], template)
    return re.sub("|".join(slots), lambda m: slots[m.group(0)], template)


def inline_script(js: str) -> str:
    # HTML parses "<!--" and "<script" inside a <script> element (WHATWG "script data escaped" states), and
    # highlight.js carries both in its regexes. "\x3C" is the same character to JS strings and regexes.
    return re.sub(r"<(?=!--|/?script)", r"\\x3C", js, flags=re.IGNORECASE)


def escape_html(text: str) -> str:
    return text.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--work", required=True, type=Path, help="The directory prepare.py wrote")
    parser.add_argument("--output", type=Path)
    args = parser.parse_args()
    output = args.output or args.work / "review.html"
    try:
        review = read_json(args.work / "review.json")
        stored = Path(read_json(args.work / "manifest.json")["glossary_file"])
        known = json.loads(stored.read_text()) if stored.exists() else {}
        texts = read_json(args.work / "contents.json")
        page = render(review, (args.work / "patch.diff").read_text(), texts, known)
    except (ReviewError, PrepareError) as error:
        sys.exit(f"review-lens: {error}")
    for warning in unmarked_terms(review, {**known, **review.get("glossary", {})}):
        print(f"review-lens: glossary term as plain text, write it in <code>: {warning}", file=sys.stderr)
    output.write_text(page)
    stored.parent.mkdir(parents=True, exist_ok=True)
    stored.write_text(json.dumps(dict(sorted(review["glossary"].items(), key=lambda t: t[0].lower())), ensure_ascii=False, indent=1))
    print(output.resolve())


if __name__ == "__main__":
    main()
