#!/usr/bin/env bash
# lib-rpm.sh — Shared RPM packaging functions for xibo-players
# Source this from per-repo build-rpm.sh scripts.
#
# Required variables (set by caller):
#   PKG_NAME    — package name
#   SCRIPT_DIR  — directory of the calling script
#   DIST_DIR    — output directory (default: $SCRIPT_DIR/dist)

set -euo pipefail

# ── Collect RPMs/SRPMs from rpmbuild tree ─────────────────────────────
# Arguments:
#   $1 — rpmbuild topdir (default: ~/rpmbuild or $BUILD_ROOT)

pkg_collect_rpms() {
    local topdir="${1:-${BUILD_ROOT:-$HOME/rpmbuild}}"
    DIST_DIR="${DIST_DIR:-${SCRIPT_DIR}/dist}"
    mkdir -p "$DIST_DIR"

    find "$topdir/RPMS" -name "*.rpm" -exec cp -v {} "$DIST_DIR/" \;
    find "$topdir/SRPMS" -name "*.src.rpm" -exec cp -v {} "$DIST_DIR/" \;
}

# ── Display built packages ────────────────────────────────────────────

pkg_show_result_rpm() {
    DIST_DIR="${DIST_DIR:-${SCRIPT_DIR}/dist}"
    echo ""
    echo "==> Built:"
    for rpm in "$DIST_DIR"/*.rpm; do
        [[ -f "$rpm" ]] && echo "    $(basename "$rpm") ($(du -h "$rpm" | cut -f1))"
    done
    echo "    Install: sudo dnf install ${DIST_DIR}/${PKG_NAME}-*.rpm"
    echo "    Enable:  systemctl --user enable --now ${PKG_NAME}.service"
}
