#!/bin/bash
# template.sh - 커밋 컨벤션 및 예시 조회
# convention.yaml, examples.yaml 기반 출력

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DATA_DIR="$(dirname "$SCRIPT_DIR")/data"
CONVENTION_FILE="${DATA_DIR}/convention.yaml"
EXAMPLES_FILE="${DATA_DIR}/examples.yaml"

show_help() {
    cat << EOF
Usage: $0 [OPTIONS]

Query commit conventions and examples.

Options:
    --convention     Show format and rules from convention.yaml
    --allowed       Show allowed types from convention.yaml
    --examples      Show examples from examples.yaml
    --edit-examples Open examples.yaml for editing (agent parses and edits)
    --help          Show this help message

Examples:
    $0 --convention
    $0 --allowed
    $0 --examples
    $0 --edit-examples

EOF
}

has_python() {
    command -v python3 >/dev/null 2>&1
}

show_convention() {
    if [[ ! -f "$CONVENTION_FILE" ]]; then
        echo "Error: convention.yaml not found" >&2
        exit 1
    fi
    
    if has_python; then
        python3 -c "
import yaml
with open('$CONVENTION_FILE', 'r') as f:
    data = yaml.safe_load(f)
    
    print('Format:')
    print('  ' + data.get('format', '{type}: {description}'))
    print('')
    
    print('Rules:')
    rules = data.get('rules', {})
    for key, value in rules.items():
        print(f'  {key}: {value}')
"
    fi
}

show_allowed_types() {
    if [[ ! -f "$CONVENTION_FILE" ]]; then
        echo "Error: convention.yaml not found" >&2
        exit 1
    fi
    
    if has_python; then
        python3 -c "
import yaml
with open('$CONVENTION_FILE', 'r') as f:
    data = yaml.safe_load(f)
    
    types = data.get('allowed_types', [])
    print('Allowed Types:')
    for t in types:
        print(f'  - {t}')
"
    fi
}

show_examples() {
    if [[ ! -f "$EXAMPLES_FILE" ]]; then
        echo "Error: examples.yaml not found" >&2
        exit 1
    fi
    
    if has_python; then
        python3 -c "
import yaml
with open('$EXAMPLES_FILE', 'r') as f:
    data = yaml.safe_load(f)
    
    examples = data.get('examples', [])
    print('Examples:')
    for e in examples:
        print(f'  - {e}')
"
    fi
}

edit_examples() {
    if [[ ! -f "$EXAMPLES_FILE" ]]; then
        echo "Error: examples.yaml not found" >&2
        exit 1
    fi
    
    cat "$EXAMPLES_FILE"
    echo ""
    echo "Edit this file to update examples, then save."
}

main() {
    local cmd="examples"
    
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --convention)
                cmd="convention"
                shift
                ;;
            --allowed)
                cmd="allowed"
                shift
                ;;
            --examples)
                cmd="examples"
                shift
                ;;
            --edit-examples)
                cmd="edit-examples"
                shift
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            *)
                echo "Unknown option: $1" >&2
                show_help
                exit 1
                ;;
        esac
    done
    
    case "$cmd" in
        convention)
            show_convention
            ;;
        allowed)
            show_allowed_types
            ;;
        examples)
            show_examples
            ;;
        edit-examples)
            edit_examples
            ;;
    esac
}

main "$@"
