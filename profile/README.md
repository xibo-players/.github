# Xibo Players

Open-source digital signage players for [Xibo CMS](https://xibosignage.com). Turn any PC, Raspberry Pi, or browser into a signage display.

> **Disclaimer:** This is an independent community project. Not affiliated with [Xibo Signage Ltd](https://xibosignage.com) or the Xibo Digital Signage project. Xibo is a registered trademark of Xibo Ltd.

## Players

| Player | Description | Platform |
|--------|-------------|----------|
| **[PWA Player](https://github.com/xibo-players/xiboplayer-pwa)** | Browser-based player — the engine that powers all other players. Offline-first with Service Worker caching. Supports video, images, PDF, tickers, web pages, HLS. | Any browser |
| **[Electron Player](https://github.com/xibo-players/xiboplayer-electron)** | Desktop app wrapping the PWA. Standalone window with DevTools. Best for development and testing. | RPM / DEB |
| **[Chromium Kiosk](https://github.com/xibo-players/xiboplayer-chromium)** | Locked-down Chromium running the PWA. Lightweight alternative to Electron. | RPM / DEB |
| **[Xibo Kiosk](https://github.com/xibo-players/xibo-kiosk)** | Complete kiosk OS — GNOME Kiosk session with auto-login, registration wizard, health monitoring. Pre-built bootable images for PCs and Raspberry Pi. | RPM / DEB / ISO / QCOW2 |
| **[arexibo](https://github.com/xibo-players/arexibo)** | Native Rust player with Qt6 WebEngine. High performance, x86_64 + aarch64. | RPM / DEB |

## Getting started

The easiest way is to download a pre-built kiosk image — flash it, boot and connect to your CMS:

| Hardware | Image | What to do |
|----------|-------|------------|
| **PC or laptop** | [Installer ISO](https://github.com/xibo-players/xibo-kiosk/releases/latest) | Flash to USB with [Balena Etcher](https://etcher.balena.io/), boot — automated install |
| **Raspberry Pi 4/5** | [Raw aarch64](https://github.com/xibo-players/xibo-kiosk/releases/latest) | Flash `.raw.xz` to SD card, insert, power on |
| **Virtual machine** | [QCOW2](https://github.com/xibo-players/xibo-kiosk/releases/latest) | Open in GNOME Boxes, virt-manager, Proxmox, or QEMU |
| **Intel NUC / embedded** | [Raw x86_64](https://github.com/xibo-players/xibo-kiosk/releases/latest) | Flash `.raw.xz` to SSD or SD card |

**After booting:** log in with `xibo` / `xibo`, change your password, connect to your CMS from the setup screen.

## Install packages on existing Linux

Already running Fedora or Ubuntu? Add our repo and install with one command.

**Fedora 43**
```bash
sudo dnf config-manager addrepo \
  --from-repofile=https://dnf.xiboplayer.org/rpm/xibo-players.repo

sudo dnf install xibo-kiosk            # Full kiosk OS
sudo dnf install xiboplayer-electron   # Electron player
sudo dnf install xiboplayer-chromium   # Chromium kiosk
sudo dnf install arexibo               # Native Rust player
```

**Ubuntu 24.04**
```bash
curl -fsSL https://dnf.xiboplayer.org/deb/GPG-KEY.asc \
  | sudo gpg --dearmor -o /usr/share/keyrings/xibo-players.gpg

sudo curl -fsSL https://dnf.xiboplayer.org/deb/xibo-players.sources \
  -o /etc/apt/sources.list.d/xibo-players.sources

sudo apt update && sudo apt install xibo-kiosk
```

## SDK

All players are built on the **[@xiboplayer SDK](https://github.com/xibo-players/xiboplayer)** — a modular TypeScript library with packages for caching, rendering, scheduling, XMDS communication, XMR real-time commands, and more. Published to [npm](https://www.npmjs.com/org/xiboplayer).

An [MCP Server](https://github.com/xibo-players/xiboplayer/tree/main/mcp-server) is available for AI-assisted development with the SDK.

## Links

- **[dnf.xiboplayer.org](https://dnf.xiboplayer.org)** — Browse packages, images, and setup instructions
- **[Kiosk images](https://github.com/xibo-players/xibo-kiosk/releases/latest)** — Download bootable ISO, QCOW2, and raw images
- **[npm packages](https://www.npmjs.com/org/xiboplayer)** — SDK packages on npm
