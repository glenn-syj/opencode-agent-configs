#!/bin/bash

# OpenCode Agent Config Changer
# Interactive script to view and modify agent configurations

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Default agents directory (will be set based on user selection)
AGENTS_DIR=""

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Global array for batch selection
declare -a SELECTED_AGENTS=()

# Function to get agent name from filename
get_agent_name() {
    basename "$1" .md
}

# Function to extract YAML frontmatter value
get_yaml_value() {
    local file="$1"
    local key="$2"
    
    # Extract value from frontmatter (between first --- markers)
    sed -n '/^---$/,/^---$/p' "$file" | grep "^${key}:" | head -1 | sed 's/^[^:]*: *//'
}

# Function to get description
get_description() {
    local file="$1"
    sed -n '/^---$/,/^---$/p' "$file" | grep "^description:" | head -1 | sed 's/^description: *//'
}

# Function to get mode
get_mode() {
    local file="$1"
    sed -n '/^---$/,/^---$/p' "$file" | grep "^mode:" | head -1 | sed 's/^mode: *//'
}

# Function to get model
get_model() {
    local file="$1"
    sed -n '/^---$/,/^---$/p' "$file" | grep "^model:" | head -1 | sed 's/^model: *//'
}

# Function to get temperature
get_temperature() {
    local file="$1"
    sed -n '/^---$/,/^---$/p' "$file" | grep "^temperature:" | head -1 | sed 's/^temperature: *//'
}

# Function to update model in YAML
update_model() {
    local agent_file="$1"
    local new_model="$2"
    
    sed -i "s|^model:.*|model: ${new_model}|" "$agent_file"
}

# Function to update temperature in YAML
update_temperature() {
    local agent_file="$1"
    local new_temp="$2"
    
    sed -i "s/^temperature:.*/temperature: ${new_temp}/" "$agent_file"
}

# Function to validate temperature
validate_temperature() {
    local temp="$1"
    
    if ! [[ "$temp" =~ ^[0-9]*\.?[0-9]+$ ]]; then
        return 1
    fi
    
    local temp_val
    temp_val=$(echo "$temp" | bc -l)
    
    local result
    result=$(echo "$temp_val >= 0.0 && $temp_val <= 2.0" | bc -l)
    
    [[ "$result" -eq 1 ]]
}

# Function to get all agents as sorted array
get_all_agents() {
    local agents=()
    for file in "$AGENTS_DIR"/*.md; do
        if [[ -f "$file" ]]; then
            agents+=("$(get_agent_name "$file")")
        fi
    done
    
    # Sort agents alphabetically
    IFS=$'\n' sorted_agents=($(sort <<<"${agents[*]}")); unset IFS
    echo "${sorted_agents[@]}"
}

# Function to display location selection menu
show_location_menu() {
    while true; do
        echo ""
        echo -e "${BLUE}=== OpenCode Agent Config Changer ===${NC}"
        echo ""
        echo "1. Project agents   (.opencode/agents/)"
        echo "2. Global agents   (~/.config/opencode/agent)"
        echo "3. Custom location (specify path)"
        echo "4. Quit"
        echo ""
        echo -e "${YELLOW}Select location [1-4]: ${NC}"
        read -r selection
        
        case "$selection" in
            1)
                select_project_agents
                ;;
            2)
                select_global_agents
                ;;
            3)
                select_custom_location
                ;;
            4)
                echo -e "${GREEN}Goodbye!${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}Invalid selection. Please enter a number between 1 and 4.${NC}"
                ;;
        esac
    done
}

# Function to select project agents directory
select_project_agents() {
    local project_dir=".opencode/agents"
    
    # Expand to absolute path
    if [[ -d "$project_dir" ]]; then
        AGENTS_DIR="$(cd "$project_dir" && pwd)"
        echo -e "${GREEN}Using project agents: $AGENTS_DIR${NC}"
        show_agent_selector
    else
        echo -e "${RED}Error: Project agents directory not found: $project_dir${NC}"
        echo -e "${YELLOW}This directory does not exist in the current location.${NC}"
        echo -e "${YELLOW}Please create the directory or select a different location.${NC}"
        return 1
    fi
}

# Function to select global agents directory
select_global_agents() {
    # Expand ~/ to home directory
    local global_dir="~/.config/opencode/agent"
    local expanded_dir
    
    # Expand the tilde
    expanded_dir="${global_dir/#\~/"$HOME"}"
    
    if [[ -d "$expanded_dir" ]]; then
        AGENTS_DIR="$expanded_dir"
        echo -e "${GREEN}Using global agents: $AGENTS_DIR${NC}"
        show_agent_selector
    else
        echo -e "${RED}Error: Global agents directory not found: $expanded_dir${NC}"
        echo -e "${YELLOW}This directory does not exist in your home directory.${NC}"
        echo -e "${YELLOW}Please create the directory or select a different location.${NC}"
        return 1
    fi
}

# Function to select custom location
select_custom_location() {
    echo ""
    echo -e "${YELLOW}Enter custom agent directory path:${NC}"
    echo -e "${YELLOW}(Use ~/ to refer to your home directory)${NC}"
    read -r custom_path
    
    if [[ -z "$custom_path" ]]; then
        echo -e "${RED}Error: No path entered.${NC}"
        return 1
    fi
    
    # Expand ~/ to home directory
    local expanded_path="${custom_path/#\~/"$HOME"}"
    
    # Validate directory exists
    if [[ ! -d "$expanded_path" ]]; then
        echo -e "${RED}Error: Directory does not exist: $expanded_path${NC}"
        echo -e "${YELLOW}Please enter a valid directory path.${NC}"
        return 1
    fi
    
    # Check if it's actually a directory
    if [[ ! -d "$expanded_path" ]]; then
        echo -e "${RED}Error: Path is not a directory: $expanded_path${NC}"
        return 1
    fi
    
    AGENTS_DIR="$expanded_path"
    echo -e "${GREEN}Using custom location: $AGENTS_DIR${NC}"
    show_agent_selector
}

# Function to display agent selector with checkboxes
show_agent_selector() {
    # Check if agents directory is set
    if [[ -z "$AGENTS_DIR" ]]; then
        echo -e "${RED}Error: No agents directory selected.${NC}"
        return 1
    fi
    
    # Check if directory exists
    if [[ ! -d "$AGENTS_DIR" ]]; then
        echo -e "${RED}Error: Agents directory not found: $AGENTS_DIR${NC}"
        return 1
    fi
    
    # Get list of agent files
    local agents=()
    for file in "$AGENTS_DIR"/*.md; do
        if [[ -f "$file" ]]; then
            agents+=("$(get_agent_name "$file")")
        fi
    done
    
    # Check if any agents found
    if [[ ${#agents[@]} -eq 0 ]]; then
        echo -e "${YELLOW}No agent configuration files found in this directory.${NC}"
        echo ""
        echo "Press Enter to return to location selection..."
        read -r
        return 1
    fi
    
    # Sort agents alphabetically
    IFS=$'\n' sorted_agents=($(sort <<<"${agents[*]}")); unset IFS
    agents=("${sorted_agents[@]}")
    
    # Reset selection - start with first two selected (engineer-be, engineer-fe pattern)
    SELECTED_AGENTS=()
    for agent in "${agents[@]}"; do
        if [[ "$agent" == "engineer-be" ]] || [[ "$agent" == "engineer-fe" ]]; then
            SELECTED_AGENTS+=("$agent")
        fi
    done
    # If no matching agents, start with empty selection
    if [[ ${#SELECTED_AGENTS[@]} -eq 0 ]]; then
        SELECTED_AGENTS=()
    fi
    
    while true; do
        echo ""
        echo -e "${BLUE}=== OpenCode Agent Config Changer ===${NC}"
        echo -e "${CYAN}Location: ${AGENTS_DIR}${NC}"
        echo ""
        echo -e "${YELLOW}Select agents:${NC}"
        echo ""
        
        # Display agents with checkboxes
        local count=1
        for agent in "${agents[@]}"; do
            local is_selected=false
            for sel in "${SELECTED_AGENTS[@]}"; do
                if [[ "$sel" == "$agent" ]]; then
                    is_selected=true
                    break
                fi
            done
            
            if [[ "$is_selected" == true ]]; then
                echo -e "  ${GREEN}[x]${NC} $count. $agent"
            else
                echo -e "  ${RED}[ ]${NC} $count. $agent"
            fi
            ((count++))
        done
        
        echo ""
        echo -e "${MAGENTA}Commands: a=all, n=none, d=done, q=quit${NC}"
        echo -e "${YELLOW}Select: ${NC}"
        read -r input
        
        # Handle commands
        case "$input" in
            a|all)
                SELECTED_AGENTS=()
                for agent in "${agents[@]}"; do
                    SELECTED_AGENTS+=("$agent")
                done
                ;;
            n|none)
                SELECTED_AGENTS=()
                ;;
            q|quit)
                echo -e "${GREEN}Goodbye!${NC}"
                exit 0
                ;;
            d|done)
                if [[ ${#SELECTED_AGENTS[@]} -eq 0 ]]; then
                    echo -e "${RED}No agents selected. Please select at least one agent.${NC}"
                    continue
                fi
                apply_changes "${agents[@]}"
                # After applying changes, re-show the selector
                ;;
            *)
                # Try to parse as selection
                if [[ -n "$input" ]]; then
                    local new_selection=()
                    local valid=true
                    
                    IFS=',' read -ra parts <<< "$input"
                    
                    for part in "${parts[@]}"; do
                        # Check for range (e.g., 1-3)
                        if [[ "$part" =~ ^([0-9]+)-([0-9]+)$ ]]; then
                            local start="${BASH_REMATCH[1]}"
                            local end="${BASH_REMATCH[2]}"
                            
                            if [[ "$start" -le "$end" ]] && [[ "$start" -ge 1 ]] && [[ "$end" -le ${#agents[@]} ]]; then
                                for ((i=start; i<=end; i++)); do
                                    new_selection+=("${agents[$((i-1))]}")
                                done
                            else
                                valid=false
                                break
                            fi
                        # Single number
                        elif [[ "$part" =~ ^[0-9]+$ ]]; then
                            local num="$part"
                            if [[ "$num" -ge 1 ]] && [[ "$num" -le ${#agents[@]} ]]; then
                                new_selection+=("${agents[$((num-1))]}")
                            else
                                valid=false
                                break
                            fi
                        else
                            valid=false
                            break
                        fi
                    done
                    
                    if [[ "$valid" == true ]] && [[ ${#new_selection[@]} -gt 0 ]]; then
                        SELECTED_AGENTS=("${new_selection[@]}")
                    else
                        echo -e "${RED}Invalid selection. Use numbers like: 1,3,5 or 1-3${NC}"
                    fi
                fi
                ;;
        esac
    done
}

# Function to apply changes to selected agents
apply_changes() {
    local -a agents=("$@")
    
    echo ""
    echo -e "Selected: $(IFS=,; echo "${SELECTED_AGENTS[*]}") (${#SELECTED_AGENTS[@]} agents)"
    echo ""
    echo -e "${YELLOW}Apply changes to ${#SELECTED_AGENTS[@]} agents:${NC}"
    echo ""
    
    # Ask for new model
    echo -e "${CYAN}Model [press Enter to skip]: ${NC}"
    read -r new_model
    
    # Ask for new temperature
    echo -e "${CYAN}Temperature [press Enter to skip]: ${NC}"
    read -r new_temp
    
    # Validate temperature if entered
    if [[ -n "$new_temp" ]]; then
        if ! validate_temperature "$new_temp"; then
            echo -e "${RED}Invalid temperature. Must be a number between 0.0 and 2.0${NC}"
            return 1
        fi
    fi
    
    # Check if anything will change
    if [[ -z "$new_model" ]] && [[ -z "$new_temp" ]]; then
        echo -e "${YELLOW}No changes specified. Returning to agent selection.${NC}"
        return
    fi
    
    # Apply changes to all selected agents
    local -a updated_agents=()
    local -a change_summaries=()
    
    for agent in "${SELECTED_AGENTS[@]}"; do
        local agent_file="$AGENTS_DIR/${agent}.md"
        
        if [[ -f "$agent_file" ]]; then
            local changes=()
            local summary_parts=()
            
            if [[ -n "$new_model" ]]; then
                update_model "$agent_file" "$new_model"
                changes+=("model=$new_model")
                summary_parts+=("model=$new_model")
            fi
            
            if [[ -n "$new_temp" ]]; then
                update_temperature "$agent_file" "$new_temp"
                changes+=("temp=$new_temp")
                summary_parts+=("temp=$new_temp")
            fi
            
            if [[ ${#changes[@]} -gt 0 ]]; then
                updated_agents+=("$agent")
                change_summaries+=("$(IFS=,; echo "${summary_parts[*]}")")
            fi
        fi
    done
    
    # Display summary
    echo ""
    if [[ ${#updated_agents[@]} -gt 0 ]]; then
        echo -e "${GREEN}Updated ${#updated_agents[@]} agents${NC}"
        
        local count=0
        for agent in "${updated_agents[@]}"; do
            echo -e "  - ${agent}: ${change_summaries[$count]}"
            ((count++))
        done
    else
        echo -e "${YELLOW}No changes were made.${NC}"
    fi
}

# Main function
main() {
    show_location_menu
}

# Run main function
main "$@"
