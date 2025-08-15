#!/bin/bash

# Automated test profile creation script
# This creates a demo profile for testing purposes

echo "Creating a test GitHub profile..."

# Create test profile with predefined values
expect << 'EOF'
spawn ./github-profile-manager.sh create
expect "Profile name*" { send "test-demo\r" }
expect "Your full name*" { send "Demo User\r" }
expect "Email address*" { send "demo@example.com\r" }
expect "GitHub username*" { send "demo-user\r" }
expect "Work directory*" { send "~/demo-projects\r" }
expect "Continue*" { send "Y\r" }
expect "Press Enter after adding the key to GitHub*" { send "\r" }
expect "Please authenticate with GitHub CLI*" { 
    send_user "\n\nSKIPPING GitHub CLI authentication for demo purposes\n"
    send "\003"
}
expect eof
EOF

echo "Test profile creation completed!"
