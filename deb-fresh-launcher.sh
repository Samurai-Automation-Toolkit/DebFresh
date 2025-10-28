#!/bin/bash

<<COMMENT
=====================================================================
           SYSTEM UPDATE & UPGRADE AUTOMATION SCRIPT
=====================================================================
Description: 
  - Updates package lists
  - Upgrades installed packages  
  - Performs distribution upgrade
  - Removes unnecessary packages
  - Cleans up repository cache and downloaded files

Features:
  - Color-coded output for better readability
  - Error handling and validation
  - Execution time tracking
  - Success/failure status reporting
  - Safe execution with user confirmation

Usage: ./UpDtUpGrd.sh
=====================================================================
COMMENT

# Color and Style Definitions
BOLD=$(tput bold)
GREEN=$(tput setaf 2)
RED=$(tput setaf 1)
BLUE=$(tput setaf 4)
CYAN=$(tput setaf 6)
MAGENTA=$(tput setaf 5)
RESET=$(tput sgr0)

# Function to print section headers
print_header() {
    echo " "
    echo "${MAGENTA}${BOLD}=====================================================================${RESET}"
    echo "${MAGENTA}${BOLD}  $1${RESET}"
    echo "${MAGENTA}${BOLD}=====================================================================${RESET}"
    echo " "
}

# Function to print status messages
print_status() {
    echo "${CYAN}${BOLD}[INFO]${RESET} $1"
}

print_success() {
    echo "${GREEN}${BOLD}[SUCCESS]${RESET} $1"
}

print_error() {
    echo "${RED}${BOLD}[ERROR]${RESET} $1"
}

# Function to confirm execution
confirm_execution() {
    print_header "SYSTEM UPDATE & UPGRADE AUTOMATION"
    echo "${CYAN}This script will perform the following operations:${RESET}"
    echo "  ${GREEN}✓${RESET} Update package lists"
    echo "  ${GREEN}✓${RESET} List upgradable packages" 
    echo "  ${GREEN}✓${RESET} Upgrade installed packages"
    echo "  ${GREEN}✓${RESET} Perform distribution upgrade"
    echo "  ${GREEN}✓${RESET} Remove unnecessary packages"
    echo "  ${GREEN}✓${RESET} Clean up repository cache"
    echo "  ${GREEN}✓${RESET} Clean up downloaded package files"
    echo " "
    
    read -p "${CYAN}Do you want to continue? (y/N): ${RESET}" -n 1 -r
    echo " "
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_status "Operation cancelled by user"
        exit 0
    fi
    echo " "
}

# Main update function
UpDtUpGrd() {
    local start_time=$(date +%s)
    
    # Command list with enhanced formatting
    local commands=(
        "sudo apt update -y:::Updating Package Lists"
        "echo '--- Upgradable Packages ---' && sudo apt list --upgradable:::Listing Upgradable Packages"
        "sudo apt upgrade -y:::Upgrading Installed Packages"
        "sudo apt dist-upgrade -y:::Performing Distribution Upgrade"
        "sudo apt autoremove --purge -y:::Removing Unnecessary Packages"
        "sudo apt autoclean -y:::Cleaning Local Repository Cache"
        "sudo apt clean -y:::Cleaning Downloaded Package Files"
    )

    local total_commands=${#commands[@]}
    local current_command=0
    local failed_commands=()

    print_header "STARTING SYSTEM UPDATE PROCESS"

    for item in "${commands[@]}"; do
        ((current_command++))
        
        # Split command and description
        IFS=":::" read -r COMMAND DESCRIPTION <<< "$item"
        
        # Print current operation
        echo "${BLUE}${BOLD}[$current_command/$total_commands]${RESET} ${BOLD}$DESCRIPTION${RESET}"
        echo "${CYAN}Command:${RESET} $COMMAND"
        echo " "
        
        # Execute command with error handling
        if eval "$COMMAND"; then
            print_success "$DESCRIPTION completed successfully"
        else
            print_error "$DESCRIPTION failed with exit code $?"
            failed_commands+=("$DESCRIPTION")
        fi
        
        echo " "
        echo "${MAGENTA}────────────────────────────────────────────────────────────────${RESET}"
        echo " "
    done

    # Calculate execution time
    local end_time=$(date +%s)
    local execution_time=$((end_time - start_time))
    
    # Print summary
    print_header "UPDATE PROCESS COMPLETED"
    
    echo "${BOLD}Execution Time:${RESET} ${execution_time} seconds"
    echo "${BOLD}Total Commands:${RESET} $total_commands"
    echo "${BOLD}Successful:${RESET} $(($total_commands - ${#failed_commands[@]}))"
    echo "${BOLD}Failed:${RESET} ${#failed_commands[@]}"
    echo " "
    
    if [ ${#failed_commands[@]} -eq 0 ]; then
        print_success "All operations completed successfully! 🎉"
    else
        print_error "Some operations failed. Check above for details."
    fi
    
    echo " "
    print_status "System update process finished at $(date)"
}

# Main execution flow
main() {
    # Check if running in interactive terminal
    if [[ -t 0 ]]; then
        confirm_execution
    else
        print_status "Running in non-interactive mode"
    fi
    
    # Execute main function
    UpDtUpGrd
}

# Execute main function
main "$@"