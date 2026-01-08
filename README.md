# OpenCode Agent Configuration System

This repository contains a comprehensive OpenCode agent configuration system designed for web development workflows with orchestrator-based coordination.

## Agent Architecture

### Primary Agent
- **[orchestrator.md](agents_web/orchestrator.md)** - Primary coordinator for workflow planning, task decomposition, and agent management

### Sub-agents
- **[librarian.md](agents_web/librarian.md)** - External codebase research specialist focused on GitHub research and implementation patterns
- **[architect.md](agents_web/architect.md)** - Integrated full-stack system designer for frontend, backend, and infrastructure architecture
- **[engineer-fe.md](agents_web/engineer-fe.md)** - Frontend implementation specialist with quick lookup and escalation capabilities
- **[engineer-be.md](agents_web/engineer-be.md)** - Backend implementation specialist with quick lookup and escalation capabilities  
- **[review.md](agents_web/review.md)** - Code quality assurance specialist for comprehensive code review and best practices verification

## Workflow System

### Sequential Phases
1. **Analysis & Research** - Requirements analysis and external research when needed
2. **Architecture Design** - Integrated full-stack system design and planning
3. **Implementation Planning** - Task breakdown and agent assignments
4. **Implementation Coordination** - Frontend and backend development with escalation support
5. **Code Review & Quality Assurance** - Systematic code quality assessment and feedback
6. **Integration & Validation** - Final integration testing and delivery

### Coordination Model
- **Top-Down Delegation**: Orchestrator delegates tasks to specialist agents
- **Escalation Flow**: Engineers can escalate to librarian for complex research needs
- **Quality Gates**: Review agent provides quality assurance before delivery
- **Central Coordination**: All frontend-backend communication through orchestrator

## Key Features

### Sequential Thinking
- Orchestrator uses structured, step-by-step planning approach
- Clear phase progression with defined deliverables
- Dependency management and workflow optimization
- Quality control at each phase transition

### Research Integration
- Quick lookup capabilities for routine documentation needs
- Escalation to librarian for complex research requirements
- Evidence-based research with GitHub permalinks
- Production pattern discovery and analysis

### Quality Assurance
- Systematic code review process integrated into workflow
- Security, performance, and maintainability analysis
- Constructive feedback without direct code modifications
- Best practices verification across the stack

### Cost Optimization
- Role-based model assignment for optimal performance vs. cost
- Temperature settings tuned to task requirements
- Tool restrictions minimize unnecessary operations
- Context consumption controls

## Usage Instructions

### Basic Setup
1. Copy the `agents_web/` directory to your OpenCode configuration location
2. Ensure OpenCode-compatible API access is configured with opencode/big-pickle model
3. Set up appropriate permissions and tool access according to agent specifications
4. Start OpenCode and select orchestrator as primary agent

### Workflow Usage
1. **Start with Requirements**: Provide your web development requirements to orchestrator
2. **Follow Phases**: Orchestrator will guide through sequential development phases
3. **Escalate as Needed**: Engineers will request librarian research when necessary
4. **Review Integration**: Review agent will analyze code quality before final delivery
5. **Final Delivery**: Complete, validated web application with quality assurance

### Agent Interaction
- **Orchestrator**: Use `Tab` to select as primary agent
- **Sub-agents**: Use `@agent-name` to mention specific agents
- **Direct Usage**: Agents can be invoked directly for specific tasks
- **Escalation**: Engineers can escalate to librarian via orchestrator for complex research needs

## Technology Stack

### Supported Frontend Technologies
- React, Vue.js, Angular, Svelte
- TypeScript, JavaScript, CSS-in-JS
- Next.js, Nuxt.js, Angular Universal
- Material-UI, Tailwind CSS, Styled Components

### Supported Backend Technologies  
- Node.js, Python, Go, Java, Rust
- Express.js, FastAPI, Django, Spring Boot
- REST APIs, GraphQL, WebSockets
- PostgreSQL, MongoDB, Redis, MySQL

### Infrastructure Support
- Docker, Kubernetes, CI/CD pipelines
- AWS, GCP, Azure cloud platforms
- Microservices architecture patterns
- Security and performance optimization

## Configuration Details

### Model Assignments
- **Orchestrator**: `opencode/big-pickle` - Balanced reasoning capabilities with temperature 0.2
- **Librarian**: `opencode/big-pickle` - Cost-effective research with temperature 0.1
- **Architect**: `opencode/big-pickle` - Comprehensive system design with temperature 0.3
- **Engineers**: `opencode/big-pickle` - Maximum implementation capability with temperature 0.4
- **Review**: `opencode/big-pickle` - Quality analysis focus with temperature 0.1

### Tool Permissions
- **Role-Based Access**: Each agent has appropriate tool permissions defined in YAML frontmatter
- **Security Controls**: Restricted bash commands with permission matrices (e.g., npm/yarn/pnpm for engineers, git/gh for librarian)
- **Escalation Management**: Controlled agent delegation via orchestrator
- **Quality Assurance**: Read-only access for review agent (no write/edit/bash permissions)

## Advanced Features

### Agent Interaction Protocols
- **Delegation Matrix**: Clear protocols for agent-to-agent communication
- **Escalation Workflows**: Structured processes for engineers → librarian escalation
- **Quality Gates**: Defined checkpoints at each phase transition
- **Coordination Patterns**: Standardized formats for task delegation and feedback

### Customization Options
- Agent prompts can be customized for specific domains
- Tool permissions adjustable per project requirements via YAML configuration
- Temperature settings configurable for agent behavior tuning
- Workflow phases adaptable to project methodologies

## Best Practices

### Effective Usage
1. **Clear Requirements**: Provide detailed, specific requirements to orchestrator
2. **Trust the Process**: Allow sequential phases to complete appropriately
3. **Quality Focus**: Implement review feedback before final delivery
4. **Documentation**: Maintain clear communication and decision records

### Performance Optimization
1. **Appropriate Escalation**: Engineers should attempt quick lookup before requesting librarian escalation
2. **Context Management**: Provide relevant background information to agents
3. **Parallel Execution**: Leverage agent specialization for efficiency (engineer-fe + engineer-be)
4. **Quality Gates**: Implement review feedback systematically through defined checkpoints

### Tool Usage Best Practices
1. **Permission Adherence**: Respect configured tool permissions (e.g., bash command restrictions)
2. **Escalation Protocols**: Follow proper escalation chains through orchestrator
3. **Research Efficiency**: Use librarian for complex GitHub/implementation research only
4. **Quality Integration**: Address review agent feedback before final deployment

## Troubleshooting

### Common Issues
- **Agent Not Available**: Verify agent files are in `agents_web/` directory
- **Permission Errors**: Check API access and tool permissions in agent YAML configs
- **Escalation Failures**: Ensure orchestrator permissions allow librarian delegation
- **Quality Issues**: Verify review agent has read-only access to analyze code
- **Tool Access**: Check bash permission matrices for command restrictions

### Support
- Check individual agent documentation in `agents_web/` for specific troubleshooting
- Review OpenCode configuration and API setup with opencode/big-pickle model
- Verify agent YAML frontmatter syntax and permission settings
- Ensure all required tools are enabled and permission matrices are correctly configured

## Contributing

This agent system is designed for web development workflows. Contributions and improvements are welcome for:
- Additional technology framework support
- Workflow optimization patterns
- Quality assurance enhancements
- Cost optimization strategies

## License

This configuration system is provided under the same license as the parent repository.