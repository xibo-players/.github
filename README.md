# Xibo Players - Shared GitHub Workflows

This repository contains reusable GitHub Actions workflows that can be used across all Xibo Players repositories. By centralizing workflows here, we maintain consistency and reduce duplication.

## 🔗 Quick Links

- **📦 Browse Published RPMs**: https://xibo-players.github.io/.github/rpm/
- **💿 Browse Kiosk Images**: https://xibo-players.github.io/.github/images/
- **📖 Where Can I See the RPMs?**: [RPMS.md](RPMS.md)
- **🔧 Repository Setup Script**: https://xibo-players.github.io/.github/scripts/setup-repo.sh

### Install from RPM Repository

```bash
# Quick setup
curl -fsSL https://xibo-players.github.io/.github/scripts/setup-repo.sh | sudo bash

# Install packages
sudo dnf install xiboplayer-electron
```

---

## Available Workflows

### 1. Build RPM (`build-rpm.yml`)

Builds RPM packages for Linux distributions and publishes them to a yum/dnf repository on gh-pages.

**Usage:**
```yaml
name: Build RPM

on:
  push:
    branches: [main]
    tags: ['v*']
  pull_request:
  workflow_dispatch:

jobs:
  build-rpm:
    uses: xibo-players/.github/.github/workflows/build-rpm.yml@main
    with:
      package-name: 'xiboplayer-electron'
      build-command: 'pnpm run build:linux'
      rpm-script: 'build-rpm.sh'
      rpm-output-dir: 'dist'
      node-version: '22'
      default-version: '0.2.0'
```

**Inputs:**
- `package-name` (required): RPM package name
- `build-command`: Build command before RPM (optional)
- `rpm-script`: Path to RPM build script (default: `build-rpm.sh`)
- `rpm-output-dir`: Directory where RPM files are output (default: `dist`)
- `node-version`: Node.js version (default: `22`)
- `default-version`: Default version if not tagged (default: `0.2.0`)
- `release-body`: Custom release body markdown (optional)

**Features:**
- Installs RPM build tools
- Runs optional build command with pnpm caching
- Validates RPM script exists before running
- Creates GitHub releases for tags
- **Publishes to gh-pages dnf repository with proper structure:**
  - `rpm/fedora/43/x86_64/` - 64-bit Intel/AMD packages
  - `rpm/fedora/43/aarch64/` - 64-bit ARM packages  
  - `rpm/fedora/43/noarch/` - Architecture-independent packages
- Automatically creates repository metadata with `createrepo_c`

**Installing Published RPMs:**

Once your RPMs are published, users can install them from your gh-pages repository:

```bash
# Add the repository
sudo tee /etc/yum.repos.d/xibo-players.repo <<'EOF'
[xibo-players]
name=Xibo Players
baseurl=https://xibo-players.github.io/.github/rpm/fedora/$releasever/$basearch/
enabled=1
gpgcheck=0
EOF

# Install your package
sudo dnf install your-package-name
```

Or use the setup script:

```bash
curl -fsSL https://xibo-players.github.io/.github/scripts/setup-repo.sh | sudo bash
```

**Repository Structure:**

The workflow publishes RPMs to gh-pages in this structure:
```
rpm/
├── index.html                    # Repository information page
├── fedora/
│   └── 43/
│       ├── x86_64/
│       │   ├── *.rpm
│       │   └── repodata/        # Repository metadata
│       ├── aarch64/
│       │   ├── *.rpm
│       │   └── repodata/
│       └── noarch/
│           ├── *.rpm
│           └── repodata/
```

---

### 2. Build PWA (`build-pwa.yml`)

Builds Progressive Web App distributions and creates tarballs.

**Usage:**
```yaml
name: Build PWA

on:
  push:
    tags: ['v*']
  workflow_dispatch:

jobs:
  build-pwa:
    uses: xibo-players/.github/.github/workflows/build-pwa.yml@main
    with:
      node-version: '22'
      build-command: 'pnpm run build'
      artifact-name: 'pwa-dist'
      tarball-name: 'xiboplayer-pwa-dist.tar.gz'
      release-name: 'PWA Player'
```

**Inputs:**
- `node-version`: Node.js version (default: `22`)
- `build-command`: Build command (default: `pnpm run build`)
- `artifact-name`: Artifact name for upload (default: `pwa-dist`)
- `tarball-name`: Name of tarball file (default: `xiboplayer-pwa-dist.tar.gz`)
- `release-name`: Name for GitHub release (default: `PWA Player`)

**Features:**
- Builds PWA with pnpm caching
- Creates compressed tarball
- Uploads as artifact
- Creates GitHub releases for tags

---

### 3. Publish to npm (`publish-npm.yml`)

Publishes packages to the npm registry.

**Usage:**
```yaml
name: Publish to npm

on:
  release:
    types: [published]

jobs:
  publish:
    uses: xibo-players/.github/.github/workflows/publish-npm.yml@main
    with:
      node-version: '22'
      publish-command: 'pnpm publish --no-git-checks --access public'
    secrets:
      npm-token: ${{ secrets.NPM_TOKEN }}
```

**Inputs:**
- `node-version`: Node.js version (default: `22`)
- `publish-command`: Publish command (default: `pnpm publish --no-git-checks --access public`)

**Secrets:**
- `npm-token` (required): NPM authentication token

**Features:**
- Sets up Node.js with pnpm caching
- Configures npm registry
- Publishes to npm with authentication

---

### 4. Build ISO (`build-iso.yml`)

Builds bootable kiosk images for Xibo players using modern mkosi tool. Supports installer ISOs, VM images (QCOW2), and raw disk images for both x86_64 and aarch64.

**Usage:**
```yaml
name: Build Kiosk Images

on:
  push:
    tags: ['v*']
  workflow_dispatch:

jobs:
  build-images:
    uses: xibo-players/.github/.github/workflows/build-iso.yml@main
    with:
      package-name: 'xiboplayer-electron'
      kickstart-file: 'kickstart/xibo-kiosk.ks'
      mkosi-config: 'mkosi.conf'
      build-installer: true
      build-disk-images: true
      architectures: 'x86_64,aarch64'
      default-version: '0.2.0'
```

**Inputs:**
- `package-name` (required): Package name for the kiosk image
- `kickstart-file`: Path to Kickstart file (default: `kickstart/xibo-kiosk.ks`)
- `mkosi-config`: Path to mkosi config (default: `mkosi.conf`)
- `build-installer`: Build installer ISO (default: `true`)
- `build-disk-images`: Build disk images (default: `true`)
- `architectures`: Architectures to build (default: `x86_64`)
- `default-version`: Default version (default: `0.2.0`)
- `release-body`: Custom release body markdown (optional)

**Features:**
- **Installer ISO**: Kickstart-based automated Fedora installation
- **Disk Images**:
  - QCOW2 for VMs (x86_64)
  - Compressed raw images for physical hardware (x86_64, aarch64)
- Uses modern **mkosi** tool (not legacy genisoimage)
- GNOME Kiosk for locked-down display mode
- Auto-login and kiosk session startup
- Published to gh-pages with installation instructions

**What You Need to Provide:**

1. **Kickstart File** (`kickstart/xibo-kiosk.ks`):
   - Use the template at `scripts/mkosi/kickstart/xibo-kiosk.ks.template`
   - Customize package installation and configuration
   - Add your player's repository and packages

2. **mkosi Configuration** (`mkosi.conf`) (optional):
   - Use the template at `scripts/mkosi/mkosi.conf.template`
   - Customize packages and system configuration
   - Or let the workflow use the default template

3. **mkosi-extra directory** (optional):
   - Additional files to include in the image
   - Scripts, configurations, etc.

**Image Types Produced:**

| Type | Filename Pattern | Use Case |
|------|------------------|----------|
| Installer ISO | `*-kiosk-installer_*_x86_64.iso` | Boot and auto-install to hardware |
| QCOW2 | `*-kiosk_*_x86_64.qcow2` | GNOME Boxes, virt-manager, QEMU |
| Raw (compressed) | `*-kiosk_*_x86_64.raw.xz` | Flash to USB/SD for hardware |
| Raw ARM | `*-kiosk_*_aarch64.raw.xz` | ARM devices (Raspberry Pi, etc.) |

**Published Images:**

Images are published to gh-pages at: `https://xibo-players.github.io/.github/images/`

Users can download and flash:
```bash
# Flash installer ISO
sudo dd if=xiboplayer-kiosk-installer_1.0.0_x86_64.iso of=/dev/sdX bs=8M

# Or flash raw image
xz -dc xiboplayer-kiosk_1.0.0_x86_64.raw.xz | sudo dd of=/dev/sdX bs=8M
```

**Default Credentials:**
- User: `xibo` / Password: `xibo`
- Root: `root` (locked by default on installer ISO)

---

### 5. Test (`test.yml`)

Runs automated tests.

**Usage:**
```yaml
name: Test

on:
  push:
    branches: [main]
  pull_request:

jobs:
  test:
    uses: xibo-players/.github/.github/workflows/test.yml@main
    with:
      node-version: '22'
      test-command: 'pnpm test'
```

**Inputs:**
- `node-version`: Node.js version (default: `22`)
- `test-command`: Test command (default: `pnpm test`)

**Features:**
- Sets up Node.js with pnpm caching
- Installs dependencies
- Runs test command

---

## Migration Guide

To migrate your repository to use these shared workflows:

### Step 1: Remove Local Workflow Logic

Delete or simplify your local workflow files in `.github/workflows/`.

### Step 2: Create Caller Workflows

Create simple workflow files that call the reusable workflows:

**Example: `.github/workflows/ci.yml`**
```yaml
name: CI

on:
  push:
    branches: [main]
    tags: ['v*']
  pull_request:

jobs:
  test:
    uses: xibo-players/.github/.github/workflows/test.yml@main
    with:
      node-version: '22'

  build-rpm:
    needs: test
    if: github.event_name != 'pull_request'
    uses: xibo-players/.github/.github/workflows/build-rpm.yml@main
    with:
      package-name: 'my-package'
      build-command: 'pnpm run build:linux'
```

### Step 3: Configure Secrets

Ensure required secrets are configured in your repository settings:
- `NPM_TOKEN` for npm publishing

### Step 4: Test

Test your workflows by:
1. Creating a pull request
2. Pushing to main branch
3. Creating a version tag (e.g., `v1.0.0`)

---

## Best Practices

1. **Pin to specific versions**: Use `@main` or `@v1` tags
2. **Test changes**: Test workflow changes in a branch before merging
3. **Keep secrets secure**: Never commit secrets to repositories
4. **Use semantic versioning**: Tag releases with `v` prefix (e.g., `v1.0.0`)

---

## Contributing

To add new reusable workflows or improve existing ones:

1. Create a new workflow file in `.github/workflows/`
2. Use `workflow_call` trigger
3. Define clear inputs and outputs
4. Document usage in this README
5. Test thoroughly before releasing

---

## Support

For issues or questions:
- Open an issue in this repository
- Check GitHub Actions documentation: https://docs.github.com/en/actions/using-workflows/reusing-workflows

---

## Roadmap

Planned additions:
- [ ] ISO image building workflow
- [ ] Docker image building workflow
- [ ] Automated dependency updates workflow
- [ ] Security scanning workflow
