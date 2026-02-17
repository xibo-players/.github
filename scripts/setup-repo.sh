#!/bin/bash
# Setup Xibo Players RPM Repository
# ==================================
# This script configures your Fedora/RHEL system to use the xibo-players RPM repository

set -e

REPO_NAME="xibo-players"
REPO_URL="https://dnf.xiboplayer.org/rpm/fedora/\$releasever/\$basearch/"
REPO_FILE="/etc/yum.repos.d/${REPO_NAME}.repo"

echo "==================================="
echo "Xibo Players Repository Setup"
echo "==================================="
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "Error: This script must be run as root (use sudo)"
    exit 1
fi

# Detect OS
if [ -f /etc/fedora-release ]; then
    OS="Fedora"
    VERSION=$(cat /etc/fedora-release | grep -oP '\d+')
elif [ -f /etc/redhat-release ]; then
    OS="RHEL/CentOS"
    VERSION=$(cat /etc/redhat-release | grep -oP '\d+' | head -1)
else
    echo "Error: Unsupported operating system"
    echo "This repository is designed for Fedora and RHEL-based systems"
    exit 1
fi

echo "Detected: $OS $VERSION"
echo ""

# Check if repository already exists
if [ -f "$REPO_FILE" ]; then
    echo "Repository configuration already exists at: $REPO_FILE"
    read -p "Do you want to overwrite it? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 0
    fi
fi

# Create repository configuration
echo "Creating repository configuration..."
cat > "$REPO_FILE" << EOF
[${REPO_NAME}]
name=Xibo Players RPM Repository
baseurl=${REPO_URL}
enabled=1
gpgcheck=0
metadata_expire=1h
skip_if_unavailable=1
EOF

echo "✓ Repository configuration created: $REPO_FILE"
echo ""

# Clean and update cache
echo "Updating repository cache..."
dnf clean metadata
dnf makecache

echo ""
echo "==================================="
echo "✓ Setup complete!"
echo "==================================="
echo ""
echo "You can now install packages from the xibo-players repository:"
echo ""
echo "  dnf search xibo"
echo "  dnf install <package-name>"
echo ""
echo "Available packages can be browsed at:"
echo "  https://dnf.xiboplayer.org/rpm/"
echo ""
