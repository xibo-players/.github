#!/bin/bash
# Initialize gh-pages branch with RPM repository structure
# =========================================================
# This script creates the gh-pages branch with the proper structure
# for publishing RPMs and kiosk images.
#
# Usage: Run this script as a repository administrator

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "===================================="
echo "GitHub Pages Initialization Script"
echo "===================================="
echo ""

# Check if we're in a git repository
if [ ! -d "$REPO_ROOT/.git" ]; then
    echo "Error: Not in a git repository"
    exit 1
fi

cd "$REPO_ROOT"

# Check if gh-pages branch already exists
if git rev-parse --verify gh-pages >/dev/null 2>&1; then
    echo "Warning: gh-pages branch already exists"
    read -p "Do you want to recreate it? This will DELETE the existing branch! (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 0
    fi
    git branch -D gh-pages
fi

# Create orphan gh-pages branch
echo "Creating gh-pages branch..."
git checkout --orphan gh-pages

# Remove all files from working tree
git rm -rf . 2>/dev/null || true
git clean -fd

# Create directory structure
echo "Creating directory structure..."
mkdir -p rpm/fedora/43/{x86_64,aarch64,noarch}
mkdir -p deb/ubuntu/24.04/{amd64,arm64,all}
mkdir -p images
mkdir -p scripts

# Create root index.html
cat > index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Xibo Players - Shared Resources</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            max-width: 1200px;
            margin: 0 auto;
            padding: 40px 20px;
            line-height: 1.6;
            color: #333;
        }
        h1 { color: #0066cc; border-bottom: 3px solid #0066cc; padding-bottom: 10px; }
        .card {
            background: #f8f9fa;
            border-left: 4px solid #0066cc;
            padding: 20px;
            margin: 20px 0;
            border-radius: 4px;
        }
        a { color: #0066cc; text-decoration: none; }
        a:hover { text-decoration: underline; }
        pre {
            background: #272822;
            color: #f8f8f2;
            padding: 15px;
            border-radius: 5px;
            overflow-x: auto;
        }
    </style>
</head>
<body>
    <h1>🎯 Xibo Players - Shared Resources</h1>
    
    <p>Welcome! This page provides access to RPM packages, DEB packages, kiosk images, and installation scripts.</p>

    <div class="card">
        <h3>📦 RPM Repository (Fedora/RHEL)</h3>
        <p><a href="rpm/">Browse RPM packages →</a></p>
        <pre>curl -fsSL https://dnf.xiboplayer.org/scripts/setup-repo.sh | sudo bash
sudo dnf install xiboplayer-electron</pre>
    </div>

    <div class="card">
        <h3>📦 DEB Repository (Debian/Ubuntu)</h3>
        <p><a href="deb/">Browse DEB packages →</a></p>
        <pre>echo "deb [trusted=yes] https://xibo-players.github.io/.github/deb/ubuntu/24.04 ./" | sudo tee /etc/apt/sources.list.d/xibo-players.list
sudo apt-get update
sudo apt-get install xiboplayer-electron</pre>
    </div>

    <div class="card">
        <h3>💿 Kiosk Images</h3>
        <p><a href="images/">Browse bootable images →</a></p>
    </div>

    <div class="card">
        <h3>📚 Documentation</h3>
        <p><a href="https://github.com/xibo-players/.github">GitHub Repository</a></p>
    </div>
</body>
</html>
EOF

# Create rpm/index.html
cat > rpm/index.html << 'RPMEOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Xibo Players - RPM Repository</title>
    <style>
        body { font-family: sans-serif; max-width: 1000px; margin: 0 auto; padding: 40px 20px; }
        h1 { color: #0066cc; }
        pre { background: #272822; color: #f8f8f2; padding: 15px; border-radius: 5px; }
        a { color: #0066cc; }
    </style>
</head>
<body>
    <h1>📦 RPM Repository</h1>
    <p>Architectures: <a href="fedora/43/x86_64/">x86_64</a> | <a href="fedora/43/aarch64/">aarch64</a> | <a href="fedora/43/noarch/">noarch</a></p>
    <h2>Installation</h2>
    <pre>curl -fsSL https://dnf.xiboplayer.org/scripts/setup-repo.sh | sudo bash
sudo dnf install xiboplayer-electron</pre>
    <p><a href="../">← Back</a></p>
</body>
</html>
RPMEOF

# Create deb/index.html
cat > deb/index.html << 'DEBEOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Xibo Players - DEB Repository</title>
    <style>
        body { font-family: sans-serif; max-width: 1000px; margin: 0 auto; padding: 40px 20px; }
        h1 { color: #0066cc; }
        pre { background: #272822; color: #f8f8f2; padding: 15px; border-radius: 5px; }
        a { color: #0066cc; }
    </style>
</head>
<body>
    <h1>📦 DEB Repository</h1>
    <p>Architectures: <a href="ubuntu/24.04/amd64/">amd64</a> | <a href="ubuntu/24.04/arm64/">arm64</a> | <a href="ubuntu/24.04/all/">all</a></p>
    <h2>Installation</h2>
    <pre>echo "deb [trusted=yes] https://xibo-players.github.io/.github/deb/ubuntu/24.04 ./" | sudo tee /etc/apt/sources.list.d/xibo-players.list
sudo apt-get update
sudo apt-get install xiboplayer-electron</pre>
    <p><a href="../">← Back</a></p>
</body>
</html>
DEBEOF

# Create images/index.html
cat > images/index.html << 'IMGEOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Xibo Players - Kiosk Images</title>
    <style>
        body { font-family: sans-serif; max-width: 1000px; margin: 0 auto; padding: 40px 20px; }
        h1 { color: #0066cc; }
        a { color: #0066cc; }
    </style>
</head>
<body>
    <h1>💿 Kiosk Images</h1>
    <p>Bootable kiosk images will appear here after workflows run.</p>
    <p><a href="../">← Back</a></p>
</body>
</html>
IMGEOF

# Copy setup script from main branch
echo "Copying setup script..."
git show copilot/fix-rpm-build-workflow:scripts/setup-repo.sh > scripts/setup-repo.sh 2>/dev/null || \
    echo "Warning: Could not copy setup-repo.sh from branch"
chmod +x scripts/setup-repo.sh

# Create .gitkeep files in architecture directories
touch rpm/fedora/43/x86_64/.gitkeep
touch rpm/fedora/43/aarch64/.gitkeep
touch rpm/fedora/43/noarch/.gitkeep
touch deb/ubuntu/24.04/amd64/.gitkeep
touch deb/ubuntu/24.04/arm64/.gitkeep
touch deb/ubuntu/24.04/all/.gitkeep

# Commit
echo "Committing files..."
git add -A
git commit -m "Initial gh-pages setup with RPM and DEB repository structure

- Created root index.html with RPM and DEB sections
- Created rpm/index.html  
- Created deb/index.html
- Created images/index.html
- Added setup-repo.sh script
- Created rpm/fedora/43/{x86_64,aarch64,noarch} structure
- Created deb/ubuntu/24.04/{amd64,arm64,all} structure"

echo ""
echo "===================================="
echo "✓ gh-pages branch created locally"
echo "===================================="
echo ""
echo "Next steps:"
echo "1. Push the branch: git push -u origin gh-pages"
echo "2. Enable GitHub Pages in repository settings"
echo "3. Set source to 'gh-pages' branch, '/' root"
echo ""
echo "URLs will be available at:"
echo "  https://dnf.xiboplayer.org/"
echo "  https://dnf.xiboplayer.org/rpm/"
echo "  https://dnf.xiboplayer.org/deb/"
echo "  https://dnf.xiboplayer.org/images/"
echo ""
echo "Note: Custom domain dnf.xiboplayer.org is configured"
echo ""
