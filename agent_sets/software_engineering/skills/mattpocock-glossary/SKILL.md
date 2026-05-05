---
name: mattpocock-glossary
description: Domain terminology and entity relationships. Use when establishing ubiquitous language with domain experts, defining business terms, or clarifying entity relationships.
---

# Matt Pocock Glossary Skill

Domain-Driven Context documentation based on Matt Pocock's principles.

## Usage
Load this skill when establishing ubiquitous language with domain experts.
```
skill: mattpocock-glossary
```

## When to Use

Create/update glossary when:
1. Initial project setup with domain expert
2. New term introduced during Q&A
3. Existing term clarified or disambiguated
4. Relationships between entities need clarification

## IMPORTANT: Domain Terms Only

This glossary is for **domain/business terminology** — terms that bridge human communication.

- ✅ **Domain terms**: Course, Section, Lesson, Publish, Ghost Entity
- ❌ **NOT technical terms**: API endpoint, database schema, function signature

Technical terms belong in:
- `interfaces.md` (architect)
- Code comments
- API documentation

This glossary establishes **ubiquitous language** between Dev and Domain Expert.

## Glossary Structure

### Language Section
Organize terms by category. Each term includes:
- **Term**: Canonical name (bold)
- **Definition**: Clear, unambiguous definition
- **Avoid**: Terms to avoid and why (prevents confusion)
- **Example**: Optional usage example

### Relationships Section
Define how entities relate to each other using bullet points:
- `A **Course** is either a **Ghost Course** or backed by a **CourseRepo**`
- `A **Course** contains one or more **CourseVersions**`

### Example Dialogue Section
Record key exchanges between Dev and Domain Expert:
```markdown
> **Dev:** "What is X?"
> **Domain expert:** "X is..."
```

### Flagged Ambiguities Section
Resolve ambiguous terms:
```markdown
- **"Term"** — Ambiguous usage explained. Now clearly distinguished as **ClearTerm**.
```

## Key Principles

1. **One canonical name per concept** - Avoid synonyms causing confusion
2. **"Avoid" is as important as definitions** - Prevents miscommunication
3. **Relationships define the domain model** - Not just individual terms
4. **Example dialogue captures context** - Shows terms in real usage
5. **Flagged ambiguities prevent future confusion** - Resolves confusion proactively

## Output Location
All glossary files saved to:
```
.mattpocock/{task_name}/glossary.md
```