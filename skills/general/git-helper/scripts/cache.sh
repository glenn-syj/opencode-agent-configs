#!/bin/bash
# cache.sh - Cache management utility
# Cache YAML parsed data to improve performance

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DATA_DIR="$(dirname "$SCRIPT_DIR")/data"
CACHE_DIR="${DATA_DIR}/.cache"

show_help() {
    cat << EOF
Usage: $0 [OPTIONS]

Manage YAML parsing cache for git-helper.

Options:
    --clear         Clear all cache files
    --status        Show cache status and statistics
    --validate      Validate cache is up-to-date
    --help          Show this help message

Examples:
    $0 --clear
    $0 --status
    $0 --validate

EOF
}

ensure_cache_dir() {
    if [[ ! -d "$CACHE_DIR" ]]; then
        mkdir -p "$CACHE_DIR"
    fi
}

get_mtime() {
    local file="$1"
    if [[ -f "$file" ]]; then
        stat -c %Y "$file" 2>/dev/null || stat -f %m "$file" 2>/dev/null
    else
        echo "0"
    fi
}

is_cache_valid() {
    local source_file="$1"
    local cache_file="$2"
    
    if [[ ! -f "$cache_file" ]]; then
        echo "false"
        return
    fi
    
    local source_mtime cache_mtime
    source_mtime=$(get_mtime "$source_file")
    cache_mtime=$(get_mtime "$cache_file")
    
    if [[ "$source_mtime" -gt "$cache_mtime" ]]; then
        echo "false"
    else
        echo "true"
    fi
}

clear_cache() {
    ensure_cache_dir
    
    if [[ -d "$CACHE_DIR" ]]; then
        rm -rf "${CACHE_DIR}"/*
        echo "Cache cleared successfully"
    else
        echo "Cache directory does not exist"
    fi
}

show_status() {
    ensure_cache_dir
    
    echo "Cache Directory: $CACHE_DIR"
    echo ""
    
    if [[ -z "$(ls -A "$CACHE_DIR" 2>/dev/null)" ]]; then
        echo "No cache files found"
        return
    fi
    
    echo "Cached Files:"
    local total_size=0
    local count=0
    
    for cache_file in "$CACHE_DIR"/*; do
        if [[ -f "$cache_file" ]]; then
            local filename=$(basename "$cache_file")
            local size=$(wc -c < "$cache_file" 2>/dev/null || echo 0)
            total_size=$((total_size + size))
            count=$((count + 1))
            echo "  - $filename ($(($size / 1024))KB)"
        fi
    done
    
    echo ""
    echo "Total: $count files, $(($total_size / 1024))KB"
}

validate_cache() {
    local source_dir="${DATA_DIR}"
    local cache_dir="${CACHE_DIR}"
    local valid=true
    
    echo "Validating cache..."
    echo ""
    
    for source_file in "${source_dir}"/*.yaml; do
        if [[ -f "$source_file" ]]; then
            local filename=$(basename "$source_file" .yaml)
            local cache_file="${cache_dir}/${filename}.json"
            
            if [[ "false" == "$(is_cache_valid "$source_file" "$cache_file")" ]]; then
                echo "  ⚠ Stale: $filename.yaml"
                valid=false
            else
                echo "  ✓ Valid: $filename.yaml"
            fi
        fi
    done
    
    echo ""
    if [[ "$valid" == "true" ]]; then
        echo "All caches are valid"
    else
        echo "Some caches are stale. Run '$0 --clear' to refresh."
    fi
}

parse_yaml_to_json() {
    local yaml_file="$1"
    local json_file="$2"
    
    if ! has_python; then
        return 1
    fi
    
    python3 -c "
import yaml
import json
import sys

with open('$yaml_file', 'r') as f:
    data = yaml.safe_load(f)

with open('$json_file', 'w') as f:
    json.dump(data, f, indent=2)
"
}

ensure_cache_for_file() {
    local yaml_file="$1"
    local json_file="${CACHE_DIR}/$(basename "$yaml_file" .yaml).json"
    
    if [[ "false" == "$(is_cache_valid "$yaml_file" "$json_file")" ]]; then
        parse_yaml_to_json "$yaml_file" "$json_file"
    fi
    
    echo "$json_file"
}

get_cached_data() {
    local yaml_file="$1"
    local json_file
    
    json_file=$(ensure_cache_for_file "$yaml_file")
    
    cat "$json_file"
}

has_python() {
    command -v python3 >/dev/null 2>&1
}

main() {
    local cmd="status"
    
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --clear)
                cmd="clear"
                shift
                ;;
            --status)
                cmd="status"
                shift
                ;;
            --validate)
                cmd="validate"
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
        clear)
            clear_cache
            ;;
        status)
            show_status
            ;;
        validate)
            validate_cache
            ;;
    esac
}

main "$@"
