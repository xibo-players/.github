# Initializing GitHub Pages

## Problem

The URLs documented in this repository (like https://dnf.xiboplayer.org/rpm/) require the `gh-pages` branch to be initialized and GitHub Pages to be configured with the custom domain.

## Solution

The `gh-pages` branch needs to be initialized with the proper structure. This can be done in two ways:

### Option 1: Manual Initialization (Recommended for First Time)

A repository administrator should run:

```bash
git checkout --orphan gh-pages
git rm -rf .
git clean -fd

# Create directory structure
mkdir -p rpm/fedora/43/{x86_64,aarch64,noarch}
mkdir -p images
mkdir -p scripts

# Add the index files and script (see gh-pages-content/ directory)
# Copy files from our prepared structure

git add -A
git commit -m "Initial gh-pages setup"
git push -u origin gh-pages
```

### Option 2: Let Workflows Create It

The workflows will automatically initialize gh-pages on the first successful build that triggers publishing. However, the index pages won't exist until then.

## Prepared Content

The gh-pages content has been prepared in this branch and committed locally. A repository administrator with push permissions needs to:

1. Check out the `gh-pages` branch from this repository
2. Push it to origin

Alternatively, the content can be recreated using the script:

```bash
./scripts/init-gh-pages.sh
```

## Enabling GitHub Pages

After the gh-pages branch exists, ensure GitHub Pages is enabled:

1. Go to repository Settings
2. Navigate to Pages section
3. Set Source to "Deploy from a branch"
4. Select branch: `gh-pages`
5. Select folder: `/ (root)`
6. Click Save

## Verification

Once enabled and the custom domain (dnf.xiboplayer.org) is configured, the following URLs should be accessible:
- https://dnf.xiboplayer.org/ - Main index
- https://dnf.xiboplayer.org/rpm/ - RPM repository index
- https://dnf.xiboplayer.org/images/ - Kiosk images index
- https://dnf.xiboplayer.org/scripts/setup-repo.sh - Setup script

The RPM repository structure will be:
- https://dnf.xiboplayer.org/rpm/fedora/43/x86_64/
- https://dnf.xiboplayer.org/rpm/fedora/43/aarch64/
- https://dnf.xiboplayer.org/rpm/fedora/43/noarch/

**Note:** The custom domain `dnf.xiboplayer.org` is now configured. See [CUSTOM-DOMAIN-SETUP.md](CUSTOM-DOMAIN-SETUP.md) for details on the custom domain setup.
