# Setting Up dnf.xiboplayer.org Custom Domain

This guide explains how to configure **dnf.xiboplayer.org** to host your RPM repository and GitHub Pages content.

## Overview

Instead of using the default GitHub Pages URL (`xibo-players.github.io/.github`), you can use your custom domain `dnf.xiboplayer.org` for a cleaner, more professional URL structure.

**Result:**
- Repository URLs: `https://dnf.xiboplayer.org/rpm/fedora/43/x86_64/`
- Setup script: `https://dnf.xiboplayer.org/scripts/setup-repo.sh`
- Documentation: `https://dnf.xiboplayer.org/`

## Prerequisites

- Domain ownership: `xiboplayer.org`
- Access to DNS management for the domain
- Admin access to this GitHub repository

## Step 1: Configure DNS Records

Add a CNAME record in your DNS provider's control panel:

### DNS Configuration

| Type  | Name | Value                          | TTL  |
|-------|------|--------------------------------|------|
| CNAME | dnf  | xibo-players.github.io.        | 3600 |

**Important:** Note the trailing dot (`.`) after `github.io` - some DNS providers require it.

### Common DNS Providers

**Cloudflare:**
1. Log in to Cloudflare
2. Select your domain `xiboplayer.org`
3. Go to DNS → Records
4. Click "Add record"
5. Type: `CNAME`
6. Name: `dnf`
7. Target: `xibo-players.github.io`
8. Proxy status: DNS only (gray cloud icon)
9. Click Save

**GoDaddy:**
1. Log in to GoDaddy
2. My Products → DNS
3. Click "Add" under Records
4. Type: `CNAME`
5. Host: `dnf`
6. Points to: `xibo-players.github.io`
7. TTL: 1 Hour
8. Click Save

**Namecheap:**
1. Log in to Namecheap
2. Domain List → Manage
3. Advanced DNS
4. Add New Record
5. Type: `CNAME Record`
6. Host: `dnf`
7. Value: `xibo-players.github.io.`
8. Click Save

### Verify DNS Propagation

Wait 5-10 minutes, then verify the DNS record:

```bash
# Check DNS resolution
nslookup dnf.xiboplayer.org

# Or use dig
dig dnf.xiboplayer.org CNAME +short
```

Expected output: `xibo-players.github.io.`

## Step 2: Configure GitHub Pages Custom Domain

### Via GitHub Web Interface

1. Go to repository: https://github.com/xibo-players/.github
2. Navigate to **Settings** → **Pages**
3. Under "Custom domain", enter: `dnf.xiboplayer.org`
4. Click **Save**
5. Wait a few minutes for DNS verification
6. Once verified, check "Enforce HTTPS" (recommended)

### Via Git (Alternative Method)

Create a CNAME file in the gh-pages branch:

```bash
# Switch to gh-pages branch
git checkout gh-pages

# Create CNAME file
echo "dnf.xiboplayer.org" > CNAME

# Commit and push
git add CNAME
git commit -m "Add custom domain"
git push origin gh-pages
```

## Step 3: Update Workflow to Use Custom Domain

Update `.github/workflows/build-rpm.yml` to reference the custom domain in documentation.

### Find and Update Index.html

In the "Create repository documentation" step, update the baseurl references:

**Before:**
```yaml
baseurl=https://xibo-players.github.io/.github/rpm/fedora/$releasever/$basearch/
```

**After:**
```yaml
baseurl=https://dnf.xiboplayer.org/rpm/fedora/$releasever/$basearch/
```

## Step 4: Verify Setup

### Check GitHub Pages Status

1. Go to repository Settings → Pages
2. You should see: "Your site is published at https://dnf.xiboplayer.org"
3. Status should show a green checkmark

### Test URLs

Once DNS propagation is complete and GitHub verifies the domain (usually 5-30 minutes):

```bash
# Test main page
curl -I https://dnf.xiboplayer.org/

# Test RPM repository
curl -I https://dnf.xiboplayer.org/rpm/

# Test architecture-specific repo
curl -I https://dnf.xiboplayer.org/rpm/fedora/43/x86_64/
```

All should return `200 OK` or `301/302` redirects.

### Test DNF Repository

Configure DNF to use the custom domain:

```bash
# Create repo configuration
sudo tee /etc/yum.repos.d/xibo-players.repo <<'EOF'
[xibo-players]
name=Xibo Players
baseurl=https://dnf.xiboplayer.org/rpm/fedora/$releasever/$basearch/
enabled=1
gpgcheck=0
EOF

# Query available packages
dnf repoquery --repofrompath=xibo,https://dnf.xiboplayer.org/rpm/fedora/43/x86_64/ --available
```

## Step 5: Update Documentation

Update references in these files to use the new custom domain:

### Files to Update

1. **RPMS.md** - Update all URLs from `xibo-players.github.io/.github` to `dnf.xiboplayer.org`
2. **README.md** - Update repository URLs
3. **scripts/setup-repo.sh** - Update script URLs if they exist

### Example Updates

**Before:**
```
https://xibo-players.github.io/.github/rpm/
```

**After:**
```
https://dnf.xiboplayer.org/rpm/
```

## Troubleshooting

### DNS Not Resolving

**Problem:** `nslookup dnf.xiboplayer.org` returns no results

**Solutions:**
1. Wait longer - DNS can take up to 48 hours to propagate globally
2. Check your DNS provider's control panel for typos
3. Ensure CNAME points to `xibo-players.github.io` (not `.github`)
4. Some providers need trailing dot: `xibo-players.github.io.`

### GitHub Pages Shows "Domain's DNS record could not be retrieved"

**Problem:** GitHub can't verify your custom domain

**Solutions:**
1. Wait 10-30 minutes after creating DNS record
2. Temporarily disable "Enforce HTTPS"
3. Remove and re-add the custom domain
4. Check DNS with `dig dnf.xiboplayer.org CNAME +short`
5. Ensure CNAME points to `xibo-players.github.io` (not the full path)

### HTTPS Certificate Issues

**Problem:** Browser shows certificate warnings

**Solutions:**
1. Wait up to 24 hours for GitHub to provision Let's Encrypt certificate
2. Ensure DNS is properly configured first
3. Try toggling "Enforce HTTPS" off and on
4. If Cloudflare: Set SSL/TLS mode to "Full" (not "Flexible")

### 404 Errors After Custom Domain Setup

**Problem:** Pages return 404 after custom domain is configured

**Solutions:**
1. Ensure CNAME file exists in gh-pages branch root
2. Verify GitHub Pages is enabled and set to gh-pages branch
3. Check that files exist in gh-pages branch: `git ls-tree -r gh-pages`
4. Clear browser cache or test in incognito mode

### Mixed Content Warnings

**Problem:** HTTP/HTTPS mixed content issues

**Solutions:**
1. Update all internal links to use relative paths or HTTPS
2. In workflow files, use `https://dnf.xiboplayer.org`
3. Enable "Enforce HTTPS" in GitHub Pages settings

## Advanced: Subdirectory Setup

If you want to use paths like `https://dnf.xiboplayer.org/` for the root:

1. Keep gh-pages branch structure as-is
2. All content in gh-pages branch root will be at `https://dnf.xiboplayer.org/`
3. RPM repo: `https://dnf.xiboplayer.org/rpm/`
4. No path prefix needed - cleaner URLs!

## Post-Setup Checklist

- [ ] DNS CNAME record created and verified
- [ ] GitHub Pages custom domain configured
- [ ] HTTPS enabled and certificate issued
- [ ] Workflow files updated with new domain
- [ ] Documentation files updated (RPMS.md, README.md)
- [ ] Test URLs returning 200 OK
- [ ] DNF repository query working
- [ ] SSL certificate valid (no browser warnings)

## Example DNF Configuration (Final)

After complete setup, users will configure their systems with:

```bash
# Add repository
sudo tee /etc/yum.repos.d/xibo-players.repo <<'EOF'
[xibo-players]
name=Xibo Players
baseurl=https://dnf.xiboplayer.org/rpm/fedora/$releasever/$basearch/
enabled=1
gpgcheck=0
EOF

# Install packages
sudo dnf install xiboplayer-electron xiboplayer-chromium
```

Much cleaner than the GitHub Pages default URL! 🎉

## Support

If you encounter issues:
1. Check [GitHub Pages documentation](https://docs.github.com/en/pages/configuring-a-custom-domain-for-your-github-pages-site)
2. Verify DNS with online tools: https://dnschecker.org/
3. Review GitHub Pages status at repository Settings → Pages
4. Check workflow logs for any errors

## Security Considerations

### HTTPS/SSL
- Always enable "Enforce HTTPS" in GitHub Pages settings
- GitHub automatically provisions Let's Encrypt certificates
- Certificates renew automatically

### Cloudflare (Optional)
For additional DDoS protection and CDN:
1. Add domain to Cloudflare
2. Use Cloudflare nameservers
3. Set SSL/TLS to "Full"
4. Enable "Always Use HTTPS"

This provides:
- DDoS protection
- Global CDN caching
- Analytics
- Faster page loads

**Note:** With Cloudflare proxy enabled (orange cloud), DNS points to Cloudflare IPs, which then proxies to GitHub Pages.
