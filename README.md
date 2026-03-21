# opencode-agent-configs

Pre-configured agent sets and skills for opencode CLI tool.

## Quick Start

```bash
git clone <repo-url> opencode-agent-configs
cd opencode-agent-configs
./agent-config-applier.sh
```

## What's Included

| Item | Description |
|------|-------------|
| agent_sets/web | 7-agent package |
| skills/general | 3 skills |
| agent-config-applier.sh | Apply configs |
| agent-changer.sh | Modify configs |

## How to Use

### 1. Clone the repository
```bash
git clone <repo-url> opencode-agent-configs
cd opencode-agent-configs
```

### 2. Apply agents
```bash
bash ./agent-config-applier.sh
```
Follow the prompts:
- Select location (1=project, 2=global, 3=custom)
- Choose agent set (e.g., web)
- Select agents (numbers, a=all, d=done)
- Add skills (s=skip, numbers)

### 3. Modify (optional)
```bash
bash ./agent-changer.sh
```

This is used to change the model configs on your agents_set.

## Repository Structure

```
opencode-agent-configs/
├── agent-config-applier.sh
├── agent-changer.sh
├── agent-sets/
│   └── web/
│       └── agents.yaml
└── skills/
    └── general/
        ├── ask-user-question/
        ├── git-helper/
        └── markdown-structure-to-yaml/
```

## Usage

Run opencode in your project directory. The tool will prompt you for tasks, analyze code, suggest edits, and execute changes. Use standard tools (read, edit, bash, glob, grep) to interact with your codebase. The loaded skills provide specialized workflows for questions, git commits, and markdown analysis.

## License

MIT
