---
name: git-helper
description: Git commit message assistance - YAML-based flexible commit format
license: MIT
compatibility: opencode
metadata:
  author: sonyj
  version: "2.0.0"
  category: general
  tags: [git, commit, helper, conventional-commits]
---

# Git Commit Helper

## Principles

**YAML defines conventions, but they can be changed anytime.**

- `convention.yaml`: Format, rules, allowed types definition
- `examples.yaml`: Example collection (agent edits directly)
- Scripts: Execute git commands only
- Agent: Parse YAML, converse, recommend types, validate messages

## YAML Configuration

### convention.yaml - Convention Definition

```yaml
format: "{type}: {description}"  # Agent can modify

rules:
  max_length: 72
  body_required: false
  scope: optional

allowed_types:
  - fix
  - feat
  - refactor
  - docs
  - ...
```

### examples.yaml - Example Collection

```yaml
examples:
  - "fix: resolve auth timeout"
  - "feat: add dark mode"
  - "refactor: simplify middleware"
  - ...
```

**Change Flexibility:**
- Change `format` → Agent regenerates examples.yaml
- Change `allowed_types` → Edit convention.yaml directly
- Change `examples` → Agent edits via `./template.sh --edit-examples`

## Script Usage

### analyze.sh - Query Changes
```bash
./scripts/analyze.sh --files   # Changed files
./scripts/analyze.sh --diff    # Detailed diff
./scripts/analyze.sh --stats   # Statistics
```

### template.sh - Query Convention and Examples
```bash
./scripts/template.sh --convention       # format, rules
./scripts/template.sh --allowed         # allowed_types
./scripts/template.sh --examples        # examples
./scripts/template.sh --edit-examples   # Edit examples.yaml
```

### commit.sh - Commit/Validate
```bash
./scripts/commit.sh --validate "fix: resolve bug"  # Validate only
./scripts/commit.sh --dry-run "fix: resolve bug"   # Preview
./scripts/commit.sh "fix: resolve bug"             # Actual commit
```

## Agent Workflow

### Basic Flow
```
1. ./analyze.sh --files → Check changes
2. ./template.sh --convention → Check format
3. ./template.sh --allowed → Check types
4. ./template.sh --examples → Check examples

5. User input → "refactor: simplify auth logic"

6. ./commit.sh --validate "refactor: simplify auth logic"
7. ./commit.sh "refactor: simplify auth logic"
```

### Format Change Flow
```
Agent: "Change format to {type}({scope}): {description}?"
User: "Yes"

→ Edit convention.yaml (change format)
→ Regenerate examples.yaml (match new format)
→ Commit with new format
```

### Examples Change Flow
```
Agent: "Update examples?"
User: "Yes"

→ ./template.sh --edit-examples
→ Agent parses and edits examples.yaml
→ Save
```

## Key Points

| Element | Description | How to Change |
|---------|-------------|---------------|
| `format` | Commit message format | Edit convention.yaml |
| `rules` | Length, body, scope rules | Edit convention.yaml |
| `allowed_types` | Recommended types list | Edit convention.yaml |
| `examples` | Example collection | Edit via --edit-examples |

## Dependencies
- `git`
- `bash 4.0+`
- `python3` (for YAML parsing)
