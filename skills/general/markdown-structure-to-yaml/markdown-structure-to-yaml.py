#!/usr/bin/env python3
"""
markdown-structure-to-yaml.py
Convert markdown document structure to YAML format for token-efficient grep-friendly analysis

Usage:
    python markdown-structure-to-yaml.py <markdown-file>
    python markdown-structure-to-yaml.py <markdown-file> --stat   # Show stats only
"""

import sys
import mistune
import yaml
from pathlib import Path


def parse_markdown_structure(markdown_text):
    """Parse markdown and extract nested structure with line numbers"""

    # Split into lines for line number tracking
    lines = markdown_text.split("\n")

    # Build a map of line numbers for each heading pattern
    heading_lines = {}
    code_lines = []
    list_start_lines = []

    for i, line in enumerate(lines, 1):
        stripped = line.strip()

        # Headings
        if stripped.startswith("#"):
            for level in range(1, 7):
                prefix = "#" * level + " "
                if stripped.startswith(prefix):
                    heading_lines[stripped] = i
                    break

        # Code blocks
        if stripped.startswith("```"):
            code_lines.append(i)

        # List items
        if stripped and (
            stripped.startswith(("- ", "* "))
            or (len(stripped) > 1 and stripped[0].isdigit() and ". " in stripped)
        ):
            list_start_lines.append(i)

    # Parse the text
    md = mistune.Markdown()
    result = md.parse(markdown_text)

    if isinstance(result, tuple):
        tokens = result[0]
    elif isinstance(result, list):
        tokens = result
    else:
        tokens = []

    # Build nested structure with line numbers
    root = []
    stack = []  # [(level, list_ref), ...]
    last_heading_line = 0

    for token in tokens:
        if not isinstance(token, dict):
            continue

        token_type = token.get("type")

        if token_type == "heading":
            level = token.get("attrs", {}).get("level", 1)
            text = extract_text(token.get("children", []))

            # Find line number
            heading_pattern = "#" * level + " " + text
            line_num = heading_lines.get(heading_pattern, 1)
            last_heading_line = line_num

            key = f"h{level}"
            node = {key: text, "line": line_num}

            # Pop stack until we find parent level
            while stack and stack[-1][0] >= level:
                stack.pop()

            if not stack:
                root.append(node)
            else:
                parent = stack[-1][1]
                if "children" not in parent:
                    parent["children"] = []
                parent["children"].append(node)

            stack.append((level, node))

        elif token_type == "block_code":
            info = token.get("attrs", {}).get("info", "")

            # Find line number - first ``` after last heading
            line_num = 1
            for cl in code_lines:
                if cl > last_heading_line:
                    line_num = cl
                    break

            code_node = {"code": info or "text", "line": line_num}

            if stack:
                parent = stack[-1][1]
                if "children" not in parent:
                    parent["children"] = []
                parent["children"].append(code_node)
            else:
                root.append(code_node)

        elif token_type == "list":
            style = token.get("ordered", False) and "ordered" or "unordered"
            items = token.get("children", [])

            # Find first list item after last heading
            line_num = 1
            for ll in list_start_lines:
                if ll > last_heading_line:
                    line_num = ll
                    break

            list_node = {"list": style, "count": len(items), "line": line_num}

            if stack:
                parent = stack[-1][1]
                if "children" not in parent:
                    parent["children"] = []
                parent["children"].append(list_node)
            else:
                root.append(list_node)

    return root


def extract_text(children):
    """Extract text from token children"""
    if not children:
        return ""
    if isinstance(children, str):
        return children
    parts = []
    for child in children:
        if isinstance(child, str):
            parts.append(child)
        elif isinstance(child, dict):
            parts.append(child.get("raw", child.get("text", "")))
    return "".join(parts).strip()


def print_yaml(root):
    """Print nested YAML output"""

    def format_node(node, indent=0):
        prefix = "  " * indent

        if "children" in node:
            # It's a heading node
            for key in ["h1", "h2", "h3", "h4", "h5"]:
                if key in node:
                    line_num = node.get("line", 0)
                    result = [f"{prefix}- {key}: {node[key]} @ {line_num}"]
                    break
            else:
                result = []

            for child in node.get("children", []):
                result.extend(format_node(child, indent + 1))
            return result
        elif "code" in node:
            line_num = node.get("line", 0)
            return [f"{prefix}- code: {node['code']} @ {line_num}"]
        elif "list" in node:
            line_num = node.get("line", 0)
            return [
                f"{prefix}- list: {node['list']} ({node['count']} items) @ {line_num}"
            ]
        else:
            return []

    for node in root:
        for line in format_node(node):
            print(line)


def print_stat(root):
    """Print statistics"""
    stats = {
        "total_h1": 0,
        "total_h2": 0,
        "total_h3": 0,
        "total_h4": 0,
        "total_h5": 0,
        "total_code_blocks": 0,
        "total_lists": 0,
    }

    def count(nodes):
        for node in nodes:
            if isinstance(node, dict):
                if "h1" in node:
                    stats["total_h1"] += 1
                elif "h2" in node:
                    stats["total_h2"] += 1
                elif "h3" in node:
                    stats["total_h3"] += 1
                elif "h4" in node:
                    stats["total_h4"] += 1
                elif "h5" in node:
                    stats["total_h5"] += 1

                if "code" in node:
                    stats["total_code_blocks"] += 1
                if "list" in node:
                    stats["total_lists"] += 1
                if "children" in node:
                    count(node["children"])

    count(root)
    for key, value in stats.items():
        print(f"{key}: {value}")


def main():
    args = sys.argv[1:]

    if not args or args[0] in ["-h", "--help"]:
        print(__doc__)
        sys.exit(1)

    filepath = args[0]
    if not Path(filepath).exists():
        print(f"Error: File not found: {filepath}", file=sys.stderr)
        sys.exit(1)

    with open(filepath, "r", encoding="utf-8") as f:
        markdown_text = f.read()

    root = parse_markdown_structure(markdown_text)

    if "--stat" in args:
        print_stat(root)
    else:
        print_yaml(root)


if __name__ == "__main__":
    main()
