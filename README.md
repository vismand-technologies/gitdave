# GitHub Profile Manager for Windsurf IDE

Automate the setup and management of multiple GitHub profiles with SSH keys, Git configuration, and GitHub CLI authentication for seamless development across different accounts.

## 🚀 Features

- **Automated Profile Creation**: Generate SSH keys, Git configs, and GitHub CLI authentication
- **Multi-Account Support**: Manage personal, work, and other GitHub accounts separately
- **Windsurf IDE Integration**: Workspace-specific configurations for seamless switching
- **SSH Key Management**: Automatic SSH key generation and configuration
- **Git Configuration**: Conditional includes for directory-based profile switching
- **Profile Validation**: Test SSH connections and validate configurations
- **Repository Cloning**: Clone repositories with the correct profile automatically
- **Import/Export**: Backup and restore profile configurations

## 📋 Prerequisites

- **Git**: Installed and configured
- **SSH**: OpenSSH client
- **GitHub CLI** (optional but recommended): `gh` command
- **Python 3.6+**: For the advanced helper script

### Install GitHub CLI (recommended)

```bash
# Ubuntu/Debian
sudo apt install gh

# macOS
brew install gh

# Or visit: https://cli.github.com/
```

## 🛠️ Installation

1. **Clone or download the scripts**:
   ```bash
   git clone <this-repo> # or download the files
   cd github-profile-manager
   ```

2. **Make scripts executable**:
   ```bash
   chmod +x github-profile-manager.sh
   chmod +x github-profile-helper.py
   ```

3. **Add to PATH** (optional):
   ```bash
   # Add to your ~/.bashrc or ~/.zshrc
   export PATH="$PATH:/path/to/github-profile-manager"
   
   # Create symlinks (alternative)
   sudo ln -s /path/to/github-profile-manager.sh /usr/local/bin/github-profile
   sudo ln -s /path/to/github-profile-helper.py /usr/local/bin/github-helper
   ```

## 📖 Usage

### Basic Profile Management

#### Create a New Profile
```bash
./github-profile-manager.sh create
```

This will prompt you for:
- Profile name (e.g., `personal`, `work`, `client`)
- Full name
- Email address
- GitHub username
- Work directory path

The script will:
1. Generate an SSH key pair
2. Update SSH configuration
3. Create Git configuration files
4. Set up GitHub CLI authentication
5. Create the work directory structure

#### List All Profiles
```bash
./github-profile-manager.sh list
```

#### Switch Profile (Current Session)
```bash
./github-profile-manager.sh switch personal
```

#### Delete a Profile
```bash
./github-profile-manager.sh delete work
```

### Advanced Features (Python Helper)

#### Validate All Profiles
```bash
./github-profile-helper.py validate
```

Tests SSH connections and validates configurations for all profiles.

#### Clone Repository with Specific Profile
```bash
./github-profile-helper.py clone personal https://github.com/user/repo.git
./github-profile-helper.py clone work git@github.com:company/project.git --target ~/custom/path
```

#### Setup Windsurf Workspace
```bash
./github-profile-helper.py workspace personal ~/personal-projects
```

Creates a Windsurf-compatible workspace with profile-specific settings.

#### Export/Import Profiles
```bash
# Export all profiles to backup
./github-profile-helper.py export profiles-backup.json

# Import profiles from backup
./github-profile-helper.py import profiles-backup.json
```

#### Generate Clone Commands
```bash
./github-profile-helper.py generate-clones work \
  https://github.com/company/repo1.git \
  https://github.com/company/repo2.git \
  company/repo3
```

## 🏗️ Directory Structure

After setup, your system will have:

```
~/.github-profiles/
├── profile-personal.json      # Profile metadata
├── profile-work.json
├── gitconfig-personal         # Git configuration
└── gitconfig-work

~/.ssh/
├── config                     # SSH configuration
├── id_ed25519_personal        # SSH private keys
├── id_ed25519_personal.pub
├── id_ed25519_work
└── id_ed25519_work.pub

~/personal/                    # Work directories
├── project1/
└── project2/

~/work/
├── company-repo1/
└── company-repo2/
```

## 🔧 Configuration Examples

### SSH Config Entry
```
# GitHub Profile: personal
Host github-personal
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_personal
    IdentitiesOnly yes
```

### Git Config with Conditional Includes
```gitconfig
# ~/.gitconfig
[includeIf "gitdir:~/personal/"]
    path = ~/.github-profiles/gitconfig-personal

[includeIf "gitdir:~/work/"]
    path = ~/.github-profiles/gitconfig-work
```

### Profile-Specific Git Config
```gitconfig
# ~/.github-profiles/gitconfig-personal
[user]
    name = John Doe
    email = john@personal.com

[core]
    sshCommand = ssh -i ~/.ssh/id_ed25519_personal

[url "git@github-personal:"]
    insteadOf = https://github.com/
```

## 🎯 Windsurf IDE Integration

### Workspace Settings
The helper script creates `.vscode/settings.json` files with:

```json
{
  "git.defaultCloneDirectory": "/home/user/personal",
  "git.user.name": "John Doe",
  "git.user.email": "john@personal.com",
  "terminal.integrated.env.linux": {
    "GIT_AUTHOR_NAME": "John Doe",
    "GIT_AUTHOR_EMAIL": "john@personal.com",
    "GIT_COMMITTER_NAME": "John Doe",
    "GIT_COMMITTER_EMAIL": "john@personal.com",
    "GITHUB_USER": "johndoe"
  }
}
```

### Recommended Workflow

1. **Create profiles** for each GitHub account
2. **Set up workspaces** for each profile:
   ```bash
   ./github-profile-helper.py workspace personal ~/personal-projects
   ./github-profile-helper.py workspace work ~/work-projects
   ```
3. **Open separate Windsurf windows** for each workspace
4. **Clone repositories** into the appropriate directories

## 🔍 Troubleshooting

### SSH Connection Issues
```bash
# Test SSH connection manually
ssh -T git@github-personal

# Check SSH agent
ssh-add -l

# Add key to agent if missing
ssh-add ~/.ssh/id_ed25519_personal
```

### Git Configuration Issues
```bash
# Check current Git config
git config --list --show-origin

# Test in specific directory
cd ~/personal/some-repo
git config user.name
git config user.email
```

### GitHub CLI Issues
```bash
# Check authentication status
gh auth status

# Switch between accounts
gh auth switch --hostname github.com --user username
```

## 📝 Common Use Cases

### 1. Personal + Work Setup
```bash
# Create personal profile
./github-profile-manager.sh create
# Profile: personal, Directory: ~/personal

# Create work profile  
./github-profile-manager.sh create
# Profile: work, Directory: ~/work

# Clone personal project
./github-profile-helper.py clone personal https://github.com/myuser/personal-project.git

# Clone work project
./github-profile-helper.py clone work https://github.com/company/work-project.git
```

### 2. Multiple Clients
```bash
# Create client profiles
./github-profile-manager.sh create  # client-a
./github-profile-manager.sh create  # client-b

# Set up separate workspaces
./github-profile-helper.py workspace client-a ~/clients/client-a
./github-profile-helper.py workspace client-b ~/clients/client-b
```

### 3. Team Collaboration
```bash
# Export your profile setup
./github-profile-helper.py export team-profiles.json

# Share with team members
# They can import with:
./github-profile-helper.py import team-profiles.json
```

## 🛡️ Security Best Practices

1. **SSH Key Security**:
   - Use strong passphrases for SSH keys
   - Regularly rotate SSH keys
   - Use `ssh-agent` for key management

2. **Profile Isolation**:
   - Keep work and personal directories separate
   - Use different SSH keys for each profile
   - Regularly validate profile configurations

3. **Backup**:
   - Export profile configurations regularly
   - Backup SSH keys securely
   - Document your setup

## 🤝 Contributing

Feel free to submit issues, feature requests, or pull requests to improve this tool.

## 📄 License

MIT License - feel free to use and modify as needed.
