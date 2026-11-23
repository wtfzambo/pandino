"""Find the declarations that enclose a line of source code, from indentation alone, for any brace or indent language."""

import re

# A line that opens a named scope in common languages. Matching is deliberately loose: a false hit only adds a crumb.
DECLARATION = re.compile(
    r"^\s*(?:(?:public|private|protected|internal|static|abstract|sealed|partial|async|export|default|pub(?:\([^)]*\))?|"
    r"override|virtual|final|readonly|unsafe|extern|declare|data|open|inline)\s+)*"
    r"(?P<kind>namespace|module|class|record|struct|interface|enum|trait|impl|object|def|fn|func|function|type)\b"
)
COMMENT_OR_ATTRIBUTE = re.compile(r"^\s*(?://|#|/\*|\*|\[|@|--)")
FILE_SCOPED_NAMESPACE = re.compile(r"^\s*(?:namespace|package)\s+[\w.]+\s*;")
CRUMB_WIDTH = 90


def indent_of(line: str) -> int:
    return len(line.expandtabs(4)) - len(line.expandtabs(4).lstrip())


def is_declaration(line: str) -> bool:
    return bool(DECLARATION.match(line)) and not COMMENT_OR_ATTRIBUTE.match(line)


def crumb(line: str) -> str:
    text = re.sub(r"\s*[{:]\s*$", "", line.strip())
    return text if len(text) <= CRUMB_WIDTH else text[:CRUMB_WIDTH - 1] + "…"


def enclosing(lines: list[str], index: int) -> list[str]:
    """Declarations enclosing lines[index], outermost first. An empty list means indentation gave no answer."""
    chain = []
    limit = indent_of(lines[index]) if lines[index].strip() else 10**6
    for line in reversed(lines[:index]):
        if not line.strip() or indent_of(line) >= limit:
            continue
        if is_declaration(line):
            chain.append(crumb(line))
            limit = indent_of(line)
        if limit == 0:
            break
    top = next((crumb(line) for line in lines if FILE_SCOPED_NAMESPACE.match(line)), None)
    if top and top not in chain:
        chain.append(top)
    return list(reversed(chain))


HUNK_HEADER = re.compile(r"^@@ -(\d+)(?:,\d+)? \+(\d+)(?:,\d+)? @@")


def hunk_crumbs(block: str, old_text: str | None, new_text: str | None) -> dict[str, list[str]]:
    """Breadcrumbs for each hunk of one file's diff, keyed by its first changed line: "new:12" or "old:40"."""
    old_lines = (old_text or "").splitlines()
    new_lines = (new_text or "").splitlines()
    crumbs: dict[str, list[str]] = {}
    old = new = 0
    anchor_pending = False
    for line in block.splitlines():
        header = HUNK_HEADER.match(line)
        if header:
            old, new = int(header.group(1)), int(header.group(2))
            anchor_pending = True
            continue
        if not old and not new or line.startswith("\\"):
            continue
        if anchor_pending and line[:1] in "+-":
            side, number, source = ("new", new, new_lines) if line[0] == "+" else ("old", old, old_lines)
            if 0 < number <= len(source):
                chain = enclosing(source, number - 1)
                if chain:
                    crumbs[f"{side}:{number}"] = chain
            anchor_pending = False
        if line.startswith("+"):
            new += 1
        elif line.startswith("-"):
            old += 1
        else:
            old += 1
            new += 1
    return crumbs
