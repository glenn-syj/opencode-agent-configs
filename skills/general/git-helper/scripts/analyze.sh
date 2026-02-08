#!/bin/bash
# analyze.sh - Analyze changes
# Agent calls this to output git change information

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

show_help() {
    cat << EOF
Usage: $0 [OPTIONS]

Analyze staged git changes.

Options:
    --files      List of staged files
    --diff       Detailed diff
    --stats      Change statistics
    --help       Show this help message

Examples:
    $0 --files
    $0 --diff
    $0 --stats

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
        echo "Error: No staged files" >&2
        exit 1
    fi
}

main() {
    local mode="files"
    
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --files)
                mode="files"
                shift
                ;;
            --diff)
                mode="diff"
                shift
                ;;
            --stats)
                mode="stats"
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
    
    check_git
    check_staged
    
    case "$mode" in
        files)
            git diff --cached --name-only
            ;;
        diff)
            git diff --cached --unified=5
            ;;
        stats)
            git diff --cached --stat
            ;;
    esac
}

main "$@"
