Turn any Linux PC, Raspberry Pi or virtual machine into a digital signage kiosk. Download an image, flash it, boot and connect to your [Xibo CMS](https://xibosignage.com). That's it.

> **Community project** — not affiliated with Xibo Signage Ltd. [Xibo](https://xibosignage.com) is a trademark of Xibo Ltd.

---

## Get started in minutes

Download a ready-made kiosk image. Flash to USB or SD card, boot and your display is ready. No Linux experience needed.

<table>
<tr>
<td width="25%" align="center" valign="top">

**🖥️ PC / laptop**

Flash to USB, boot.<br>Fully offline — no network needed.

[Download ISO](https://github.com/xibo-players/xiboplayer-kiosk/releases/latest)

</td>
<td width="25%" align="center" valign="top">

**🍓 Raspberry Pi 4/5**

Flash `.raw.xz` to SD card.<br>Insert, power on, done.

[Download image](https://github.com/xibo-players/xiboplayer-kiosk/releases/latest)

</td>
<td width="25%" align="center" valign="top">

**💻 Virtual machine**

Open in GNOME Boxes,<br>virt-manager or QEMU.

[Download QCOW2](https://github.com/xibo-players/xiboplayer-kiosk/releases/latest)

</td>
<td width="25%" align="center" valign="top">

**🔧 NUC / embedded**

Flash to SSD or eMMC.<br>Works on any x86_64 board.

[Download image](https://github.com/xibo-players/xiboplayer-kiosk/releases/latest)

</td>
</tr>
</table>

Default login: `xibo` / `xibo` — change your password after first boot.

**[All images and downloads](https://www.xiboplayer.org/downloads/)** | **[First-boot guide](https://www.xiboplayer.org/guide/first-boot)** | **[Quick start](https://www.xiboplayer.org/guide/quick-start)**

---

## Install on existing Linux

Already have Fedora, Ubuntu or Debian? Add the repo and install.

**Fedora**
```bash
sudo dnf install https://dl.xiboplayer.org/rpm/fedora/43/noarch/xiboplayer-release-43-7.fc43.noarch.rpm
sudo dnf install xiboplayer-kiosk xiboplayer-electron
```

**Ubuntu / Debian / Raspberry Pi OS**
```bash
curl -fsSL https://dl.xiboplayer.org/deb/DEB-GPG-KEY-xiboplayer | \
  sudo tee /etc/apt/keyrings/xiboplayer.asc > /dev/null
echo "deb [signed-by=/etc/apt/keyrings/xiboplayer.asc] https://dl.xiboplayer.org/deb/debian/trixie ./" | \
  sudo tee /etc/apt/sources.list.d/xiboplayer.list
sudo apt update && sudo apt install xiboplayer-kiosk xiboplayer-electron
```

**[Full installation guide](https://www.xiboplayer.org/downloads/)**

---

## Players

Multiple player implementations to fit your hardware and use case.

| Player | Description | Platforms |
|--------|-------------|-----------|
| [**Electron**](https://github.com/xibo-players/xiboplayer-electron) | Full-featured desktop app with GPU acceleration and multi-instance support | RPM, DEB — x86_64, aarch64 |
| [**Chromium Kiosk**](https://github.com/xibo-players/xiboplayer-chromium) | Lightweight — uses system Chromium, smallest footprint (~5 MB) | RPM, DEB — noarch |
| [**PWA**](https://github.com/xibo-players/xiboplayer/tree/main/packages/pwa) | Browser-based player — open a URL, zero installation | Any modern browser |
| [**arexibo**](https://github.com/xibo-players/arexibo) | Native Rust player with Qt6 WebEngine and serial port control | RPM, DEB — x86_64, aarch64 |
| [**Kiosk**](https://github.com/xibo-players/xiboplayer-kiosk) | Complete kiosk OS — GNOME Kiosk session, auto-login, health monitoring | ISO, QCOW2, raw images |

Switch players at any time: `doas alternatives --config xiboplayer`

**[Player comparison](https://www.xiboplayer.org/features/comparison)** | **[All players](https://www.xiboplayer.org/players)**

---

## SDK

All players are built on the **[@xiboplayer SDK](https://github.com/xibo-players/xiboplayer)** — 14 modular TypeScript packages for building digital signage applications.

Caching, rendering, scheduling, CMS communication (SOAP + REST), XMR real-time commands, multi-display sync and more.

```bash
npm install @xiboplayer/core @xiboplayer/renderer @xiboplayer/cache @xiboplayer/schedule @xiboplayer/xmds
```

**[SDK documentation](https://www.xiboplayer.org/sdk)** | **[npm packages](https://www.npmjs.com/org/xiboplayer)**

---

## Links

| | |
|---|---|
| **[xiboplayer.org](https://www.xiboplayer.org)** | Website — players, guides, downloads |
| **[Downloads](https://www.xiboplayer.org/downloads)** | Bootable images, RPM and DEB packages |
| **[Features](https://www.xiboplayer.org/features)** | Feature comparison vs upstream players |
| **[Blog](https://www.xiboplayer.org/blog)** | Guides and tutorials |
| **[First-boot guide](https://www.xiboplayer.org/guide/first-boot)** | Post-install setup steps |
