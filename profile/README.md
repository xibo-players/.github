<img alt="XiboPlayer" src="https://www.xiboplayer.org/logo-192.png" width="64">

### Free open-source signage players for [Xibo CMS](https://xibosignage.com)

Turn any Linux PC, Raspberry Pi, Android device or web browser into a digital signage display. Cross-platform, offline-first, cross-device video walls, GPU-accelerated and built on a modular TypeScript SDK with 1629 tests.

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
  https://dl.xiboplayer.org/rpm/fedora/43/noarch/xiboplayer-release-43-7.fc43.noarch.rpm

sudo dnf install xiboplayer-kiosk        # Full kiosk environment
sudo dnf install xiboplayer-electron     # Electron player
sudo dnf install xiboplayer-chromium     # Chromium kiosk
sudo dnf install arexibo                 # Native Rust player
```

**Debian Trixie / Ubuntu 24.04 / Raspberry Pi OS**
```bash
curl -fsSL https://dl.xiboplayer.org/deb/DEB-GPG-KEY-xiboplayer | \
  sudo tee /etc/apt/keyrings/xiboplayer.asc > /dev/null
echo "deb [signed-by=/etc/apt/keyrings/xiboplayer.asc] https://dl.xiboplayer.org/deb/debian/trixie ./" | \
  sudo tee /etc/apt/sources.list.d/xiboplayer.list

sudo apt update && sudo apt install xiboplayer-chromium
```

## SDK

All players are built on the **[@xiboplayer SDK](https://github.com/xibo-players/xiboplayer)** — 14 modular TypeScript packages for caching, rendering, scheduling, CMS communication (SOAP + REST), XMR real-time commands, multi-display sync, and more.

```bash
npm install @xiboplayer/core @xiboplayer/renderer @xiboplayer/cache @xiboplayer/schedule @xiboplayer/xmds
```

## Links

| | |
|---|---|
| **[xiboplayer.org](https://www.xiboplayer.org)** | Players, guides, downloads and documentation |
| **[Feature comparison](https://www.xiboplayer.org/features/comparison)** | 53 features, 5% CPU, zero memory leaks — vs upstream players |
| **[Blog](https://www.xiboplayer.org/blog)** | Guides and tutorials about digital signage |
| **[Downloads](https://www.xiboplayer.org/downloads)** | Bootable images, RPM and DEB packages |
| **[npm packages](https://www.npmjs.com/org/xiboplayer)** | 14 SDK packages on npm |
