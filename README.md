# Xibo Players - Shared GitHub Workflows

This repository contains reusable GitHub Actions workflows that can be used across all Xibo Players repositories. By centralizing workflows here, we maintain consistency and reduce duplication.

> **⚠️ Initial Setup Required**: Before the Quick Links below work, the `gh-pages` branch needs to be initialized. See [GH-PAGES-SETUP.md](GH-PAGES-SETUP.md) for instructions.
> 
> **🌐 Custom Domain**: Want to use `dl.xiboplayer.org` instead of the GitHub Pages URL? See [CUSTOM-DOMAIN-SETUP.md](CUSTOM-DOMAIN-SETUP.md) for complete setup instructions.

## 🔗 Quick Links

- **📦 Browse Published RPMs**: https://dl.xiboplayer.org/rpm/
- **📦 Browse Published DEBs**: https://dl.xiboplayer.org/deb/
- **💿 Browse Kiosk Images**: https://dl.xiboplayer.org/images/
- **📖 Where Can I See the RPMs?**: [RPMS.md](RPMS.md)
- **🔧 Repository Setup Script**: https://dl.xiboplayer.org/scripts/setup-repo.sh

### Install from RPM Repository (Fedora/RHEL)

```bash
# Quick setup
curl -fsSL https://dl.xiboplayer.org/scripts/setup-repo.sh | sudo bash

# Install packages
sudo dnf install xiboplayer-electron
```

### Install from DEB Repository (Debian/Ubuntu)

```bash
# Add repository
echo "deb [trusted=yes] https://xibo-players.github.io/.github/deb/ubuntu/24.04 ./" | sudo tee /etc/apt/sources.list.d/xibo-players.list
sudo apt-get update

# Install packages
sudo apt-get install xiboplayer-electron
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

**Alternative: Using RPM Spec File**
```yaml
jobs:
  build-rpm:
    uses: xibo-players/.github/.github/workflows/build-rpm.yml@main
    with:
      package-name: 'xiboplayer-electron'
      build-command: 'pnpm run build:linux'
      rpm-spec: 'xiboplayer-electron.spec'  # Provide spec file instead of script
      rpm-output-dir: 'dist'
      node-version: '22'
      default-version: '0.2.0'
```

**Inputs:**
- `package-name` (required): RPM package name
- `build-command`: Build command before RPM (optional)
- `rpm-script`: Path to RPM build script (default: `build-rpm.sh`)
- `rpm-spec`: Path to RPM spec file (optional, e.g. `package.spec`). If provided, uses `rpmbuild` instead of `rpm-script`
- `rpm-output-dir`: Directory where RPM files are output (default: `dist`)
- `node-version`: Node.js version (default: `22`)
- `default-version`: Default version if not tagged (default: `0.2.0`)
- `release-body`: Custom release body markdown (optional)
- `publish-to-repo`: Publish to gh-pages repository (default: `true` - publishes on every build)
- `create-github-release`: Create GitHub Release for tags (default: `true` - only runs on tags)

**Features:**
- Uses Fedora 43 container for native RPM building
- Installs RPM build tools (rpm-build, rpmdevtools, createrepo_c)
- Runs optional build command with pnpm caching
- **Two build approaches supported:**
  - **Spec file approach**: Provide `.spec` file, workflow runs `rpmbuild` automatically
  - **Script approach**: Provide custom `build-rpm.sh` script for full control
- Validates spec file or build script exists before running
- **Publishes to gh-pages dnf repository on every successful build** (configurable)
- Creates GitHub releases for tags (configurable)
- **Publishes to gh-pages dnf repository with proper structure:**
  - `rpm/fedora/43/x86_64/` - 64-bit Intel/AMD packages
  - `rpm/fedora/43/aarch64/` - 64-bit ARM packages  
  - `rpm/fedora/43/noarch/` - Architecture-independent packages
- Automatically creates repository metadata with `createrepo_c`
- All RPM operations run in Fedora container for consistency

**Publishing Behavior:**

By default, RPMs are published to the yum/dnf repository on **every successful build**, making them immediately available to users. This means:
- ✅ Push to main → RPMs published
- ✅ Pull request builds → RPMs published (if workflow runs)
- ✅ Tagged releases → RPMs published + GitHub Release created
- ✅ Manual workflow runs → RPMs published

To disable automatic publishing, set `publish-to-repo: false` in your workflow call.

**Build Approaches:**

*Option 1: Using RPM Spec File (Recommended)*

Provide a `.spec` file and let the workflow handle `rpmbuild`:

```spec
Name:           xiboplayer-electron
Version:        0.2.0
Release:        1%{?dist}
Summary:        Xibo Player Electron Application

License:        AGPLv3+
URL:            https://github.com/xibo-players/xiboplayer-electron
Source0:        %{name}-%{version}.tar.gz

BuildArch:      x86_64
Requires:       libX11, libXrandr

%description
Xibo digital signage player built with Electron.

%prep
%setup -q

%install
mkdir -p %{buildroot}/opt/xiboplayer
cp -r dist/* %{buildroot}/opt/xiboplayer/

%files
/opt/xiboplayer/*

%changelog
* Mon Feb 17 2026 Builder <builder@example.com> - 0.2.0-1
- Initial RPM release
```

The workflow will:
- Setup rpmbuild directory structure
- Copy your spec file
- Update the version automatically
- Create source tarball from build artifacts
- Run `rpmbuild -bb` to build the RPM

*Option 2: Using Build Script*

For more control, provide a custom `build-rpm.sh` script:

```bash
#!/bin/bash
VERSION="$1"
# Your custom RPM build logic here
```

**Installing Published RPMs:**

Once your RPMs are published, users can install them from your gh-pages repository:

```bash
# Add the repository
sudo tee /etc/yum.repos.d/xibo-players.repo <<'EOF'
[xibo-players]
name=Xibo Players
baseurl=https://dl.xiboplayer.org/rpm/fedora/$releasever/$basearch/
enabled=1
gpgcheck=0
EOF

# Install your package
sudo dnf install your-package-name
```

Or use the setup script:

```bash
curl -fsSL https://dl.xiboplayer.org/scripts/setup-repo.sh | sudo bash
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

### 2. Build DEB (`build-deb.yml`)

Builds DEB packages for Debian/Ubuntu distributions and publishes them to an apt repository on gh-pages.

**Usage:**
```yaml
name: Build DEB

on:
  push:
    branches: [main]
    tags: ['v*']
  pull_request:
  workflow_dispatch:

jobs:
  build-deb:
    uses: xibo-players/.github/.github/workflows/build-deb.yml@main
    with:
      package-name: 'xiboplayer-electron'
      build-command: 'pnpm run build:linux'
      deb-script: 'build-deb.sh'
      deb-output-dir: 'dist'
      node-version: '22'
      default-version: '0.2.0'
```

**Inputs:**
- `package-name` (required): DEB package name
- `build-command`: Build command before DEB (optional)
- `deb-script`: Path to DEB build script (default: `build-deb.sh`)
- `deb-output-dir`: Directory where DEB files are output (default: `dist`)
- `node-version`: Node.js version (default: `22`)
- `default-version`: Default version if not tagged (default: `0.2.0`)
- `release-body`: Custom release body markdown (optional)
- `publish-to-repo`: Publish to gh-pages repository (default: `true`)
- `create-github-release`: Create GitHub Release for tags (default: `true`)
- `ubuntu-version`: Ubuntu version number for repository structure (default: `24.04`)

**Features:**
- Uses Ubuntu container for native DEB building
- Installs DEB build tools with dpkg-dev
- Runs optional build command with pnpm caching
- Validates DEB script exists before running
- Publishes to gh-pages apt repository on every successful build (configurable)
- Creates GitHub releases for tags (configurable)
- Publishes to gh-pages apt repository with proper structure:
  - `deb/ubuntu/24.04/amd64/` - 64-bit Intel/AMD packages
  - `deb/ubuntu/24.04/arm64/` - 64-bit ARM packages  
  - `deb/ubuntu/24.04/all/` - Architecture-independent packages
- Automatically creates repository metadata with `dpkg-scanpackages`

**Installing Published DEBs:**

Once your DEBs are published, users can install them from your gh-pages repository:

```bash
# Add the repository
echo "deb [trusted=yes] https://xibo-players.github.io/.github/deb/ubuntu/24.04 ./" | sudo tee /etc/apt/sources.list.d/xibo-players.list
sudo apt-get update

# Install your package
sudo apt-get install your-package-name
```

---

### 3. Build PWA (`build-pwa.yml`)

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

### 4. Publish to npm (`publish-npm.yml`)

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

### 5. Build ISO (`build-iso.yml`)

Builds bootable kiosk images for Xibo players. Three build paths run in parallel, each independently opt-in:

- **Disk images** — raw + QCOW2 disk images built with `mkosi` (pre-installed, boot directly)
- **Self-contained ISO** — offline-install Everything ISO with all packages bundled, built by remastering Fedora's netinstall ISO with `mkksiso`
- **Netinstall ISO** — lightweight installer that pulls packages from the network at install time, also via `mkksiso`

A single job controls the whole pipeline: preflight (waits for the current RPM version to land in the repo), then the three build jobs, then a release job that publishes checksums, creates/updates the GH release, and uploads assets.

**Production usage** (tag-triggered, uploads to R2, creates release):

```yaml
name: Build Kiosk Images

on:
  push:
    tags: ['v*']
  workflow_dispatch:

permissions:
  contents: write

jobs:
  build:
    uses: xibo-players/.github/.github/workflows/build-iso.yml@<pinned-sha>
    with:
      package-name: xiboplayer-kiosk
      kickstart-file: 'kickstart/xiboplayer-kiosk.ks'
      build-disk-images: true
      build-self-contained-iso: true
      build-netinstall: true
      architectures: 'x86_64,aarch64'
    secrets: inherit
```

**Required inputs:**

| Input | Type | Default | Description |
|-------|------|---------|-------------|
| `package-name` | string | — | Package name (e.g. `xiboplayer-kiosk`). Used for image file names and repo checks. |

**Build-path selectors** (at least one must be `true`):

| Input | Type | Default | Description |
|-------|------|---------|-------------|
| `build-disk-images` | bool | `true` | Build raw + QCOW2 via mkosi |
| `build-self-contained-iso` | bool | `false` | Build offline Everything ISO via mkksiso |
| `build-netinstall` | bool | `false` | Build lightweight netinstall ISO via mkksiso |

**Source files:**

| Input | Type | Default | Description |
|-------|------|---------|-------------|
| `kickstart-file` | string | `kickstart/xibo-kiosk.ks` | Path to Kickstart file consumed by mkksiso |
| `mkosi-config` | string | `mkosi.conf` | Path to mkosi config consumed by the disk-images job |
| `architectures` | string | `x86_64` | Comma-separated architecture list: `x86_64`, `aarch64`, or both |
| `default-version` | string | `0.2.0` | Fallback version. Unused in normal flows (version is read from tag → RPM spec → `package.json`). |

**Customization inputs** — pass through to `mkksiso` to override volume label, kernel cmdline, or grub.cfg text:

| Input | Type | Default | Description |
|-------|------|---------|-------------|
| `iso-volid` | string | `''` | Override the ISO volume ID (`mkksiso -V`). When set, remember to also rewrite the embedded grub.cfg label references via `iso-grub-replacements`. |
| `iso-cmdline-append` | string | `''` | Append to the installer kernel cmdline (`mkksiso -c`). Space-separated args. |
| `iso-cmdline-remove` | string | `''` | Remove args from the installer kernel cmdline (`mkksiso -r`). Space-separated, e.g. `'quiet rhgb splash'`. |
| `iso-grub-replacements` | string | `''` | Multiline text replacements for grub.cfg (`mkksiso -R`). One pair per line, pipe-separated: `FROM\|TO`. Applied with `sed -i` behavior to every menu entry. |

**Test-build inputs** — skip production gates for fast iteration:

| Input | Type | Default | Description |
|-------|------|---------|-------------|
| `skip-preflight` | bool | `false` | Skip the "wait for current RPM version to appear in dl.xiboplayer.org/rpm" preflight check. Use for test workflows that don't depend on a fresh RPM. |
| `upload-as-artifact` | bool | `false` | Upload the result as a GitHub Actions artifact (retention 14 days) instead of pushing to R2 and creating a release. Use for test builds. Also disables the `release` job at the end. |

---

#### Features

- **Self-contained Everything ISO**: mkksiso-based offline install — all packages pre-downloaded and baked onto the ISO. No network needed at install time.
- **Netinstall ISO**: mkksiso-based lightweight installer (~1.1 GB) — pulls packages from Fedora mirrors + our RPM repo at install time.
- **Disk images** (raw + QCOW2): built with mkosi — pre-installed, user just dds them to disk and boots.
- GNOME Kiosk session, auto-login, kiosk dispatcher script via `gnome-kiosk-script-session`
- Published to R2 at `https://images.xiboplayer.org/<package>/<version>/`
- GitHub Release auto-generated with download links and SHA256SUMS

#### What you need in the caller repo

1. **RPM spec file** (`rpm/*.spec`) with a literal `Version:` line — used by the version-detection job as a fallback when no git tag is present.
2. **Kickstart file** (referenced by `kickstart-file`) — drives the ISO builds.
3. **mkosi config** (`mkosi.conf` + `mkosi-extra/`) — drives the disk-images build.

#### Image types produced

| Type | Filename Pattern | Build job | Use case |
|------|------------------|-----------|----------|
| Everything ISO | `<pkg>-everything_<ver>_<arch>.iso` | `build-self-contained-iso` | Offline install on PCs, NUCs, signage boxes |
| Netinstall ISO | `<pkg>-netinstall_<ver>_<arch>.iso` | `build-netinstall` | Lightweight installer, needs network |
| QCOW2 | `<pkg>_<ver>_<arch>.qcow2` | `build-disk-images` | Virtual machines (QEMU/KVM, GNOME Boxes) |
| Raw (xz) | `<pkg>_<ver>_<arch>.raw.xz` | `build-disk-images` | dd to SD card / eMMC / SSD |

Images are uploaded to R2 at `https://images.xiboplayer.org/<package>/<version>/` and attached to the GitHub Release (files under 2 GB). A SHA256SUMS file and a `LATEST` pointer are written alongside.

#### Default credentials

- User: `xibo` / password: `xibo`
- Root: locked by default

---

#### Test-build workflow pattern

The `skip-preflight` + `upload-as-artifact` inputs enable a fast iteration loop for kickstart / mkosi-extra changes without needing to cut a new RPM version first. Combined with the customization inputs, you get full control over grub menu text, kernel cmdline, and which image variant gets built.

**Example — `xiboplayer-kiosk/.github/workflows/test-image.yml`**:

```yaml
name: Test Kiosk Image (netinstall x86_64 only)

on:
  workflow_dispatch:
  push:
    branches: ['fix/**', 'test/**']

permissions:
  contents: write

jobs:
  build:
    uses: xibo-players/.github/.github/workflows/build-iso.yml@<pinned-sha>
    with:
      package-name: xiboplayer-kiosk
      kickstart-file: 'kickstart/xiboplayer-kiosk.ks'
      # Only build the netinstall variant — fastest (~5 min)
      build-disk-images: false
      build-self-contained-iso: false
      build-netinstall: true
      architectures: 'x86_64'
      # Skip the "wait for RPM in repo" preflight — test builds don't
      # need a fresh RPM, they use the one already published
      skip-preflight: true
      # Upload result as GH Actions artifact, not to R2 or a release
      upload-as-artifact: true
      # Customize the ISO grub menu — preserves the verbs (Install /
      # Test this media / Rescue), only renames the product
      iso-grub-replacements: |
        Fedora 43|xiboplayer kiosk
      # Debug kernel cmdline — remove quiet splash, add verbose anaconda
      iso-cmdline-remove: 'quiet rhgb splash'
      iso-cmdline-append: 'systemd.log_level=debug inst.debug rd.shell rd.debug console=tty0 console=ttyS0,115200'
    secrets: inherit
```

**Iteration loop:**

```bash
# 1. Edit kickstart / mkosi-extra on a fix branch
git checkout -b fix/my-test
vim kickstart/xiboplayer-kiosk.ks

# 2. Push and trigger the test build
git commit -am "test: $topic" && git push
gh workflow run test-image.yml --ref fix/my-test

# 3. Wait ~5 min, download the artifact
gh run list --workflow=test-image.yml --limit 1
gh run download <run-id>

# 4. Boot in qemu and debug
qemu-system-x86_64 -enable-kvm -m 4G \
  -cdrom xiboplayer-kiosk-netinstall_*_x86_64.iso \
  -drive file=/tmp/test.qcow2,format=qcow2 \
  -serial mon:stdio
# serial console streams to your terminal thanks to console=ttyS0 in -c
```

**What each customization flag buys you:**

| Flag | Passed to `mkksiso` as | Effect |
|------|----------------------|--------|
| `iso-volid: xiboplayer-kiosk` | `-V xiboplayer-kiosk` | ISO volume label becomes `xiboplayer-kiosk`. Note: Fedora's default grub.cfg has `inst.stage2=hd:LABEL=Fedora-E-dvd-x86_64-43` hardcoded — if you override the volid without also rewriting the grub.cfg via `iso-grub-replacements`, anaconda won't find stage2 and the ISO won't boot. |
| `iso-cmdline-append: 'inst.debug'` | `-c inst.debug` | Appends `inst.debug` to every `menuentry`'s `linux` line in the embedded grub.cfg. |
| `iso-cmdline-remove: 'quiet rhgb splash'` | `-r 'quiet rhgb splash'` | Removes `quiet`, `rhgb`, `splash` from every `menuentry`'s `linux` line — unblocks verbose kernel + systemd output during install. |
| `iso-grub-replacements: 'Fedora 43\|xiboplayer kiosk'` | `-R 'Fedora 43' 'xiboplayer kiosk'` | Runs sed-style text replacement on grub.cfg. `Install Fedora 43` → `Install xiboplayer kiosk`, `Test this media & install Fedora 43` → `Test this media & install xiboplayer kiosk`, etc — preserves the verbs, only renames the product. Multiple lines → multiple `-R` flag pairs. |

**Common pitfalls:**

- **The pipe delimiter in `iso-grub-replacements` is parsed literally** — if your FROM or TO text contains a `|` character, you'll need to either escape it or use the non-pipe form (which isn't supported yet; file an issue).
- **mkksiso `-R` does a simple text replacement, not a menuentry rewrite** — you can't use it to DELETE an entry (e.g. remove the "Test this media" entry entirely). For full grub.cfg replacement, use `iso-grub-replacements` to neutralize the text OR post-process the ISO with xorriso (not currently wired into this workflow).
- **Don't set `iso-volid` without also providing the matching `iso-grub-replacements`** — the Fedora-provided grub.cfg references the volid in `inst.stage2=hd:LABEL=` and `inst.ks=hd:LABEL=`. Changing one without the other breaks the boot.
- **`skip-preflight: true` + a stale RPM version mismatch** — if your kickstart references packages at a version that isn't yet in the RPM repo, the install will fail at the `dnf install` step inside anaconda. The preflight gate exists precisely to prevent this; only skip it when you know the RPM version is unchanged.

---

### 6. Test (`test.yml`)

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
