# Security Policy

## Reporting a Vulnerability

If you discover a security vulnerability in any `xibo-players` repository,
please report it privately to the maintainer rather than opening a public
issue.

**Email:** Pau Aliagas <linuxnow@gmail.com>

Please include:

- Which repository and version are affected
- A clear description of the vulnerability
- Steps to reproduce, if known
- Any proof-of-concept code or screenshots
- Your assessment of severity and potential impact

## Response

- **Acknowledgement**: we aim to acknowledge receipt within 3 business days.
- **Assessment**: initial assessment and severity classification within 7 days.
- **Fix**: critical issues are prioritised for immediate patching; non-critical
  issues are scheduled on the next release cycle.
- **Disclosure**: we coordinate disclosure with reporters. Credit is given in
  release notes where the reporter wishes.

## Supported Versions

Only the latest release of each component is actively maintained for security
updates. Older releases may receive fixes for critical vulnerabilities at our
discretion.

## Scope

This policy applies to all repositories in the
[xibo-players](https://github.com/xibo-players) organisation. For
vulnerabilities in upstream Xibo CMS, please report to the Xibo project at
[xibosignage/xibo-cms](https://github.com/xibosignage/xibo-cms).

## Out of Scope

- Security issues in third-party dependencies — report those to the upstream
  project first; we will accept fixes that land in our ecosystem via rebase.
- Social engineering attacks, physical access, and issues requiring privileged
  access to a running player.
