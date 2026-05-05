---
name: mattpocock-grill
description: Question tracking as threads with checklist format. Use when exploring design with users, deriving sub-questions, or tracking requirements via Q&A.
---

# Matt Pocock Workflow Skill

This skill provides the question tracking mechanism and design workflow based on Matt Pocock's principles.

## Usage
Load this skill when performing initial design exploration with users.
```
skill: mattpocock-grill
```

## Core Components

### 1. Question Tracking (threads.md)

Questions are organized as **threads** - each thread starts with an initial question and branches into derived questions as answers come in.

```markdown
# Question Threads

## Initial Analysis
**Prompt**: [Summary of initial requirements provided by user]
**Extracted Questions**: [Primary questions extracted by Designer]

---

## Thread: Q-001 (Initial)
- [ ] **Question**: [Primary question text]
  **Context**: [Why this question matters]
  **Derived From Prompt**: [Which part of initial prompt this came from]

### Derived Questions from Q-001
- [ ] **Q-001-1**: [Derived question based on Q-001 answer]
  **References**: Q-001
```

### Question Checklist Format

ALL questions use checklist format:
- `[ ]` = unanswered/pending
- `[x]` = answered/completed
- **NO "Asked" date** - don't track when question was asked
- **NO "Status" field** - checkbox state is the status

### Derived Question Flow

```
Q-001 answered: "Python + React"
    ↓
Q-001-1: "Which framework?" (References: Q-001)
Q-001-2: "Existing project experience?" (References: Q-001)
    ↓
Q-001-1 answered: "Django for Python"
    ↓
Q-001-1-1: "Which Django version?" (References: Q-001, Q-001-1)
```

### Cross-Reference

Derived questions can reference multiple previous answers:
```markdown
- [ ] **Q-003-1**: "ORM with Python and PostgreSQL combination?"
  **References**: Q-001 (Python), Q-002 (PostgreSQL)
```

### Key Principles

1. **No Question Limit**: Unlimited questions across unlimited derivation levels
2. **Checklist Format Only**: `[ ]` pending, `[x]` completed
3. **No Date Tracking**: Remove all timestamps
4. **Thread-Based**: Each initial question starts its own thread
5. **References Required**: Every derived question must show **References** field
6. **Hierarchical IDs**: Q-001 → Q-001-1 → Q-001-1-1
7. **Sequential IDs**: Each thread uses Q-XXX format

### Documentation Integration

All documentation files go under `.mattpocock/{task_name}/`.

After questions are answered:
1. Key decisions → `.mattpocock/{task_name}/design-doc.md`
2. New terminology → `.mattpocock/{task_name}/glossary.md`
3. Mark in thread: **Used in**: .mattpocock/{task_name}/design-doc.md "Section Name"