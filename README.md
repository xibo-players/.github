# Xibo Players - Shared GitHub Workflows

This repository contains reusable GitHub Actions workflows that can be used across all Xibo Players repositories. By centralizing workflows here, we maintain consistency and reduce duplication.

## Available Workflows

### 1. Build RPM (`build-rpm.yml`)

Builds RPM packages for Linux distributions.

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
- Publishes to gh-pages dnf repository

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

### 4. Test (`test.yml`)

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
