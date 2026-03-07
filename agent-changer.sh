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
NC='\033[0m' # No Color

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

# Function to get tools as formatted string
get_tools() {
    local file="$1"
    # Extract tools section and format as comma-separated list
    sed -n '/^---$/,/^---$/p' "$file" | sed -n '/^tools:/,/^[^ ]/p' | grep -E "^\s+[a-z]+:" | sed 's/.*^\([a-z]\+\).*/\1/' | tr '\n' ',' | sed 's/,$//'
}

# Function to display agent info
display_agent_info() {
    local agent_name="$1"
    local agent_file="$AGENTS_DIR/${agent_name}.md"
    
    if [[ ! -f "$agent_file" ]]; then
        echo -e "${RED}Error: Agent file not found: $agent_file${NC}"
        return 1
    fi
    
    local description mode model temperature tools
    
    description=$(get_description "$agent_file")
    mode=$(get_mode "$agent_file")
    model=$(get_model "$agent_file")
    temperature=$(get_temperature "$agent_file")
    tools=$(get_tools "$agent_file")
    
    echo ""
    echo -e "${CYAN}=== ${agent_name} ===${NC}"
    echo -e "Description: ${description}"
    echo -e "Mode: ${mode}"
    echo -e "Model: ${model}"
    echo -e "Temperature: ${temperature}"
    echo -e "Tools: ${tools}"
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

# Function to display location selection menu
show_location_menu() {
    while true; do
        echo ""
        echo -e "${BLUE}=== OpenCode Agent Config Changer ===${NC}"
        echo ""
        echo "1. Project agents   (.opencode/agents/)"
        echo "2. Global agents   (~/.opencode/agents/)"
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
        show_main_menu
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
    local global_dir="~/.opencode/agents"
    local expanded_dir
    
    # Expand the tilde
    expanded_dir="${global_dir/#\~/"$HOME"}"
    
    if [[ -d "$expanded_dir" ]]; then
        AGENTS_DIR="$expanded_dir"
        echo -e "${GREEN}Using global agents: $AGENTS_DIR${NC}"
        show_main_menu
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
    show_main_menu
}

# Function to display main menu
show_main_menu() {
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
    
    while true; do
        echo ""
        echo -e "${BLUE}=== OpenCode Agent Config Changer ===${NC}"
        echo -e "${CYAN}Location: ${AGENTS_DIR}${NC}"
        echo ""
        echo -e "${YELLOW}Available agents:${NC}"
        
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
        
        # Display numbered list
        local count=1
        for agent in "${sorted_agents[@]}"; do
            echo "  $count. $agent"
            ((count++))
        done
        
        echo ""
        echo -e "${YELLOW}Select agent [1-${#sorted_agents[@]}]: ${NC}"
        read -r selection
        
        # Validate selection
        if ! [[ "$selection" =~ ^[0-9]+$ ]] || [[ "$selection" -lt 1 ]] || [[ "$selection" -gt ${#sorted_agents[@]} ]]; then
            echo -e "${RED}Invalid selection. Please enter a number between 1 and ${#sorted_agents[@]}${NC}"
            continue
        fi
        
        local selected_agent="${sorted_agents[$((selection-1))]}"
        show_agent_menu "$selected_agent"
    done
}

# Function to display agent options menu
show_agent_menu() {
    local agent_name="$1"
    local agent_file="$AGENTS_DIR/${agent_name}.md"
    
    while true; do
        display_agent_info "$agent_name"
        
        echo ""
        echo -e "${YELLOW}Options:${NC}"
        echo "  1. Change model"
        echo "  2. Change temperature"
        echo "  3. Back to location selection"
        echo "  4. Quit"
        echo ""
        echo -e "${YELLOW}Select option: ${NC}"
        read -r option
        
        case "$option" in
            1)
                change_model "$agent_name"
                ;;
            2)
                change_temperature "$agent_name"
                ;;
            3)
                return 0
                ;;
            4)
                echo -e "${GREEN}Goodbye!${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}Invalid option. Please try again.${NC}"
                ;;
        esac
    done
}

# Function to change model
change_model() {
    local agent_name="$1"
    local agent_file="$AGENTS_DIR/${agent_name}.md"
    local current_model
    
    current_model=$(get_model "$agent_file")
    
    echo ""
    echo -e "${YELLOW}Current model: ${current_model}${NC}"
    echo -e "${YELLOW}Enter new model (or press Enter to cancel): ${NC}"
    read -r new_model
    
    if [[ -z "$new_model" ]]; then
        echo -e "${YELLOW}Cancelled.${NC}"
        return
    fi
    
    # Update the model
    update_model "$agent_file" "$new_model"
    echo -e "${GREEN}Model updated successfully!${NC}"
}

# Function to change temperature
change_temperature() {
    local agent_name="$1"
    local agent_file="$AGENTS_DIR/${agent_name}.md"
    local current_temp
    
    current_temp=$(get_temperature "$agent_file")
    
    echo ""
    echo -e "${YELLOW}Current temperature: ${current_temp}${NC}"
    echo -e "${YELLOW}Enter new temperature (0.0-2.0, or press Enter to cancel): ${NC}"
    read -r new_temp
    
    if [[ -z "$new_temp" ]]; then
        echo -e "${YELLOW}Cancelled.${NC}"
        return
    fi
    
    # Validate temperature
    if ! validate_temperature "$new_temp"; then
        echo -e "${RED}Invalid temperature. Must be a number between 0.0 and 2.0${NC}"
        return 1
    fi
    
    # Update the temperature
    update_temperature "$agent_file" "$new_temp"
    echo -e "${GREEN}Temperature updated successfully!${NC}"
}

# Main function
main() {
    show_location_menu
}

# Run main function
main "$@"
