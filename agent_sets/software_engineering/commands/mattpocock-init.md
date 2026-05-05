---
description: Initialize a new task with design and architecture
agent: designer
subtask: true
---

# MattPocock Init - Task Initialization

Initialize task **$ARGUMENTS** with design + architecture:

## Phase 1: Design
1. Use `mattpocock-grill` skill to interview user about the task
2. Create `.mattpocock/$ARGUMENTS/design-doc.md` with design decisions
3. Create `.mattpocock/$ARGUMENTS/glossary.md` with domain terminology

## Phase 2: Architecture
4. Read design-doc.md and glossary.md
5. Create `.mattpocock/$ARGUMENTS/interfaces.md` with module interface contracts
6. Create `.mattpocock/$ARGUMENTS/modules.md` with Deep Module architecture

After completion, ready for Coordinator to create worksheet.

Output location: `.mattpocock/$ARGUMENTS/`