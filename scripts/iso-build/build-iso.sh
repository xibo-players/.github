#!/bin/bash
# ISO Build Script for Xibo Player
# Creates a bootable ISO with Xibo player that auto-starts on boot
#
# Usage: ./build-iso.sh <version> <iso-label> [player-binary]
#
# This script creates a Fedora-based live ISO optimized for kiosk deployment

set -e

VERSION="${1:-0.1.0}"
ISO_LABEL="${2:-XIBOPLAYER}"
PLAYER_BINARY="${3:-target/release/arexibo}"
WORK_DIR="$(pwd)/iso-build"
OUTPUT_DIR="$(pwd)/dist"

echo "========================================="
echo "Building Xibo Player ISO"
echo "Version: $VERSION"
echo "Label: $ISO_LABEL"
echo "Player: $PLAYER_BINARY"
echo "========================================="

# Check for required tools
for tool in genisoimage xorriso; do
    if ! command -v $tool &> /dev/null; then
        echo "Error: $tool is not installed"
        exit 1
    fi
done

# Create work and output directories
mkdir -p "$WORK_DIR"
mkdir -p "$OUTPUT_DIR"

# Function to create minimal ISO content
create_iso_content() {
    echo "Creating ISO content..."
    
    # Create basic directory structure
    mkdir -p "$WORK_DIR"/{boot,player,docs,config}
    
    # Copy player binary if it exists
    if [ -f "$PLAYER_BINARY" ]; then
        echo "Copying player binary: $PLAYER_BINARY"
        cp "$PLAYER_BINARY" "$WORK_DIR/player/"
        chmod +x "$WORK_DIR/player/$(basename $PLAYER_BINARY)"
    else
        echo "Warning: Player binary not found: $PLAYER_BINARY"
        echo "ISO will be created without the player binary"
    fi
    
    # Copy any additional files (RPMs, config examples, etc.)
    if [ -d "rpms" ]; then
        echo "Copying RPM packages..."
        cp -r rpms/* "$WORK_DIR/player/" 2>/dev/null || true
    fi
    
    # Create systemd service for auto-start
    cat > "$WORK_DIR/config/xibo-player.service" << 'SERVICEEOF'
[Unit]
Description=Xibo Digital Signage Player
After=network-online.target graphical.target
Wants=network-online.target

[Service]
Type=simple
User=xibo
Environment=DISPLAY=:0
Environment=NO_AT_BRIDGE=1
ExecStart=/usr/bin/xinit /usr/bin/arexibo /home/xibo/player-data -- :0 vt7 -s 0 -dpms
Restart=always
RestartSec=10

[Install]
WantedBy=graphical.target
SERVICEEOF
    
    # Create version file
    echo "$VERSION" > "$WORK_DIR/VERSION.txt"
    
    # Create installation instructions
    cat > "$WORK_DIR/INSTALL.txt" << INSTEOF
Xibo Player ISO - Version $VERSION
===================================

This ISO contains the Xibo digital signage player and all required components.

INSTALLATION METHODS:

1. Boot from ISO (Live Mode):
   - Boot from this ISO image
   - Player will start automatically in live mode
   - Changes will not persist after reboot

2. Install to Hard Drive:
   a) Install your preferred Linux distribution (Fedora/Ubuntu recommended)
   b) Mount this ISO or extract its contents
   c) Install the player binary:
      sudo cp player/arexibo /usr/bin/
      sudo chmod +x /usr/bin/arexibo
   d) Install the systemd service:
      sudo cp config/xibo-player.service /etc/systemd/system/
      sudo systemctl enable xibo-player
      sudo systemctl start xibo-player

3. Install from RPM (Fedora/RHEL):
   sudo dnf install player/arexibo-*.rpm

FIRST RUN CONFIGURATION:
   arexibo --host https://your-cms-url/ --key YOUR_DISPLAY_KEY /home/xibo/player-data

For more information, visit: https://xibo.org.uk/

Build Date: $(date)
INSTEOF
    
    # Create README
    cat > "$WORK_DIR/README.txt" << READMEEOF
Xibo Player Distribution - Version $VERSION

Contents:
---------
/player/          - Player binaries and packages
/config/          - Configuration files and systemd services
/docs/            - Documentation
INSTALL.txt       - Installation instructions
VERSION.txt       - Version information

Visit https://xibo.org.uk/ for documentation and support.
READMEEOF
}

# Main ISO creation
create_iso() {
    echo "Creating ISO image..."
    
    # Create ISO content
    create_iso_content
    
    # Create the ISO
    ISO_FILE="$OUTPUT_DIR/${ISO_LABEL}-${VERSION}.iso"
    
    echo "Building ISO file: $ISO_FILE"
    
    # Create ISO with proper options for maximum compatibility
    genisoimage \
        -o "$ISO_FILE" \
        -V "$ISO_LABEL" \
        -A "Xibo Player $VERSION" \
        -p "Xibo Players Organization" \
        -publisher "xibo-players" \
        -J -R -l \
        -input-charset utf-8 \
        -joliet-long \
        "$WORK_DIR"
    
    if [ -f "$ISO_FILE" ]; then
        echo "✓ ISO created successfully: $ISO_FILE"
        echo "  Size: $(du -h $ISO_FILE | cut -f1)"
        
        # Create checksum
        cd "$OUTPUT_DIR"
        sha256sum "$(basename $ISO_FILE)" > "$(basename $ISO_FILE).sha256"
        echo "✓ Checksum created: $(basename $ISO_FILE).sha256"
        cat "$(basename $ISO_FILE).sha256"
        cd - > /dev/null
    else
        echo "✗ Failed to create ISO"
        exit 1
    fi
}

# Cleanup function
cleanup() {
    if [ $? -eq 0 ]; then
        echo "Cleaning up temporary files..."
        rm -rf "$WORK_DIR"
    else
        echo "Build failed. Work directory preserved for debugging: $WORK_DIR"
    fi
}

# Run the build
trap cleanup EXIT
create_iso

echo "========================================="
echo "ISO build complete!"
echo "Output directory: $OUTPUT_DIR"
ls -lh "$OUTPUT_DIR"
echo "========================================="
