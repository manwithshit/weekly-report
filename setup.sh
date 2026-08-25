#!/usr/bin/env bash
#
# weekly-report skill installer
# ------------------------------------------------------------------
# Copies the `weekly-report/` skill into your Agent's skills directory.
# Auto-detects Codex / WorkBuddy / Claude skill dirs, or install to a
# path you name with --target. Nothing here needs your credentials.
#
# Usage:
#   ./setup.sh                 # detect skill dirs, ask, then install
#   ./setup.sh --all           # install into every detected skill dir
#   ./setup.sh --target DIR    # install into a specific skills directory
#   ./setup.sh --list          # just show what would be detected
#   ./setup.sh --force         # overwrite an existing install without asking
#
set -euo pipefail

SKILL_NAME="weekly-report"

# Resolve the directory this script lives in (portable, no realpath dep).
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
SRC_DIR="${SCRIPT_DIR}/${SKILL_NAME}"

# --- pretty output -------------------------------------------------
if [ -t 1 ]; then
  BOLD=$'\033[1m'; DIM=$'\033[2m'; GREEN=$'\033[32m'; YELLOW=$'\033[33m'
  RED=$'\033[31m'; CYAN=$'\033[36m'; RESET=$'\033[0m'
else
  BOLD=""; DIM=""; GREEN=""; YELLOW=""; RED=""; CYAN=""; RESET=""
fi
info()  { printf "%s\n" "$*"; }
ok()    { printf "${GREEN}✓${RESET} %s\n" "$*"; }
warn()  { printf "${YELLOW}!${RESET} %s\n" "$*"; }
err()   { printf "${RED}✗${RESET} %s\n" "$*" >&2; }
step()  { printf "\n${BOLD}%s${RESET}\n" "$*"; }

# --- args ----------------------------------------------------------
MODE="detect"   # detect | all | target | list
TARGET=""
FORCE=0
while [ $# -gt 0 ]; do
  case "$1" in
    --all)    MODE="all" ;;
    --list)   MODE="list" ;;
    --force)  FORCE=1 ;;
    --target) MODE="target"; TARGET="${2:-}"; shift ;;
    --target=*) MODE="target"; TARGET="${1#*=}" ;;
    -h|--help)
      grep '^#' "$0" | sed 's/^# \{0,1\}//' | sed '/^!/d'
      exit 0 ;;
    *) err "Unknown option: $1"; exit 2 ;;
  esac
  shift
done

# --- sanity: source present ---------------------------------------
if [ ! -f "${SRC_DIR}/SKILL.md" ]; then
  err "Cannot find ${SKILL_NAME}/SKILL.md next to this script."
  err "Run setup.sh from inside the cloned repository."
  exit 1
fi

# --- platform note (non-fatal) ------------------------------------
if [ "$(uname -s)" != "Darwin" ]; then
  warn "This skill's connectors target macOS. You can still install the files,"
  warn "but calendar/reminders (EventKit) and some CLIs are macOS-only."
fi

# --- candidate skill directories ----------------------------------
# Bases whose PARENT exists are considered "present". Order = priority.
CANDIDATES=(
  "${CODEX_HOME:-$HOME/.codex}/skills"
  "$HOME/.workbuddy/skills"
  "$HOME/.claude/skills"
  "$PWD/.claude/skills"
)

detected=()
for base in "${CANDIDATES[@]}"; do
  parent="$(dirname "$base")"
  if [ -d "$parent" ]; then
    detected+=("$base")
  fi
done

# --- install helper -----------------------------------------------
install_into() {
  local base="$1"
  local dest="${base}/${SKILL_NAME}"
  mkdir -p "$base"
  if [ -e "$dest" ] && [ "$FORCE" -ne 1 ]; then
    if [ -t 0 ]; then
      printf "${YELLOW}?${RESET} %s already exists. Overwrite? [y/N] " "$dest"
      read -r ans
      case "$ans" in y|Y|yes|YES) ;; *) warn "Skipped ${dest}"; return 0 ;; esac
    else
      warn "Exists (use --force to overwrite): ${dest}"
      return 0
    fi
  fi
  rm -rf "$dest"
  # Copy the skill folder (SKILL.md + references/), nothing else.
  cp -R "$SRC_DIR" "$dest"
  ok "Installed → ${dest}"
}

# --- modes ---------------------------------------------------------
case "$MODE" in
  list)
    step "Detected Agent skills directories"
    if [ ${#detected[@]} -eq 0 ]; then
      warn "None found. Pass --target <dir> to install anywhere."
    else
      for d in "${detected[@]}"; do info "  ${CYAN}${d}${RESET}"; done
    fi
    exit 0
    ;;

  target)
    [ -n "$TARGET" ] || { err "--target needs a directory"; exit 2; }
    # Allow ~ expansion when passed quoted
    TARGET="${TARGET/#\~/$HOME}"
    step "Installing to ${TARGET}"
    install_into "$TARGET"
    ;;

  all)
    if [ ${#detected[@]} -eq 0 ]; then
      err "No skill directories detected. Use --target <dir>."
      exit 1
    fi
    step "Installing into all detected skill directories"
    for d in "${detected[@]}"; do install_into "$d"; done
    ;;

  detect)
    step "Detected Agent skills directories"
    if [ ${#detected[@]} -eq 0 ]; then
      warn "No Codex / WorkBuddy / Claude skill directory found."
      info "Install manually with:"
      info "  ${DIM}./setup.sh --target /path/to/your/agent/skills${RESET}"
      exit 1
    fi
    for i in "${!detected[@]}"; do
      printf "  %s) %s\n" "$((i+1))" "${detected[$i]}"
    done
    if [ -t 0 ]; then
      printf "\nInstall into which? [1-%s / a=all / q=quit] " "${#detected[@]}"
      read -r choice
      case "$choice" in
        a|A) for d in "${detected[@]}"; do install_into "$d"; done ;;
        q|Q|"") warn "Cancelled."; exit 0 ;;
        *)
          if [ "$choice" -ge 1 ] 2>/dev/null && [ "$choice" -le ${#detected[@]} ]; then
            install_into "${detected[$((choice-1))]}"
          else
            err "Invalid choice."; exit 2
          fi ;;
      esac
    else
      # Non-interactive (e.g. piped): default to the first detected dir.
      warn "Non-interactive shell; installing into the first detected dir."
      install_into "${detected[0]}"
    fi
    ;;
esac

step "Done"
info "Open your Agent (Codex / WorkBuddy) and say: ${BOLD}写周报${RESET} (write my weekly report)."
info "First run walks you through connecting your sources; after that, one line generates the draft."
