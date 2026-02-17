# Initializing GitHub Pages

## Problem

The URLs documented in this repository (like https://dnf.xiboplayer.org/rpm/) require the `gh-pages` branch to be initialized and GitHub Pages to be configured with the custom domain.

## Solution

The `gh-pages` branch needs to be initialized with the proper structure. This can be done in two ways:

### Option 1: Use the Automated Workflow (Recommended)

Run the `publish-gh-pages.yml` workflow to automatically create the gh-pages branch with the proper structure:

1. Go to the repository's Actions tab
2. Select the "Publish gh-pages" workflow
3. Click "Run workflow"
4. The workflow will create the gh-pages branch with all necessary structure and index pages

This is the easiest and most reliable method.

### Option 2: Let Build Workflows Create It

The build workflows (build-rpm.yml, build-deb.yml, build-iso.yml) will automatically initialize gh-pages on the first successful build that triggers publishing. However, the index pages may need to be created separately.

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
- https://dnf.xiboplayer.org/deb/ - DEB repository index
- https://dnf.xiboplayer.org/images/ - Kiosk images index
- https://dnf.xiboplayer.org/scripts/setup-repo.sh - Setup script

The RPM repository structure will be:
- https://dnf.xiboplayer.org/rpm/fedora/43/x86_64/
- https://dnf.xiboplayer.org/rpm/fedora/43/aarch64/
- https://dnf.xiboplayer.org/rpm/fedora/43/noarch/

The DEB repository structure will be:
- https://dnf.xiboplayer.org/deb/ubuntu/24.04/amd64/
- https://dnf.xiboplayer.org/deb/ubuntu/24.04/arm64/
- https://dnf.xiboplayer.org/deb/ubuntu/24.04/all/

**Note:** The custom domain `dnf.xiboplayer.org` is now configured. See [CUSTOM-DOMAIN-SETUP.md](CUSTOM-DOMAIN-SETUP.md) for details on the custom domain setup.
