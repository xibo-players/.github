#!/usr/bin/env bash
# lib-deb.sh — Shared DEB packaging functions for xibo-players
# Source this from per-repo build-deb.sh scripts.
#
# Required variables (set by caller before calling functions):
#   PKG_NAME        — package name (e.g. xiboplayer-electron)
#   VERSION         — package version (e.g. 0.6.0)
#   RELEASE         — package release (e.g. 1)
#   SCRIPT_DIR      — directory of the calling script
#
# Optional variables (set by caller for specific functions):
#   PKG_ARCH        — architecture (default: auto-detect)
#   PKG_DEPENDS     — Depends line
#   PKG_RECOMMENDS  — Recommends line (optional)
#   PKG_CONFLICTS   — Conflicts line (optional)
#   PKG_DESCRIPTION — single-line description
#   PKG_DESCRIPTION_LONG — multi-line description body (indented with space)
#   PKG_HOMEPAGE    — homepage URL (default: https://xiboplayer.org)
#   PKG_MAINTAINER  — maintainer (default: Pau Aliagas <linuxnow@gmail.com>)
#   PKG_SECTION     — section (default: misc)
#   PKG_INSTALLED_SIZE — installed size in KB (optional, auto-calculated if empty)
#
#   ALT_NAME        — alternatives name (e.g. xiboplayer)
#   ALT_LINK        — alternatives link (e.g. /usr/bin/xiboplayer)
#   ALT_PATH        — alternatives path (e.g. /usr/bin/xiboplayer-chromium)
#   ALT_PRIORITY    — alternatives priority (e.g. 50)
#
#   DIST_DIR        — output directory for packages (default: $SCRIPT_DIR/dist)
#   BUILD_ROOT      — build directory (default: $SCRIPT_DIR/_debbuild)
#
# Exported for use by callers:
#   PKGDIR          — the package root directory ($BUILD_ROOT/$PKG_NAME)
#   ARCH            — resolved architecture
#   ELECTRON_ARCH   — x64/arm64 (only set by pkg_detect_arch)

set -euo pipefail

# ── Architecture detection ────────────────────────────────────────────

pkg_detect_arch() {
    case "$(uname -m)" in
        x86_64)  ARCH="amd64"; ELECTRON_ARCH="x64" ;;
        aarch64) ARCH="arm64"; ELECTRON_ARCH="arm64" ;;
        *)       echo "ERROR: Unsupported architecture: $(uname -m)"; exit 1 ;;
    esac
    export ARCH ELECTRON_ARCH
}

# ── Version parsing ───────────────────────────────────────────────────

pkg_parse_version() {
    VERSION="${1:-${VERSION:-0.6.0}}"
    RELEASE="${2:-${RELEASE:-1}}"
    export VERSION RELEASE
    echo "==> Building ${PKG_NAME}-${VERSION}-${RELEASE} DEB"
}

# ── Directory tree ────────────────────────────────────────────────────

pkg_create_deb_tree() {
    BUILD_ROOT="${BUILD_ROOT:-${SCRIPT_DIR}/_debbuild}"
    PKGDIR="${BUILD_ROOT}/${PKG_NAME}"
    DIST_DIR="${DIST_DIR:-${SCRIPT_DIR}/dist}"

    rm -rf "$BUILD_ROOT"
    mkdir -p "$PKGDIR/DEBIAN"
    mkdir -p "$PKGDIR/usr/bin"
    mkdir -p "$PKGDIR/usr/lib/systemd/user"
    mkdir -p "$PKGDIR/usr/share/applications"
    mkdir -p "$PKGDIR/usr/share/icons/hicolor/256x256/apps"
    mkdir -p "$PKGDIR/usr/share/doc/${PKG_NAME}"
    mkdir -p "$DIST_DIR"

    export BUILD_ROOT PKGDIR DIST_DIR
}

# ── DEBIAN/control ────────────────────────────────────────────────────

pkg_write_control() {
    local arch="${PKG_ARCH:-${ARCH:-all}}"
    local installed_size="${PKG_INSTALLED_SIZE:-}"

    if [[ -z "$installed_size" ]]; then
        installed_size=$(du -sk "$PKGDIR" | cut -f1)
    fi

    {
        echo "Package: ${PKG_NAME}"
        echo "Version: ${VERSION}-${RELEASE}"
        echo "Section: ${PKG_SECTION:-misc}"
        echo "Priority: optional"
        echo "Architecture: ${arch}"
        echo "Installed-Size: ${installed_size}"
        echo "Depends: ${PKG_DEPENDS}"
        [[ -n "${PKG_RECOMMENDS:-}" ]] && echo "Recommends: ${PKG_RECOMMENDS}"
        [[ -n "${PKG_CONFLICTS:-}" ]] && echo "Conflicts: ${PKG_CONFLICTS}"
        echo "Maintainer: ${PKG_MAINTAINER:-Pau Aliagas <linuxnow@gmail.com>}"
        echo "Description: ${PKG_DESCRIPTION}"
        [[ -n "${PKG_DESCRIPTION_LONG:-}" ]] && echo "${PKG_DESCRIPTION_LONG}"
        echo "Homepage: ${PKG_HOMEPAGE:-https://xiboplayer.org}"
    } > "$PKGDIR/DEBIAN/control"
}

# ── update-alternatives postinst/prerm ────────────────────────────────

pkg_write_alternatives() {
    [[ -z "${ALT_NAME:-}" ]] && return 0

    cat > "$PKGDIR/DEBIAN/postinst" << EOF
#!/bin/bash
set -e
update-alternatives --install ${ALT_LINK} ${ALT_NAME} ${ALT_PATH} ${ALT_PRIORITY}
EOF
    chmod 755 "$PKGDIR/DEBIAN/postinst"

    cat > "$PKGDIR/DEBIAN/prerm" << EOF
#!/bin/bash
set -e
if [ "\$1" = "remove" ]; then
    update-alternatives --remove ${ALT_NAME} ${ALT_PATH}
fi
EOF
    chmod 755 "$PKGDIR/DEBIAN/prerm"
}

# ── Build binary DEB ──────────────────────────────────────────────────

pkg_build_binary_deb() {
    local arch="${PKG_ARCH:-${ARCH:-all}}"
    local deb_file="${PKG_NAME}_${VERSION}-${RELEASE}_${arch}.deb"

    echo "==> Running dpkg-deb..."
    dpkg-deb --build "$PKGDIR" "$BUILD_ROOT/${deb_file}"
    cp -v "$BUILD_ROOT/${deb_file}" "$DIST_DIR/"

    echo ""
    echo "==> Built: ${deb_file} ($(du -h "$DIST_DIR/${deb_file}" | cut -f1))"
    echo "    Install: sudo apt install ${DIST_DIR}/${deb_file}"

    rm -rf "$PKGDIR"
}

# ── Build source DEB ─────────────────────────────────────────────────
# Arguments:
#   $1 — callback function name that populates $ORIG_DIR with source files
#         (receives $ORIG_DIR as $1). If omitted, creates tarball from repo.
#   $2 — (optional) source architecture for debian/control (default: from PKG_ARCH)
#
# The source package is built once per version (skipped if .source-built marker exists).

pkg_build_source_deb() {
    local populate_fn="${1:-}"
    local src_arch="${2:-${PKG_ARCH:-${ARCH:-all}}}"

    local src_marker="${DIST_DIR}/.source-built"
    [[ -f "$src_marker" ]] && return 0

    echo "==> Building source package..."
    local src_build="${SCRIPT_DIR}/_srcbuild"
    rm -rf "$src_build"
    local src_name="${PKG_NAME}-${VERSION}"
    local orig_dir="$src_build/$src_name"
    mkdir -p "$orig_dir"

    # Populate source tree (callback may create its own orig tarball)
    if [[ -n "$populate_fn" ]]; then
        "$populate_fn" "$orig_dir"
    fi

    # Create orig tarball (skip if callback already created one)
    cd "$src_build"
    if [[ ! -f "${PKG_NAME}_${VERSION}.orig.tar.gz" ]]; then
        tar czf "${PKG_NAME}_${VERSION}.orig.tar.gz" "$src_name"
    fi

    # Create debian/ directory
    mkdir -p "$orig_dir/debian/source"
    echo "3.0 (quilt)" > "$orig_dir/debian/source/format"

    local build_depends="${PKG_SRC_BUILD_DEPENDS:-debhelper (>= 12)}"

    {
        echo "Source: ${PKG_NAME}"
        echo "Section: ${PKG_SECTION:-misc}"
        echo "Priority: optional"
        echo "Maintainer: ${PKG_MAINTAINER:-Pau Aliagas <linuxnow@gmail.com>}"
        echo "Build-Depends: ${build_depends}"
        echo "Standards-Version: 4.6.0"
        echo "Homepage: ${PKG_HOMEPAGE:-https://xiboplayer.org}"
        echo ""
        echo "Package: ${PKG_NAME}"
        echo "Architecture: ${src_arch}"
        echo "Depends: ${PKG_DEPENDS}"
        [[ -n "${PKG_RECOMMENDS:-}" ]] && echo "Recommends: ${PKG_RECOMMENDS}"
        echo "Description: ${PKG_DESCRIPTION}"
        [[ -n "${PKG_DESCRIPTION_LONG:-}" ]] && echo "${PKG_DESCRIPTION_LONG}"
    } > "$orig_dir/debian/control"

    cat > "$orig_dir/debian/changelog" << EOF
${PKG_NAME} (${VERSION}-${RELEASE}) stable; urgency=medium

  * Release ${VERSION}

 -- ${PKG_MAINTAINER:-Pau Aliagas <linuxnow@gmail.com>}  $(date -R)
EOF

    cat > "$orig_dir/debian/rules" << 'EOF'
#!/usr/bin/make -f
%:
	dh $@
EOF
    chmod +x "$orig_dir/debian/rules"

    echo "12" > "$orig_dir/debian/compat"

    # Build source package
    cd "$orig_dir"
    dpkg-source -b .
    cd "$SCRIPT_DIR"

    # Copy source package files to output
    cp "$src_build"/*.dsc "$DIST_DIR/" 2>/dev/null || true
    cp "$src_build"/*.orig.tar.* "$DIST_DIR/" 2>/dev/null || true
    cp "$src_build"/*.debian.tar.* "$DIST_DIR/" 2>/dev/null || true

    echo "==> Source package files:"
    ls -lh "$DIST_DIR"/*.dsc "$DIST_DIR"/*.tar.* 2>/dev/null || true

    touch "$src_marker"
    rm -rf "$src_build"
}

# ── Display results ───────────────────────────────────────────────────

pkg_show_result_deb() {
    echo ""
    echo "==> Built packages:"
    for deb in "$DIST_DIR"/*.deb; do
        [[ -f "$deb" ]] && echo "    $(basename "$deb") ($(du -h "$deb" | cut -f1))"
    done
    echo "    Enable: systemctl --user enable --now ${PKG_NAME}.service"
}
