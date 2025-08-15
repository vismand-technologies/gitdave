#!/usr/bin/env python3
"""
GitHub Profile Helper for Windsurf IDE
Advanced Python companion script for managing GitHub profiles
"""

import json
import os
import subprocess
import sys
from pathlib import Path
from typing import Dict, List, Optional
import argparse

class GitHubProfileManager:
    def __init__(self):
        self.home_dir = Path.home()
        self.profiles_dir = self.home_dir / ".github-profiles"
        self.ssh_dir = self.home_dir / ".ssh"
        self.profiles_dir.mkdir(exist_ok=True)
    
    def get_profiles(self) -> List[Dict]:
        """Get all existing profiles"""
        profiles = []
        for profile_file in self.profiles_dir.glob("profile-*.json"):
            try:
                with open(profile_file, 'r') as f:
                    profile_data = json.load(f)
                    profiles.append(profile_data)
            except (json.JSONDecodeError, FileNotFoundError):
                continue
        return profiles
    
    def get_profile(self, profile_name: str) -> Optional[Dict]:
        """Get a specific profile by name"""
        profile_file = self.profiles_dir / f"profile-{profile_name}.json"
        if profile_file.exists():
            try:
                with open(profile_file, 'r') as f:
                    return json.load(f)
            except json.JSONDecodeError:
                return None
        return None
    
    def test_ssh_connection(self, profile_name: str) -> bool:
        """Test SSH connection for a profile"""
        try:
            result = subprocess.run(
                ["ssh", "-T", f"git@github-{profile_name}"],
                capture_output=True,
                text=True,
                timeout=10
            )
            # GitHub SSH test returns exit code 1 but with success message
            return "successfully authenticated" in result.stderr.lower()
        except (subprocess.TimeoutExpired, subprocess.CalledProcessError):
            return False
    
    def clone_repo(self, profile_name: str, repo_url: str, target_dir: Optional[str] = None):
        """Clone a repository using a specific profile"""
        profile = self.get_profile(profile_name)
        if not profile:
            print(f"❌ Profile '{profile_name}' not found")
            return False
        
        # Convert HTTPS URL to SSH format for the profile
        if repo_url.startswith("https://github.com/"):
            repo_path = repo_url.replace("https://github.com/", "")
            ssh_url = f"git@github-{profile_name}:{repo_path}"
        elif repo_url.startswith("git@github.com:"):
            repo_path = repo_url.replace("git@github.com:", "")
            ssh_url = f"git@github-{profile_name}:{repo_path}"
        else:
            ssh_url = repo_url
        
        # Determine target directory
        if not target_dir:
            work_dir = Path(profile["work_directory"]).expanduser()
            repo_name = repo_path.split("/")[-1].replace(".git", "")
            target_dir = work_dir / repo_name
        else:
            target_dir = Path(target_dir)
        
        print(f"🔄 Cloning {ssh_url} to {target_dir}")
        
        try:
            subprocess.run(
                ["git", "clone", ssh_url, str(target_dir)],
                check=True
            )
            print(f"✅ Repository cloned successfully to {target_dir}")
            return True
        except subprocess.CalledProcessError as e:
            print(f"❌ Failed to clone repository: {e}")
            return False
    
    def setup_windsurf_workspace(self, profile_name: str, workspace_path: str):
        """Create Windsurf workspace configuration for a profile"""
        profile = self.get_profile(profile_name)
        if not profile:
            print(f"❌ Profile '{profile_name}' not found")
            return False
        
        workspace_path = Path(workspace_path).expanduser()
        workspace_path.mkdir(parents=True, exist_ok=True)
        
        # Create .vscode/settings.json for workspace-specific Git config
        vscode_dir = workspace_path / ".vscode"
        vscode_dir.mkdir(exist_ok=True)
        
        settings = {
            "git.defaultCloneDirectory": str(workspace_path),
            "git.user.name": profile["name"],
            "git.user.email": profile["email"],
            "terminal.integrated.env.linux": {
                "GIT_AUTHOR_NAME": profile["name"],
                "GIT_AUTHOR_EMAIL": profile["email"],
                "GIT_COMMITTER_NAME": profile["name"],
                "GIT_COMMITTER_EMAIL": profile["email"],
                "GITHUB_USER": profile["github_username"]
            }
        }
        
        settings_file = vscode_dir / "settings.json"
        with open(settings_file, 'w') as f:
            json.dump(settings, f, indent=2)
        
        print(f"✅ Windsurf workspace configured for profile '{profile_name}' at {workspace_path}")
        return True
    
    def validate_profiles(self):
        """Validate all profiles and their configurations"""
        profiles = self.get_profiles()
        if not profiles:
            print("⚠️  No profiles found")
            return
        
        print("🔍 Validating GitHub profiles...")
        print()
        
        for profile in profiles:
            profile_name = profile["profile_name"]
            print(f"📋 Profile: {profile_name}")
            
            # Check SSH key
            ssh_key_path = Path(profile["ssh_key"]).expanduser()
            if ssh_key_path.exists():
                print(f"  ✅ SSH key exists: {ssh_key_path}")
            else:
                print(f"  ❌ SSH key missing: {ssh_key_path}")
            
            # Check Git config
            git_config_path = Path(profile["git_config"]).expanduser()
            if git_config_path.exists():
                print(f"  ✅ Git config exists: {git_config_path}")
            else:
                print(f"  ❌ Git config missing: {git_config_path}")
            
            # Check work directory
            work_dir = Path(profile["work_directory"]).expanduser()
            if work_dir.exists():
                print(f"  ✅ Work directory exists: {work_dir}")
            else:
                print(f"  ⚠️  Work directory missing: {work_dir}")
            
            # Test SSH connection
            print("  🔄 Testing SSH connection...")
            if self.test_ssh_connection(profile_name):
                print(f"  ✅ SSH connection successful")
            else:
                print(f"  ❌ SSH connection failed")
            
            print()
    
    def export_profiles(self, output_file: str):
        """Export all profiles to a JSON file"""
        profiles = self.get_profiles()
        output_path = Path(output_file)
        
        with open(output_path, 'w') as f:
            json.dump(profiles, f, indent=2)
        
        print(f"✅ Profiles exported to {output_path}")
    
    def import_profiles(self, input_file: str):
        """Import profiles from a JSON file"""
        input_path = Path(input_file)
        if not input_path.exists():
            print(f"❌ File not found: {input_path}")
            return False
        
        try:
            with open(input_path, 'r') as f:
                profiles = json.load(f)
            
            for profile in profiles:
                profile_name = profile["profile_name"]
                profile_file = self.profiles_dir / f"profile-{profile_name}.json"
                
                with open(profile_file, 'w') as f:
                    json.dump(profile, f, indent=2)
                
                print(f"✅ Imported profile: {profile_name}")
            
            print(f"✅ All profiles imported from {input_path}")
            return True
            
        except json.JSONDecodeError:
            print(f"❌ Invalid JSON file: {input_path}")
            return False
    
    def generate_clone_commands(self, profile_name: str, repos: List[str]):
        """Generate clone commands for multiple repositories"""
        profile = self.get_profile(profile_name)
        if not profile:
            print(f"❌ Profile '{profile_name}' not found")
            return
        
        work_dir = Path(profile["work_directory"]).expanduser()
        
        print(f"📋 Clone commands for profile '{profile_name}':")
        print(f"📁 Target directory: {work_dir}")
        print()
        
        for repo in repos:
            if repo.startswith("https://github.com/"):
                repo_path = repo.replace("https://github.com/", "")
                ssh_url = f"git@github-{profile_name}:{repo_path}"
            elif repo.startswith("git@github.com:"):
                repo_path = repo.replace("git@github.com:", "")
                ssh_url = f"git@github-{profile_name}:{repo_path}"
            else:
                ssh_url = f"git@github-{profile_name}:{repo}"
            
            repo_name = repo_path.split("/")[-1].replace(".git", "")
            target_path = work_dir / repo_name
            
            print(f"git clone {ssh_url} {target_path}")
        
        print()

def main():
    parser = argparse.ArgumentParser(description="GitHub Profile Helper for Windsurf IDE")
    subparsers = parser.add_subparsers(dest="command", help="Available commands")
    
    # Validate command
    validate_parser = subparsers.add_parser("validate", help="Validate all profiles")
    
    # Clone command
    clone_parser = subparsers.add_parser("clone", help="Clone repository with specific profile")
    clone_parser.add_argument("profile", help="Profile name to use")
    clone_parser.add_argument("repo_url", help="Repository URL to clone")
    clone_parser.add_argument("--target", help="Target directory (optional)")
    
    # Workspace command
    workspace_parser = subparsers.add_parser("workspace", help="Setup Windsurf workspace")
    workspace_parser.add_argument("profile", help="Profile name")
    workspace_parser.add_argument("path", help="Workspace path")
    
    # Export command
    export_parser = subparsers.add_parser("export", help="Export profiles to JSON")
    export_parser.add_argument("output", help="Output file path")
    
    # Import command
    import_parser = subparsers.add_parser("import", help="Import profiles from JSON")
    import_parser.add_argument("input", help="Input file path")
    
    # Generate clone commands
    generate_parser = subparsers.add_parser("generate-clones", help="Generate clone commands")
    generate_parser.add_argument("profile", help="Profile name")
    generate_parser.add_argument("repos", nargs="+", help="Repository URLs")
    
    # List profiles
    list_parser = subparsers.add_parser("list", help="List all profiles")
    
    args = parser.parse_args()
    
    if not args.command:
        parser.print_help()
        return
    
    manager = GitHubProfileManager()
    
    if args.command == "validate":
        manager.validate_profiles()
    elif args.command == "clone":
        manager.clone_repo(args.profile, args.repo_url, args.target)
    elif args.command == "workspace":
        manager.setup_windsurf_workspace(args.profile, args.path)
    elif args.command == "export":
        manager.export_profiles(args.output)
    elif args.command == "import":
        manager.import_profiles(args.input)
    elif args.command == "generate-clones":
        manager.generate_clone_commands(args.profile, args.repos)
    elif args.command == "list":
        profiles = manager.get_profiles()
        if profiles:
            print("📋 Available GitHub profiles:")
            for profile in profiles:
                print(f"  • {profile['profile_name']} ({profile['name']} <{profile['email']}>)")
        else:
            print("⚠️  No profiles found")

if __name__ == "__main__":
    main()
