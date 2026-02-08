#!/bin/bash
# commit.sh - Git 커밋 실행
# convention.yaml 기반 형식 검증 후 커밋 수행

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DATA_DIR="$(dirname "$SCRIPT_DIR")/data"
CACHE_SCRIPT="${SCRIPT_DIR}/cache.sh"
CONVENTION_FILE="${DATA_DIR}/convention.yaml"

show_help() {
    cat << EOF
Usage: $0 [OPTIONS] "COMMIT MESSAGE"

Execute, validate, or preview git commit.

Arguments:
    COMMIT_MESSAGE    The commit message (required)

Options:
    --help, -h       Show this help message
    --dry-run        Show what would be committed without committing
    --validate       Validate commit message format against convention.yaml
    --clear-cache    Clear YAML parsing cache

Examples:
    $0 "fix: resolve database connection timeout"
    $0 --dry-run "feat: add user authentication"
    $0 --validate "chore: update dependencies"
    $0 --clear-cache

EOF
}

check_git() {
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo "Error: Not a git repository" >&2
        exit 1
    fi
}

check_staged() {
    if ! git diff --cached --quiet 2>/dev/null; then
        return 0
    else
        echo "Error: No staged files found" >&2
        exit 1
    fi
}

has_python() {
    command -v python3 >/dev/null 2>&1
}

has_cache() {
    [[ -x "$CACHE_SCRIPT" ]]
}

get_format() {
    if has_cache; then
        local cached_data
        cached_data=$("$CACHE_SCRIPT" get_cached_data "$CONVENTION_FILE" 2>/dev/null)
        if [[ -n "$cached_data" ]]; then
            python3 -c "
import json
import sys

data = json.load(sys.stdin)
print(data.get('format', '{type}: {description}'))
" <<< "$cached_data"
            return
        fi
    fi
    
    python3 -c "
import yaml
with open('$CONVENTION_FILE', 'r') as f:
    data = yaml.safe_load(f)
    print(data.get('format', '{type}: {description}'))
" 2>/dev/null || echo "{type}: {description}"
}

get_allowed_types() {
    if has_cache; then
        local cached_data
        cached_data=$("$CACHE_SCRIPT" get_cached_data "$CONVENTION_FILE" 2>/dev/null)
        if [[ -n "$cached_data" ]]; then
            python3 -c "
import json
import sys

data = json.load(sys.stdin)
types = data.get('allowed_types', [])
print(' '.join(sorted(types)))
" <<< "$cached_data"
            return
        fi
    fi
    
    python3 -c "
import yaml
with open('$CONVENTION_FILE', 'r') as f:
    data = yaml.safe_load(f)
    types = data.get('allowed_types', [])
    print(' '.join(sorted(types)))
" 2>/dev/null || echo ""
}

validate_message() {
    local message="$1"
    local format types
    
    format=$(get_format)
    types=$(get_allowed_types)
    
    if [[ -z "$types" ]]; then
        echo "Error: Cannot read allowed_types from convention.yaml" >&2
        exit 1
    fi
    
    if [[ ! "$message" =~ ":" ]]; then
        echo "Invalid: Message must match format: $format" >&2
        echo "Example: fix: resolve bug" >&2
        exit 1
    fi
    
    local type
    type=$(echo "$message" | cut -d':' -f1 | tr -d ' ')
    
    if ! echo "$types" | grep -qw "$type"; then
        echo "Warning: Type '$type' not in allowed_types (reference only)" >&2
    fi
    
    local description
    description=$(echo "$message" | cut -d':' -f2- | sed 's/^ *//')
    
    if [[ -z "$description" ]]; then
        echo "Invalid: Description required after ':'" >&2
        exit 1
    fi
    
    echo "Valid: $message"
}

show_files() {
    echo "Staged files:"
    git diff --cached --name-only | while read -r file; do
        echo "  - $file"
    done
}

dry_run() {
    local message="$1"
    check_git
    check_staged
    
    echo "[DRY RUN] Commit message:"
    echo "  $message"
    echo ""
    show_files
}

do_commit() {
    local message="$1"
    check_git
    check_staged
    
    echo "Committing with message:"
    echo "  $message"
    echo ""
    show_files
    echo ""
    
    if git commit -m "$message"; then
        echo "Commit completed successfully!"
    else
        echo "Error: Git commit failed" >&2
        exit 1
    fi
}

main() {
    local mode="commit"
    local message=""
    
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --help|-h)
                show_help
                exit 0
                ;;
            --dry-run)
                mode="dry-run"
                shift
                ;;
            --validate)
                mode="validate"
                shift
                ;;
            --clear-cache)
                if has_cache; then
                    "$CACHE_SCRIPT" --clear
                else
                    echo "Cache script not found or not executable"
                fi
                exit 0
                ;;
            -*)
                echo "Unknown option: $1" >&2
                show_help
                exit 1
                ;;
            *)
                message="$1"
                shift
                ;;
        esac
    done
    
    if [[ -z "$message" ]]; then
        echo "Error: Commit message required" >&2
        show_help
        exit 1
    fi
    
    case "$mode" in
        validate)
            validate_message "$message"
            ;;
        dry-run)
            dry_run "$message"
            ;;
        commit)
            do_commit "$message"
            ;;
    esac
}

main "$@"
