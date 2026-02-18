# Xibo Players

Open-source digital signage players for [Xibo CMS](https://xibosignage.com).

> **Note:** This is an independent open-source project and is **not affiliated with, endorsed by, or supported by [Xibo Signage Ltd](https://xibosignage.com)**. These are community-built players provided as-is, with no warranty. Use at your own risk.

## Players

| Package | Platform | Description |
|---------|----------|-------------|
| [xibo-kiosk](https://github.com/xibo-players/xibo-kiosk) | Fedora / Ubuntu | GNOME Kiosk session with auto-login, registration wizard, and health monitoring |
| [xiboplayer-electron](https://github.com/xibo-players/xiboplayer-electron) | Fedora | Electron-based player with offline support and service worker caching |
| [xiboplayer-chromium](https://github.com/xibo-players/xiboplayer-chromium) | Fedora | Chromium kiosk wrapper for the PWA player |
| [arexibo](https://github.com/xibo-players/arexibo) | Fedora / Ubuntu | Native Rust player with Qt6 WebEngine (x86_64 + aarch64) |

## Quick install

**Fedora 43 (DNF)**
```bash
sudo dnf config-manager addrepo \
  --set=baseurl=https://dnf.xiboplayer.org/rpm/fedora/43/\$basearch/ \
  --set=gpgcheck=0 \
  --id=xibo-players

sudo dnf install xibo-kiosk xiboplayer-electron
```

**Ubuntu 24.04 (APT)**
```bash
echo "deb [trusted=yes] https://dnf.xiboplayer.org/deb/ubuntu/24.04 all/" \
  | sudo tee /etc/apt/sources.list.d/xibo-players.list

sudo apt update && sudo apt install xibo-kiosk
```

## Package repository

Browse packages and setup instructions at [dnf.xiboplayer.org](https://dnf.xiboplayer.org).
