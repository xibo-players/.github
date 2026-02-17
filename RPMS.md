# Where Can I See the RPMs?

## Published RPM Repository

RPMs built by the workflows in this repository are automatically published to GitHub Pages.

### Browse RPMs Online

**Main Repository Index:**
- 🔗 https://xibo-players.github.io/.github/rpm/

This page shows:
- Available architectures (x86_64, aarch64, noarch)
- Installation instructions
- Repository configuration

### Direct Architecture URLs

- **x86_64** (64-bit Intel/AMD): https://xibo-players.github.io/.github/rpm/fedora/43/x86_64/
- **aarch64** (64-bit ARM): https://xibo-players.github.io/.github/rpm/fedora/43/aarch64/
- **noarch** (Architecture independent): https://xibo-players.github.io/.github/rpm/fedora/43/noarch/

## GitHub Releases

RPMs are also attached to GitHub Releases when tagged:

1. Go to any repository using these workflows
2. Click on "Releases" in the sidebar
3. Find the release version
4. Download `.rpm` files from the "Assets" section

## Installing RPMs

### Quick Install (Recommended)

```bash
# Setup repository
curl -fsSL https://xibo-players.github.io/.github/scripts/setup-repo.sh | sudo bash

# Install package
sudo dnf install package-name
```

### Manual Repository Setup

```bash
# Add repository
sudo tee /etc/yum.repos.d/xibo-players.repo <<'EOF'
[xibo-players]
name=Xibo Players
baseurl=https://xibo-players.github.io/.github/rpm/fedora/$releasever/$basearch/
enabled=1
gpgcheck=0
EOF

# Install package
sudo dnf install package-name
```

### Direct RPM Download

If you prefer to download and install manually:

1. Browse to the architecture URL above
2. Find your `.rpm` file
3. Download and install:
   ```bash
   sudo dnf install ./package-name-version.rpm
   ```

## Repository Structure

The RPM repository is organized as:

```
https://xibo-players.github.io/.github/rpm/
├── index.html                    # Main repository page
├── fedora/
│   └── 43/
│       ├── x86_64/
│       │   ├── package1.rpm
│       │   ├── package2.rpm
│       │   └── repodata/        # yum/dnf metadata
│       ├── aarch64/
│       │   ├── package1.rpm
│       │   └── repodata/
│       └── noarch/
│           ├── package.rpm
│           └── repodata/
```

## Checking if RPMs are Published

To verify that RPMs have been published:

1. **Check GitHub Actions**: Go to the repository's "Actions" tab and verify the workflow completed successfully
2. **Browse gh-pages**: Visit https://xibo-players.github.io/.github/rpm/
3. **Query the repository**:
   ```bash
   dnf repoquery --repofrompath=xibo,https://xibo-players.github.io/.github/rpm/fedora/43/x86_64/ --available
   ```

## Troubleshooting

### RPMs Not Showing Up?

1. Ensure the workflow ran on a tagged release (tags starting with `v`)
2. Check that GitHub Pages is enabled in repository settings
3. Wait a few minutes after workflow completes for GitHub Pages to update
4. Clear your browser cache if browsing the index page

### Need Help?

- Check the workflow logs in GitHub Actions
- Verify the `publish-rpm` job completed successfully
- Open an issue in the repository

## For Repository Maintainers

RPMs are automatically published when:
- A tag starting with `v` is pushed (e.g., `v1.0.0`)
- The `build-rpm.yml` workflow completes successfully
- The `publish-rpm` job pushes to the `gh-pages` branch

The publishing process:
1. Builds RPM packages
2. Uploads as GitHub Actions artifacts
3. Publishes to GitHub Releases (for tags)
4. Organizes by architecture in `gh-pages` branch
5. Runs `createrepo_c` to generate repository metadata
6. GitHub Pages serves the `gh-pages` branch content
