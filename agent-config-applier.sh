#!/bin/bash
shopt -s globstar

# OpenCode Agent Config Applier
# Applies agent configurations from agent_sets to global/project/custom locations

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENT_SETS_DIR="$SCRIPT_DIR/agent_sets"
SKILLS_DIR="$SCRIPT_DIR/skills"

# Target directories (will be set based on user selection)
TARGET_AGENTS_DIR=""
TARGET_SKILLS_DIR=""

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Global array for selections
declare -a SELECTED_AGENTS=()
declare -a SELECTED_SKILLS=()

# Function to get agent name from filename
get_agent_name() {
    basename "$1" .md
}

# Function to get skill name from filename
get_skill_name() {
    local file="$1"
    local rel_path="${file#$SKILLS_DIR/}"
    local skill_name=$(dirname "$rel_path")
    echo "$skill_name"
}

# Function to get all available agent sets
get_agent_sets() {
    local sets=()
    if [[ -d "$AGENT_SETS_DIR" ]]; then
        for dir in "$AGENT_SETS_DIR"/*/; do
            if [[ -d "$dir" ]]; then
                sets+=("$(basename "$dir")")
            fi
        done
    fi
    echo "${sets[@]}"
}

# Function to get all skills
get_all_skills() {
    local skills=()
    if [[ -d "$SKILLS_DIR" ]]; then
        for file in "$SKILLS_DIR"/**/SKILL.md; do
            if [[ -f "$file" ]]; then
                skills+=("$(get_skill_name "$file")")
            fi
        done
    fi
    echo "${skills[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '
}

# Function to get agents in a set
get_agents_in_set() {
    local set_name="$1"
    local agents=()
    local set_dir="$AGENT_SETS_DIR/$set_name"
    
    if [[ -d "$set_dir" ]]; then
        for file in "$set_dir"/*.md; do
            if [[ -f "$file" ]]; then
                agents+=("$(get_agent_name "$file")")
            fi
        done
    fi
    echo "${agents[@]}"
}

# Function to display location selection menu
show_location_menu() {
    while true; do
        echo ""
        echo -e "${BLUE}=== OpenCode Agent Config Applier ===${NC}"
        echo ""
        echo "Select target location:"
        echo "1. Project     (.opencode/agents/ and .opencode/skills/)"
        echo "2. Global      (~/.config/opencode/agent and ~/.config/opencode/skills)"
        echo "3. Custom path (specify both agents and skills paths)"
        echo "4. Quit"
        echo ""
        echo -e "${YELLOW}Select [1-4]: ${NC}"
        read -r selection
        
        case "$selection" in
            1)
                select_project_location
                ;;
            2)
                select_global_location
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

# Function to select project location
select_project_location() {
    local agents_dir=".opencode/agents"
    local skills_dir=".opencode/skills"
    
    if [[ -d "$agents_dir" ]]; then
        TARGET_AGENTS_DIR="$(cd "$agents_dir" && pwd)"
    else
        echo -e "${YELLOW}Directory $agents_dir does not exist. Create it? [y/n]: ${NC}"
        read -r create_dir
        if [[ "$create_dir" == "y" ]]; then
            mkdir -p "$agents_dir" || { echo -e "${RED}Error: Failed to create directory${NC}"; return 1; }
            TARGET_AGENTS_DIR="$(cd "$agents_dir" && pwd)"
        else
            echo -e "${YELLOW}Returning to menu...${NC}"
            return 1
        fi
    fi
    
    if [[ -d "$skills_dir" ]]; then
        TARGET_SKILLS_DIR="$(cd "$skills_dir" && pwd)"
    else
        echo -e "${YELLOW}Directory $skills_dir does not exist. Create it? [y/n]: ${NC}"
        read -r create_dir
        if [[ "$create_dir" == "y" ]]; then
            mkdir -p "$skills_dir" || { echo -e "${RED}Error: Failed to create directory${NC}"; return 1; }
            TARGET_SKILLS_DIR="$(cd "$skills_dir" && pwd)"
        else
            echo -e "${YELLOW}Returning to menu...${NC}"
            return 1
        fi
    fi
    
    echo -e "${GREEN}Using project location:${NC}"
    echo "  Agents: $TARGET_AGENTS_DIR"
    echo "  Skills: $TARGET_SKILLS_DIR"
    show_agent_set_selector
}

# Function to select global location
select_global_location() {
    local agents_dir="~/.config/opencode/agent"
    local skills_dir="~/.config/opencode/skills"
    
    local expanded_agents="${agents_dir/#\~/"$HOME"}"
    local expanded_skills="${skills_dir/#\~/"$HOME"}"
    
    if [[ -d "$expanded_agents" ]]; then
        TARGET_AGENTS_DIR="$expanded_agents"
    else
        echo -e "${YELLOW}Directory $expanded_agents does not exist. Create it? [y/n]: ${NC}"
        read -r create_dir
        if [[ "$create_dir" == "y" ]]; then
            mkdir -p "$expanded_agents" || { echo -e "${RED}Error: Failed to create directory${NC}"; return 1; }
            TARGET_AGENTS_DIR="$expanded_agents"
        else
            echo -e "${YELLOW}Returning to menu...${NC}"
            return 1
        fi
    fi
    
    if [[ -d "$expanded_skills" ]]; then
        TARGET_SKILLS_DIR="$expanded_skills"
    else
        echo -e "${YELLOW}Directory $expanded_skills does not exist. Create it? [y/n]: ${NC}"
        read -r create_dir
        if [[ "$create_dir" == "y" ]]; then
            mkdir -p "$expanded_skills" || { echo -e "${RED}Error: Failed to create directory${NC}"; return 1; }
            TARGET_SKILLS_DIR="$expanded_skills"
        else
            echo -e "${YELLOW}Returning to menu...${NC}"
            return 1
        fi
    fi
    
    echo -e "${GREEN}Using global location:${NC}"
    echo "  Agents: $TARGET_AGENTS_DIR"
    echo "  Skills: $TARGET_SKILLS_DIR"
    show_agent_set_selector
}

# Function to select custom location
select_custom_location() {
    echo ""
    echo -e "${YELLOW}Enter custom agents directory path:${NC}"
    read -r custom_agents_path
    
    if [[ -z "$custom_agents_path" ]]; then
        echo -e "${RED}Error: No path entered.${NC}"
        return 1
    fi
    
    local expanded_agents="${custom_agents_path/#\~/"$HOME"}"
    
    if [[ ! -d "$expanded_agents" ]]; then
        echo -e "${YELLOW}Directory $expanded_agents does not exist. Create it? [y/n]: ${NC}"
        read -r create_dir
        if [[ "$create_dir" == "y" ]]; then
            mkdir -p "$expanded_agents" || { echo -e "${RED}Error: Failed to create directory${NC}"; return 1; }
        else
            echo -e "${YELLOW}Returning to menu...${NC}"
            return 1
        fi
    fi
    
    TARGET_AGENTS_DIR="$expanded_agents"
    
    echo ""
    echo -e "${YELLOW}Enter custom skills directory path:${NC}"
    read -r custom_skills_path
    
    if [[ -z "$custom_skills_path" ]]; then
        echo -e "${RED}Error: No path entered.${NC}"
        return 1
    fi
    
    local expanded_skills="${custom_skills_path/#\~/"$HOME"}"
    
    if [[ ! -d "$expanded_skills" ]]; then
        echo -e "${YELLOW}Directory $expanded_skills does not exist. Create it? [y/n]: ${NC}"
        read -r create_dir
        if [[ "$create_dir" == "y" ]]; then
            mkdir -p "$expanded_skills" || { echo -e "${RED}Error: Failed to create directory${NC}"; return 1; }
        else
            echo -e "${YELLOW}Returning to menu...${NC}"
            return 1
        fi
    fi
    
    TARGET_SKILLS_DIR="$expanded_skills"
    
    echo -e "${GREEN}Using custom location:${NC}"
    echo "  Agents: $TARGET_AGENTS_DIR"
    echo "  Skills: $TARGET_SKILLS_DIR"
    show_agent_set_selector
}

# Function to display agent set selector
show_agent_set_selector() {
    local agent_sets=($(get_agent_sets))
    
    if [[ ${#agent_sets[@]} -eq 0 ]]; then
        echo -e "${RED}No agent sets found in $AGENT_SETS_DIR${NC}"
        echo ""
        echo "Press Enter to return to location selection..."
        read -r
        show_location_menu
        return
    fi
    
    echo ""
    echo -e "${BLUE}=== Available Agent Sets ===${NC}"
    echo ""
    
    local count=1
    for set in "${agent_sets[@]}"; do
        local agent_count=$(get_agents_in_set "$set" | wc -w)
        echo -e "  ${CYAN}$count${NC}. $set ($agent_count agents)"
        ((count++))
    done
    
    echo ""
    echo -e "${YELLOW}Select agent set [1-${#agent_sets[@]}]: ${NC}"
    read -r selection
    
    if [[ -z "$selection" ]] || ! [[ "$selection" =~ ^[0-9]+$ ]]; then
        echo -e "${RED}Invalid selection.${NC}"
        show_agent_set_selector
        return
    fi
    
    if [[ "$selection" -lt 1 ]] || [[ "$selection" -gt ${#agent_sets[@]} ]]; then
        echo -e "${RED}Invalid selection.${NC}"
        show_agent_set_selector
        return
    fi
    
    local selected_set="${agent_sets[$((selection-1))]}"
    show_agent_selector "$selected_set"
}

# Function to display agent selector for a specific set
show_agent_selector() {
    local set_name="$1"
    local agents_dir="$AGENT_SETS_DIR/$set_name"
    local agents=($(get_agents_in_set "$set_name"))
    
    if [[ ${#agents[@]} -eq 0 ]]; then
        echo -e "${RED}No agents found in set: $set_name${NC}"
        show_agent_set_selector
        return
    fi
    
    IFS=$'\n' sorted_agents=($(sort <<<"${agents[*]}")); unset IFS
    agents=("${sorted_agents[@]}")
    
    SELECTED_AGENTS=()
    
    while true; do
        echo ""
        echo -e "${BLUE}=== Select Agents from: $set_name ===${NC}"
        echo ""
        echo -e "${YELLOW}Available agents:${NC}"
        echo ""
        
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
        echo -e "${MAGENTA}Commands: a=all, n=none, d=done, q=quit (or enter numbers)${NC}"
        echo -e "${YELLOW}Select: ${NC}"
        read -r input
        
        case "$input" in
            a|all)
                SELECTED_AGENTS=("${agents[@]}")
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
                show_skill_selector
                ;;
            *)
                if [[ -n "$input" ]]; then
                    local new_selection=()
                    local valid=true
                    
                    IFS=',' read -ra parts <<< "$input"
                    
                    for part in "${parts[@]}"; do
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

# Function to display skill selector
show_skill_selector() {
    local skills=($(get_all_skills))
    
    if [[ ${#skills[@]} -eq 0 ]]; then
        echo -e "${YELLOW}No skills found in $SKILLS_DIR${NC}"
        echo -e "${YELLOW}Proceeding without skills...${NC}"
        apply_config
        return
    fi
    
    SELECTED_SKILLS=()
    
    while true; do
        echo ""
        echo -e "${BLUE}=== Select Skills (Optional) ===${NC}"
        echo ""
        echo -e "${YELLOW}Available skills:${NC}"
        echo ""
        
        local count=1
        for skill in "${skills[@]}"; do
            local is_selected=false
            for sel in "${SELECTED_SKILLS[@]}"; do
                if [[ "$sel" == "$skill" ]]; then
                    is_selected=true
                    break
                fi
            done
            
            if [[ "$is_selected" == true ]]; then
                echo -e "  ${GREEN}[x]${NC} $count. $skill"
            else
                echo -e "  ${RED}[ ]${NC} $count. $skill"
            fi
            ((count++))
        done
        
        echo ""
        echo -e "${MAGENTA}Commands: a=all, n=none, s=skip/done, q=quit (or enter numbers)${NC}"
        echo -e "${YELLOW}Select: ${NC}"
        read -r input
        
        case "$input" in
            a|all)
                SELECTED_SKILLS=("${skills[@]}")
                ;;
            n|none)
                SELECTED_SKILLS=()
                ;;
            s|skip|done)
                ;;
            q|quit)
                echo -e "${GREEN}Goodbye!${NC}"
                exit 0
                ;;
            *)
                if [[ -n "$input" ]]; then
                    local new_selection=()
                    local valid=true
                    
                    IFS=',' read -ra parts <<< "$input"
                    
                    for part in "${parts[@]}"; do
                        if [[ "$part" =~ ^([0-9]+)-([0-9]+)$ ]]; then
                            local start="${BASH_REMATCH[1]}"
                            local end="${BASH_REMATCH[2]}"
                            
                            if [[ "$start" -le "$end" ]] && [[ "$start" -ge 1 ]] && [[ "$end" -le ${#skills[@]} ]]; then
                                for ((i=start; i<=end; i++)); do
                                    new_selection+=("${skills[$((i-1))]}")
                                done
                            else
                                valid=false
                                break
                            fi
                        elif [[ "$part" =~ ^[0-9]+$ ]]; then
                            local num="$part"
                            if [[ "$num" -ge 1 ]] && [[ "$num" -le ${#skills[@]} ]]; then
                                new_selection+=("${skills[$((num-1))]}")
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
                        SELECTED_SKILLS=("${new_selection[@]}")
                    else
                        echo -e "${RED}Invalid selection. Use numbers like: 1,3,5 or 1-3${NC}"
                    fi
                fi
                ;;
        esac
        
        if [[ "$input" == "s" ]] || [[ "$input" == "skip" ]] || [[ "$input" == "done" ]]; then
            break
        fi
    done
    
    apply_config
}

# Function to apply configuration
apply_config() {
    echo ""
    echo -e "${BLUE}=== Applying Configuration ===${NC}"
    echo ""
    echo "Target:"
    echo "  Agents: $TARGET_AGENTS_DIR"
    echo "  Skills: $TARGET_SKILLS_DIR"
    echo ""
    echo "Selected Agents (${#SELECTED_AGENTS[@]}):"
    for agent in "${SELECTED_AGENTS[@]}"; do
        echo "  - $agent"
    done
    echo ""
    echo "Selected Skills (${#SELECTED_SKILLS[@]}):"
    if [[ ${#SELECTED_SKILLS[@]} -gt 0 ]]; then
        for skill in "${SELECTED_SKILLS[@]}"; do
            echo "  - $skill"
        done
    else
        echo "  (none)"
    fi
    echo ""
    
    echo -e "${YELLOW}Proceed with applying config? [y/n]: ${NC}"
    read -r confirm
    
    if [[ "$confirm" != "y" ]]; then
        echo -e "${YELLOW}Cancelled.${NC}"
        show_location_menu
        return
    fi
    
    # Agents: Total replace (overwrite existing files)
    # Skills: Merge/add (keep existing files, add new ones, overwrite matching)
    # Copy agents
    for dir in "$AGENT_SETS_DIR"/*/; do
        if [[ -d "$dir" ]]; then
            for agent in "${SELECTED_AGENTS[@]}"; do
                if [[ -f "$dir/${agent}.md" ]]; then
                    cp "$dir/${agent}.md" "$TARGET_AGENTS_DIR/"
                    echo -e "${GREEN}Copied:${NC} $agent.md -> $TARGET_AGENTS_DIR/"
                fi
            done
        fi
    done
    
    # Copy skills
    for skill in "${SELECTED_SKILLS[@]}"; do
        local skill_src="$SKILLS_DIR/$skill"
        local skill_dest="$TARGET_SKILLS_DIR/$skill"
        
        if [[ -d "$skill_src" ]]; then
            mkdir -p "$skill_dest"
            cp -r "$skill_src/"* "$skill_dest/"
            echo -e "${GREEN}Copied:${NC} $skill -> $TARGET_SKILLS_DIR/"
        fi
    done
    
    echo ""
    echo -e "${GREEN}Configuration applied successfully!${NC}"
    echo ""
    echo -e "${CYAN}Applied to:${NC}"
    echo "  Agents: $TARGET_AGENTS_DIR"
    echo "  Skills: $TARGET_SKILLS_DIR"
    echo ""
    
    echo -e "${YELLOW}Apply another configuration? [y/n]: ${NC}"
    read -r again
    
    if [[ "$again" == "y" ]]; then
        show_location_menu
    else
        echo -e "${GREEN}Goodbye!${NC}"
        exit 0
    fi
}

# Main function
main() {
    if [[ ! -d "$AGENT_SETS_DIR" ]]; then
        echo -e "${RED}Error: agent_sets directory not found: $AGENT_SETS_DIR${NC}"
        exit 1
    fi
    
    if [[ ! -d "$SKILLS_DIR" ]]; then
        echo -e "${RED}Error: skills directory not found: $SKILLS_DIR${NC}"
        exit 1
    fi
    
    show_location_menu
}

main "$@"
