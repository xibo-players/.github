# GitHub Copilot Instructions for Xibo Players Shared Workflows

## Repository Overview

This repository contains reusable GitHub Actions workflows for the Xibo Players project. It centralizes build, test, and publish workflows to maintain consistency and reduce duplication across all Xibo Players repositories.

## Purpose and Context

- **Primary Function**: Provide reusable GitHub Actions workflows for building and publishing various package types
- **Target Users**: Xibo Players developers and contributors across all related repositories
- **Key Technologies**: GitHub Actions, pnpm, Node.js, RPM/DEB packaging, mkosi, Fedora/Ubuntu containers

## Workflow Types

The repository maintains several reusable workflows:

1. **build-rpm.yml** - Builds RPM packages for Fedora/RHEL distributions
2. **build-deb.yml** - Builds DEB packages for Debian/Ubuntu distributions
3. **build-iso.yml** - Builds bootable kiosk images using mkosi
4. **build-pwa.yml** - Builds Progressive Web App distributions
5. **publish-npm.yml** - Publishes packages to npm registry
6. **test.yml** - Runs automated tests

## Coding Standards and Best Practices

### Workflow Development

- All workflows must use `workflow_call` trigger for reusability
- Define clear `inputs` with descriptions and sensible defaults
- Use semantic versioning for any versioned releases
- Always validate required inputs before running jobs
- Provide comprehensive error messages for debugging

### Input Parameters

- Required inputs must be explicitly marked with `required: true`
- Optional inputs should have meaningful defaults
- Boolean inputs should default to safe values (e.g., `publish-to-repo: true`)
- String inputs should include example values in descriptions

### Container Usage

- **RPM builds**: Use Fedora containers (currently Fedora 43)
- **DEB builds**: Use Ubuntu containers (currently Ubuntu 24.04)
- Always install required tools explicitly in workflow steps
- Pin container versions to ensure reproducible builds

### Publishing Behavior

- RPMs publish to: `rpm/fedora/{version}/{arch}/`
- DEBs publish to: `deb/ubuntu/{version}/{arch}/`
- ISOs publish to: `images/`
- All publishing goes to gh-pages branch
- Repository metadata is automatically generated (`createrepo_c` for RPM, `dpkg-scanpackages` for DEB)

### Node.js and pnpm

- Default Node.js version: 22
- Use pnpm for package management with caching enabled
- Always use `--frozen-lockfile` for reproducible installs
- Cache pnpm store for faster CI builds

## Architecture Support

The workflows support multiple architectures:

- **RPM**: x86_64, aarch64, noarch
- **DEB**: amd64, arm64, all
- **ISO/Images**: x86_64, aarch64

## File Structure Conventions

```
.github/workflows/        # Reusable workflow definitions
scripts/                  # Helper scripts
  ├── init-gh-pages.sh   # Initialize gh-pages branch
  ├── setup-repo.sh      # Repository setup script for users
  ├── mkosi/             # mkosi templates and configurations
  └── iso-build/         # Legacy ISO build scripts
```

## Testing and Validation

- Test workflow changes in branches before merging to main
- Validate workflows with actual consumer repositories
- Test both pull request and tag-triggered runs
- Ensure backwards compatibility when modifying existing workflows

## Common Tasks

### Adding a New Workflow

1. Create workflow file in `.github/workflows/`
2. Use `workflow_call` trigger
3. Define clear inputs and outputs
4. Add documentation to README.md
5. Test thoroughly in a consumer repository
6. Update version references if applicable

### Modifying Existing Workflows

1. Check for breaking changes
2. Update documentation in README.md
3. Test with existing consumer repositories
4. Consider backwards compatibility
5. Update examples if input signatures change

### Adding New Architecture Support

1. Update container matrix if needed
2. Add architecture-specific logic
3. Update repository structure for publishing
4. Test on actual hardware/VMs
5. Document in README.md

## Publishing and Release Process

- Workflows publish on every successful build by default
- GitHub Releases are created only for tags (starting with 'v')
- Tags should follow semantic versioning: `v1.0.0`
- Release bodies can be customized via `release-body` input

## Security Considerations

- Never commit secrets to the repository
- Use GitHub secrets for sensitive data (e.g., NPM_TOKEN)
- Validate all inputs to prevent injection attacks
- Use official GitHub Actions where possible
- Pin action versions to specific commits or tags

## Documentation Requirements

- All workflows must be documented in README.md
- Include usage examples with realistic input values
- Document all inputs with descriptions
- Explain publishing behavior and repository structure
- Provide installation instructions for published packages

## Debugging and Troubleshooting

- Use `--no-pager` with git commands to avoid interactive output
- Enable verbose logging in scripts when needed
- Validate file existence before operations
- Provide clear error messages in workflow failures
- Log architecture and version information for debugging

## Consumer Repository Integration

Consumers should:
1. Create simple caller workflows in their `.github/workflows/`
2. Reference workflows using `uses: xibo-players/.github/.github/workflows/{workflow-name}.yml@main`
3. Pass required inputs specific to their package
4. Configure necessary secrets in repository settings

Example consumer workflow:
```yaml
name: CI
on:
  push:
    branches: [main]
    tags: ['v*']

jobs:
  build-rpm:
    uses: xibo-players/.github/.github/workflows/build-rpm.yml@main
    with:
      package-name: 'my-package'
      build-command: 'pnpm run build:linux'
      node-version: '22'
```

## Important Notes for Copilot

- This repository focuses on GitHub Actions workflows, not application code
- Changes should maintain backwards compatibility with existing consumers
- All workflows use pnpm, not npm or yarn
- The gh-pages branch must be initialized before workflows can publish (see GH-PAGES-SETUP.md)
- Custom domain support is available (see CUSTOM-DOMAIN-SETUP.md)
- Minimize workflow changes - many repositories depend on these workflows

## Links and Resources

- GitHub Actions Documentation: https://docs.github.com/en/actions
- Reusable Workflows: https://docs.github.com/en/actions/using-workflows/reusing-workflows
- mkosi Documentation: https://github.com/systemd/mkosi
- RPM Packaging Guide: https://rpm-packaging-guide.github.io/
- Debian Packaging: https://www.debian.org/doc/manuals/maint-guide/
