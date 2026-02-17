# Publishing GitHub Pages

## Quick Start

To publish the GitHub Pages site for this repository:

1. **Go to Actions tab**: https://github.com/xibo-players/.github/actions
2. **Select workflow**: "Publish GitHub Pages"
3. **Click**: "Run workflow"
4. **Wait**: ~1 minute for completion
5. **Enable Pages**: Settings → Pages → Source: gh-pages branch

## What Gets Published

The workflow creates a GitHub Pages site with:

```
https://dnf.xiboplayer.org/
├── index.html                    # Main landing page
├── rpm/
│   ├── index.html               # RPM repository index
│   └── fedora/43/
│       ├── x86_64/              # x86_64 packages (published by workflows)
│       ├── aarch64/             # ARM64 packages (published by workflows)
│       └── noarch/              # Architecture-independent packages
├── images/
│   └── index.html               # Kiosk images index
└── scripts/
    └── setup-repo.sh            # Repository setup script
```

## URLs Available

After publishing and enabling GitHub Pages with custom domain:

- **Main page**: https://dnf.xiboplayer.org/
- **RPM repository**: https://dnf.xiboplayer.org/rpm/
- **Kiosk images**: https://dnf.xiboplayer.org/images/
- **Setup script**: https://dnf.xiboplayer.org/scripts/setup-repo.sh

**Note:** The custom domain `dnf.xiboplayer.org` is configured for cleaner URLs. See [CUSTOM-DOMAIN-SETUP.md](CUSTOM-DOMAIN-SETUP.md) for setup details.

## Workflow Details

**Workflow file**: `.github/workflows/publish-gh-pages.yml`

**Trigger**: Manual (`workflow_dispatch`)

**Options**:
- `force`: Overwrite existing gh-pages branch (default: false)

**What it does**:
1. Checks if gh-pages branch exists
2. Creates gh-pages content with proper structure
3. Copies setup-repo.sh script
4. Generates index.html files for all sections
5. Publishes to gh-pages branch using peaceiris/actions-gh-pages
6. Provides summary with URLs

## Re-publishing

To update the GitHub Pages site:

1. Run the workflow again with `force: true` option
2. Or manually delete the gh-pages branch and re-run

## Alternative: Using Build Workflows

The build workflows (build-rpm.yml, build-deb.yml, build-iso.yml) will automatically create the gh-pages branch if it doesn't exist when they need to publish artifacts. However, this approach may not create all the index pages initially.

## Enabling GitHub Pages

After the gh-pages branch is created:

1. Go to repository **Settings**
2. Navigate to **Pages** section (left sidebar)
3. Under **Source**:
   - Branch: `gh-pages`
   - Folder: `/ (root)`
4. Click **Save**
5. Wait a few minutes for deployment
6. Site will be available at https://dnf.xiboplayer.org/
7. **Custom Domain**: Configure dnf.xiboplayer.org in Settings → Pages → Custom domain

## Verifying Deployment

Check deployment status:
- Settings → Pages shows deployment URL (dnf.xiboplayer.org)
- Actions tab shows "pages-build-deployment" workflow
- Visit https://dnf.xiboplayer.org/ after a few minutes

## Troubleshooting

**Pages not showing?**
- Ensure gh-pages branch exists
- Check Settings → Pages is configured
- Wait 3-5 minutes for GitHub's CDN
- Check Actions tab for deployment errors

**404 errors?**
- Verify branch name is exactly "gh-pages"
- Ensure folder is set to "/" not "/docs"
- Check files exist in gh-pages branch: `git ls-tree gh-pages`

**Need to republish?**
- Run workflow with `force: true`
- Or delete gh-pages branch: `git push origin --delete gh-pages`
- Then run workflow again

## Continuous Updates

Once gh-pages exists, the RPM and image publishing workflows will automatically:
- Add new RPMs to rpm/fedora/43/{arch}/
- Create repository metadata with createrepo_c
- Add new kiosk images to images/
- Update the site automatically

No need to manually re-run this workflow unless you want to reset the structure.
