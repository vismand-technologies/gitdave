#!/bin/bash

# GitHub Profile Manager for Windsurf IDE
# Automates the setup of multiple GitHub profiles with SSH keys, Git config, and GitHub CLI

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PROFILES_DIR="$HOME/.github-profiles"
SSH_DIR="$HOME/.ssh"
GITCONFIG_FILE="$HOME/.gitconfig"

# Create profiles directory if it doesn't exist
mkdir -p "$PROFILES_DIR"

print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}  GitHub Profile Manager${NC}"
    echo -e "${BLUE}================================${NC}"
    echo
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

# Function to validate email format
validate_email() {
    local email=$1
    if [[ $email =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
        return 0
    else
        return 1
    fi
}

# Function to generate SSH key for a profile
generate_ssh_key() {
    local profile_name=$1
    local email=$2
    local ssh_key_path="$SSH_DIR/id_ed25519_$profile_name"
    
    if [[ -f "$ssh_key_path" ]]; then
        print_warning "SSH key for profile '$profile_name' already exists"
        read -p "Do you want to overwrite it? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            return 0
        fi
    fi
    
    print_info "Generating SSH key for profile: $profile_name"
    ssh-keygen -t ed25519 -C "$email" -f "$ssh_key_path" -N ""
    
    # Start ssh-agent and add key
    eval "$(ssh-agent -s)" > /dev/null 2>&1
    ssh-add "$ssh_key_path" > /dev/null 2>&1
    
    print_success "SSH key generated: $ssh_key_path"
    
    # Display public key for GitHub
    echo
    print_info "Add this public key to your GitHub account:"
    echo -e "${YELLOW}$(cat ${ssh_key_path}.pub)${NC}"
    echo
    read -p "Press Enter after adding the key to GitHub..."
}

# Function to update SSH config
update_ssh_config() {
    local profile_name=$1
    local ssh_config="$SSH_DIR/config"
    local host_alias="github-$profile_name"
    
    # Create SSH config if it doesn't exist
    touch "$ssh_config"
    
    # Check if this profile already exists in SSH config
    if grep -q "Host $host_alias" "$ssh_config"; then
        print_warning "SSH config for profile '$profile_name' already exists"
        return 0
    fi
    
    # Add SSH config entry
    cat >> "$ssh_config" << EOF

# GitHub Profile: $profile_name
Host $host_alias
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_$profile_name
    IdentitiesOnly yes
EOF
    
    print_success "SSH config updated for profile: $profile_name"
}

# Function to create Git config for profile
create_git_config() {
    local profile_name=$1
    local name=$2
    local email=$3
    local work_dir=$4
    local config_file="$PROFILES_DIR/gitconfig-$profile_name"
    
    # Create profile-specific Git config
    cat > "$config_file" << EOF
[user]
    name = $name
    email = $email

[core]
    sshCommand = ssh -i ~/.ssh/id_ed25519_$profile_name

[url "git@github-$profile_name:"]
    insteadOf = https://github.com/
EOF
    
    print_success "Git config created: $config_file"
    
    # Update main .gitconfig with conditional include
    update_main_gitconfig "$profile_name" "$work_dir"
}

# Function to update main .gitconfig
update_main_gitconfig() {
    local profile_name=$1
    local work_dir=$2
    
    # Backup existing .gitconfig
    if [[ -f "$GITCONFIG_FILE" ]]; then
        cp "$GITCONFIG_FILE" "$GITCONFIG_FILE.backup.$(date +%Y%m%d_%H%M%S)"
    fi
    
    # Check if conditional include already exists
    if grep -q "gitdir:$work_dir" "$GITCONFIG_FILE" 2>/dev/null; then
        print_warning "Git config conditional include for '$work_dir' already exists"
        return 0
    fi
    
    # Add conditional include to main .gitconfig
    cat >> "$GITCONFIG_FILE" << EOF

[includeIf "gitdir:$work_dir"]
    path = ~/.github-profiles/gitconfig-$profile_name
EOF
    
    print_success "Main .gitconfig updated with conditional include"
}

# Function to authenticate with GitHub CLI
setup_github_cli() {
    local profile_name=$1
    local username=$2
    
    print_info "Setting up GitHub CLI for profile: $profile_name"
    
    # Check if gh is installed
    if ! command -v gh &> /dev/null; then
        print_error "GitHub CLI (gh) is not installed. Please install it first:"
        echo "  Ubuntu/Debian: sudo apt install gh"
        echo "  macOS: brew install gh"
        echo "  Or visit: https://cli.github.com/"
        return 1
    fi
    
    print_info "Please authenticate with GitHub CLI for profile: $profile_name"
    print_info "Use the SSH key we just created when prompted"
    
    # Authenticate with GitHub CLI
    gh auth login --hostname github.com --git-protocol ssh --web
    
    # Store the authentication info
    echo "$username" > "$PROFILES_DIR/gh-user-$profile_name"
    
    print_success "GitHub CLI authenticated for profile: $profile_name"
}

# Function to create profile directory structure
create_profile_directory() {
    local profile_name=$1
    local work_dir=$2
    
    if [[ ! -d "$work_dir" ]]; then
        mkdir -p "$work_dir"
        print_success "Created directory: $work_dir"
    else
        print_warning "Directory already exists: $work_dir"
    fi
}

# Function to save profile metadata
save_profile_metadata() {
    local profile_name=$1
    local name=$2
    local email=$3
    local username=$4
    local work_dir=$5
    
    cat > "$PROFILES_DIR/profile-$profile_name.json" << EOF
{
    "profile_name": "$profile_name",
    "name": "$name",
    "email": "$email",
    "github_username": "$username",
    "work_directory": "$work_dir",
    "ssh_key": "~/.ssh/id_ed25519_$profile_name",
    "git_config": "~/.github-profiles/gitconfig-$profile_name",
    "created_at": "$(date -Iseconds)"
}
EOF
    
    print_success "Profile metadata saved"
}

# Function to create a new profile
create_profile() {
    print_header
    echo "Creating a new GitHub profile..."
    echo
    
    # Get profile information
    read -p "Profile name (e.g., personal, work): " profile_name
    if [[ -z "$profile_name" ]]; then
        print_error "Profile name cannot be empty"
        exit 1
    fi
    
    read -p "Your full name: " name
    if [[ -z "$name" ]]; then
        print_error "Name cannot be empty"
        exit 1
    fi
    
    read -p "Email address: " email
    if [[ -z "$email" ]] || ! validate_email "$email"; then
        print_error "Invalid email address"
        exit 1
    fi
    
    read -p "GitHub username: " username
    if [[ -z "$username" ]]; then
        print_error "GitHub username cannot be empty"
        exit 1
    fi
    
    read -p "Work directory (e.g., ~/work, ~/personal): " work_dir
    work_dir="${work_dir/#\~/$HOME}"  # Expand ~ to home directory
    if [[ -z "$work_dir" ]]; then
        print_error "Work directory cannot be empty"
        exit 1
    fi
    
    echo
    print_info "Creating profile with the following information:"
    echo "  Profile: $profile_name"
    echo "  Name: $name"
    echo "  Email: $email"
    echo "  GitHub Username: $username"
    echo "  Work Directory: $work_dir"
    echo
    
    read -p "Continue? (Y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Nn]$ ]]; then
        print_info "Profile creation cancelled"
        exit 0
    fi
    
    # Create the profile
    echo
    print_info "Setting up profile: $profile_name"
    
    generate_ssh_key "$profile_name" "$email"
    update_ssh_config "$profile_name"
    create_profile_directory "$profile_name" "$work_dir"
    create_git_config "$profile_name" "$name" "$email" "$work_dir"
    setup_github_cli "$profile_name" "$username"
    save_profile_metadata "$profile_name" "$name" "$email" "$username" "$work_dir"
    
    echo
    print_success "Profile '$profile_name' created successfully!"
    echo
    print_info "To use this profile:"
    echo "  1. Clone repositories to: $work_dir"
    echo "  2. Use SSH URL format: git@github-$profile_name:username/repo.git"
    echo "  3. Or use the switch-profile command to activate it"
}

# Function to list existing profiles
list_profiles() {
    print_header
    echo "Existing GitHub profiles:"
    echo
    
    if [[ ! -d "$PROFILES_DIR" ]] || [[ -z "$(ls -A "$PROFILES_DIR"/profile-*.json 2>/dev/null)" ]]; then
        print_warning "No profiles found"
        return 0
    fi
    
    for profile_file in "$PROFILES_DIR"/profile-*.json; do
        if [[ -f "$profile_file" ]]; then
            local profile_name=$(basename "$profile_file" .json | sed 's/profile-//')
            local name=$(grep '"name"' "$profile_file" | cut -d'"' -f4)
            local email=$(grep '"email"' "$profile_file" | cut -d'"' -f4)
            local work_dir=$(grep '"work_directory"' "$profile_file" | cut -d'"' -f4)
            
            echo -e "${GREEN}Profile: $profile_name${NC}"
            echo "  Name: $name"
            echo "  Email: $email"
            echo "  Directory: $work_dir"
            echo
        fi
    done
}

# Function to switch between profiles (for current session)
switch_profile() {
    local profile_name=$1
    
    if [[ -z "$profile_name" ]]; then
        echo "Available profiles:"
        for profile_file in "$PROFILES_DIR"/profile-*.json; do
            if [[ -f "$profile_file" ]]; then
                local pname=$(basename "$profile_file" .json | sed 's/profile-//')
                echo "  - $pname"
            fi
        done
        echo
        read -p "Enter profile name to switch to: " profile_name
    fi
    
    local profile_file="$PROFILES_DIR/profile-$profile_name.json"
    if [[ ! -f "$profile_file" ]]; then
        print_error "Profile '$profile_name' not found"
        exit 1
    fi
    
    # Load profile information
    local name=$(grep '"name"' "$profile_file" | cut -d'"' -f4)
    local email=$(grep '"email"' "$profile_file" | cut -d'"' -f4)
    local username=$(grep '"github_username"' "$profile_file" | cut -d'"' -f4)
    
    # Set environment variables for current session
    export GIT_AUTHOR_NAME="$name"
    export GIT_AUTHOR_EMAIL="$email"
    export GIT_COMMITTER_NAME="$name"
    export GIT_COMMITTER_EMAIL="$email"
    export GITHUB_USER="$username"
    
    # Switch GitHub CLI context if available
    if command -v gh &> /dev/null; then
        gh auth switch --hostname github.com --user "$username" 2>/dev/null || true
    fi
    
    print_success "Switched to profile: $profile_name ($name)"
    print_info "Environment variables set for current session"
}

# Function to delete a profile
delete_profile() {
    local profile_name=$1
    
    if [[ -z "$profile_name" ]]; then
        list_profiles
        read -p "Enter profile name to delete: " profile_name
    fi
    
    local profile_file="$PROFILES_DIR/profile-$profile_name.json"
    if [[ ! -f "$profile_file" ]]; then
        print_error "Profile '$profile_name' not found"
        exit 1
    fi
    
    echo
    print_warning "This will delete profile '$profile_name' and all associated configurations"
    read -p "Are you sure? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Profile deletion cancelled"
        exit 0
    fi
    
    # Remove SSH key
    rm -f "$SSH_DIR/id_ed25519_$profile_name"
    rm -f "$SSH_DIR/id_ed25519_$profile_name.pub"
    
    # Remove SSH config entry
    sed -i "/# GitHub Profile: $profile_name/,/^$/d" "$SSH_DIR/config" 2>/dev/null || true
    
    # Remove Git config
    rm -f "$PROFILES_DIR/gitconfig-$profile_name"
    
    # Remove profile metadata
    rm -f "$profile_file"
    rm -f "$PROFILES_DIR/gh-user-$profile_name"
    
    print_success "Profile '$profile_name' deleted successfully"
}

# Function to show usage
show_usage() {
    echo "GitHub Profile Manager for Windsurf IDE"
    echo
    echo "Usage: $0 [COMMAND] [OPTIONS]"
    echo
    echo "Commands:"
    echo "  create              Create a new GitHub profile"
    echo "  list                List all existing profiles"
    echo "  switch <profile>    Switch to a specific profile for current session"
    echo "  delete <profile>    Delete a profile"
    echo "  help                Show this help message"
    echo
    echo "Examples:"
    echo "  $0 create"
    echo "  $0 list"
    echo "  $0 switch personal"
    echo "  $0 delete work"
}

# Main script logic
main() {
    case "${1:-}" in
        "create")
            create_profile
            ;;
        "list")
            list_profiles
            ;;
        "switch")
            switch_profile "$2"
            ;;
        "delete")
            delete_profile "$2"
            ;;
        "help"|"-h"|"--help")
            show_usage
            ;;
        "")
            show_usage
            ;;
        *)
            print_error "Unknown command: $1"
            echo
            show_usage
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"
