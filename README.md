# OpenCode Agent Configurations

A monorepo containing a collection of OpenCode agent configurations and reusable skills for various development workflows.

## Repository Structure

```
opencode-agent-configs/
├── README.md
├── LICENSE
├── .gitignore
├── agents_web/              # Agent package for web development workflows
└── skills/general/          # General-purpose skills
    ├── markdown-structure-to-yaml/
    ├── ask-user-question/
    └── git-helper/
```

## Overview

This repository provides a collection of agent configurations and skills for OpenCode, organized as packages:

- **Agent Packages** - Complete sets of coordinated agents for specific workflow types
- **Skill Packages** - Reusable capabilities available to any agent

## Agent Packages

### agents_web

A comprehensive multi-agent system designed for web development workflows with orchestrator-based coordination.

**Components:**
- **Orchestrator** - Primary coordinator for workflow planning, task decomposition, and agent management
- **Librarian** - External codebase research specialist for GitHub research and implementation patterns
- **Architect** - Full-stack system designer for frontend, backend, and infrastructure architecture
- **Engineer-FE** - Frontend implementation specialist
- **Engineer-BE** - Backend implementation specialist
- **Review** - Code quality assurance specialist
- **Skill-Builder** - OpenCode skill development specialist

## Skills

### General Skills

- **markdown-structure-to-yaml** - Extract markdown document structure as YAML metadata for token-efficient analysis
- **ask-user-question** - Ask users questions via the UI for clarification and preferences
- **git-helper** - Git commit message assistance with YAML-based flexible commit format

## Workflow System

### Sequential Phases

1. **Analysis & Research** - Requirements analysis and external research when needed
2. **Architecture Design** - Integrated full-stack system design and planning
3. **Implementation Planning** - Task breakdown and agent assignments
4. **Implementation Coordination** - Frontend and backend development with escalation support
5. **Code Review & Quality Assurance** - Systematic code quality assessment and feedback
6. **Integration & Validation** - Final integration testing and delivery

### Coordination Model

- **Top-Down Delegation**: Primary agent delegates tasks to specialist agents
- **Escalation Flow**: Specialists escalate to research agents for complex needs
- **Quality Gates**: Review agents provide quality assurance before delivery
- **Central Coordination**: All agent-to-agent communication through coordinator

## Key Features

### Sequential Thinking
- Structured, step-by-step planning approach
- Clear phase progression with defined deliverables
- Quality control at each phase transition

### Research Integration
- Research specialists for complex requirements
- Evidence-based research with GitHub references
- Production pattern discovery

### Quality Assurance
- Systematic code review process integrated into workflow
- Security, performance, and maintainability analysis
- Constructive feedback without direct code modifications
- Best practices verification across the stack

### Cost Optimization
- Role-based model assignment for performance vs. cost balance
- Temperature settings configured per task type
- Tool restrictions to minimize unnecessary operations
- Context consumption controls

## Usage Instructions

### Basic Setup

1. Copy the desired agent package directory (e.g., `agents_web/`) to your OpenCode configuration location
2. Ensure OpenCode-compatible API access is configured
3. Set up appropriate permissions and tool access according to agent specifications
4. Start OpenCode and select the primary agent for your workflow

### Agent Interaction

- **Primary Agent**: Use `Tab` to select as primary agent
- **Sub-agents**: Use `@agent-name` to mention specific agents
- **Direct Usage**: Agents invoked directly for specific tasks
- **Escalation**: Specialists escalate to other agents via the coordinator

## Configuration Details

### Model Assignments

Each agent is configured with specific model settings:
- Temperature set per task type
- Tool permissions defined in YAML frontmatter
- Role-based access controls

### Tool Permissions

- **Role-Based Access**: Each agent has appropriate tool permissions defined in YAML frontmatter
- **Security Controls**: Restricted bash commands with permission matrices
- **Escalation Management**: Controlled agent delegation via coordinator

## Customization Options

- Agent prompts can be customized for specific domains
- Tool permissions configurable per project requirements via YAML
- Temperature settings adjustable
- Workflow phases configurable

## Best Practices

### Effective Usage
1. **Clear Requirements**: Provide detailed, specific requirements to the coordinator
2. **Trust the Process**: Allow sequential phases to complete appropriately
3. **Quality Focus**: Implement review feedback before final delivery
4. **Documentation**: Maintain clear communication and decision records

### Performance Optimization
1. **Appropriate Escalation**: Use quick lookup before requesting escalation
2. **Context Management**: Provide relevant background information to agents
3. **Parallel Execution**: Leverage agent specialization for efficiency
4. **Quality Gates**: Implement review feedback systematically

## Troubleshooting

### Common Issues
- **Agent Not Available**: Verify agent files are in the correct package directory
- **Permission Errors**: Check API access and tool permissions in agent YAML configs
- **Escalation Failures**: Ensure coordinator permissions allow proper delegation
- **Tool Access**: Check bash permission matrices for command restrictions

### Support
- Review individual agent documentation in the package directories
- Verify OpenCode configuration and API setup
- Ensure agent YAML frontmatter syntax and permission settings are correct

## License

This configuration system is provided under the same license as the parent repository.
