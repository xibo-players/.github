<img alt="XiboPlayer" src="https://dl.xiboplayer.org/logo-192.png" width="64">

### Open-source digital signage players for [Xibo CMS](https://xibosignage.com)

Turn any Linux PC, Raspberry Pi, or web browser into a digital signage display. Cross-platform, offline-first, cross-device video walls, and built on a modular TypeScript SDK with 1412 tests.

> **Community project** — not affiliated with Xibo Signage Ltd. [Xibo](https://xibosignage.com) is a trademark of Xibo Ltd.

---

## Quickstart: flash and boot

Download a [pre-built kiosk image](https://github.com/xibo-players/xiboplayer-kiosk/releases/latest), flash it, and connect to your CMS. That's it.

| Hardware | Image | Instructions |
|----------|-------|--------------|
| PC / laptop | [ISO installer](https://github.com/xibo-players/xiboplayer-kiosk/releases/latest) | Flash to USB, boot — fully automated install |
| Raspberry Pi 4/5 | [Raw aarch64](https://github.com/xibo-players/xiboplayer-kiosk/releases/latest) | Flash `.raw.xz` to SD card, insert, power on |
| Virtual machine | [QCOW2](https://github.com/xibo-players/xiboplayer-kiosk/releases/latest) | Open in GNOME Boxes, virt-manager, Proxmox, or QEMU |
| Intel NUC / embedded | [Raw x86_64](https://github.com/xibo-players/xiboplayer-kiosk/releases/latest) | Flash `.raw.xz` to SSD or SD card |

Default login: `xibo` / `xibo` — change your password, then connect to your CMS from the setup screen.

## Choose your player

| Player | What it does | Platforms |
|--------|-------------|-----------|
| [**Electron**](https://github.com/xibo-players/xiboplayer-electron) | Self-contained desktop app with built-in browser. Production-ready kiosk with GPU acceleration, systemd integration, and multi-instance support. | RPM, DEB — x86_64, aarch64 |
| [**Chromium Kiosk**](https://github.com/xibo-players/xiboplayer-chromium) | Lightweight — uses the system Chromium browser. Smallest footprint (~5 MB). | RPM, DEB — noarch |
| [**PWA**](https://github.com/xibo-players/xiboplayer/tree/main/packages/pwa) | Browser-based engine that powers all players. Deploy on your CMS and open a URL — zero installation. | Any modern browser |
| [**Xibo Kiosk**](https://github.com/xibo-players/xiboplayer-kiosk) | Complete kiosk OS — GNOME Kiosk session with auto-login, registration wizard, health monitoring. Pre-built bootable images. | ISO, QCOW2, raw |
| [**arexibo**](https://github.com/xibo-players/arexibo) | Native Rust player with Qt6 WebEngine. Serial port control for industrial signage. | RPM, DEB — x86_64, aarch64 |

## Install on existing Linux

**Fedora 43+**
```bash
sudo dnf install \
  https://github.com/xibo-players/xibo-players.github.io/releases/download/v43-5/xiboplayer-release-43-5.noarch.rpm

sudo dnf install xiboplayer-kiosk        # Full kiosk environment
sudo dnf install xiboplayer-electron     # Electron player
sudo dnf install xiboplayer-chromium     # Chromium kiosk
sudo dnf install arexibo                 # Native Rust player
```

**Ubuntu 24.04**
```bash
curl -fsSL https://dl.xiboplayer.org/deb/GPG-KEY.asc \
  | sudo gpg --dearmor -o /usr/share/keyrings/xibo-players.gpg

sudo curl -fsSL https://dl.xiboplayer.org/deb/xibo-players.sources \
  -o /etc/apt/sources.list.d/xibo-players.sources

sudo apt update && sudo apt install xiboplayer-kiosk
```

## SDK

All players are built on the **[@xiboplayer SDK](https://github.com/xibo-players/xiboplayer)** — 13 modular TypeScript packages for caching, rendering, scheduling, CMS communication (SOAP + REST), XMR real-time commands, multi-display sync, and more.

```bash
npm install @xiboplayer/core @xiboplayer/renderer @xiboplayer/cache @xiboplayer/schedule @xiboplayer/xmds
```

## Links

| | |
|---|---|
| **[xiboplayer.org](https://xiboplayer.org)** | Documentation, features, and guides |
| **[dl.xiboplayer.org](https://dl.xiboplayer.org)** | Browse packages, images, and setup instructions |
| **[Feature comparison](https://dl.xiboplayer.org/docs/FEATURE_COMPARISON)** | ~96% parity with unique capabilities vs upstream players |
| **[npm packages](https://www.npmjs.com/org/xiboplayer)** | 13 SDK packages on npm |
