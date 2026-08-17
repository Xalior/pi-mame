#!/bin/sh
# driver-class.sh — list MAME's driver sources belonging to one broad class.
#
# Usage: scripts/driver-class.sh computers|arcade [mame-tree]
#
# Prints repo-relative driver paths (src/mame/<vendor>/<driver>.cpp), one per
# line, for feeding a platform's SOURCES.
#
# WHY THIS IS A SCAN AND NOT A LIST. The obvious way to declare a big platform
# is to write its driver files down, and it is the wrong way: MAME grows, and a
# written list never does. Every upstream pull would add drivers that silently
# fail to appear in any kernel, with nothing to say so. Classifying by what the
# sources declare means a pull brings new machines in by itself, into whichever
# class they belong to.
#
# WHAT IT CLASSIFIES ON. MAME's own driver macros, which are the only statement
# in the tree of what a machine IS:
#
#   GAME(  GAMEL(          a coin-operated machine        -> arcade
#   COMP(  CONS(  SYST(    a computer, console or system  -> computers
#
# A file carrying both goes to ARCADE. That is a judgement rather than a fact,
# and it is deliberately the smaller error: those files are overwhelmingly an
# arcade board with a home port beside it, and putting an arcade machine in the
# computers kernel is more surprising than the reverse.
#
# The pattern tolerates leading comment text and space before the bracket:
# `COMP ( 1983, electron, ...` and `/* ... */ GAME(` are both real in this tree,
# and anchoring the macro at column 0 silently loses whole vendors — Acorn's
# electron and Sega's naomi among them.
set -e

CLASS="${1:?usage: driver-class.sh computers|arcade [mame-tree]}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MAME="${2:-$ROOT/mame}"

case "$CLASS" in
    computers|arcade) ;;
    *) echo "driver-class.sh: unknown class '$CLASS' (computers|arcade)" >&2; exit 2 ;;
esac

[ -d "$MAME/src/mame" ] || {
    echo "driver-class.sh: no $MAME/src/mame — is the mame submodule checked out?" >&2
    exit 2; }

# One pass over the tree. grep -l per pattern set, then combine: arcade is every
# file naming a GAME macro, computers is every file naming a system macro and no
# GAME macro.
ARC=$(mktemp); SYS=$(mktemp)
trap 'rm -f "$ARC" "$SYS"' EXIT

( cd "$MAME" && grep -rlE '(^|[^A-Za-z_])GAMEL?[[:space:]]*\(' src/mame --include='*.cpp' ) | sort > "$ARC"
( cd "$MAME" && grep -rlE '(^|[^A-Za-z_])(COMP|CONS|SYST)[[:space:]]*\(' src/mame --include='*.cpp' ) | sort > "$SYS"

case "$CLASS" in
    arcade)    cat "$ARC" ;;
    computers) comm -23 "$SYS" "$ARC" ;;
esac
