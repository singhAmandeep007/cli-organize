#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# cli-organize — Universal Demo & Verification Script
# Works with any language implementation that follows STANDARD.md
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEMO_DIR=""
BIN_CMD=""
SEED_DIR=""
ORGANIZED_DIR=""

# ── All extensions from the standard (10 categories) ─────────────────────────
DOCUMENTS=(txt doc docx pdf odt rtf tex wpd log md)
IMAGES=(jpg jpeg png gif bmp tiff webp heic raw svg ico)
VIDEOS=(mp4 mov avi mkv flv wmv webm mpeg)
AUDIO=(mp3 wav aac flac ogg wma m4a)
ARCHIVES=(zip tar gz rar 7z bz2 xz z)
SPREADSHEETS=(xls xlsx csv ods)
PRESENTATIONS=(ppt pptx odp)
EXECUTABLES=(exe msi dmg app)
CODE=(py js html css java c cpp h go json xml rs ts rb)

ALL_EXTENSIONS=(
    "${DOCUMENTS[@]}" "${IMAGES[@]}" "${VIDEOS[@]}" "${AUDIO[@]}"
    "${ARCHIVES[@]}" "${SPREADSHEETS[@]}" "${PRESENTATIONS[@]}"
    "${EXECUTABLES[@]}" "${CODE[@]}"
)

EXPECTED_CATEGORIES=(
    "Archives" "Audio" "Code" "Documents" "Executables"
    "Images" "Others" "Presentations" "Spreadsheets" "Videos"
)

# ── Colors ───────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# ── Helpers ──────────────────────────────────────────────────────────────────
info()    { echo -e "${BLUE}ℹ${NC}  $*"; }
success() { echo -e "${GREEN}✔${NC}  $*"; }
warn()    { echo -e "${YELLOW}⚠${NC}  $*"; }
error()   { echo -e "${RED}✖${NC}  $*" >&2; }

random_string() {
    local len="${1:-10}"
    LC_ALL=C tr -dc 'a-zA-Z0-9' < /dev/urandom | head -c "$len" 2>/dev/null || true
}

usage() {
    cat <<EOF
${BOLD}cli-organize demo script${NC}

Usage: $0 [options]

Options:
  --bin <command>    CLI binary/command to use (required for run/dry-run)
                     Examples:
                       --bin ./cli-organize-go/cli-organize-go
                       --bin "poetry -C ./cli-organize-py run organize"
  --demo-dir <dir>   Demo directory (default: ./demo)
  -h, --help         Show this help

The script presents an interactive menu for seeding, running, and verifying.
EOF
    exit 0
}

# ── Parse args ───────────────────────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
    case "$1" in
        --bin)      BIN_CMD="$2"; shift 2 ;;
        --demo-dir) DEMO_DIR="$2"; shift 2 ;;
        -h|--help)  usage ;;
        *)          error "Unknown option: $1"; usage ;;
    esac
done

DEMO_DIR="${DEMO_DIR:-$SCRIPT_DIR/demo}"
SEED_DIR="$DEMO_DIR/seed"
ORGANIZED_DIR="$DEMO_DIR/organized"

# ── Menu actions ─────────────────────────────────────────────────────────────

do_seed() {
    echo ""
    read -rp "Files per extension (1-20, default 3): " count
    count="${count:-3}"
    if ! [[ "$count" =~ ^[0-9]+$ ]] || [ "$count" -lt 1 ] || [ "$count" -gt 20 ]; then
        warn "Invalid count, using 3"
        count=3
    fi

    rm -rf "$SEED_DIR"
    mkdir -p "$SEED_DIR"

    local total=0
    for ext in "${ALL_EXTENSIONS[@]}"; do
        for ((i = 1; i <= count; i++)); do
            local name
            name="$(random_string 10).${ext}"
            local size
            size=$(( (RANDOM % 8192) + 128 ))
            dd if=/dev/urandom of="$SEED_DIR/$name" bs=1 count="$size" 2>/dev/null
            total=$((total + 1))
        done
    done

    # Add a few no-extension files (go to Others)
    for ((i = 1; i <= count; i++)); do
        local name
        name="$(random_string 10)"
        echo "no extension file" > "$SEED_DIR/$name"
        total=$((total + 1))
    done

    success "Seeded ${BOLD}$total${NC} files across ${#ALL_EXTENSIONS[@]} extensions + no-extension files in $SEED_DIR"
}

do_clean_seed() {
    rm -rf "$SEED_DIR"
    success "Removed $SEED_DIR"
}

do_clean_organized() {
    rm -rf "$ORGANIZED_DIR"
    success "Removed $ORGANIZED_DIR"
}

do_clean_all() {
    rm -rf "$DEMO_DIR"
    success "Removed $DEMO_DIR"
}

do_tree() {
    echo ""
    if command -v tree &>/dev/null; then
        tree "$DEMO_DIR" -L 2 --dirsfirst 2>/dev/null || info "Demo directory does not exist yet."
    else
        # Fallback if tree is not installed
        if [ -d "$DEMO_DIR" ]; then
            find "$DEMO_DIR" -maxdepth 2 | head -80
            info "(Install 'tree' for prettier output)"
        else
            info "Demo directory does not exist yet."
        fi
    fi
}

do_count() {
    echo ""
    if [ -d "$SEED_DIR" ]; then
        local c
        c=$(find "$SEED_DIR" -maxdepth 1 -type f | wc -l | tr -d ' ')
        info "Seed files: $c"
    else
        info "No seed directory."
    fi
    if [ -d "$ORGANIZED_DIR" ]; then
        info "Organized categories:"
        for dir in "$ORGANIZED_DIR"/*/; do
            [ -d "$dir" ] || continue
            local name count
            name="$(basename "$dir")"
            count=$(find "$dir" -maxdepth 1 -type f | wc -l | tr -d ' ')
            echo "    $name: $count files"
        done
    else
        info "No organized directory."
    fi
}

require_bin() {
    if [ -z "$BIN_CMD" ]; then
        error "No binary specified. Use --bin <command>"
        return 1
    fi
}

require_seed() {
    if [ ! -d "$SEED_DIR" ] || [ -z "$(ls -A "$SEED_DIR" 2>/dev/null)" ]; then
        error "Seed directory is empty. Run 'Seed' first."
        return 1
    fi
}

do_run() {
    require_bin || return
    require_seed || return
    rm -rf "$ORGANIZED_DIR"
    info "Running: $BIN_CMD $SEED_DIR -d $ORGANIZED_DIR --verbose"
    echo ""
    eval "$BIN_CMD" "$SEED_DIR" -d "$ORGANIZED_DIR" --verbose
    echo ""
    success "Done. Use 'Tree' or 'Count' to inspect results."
}

do_dry_run() {
    require_bin || return
    require_seed || return
    info "Running: $BIN_CMD $SEED_DIR -d $ORGANIZED_DIR --dry-run --verbose"
    echo ""
    eval "$BIN_CMD" "$SEED_DIR" -d "$ORGANIZED_DIR" --dry-run --verbose
    echo ""
    success "Dry run complete. No files were moved."
}

do_verify() {
    echo ""
    if [ ! -d "$ORGANIZED_DIR" ]; then
        error "No organized directory found. Run the organizer first."
        return
    fi

    local pass=0
    local fail=0

    # Check that each expected category with files exists
    for cat in "${EXPECTED_CATEGORIES[@]}"; do
        if [ -d "$ORGANIZED_DIR/$cat" ]; then
            local count
            count=$(find "$ORGANIZED_DIR/$cat" -maxdepth 1 -type f | wc -l | tr -d ' ')
            if [ "$count" -gt 0 ]; then
                echo -e "  ${GREEN}✔${NC} $cat ($count files)"
                pass=$((pass + 1))
            else
                echo -e "  ${YELLOW}~${NC} $cat (empty)"
            fi
        fi
    done

    # Check for unexpected directories
    for dir in "$ORGANIZED_DIR"/*/; do
        [ -d "$dir" ] || continue
        local name
        name="$(basename "$dir")"
        local found=false
        for cat in "${EXPECTED_CATEGORIES[@]}"; do
            if [ "$name" = "$cat" ]; then
                found=true
                break
            fi
        done
        if [ "$found" = false ]; then
            echo -e "  ${RED}✖${NC} Unexpected directory: $name"
            fail=$((fail + 1))
        fi
    done

    # Check no files remain in seed (if source != dest)
    if [ "$SEED_DIR" != "$ORGANIZED_DIR" ] && [ -d "$SEED_DIR" ]; then
        local remaining
        remaining=$(find "$SEED_DIR" -maxdepth 1 -type f | wc -l | tr -d ' ')
        if [ "$remaining" -eq 0 ]; then
            echo -e "  ${GREEN}✔${NC} Source directory is clean (all files moved)"
            pass=$((pass + 1))
        else
            echo -e "  ${YELLOW}~${NC} $remaining files remain in source (dotfiles/no-ext are expected)"
        fi
    fi

    echo ""
    if [ "$fail" -eq 0 ]; then
        success "Verification passed ($pass checks)"
    else
        error "Verification had $fail failure(s)"
    fi
}

# ── Main menu ────────────────────────────────────────────────────────────────
show_menu() {
    echo ""
    echo -e "${BOLD}── cli-organize demo ──${NC}"
    [ -n "$BIN_CMD" ] && echo -e "${CYAN}Binary:${NC} $BIN_CMD"
    echo -e "${CYAN}Demo dir:${NC} $DEMO_DIR"
    echo ""
    echo "  1) Seed         — Generate random test files"
    echo "  2) Clean seed   — Delete seed directory"
    echo "  3) Clean output — Delete organized directory"
    echo "  4) Clean all    — Delete entire demo directory"
    echo "  5) Tree         — Show directory structure"
    echo "  6) Count        — Show file counts per category"
    echo "  7) Run          — Organize files (move)"
    echo "  8) Dry run      — Simulate organization"
    echo "  9) Verify       — Check output against standard"
    echo "  0) Exit"
    echo ""
}

main() {
    while true; do
        show_menu
        read -rp "Choice [0-9]: " choice
        case "$choice" in
            1) do_seed ;;
            2) do_clean_seed ;;
            3) do_clean_organized ;;
            4) do_clean_all ;;
            5) do_tree ;;
            6) do_count ;;
            7) do_run ;;
            8) do_dry_run ;;
            9) do_verify ;;
            0) echo "Bye!"; exit 0 ;;
            *) warn "Invalid choice" ;;
        esac
    done
}

main
