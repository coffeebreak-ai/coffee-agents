#!/usr/bin/env bash
set -euo pipefail

REPO_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
SRC="$REPO_DIR/opencode"
TARGET="${OPENCODE_CONFIG_DIR:-${XDG_CONFIG_HOME:-$HOME/.config}/opencode}"
STAMP=$(date +%Y%m%d-%H%M%S)
BACKUP="$TARGET/.coffee-backup/$STAMP"
BEGIN='<!-- coffee:begin -->'
END='<!-- coffee:end -->'

DRY_RUN=0
FORCE=0
UNINSTALL=0

usage() {
	cat <<'EOF'
Установка Coffee-агентов, навыков и правил в глобальный конфиг OpenCode.

  ./install.sh              скопировать coffee-* в ~/.config/opencode
  ./install.sh --dry-run    показать план, ничего не писать
  ./install.sh --force      без подтверждения
  ./install.sh --uninstall  удалить coffee-* и вернуть последний бэкап

Каталог задаётся OPENCODE_CONFIG_DIR или XDG_CONFIG_HOME.
Файлы без префикса coffee- не трогаются. AGENTS.md меняется только внутри
маркеров <!-- coffee:begin --> ... <!-- coffee:end -->.
EOF
}

log() { printf '%s\n' "$*"; }

confirm() {
	[ "$FORCE" = 1 ] && return 0
	[ -t 0 ] || return 0
	printf '%s [y/N] ' "$1"
	read -r answer
	case "$answer" in
	y | Y) return 0 ;;
	*)
		log "отменено"
		exit 1
		;;
	esac
}

init_backup() {
	[ "$DRY_RUN" = 1 ] && return 0
	mkdir -p "$BACKUP"
	: >"$BACKUP/created.txt"
}

mark_created() {
	[ "$DRY_RUN" = 1 ] && return 0
	printf '%s\n' "$1" >>"$BACKUP/created.txt"
}

backup_path() {
	local rel="$1"
	local path="$TARGET/$1"
	[ "$DRY_RUN" = 1 ] && return 0
	if [ ! -e "$path" ]; then
		mark_created "$rel"
		return 0
	fi
	mkdir -p "$BACKUP/$(dirname "$rel")"
	cp -R "$path" "$BACKUP/$rel"
}

install_agents() {
	local file rel
	for file in "$SRC"/agents/coffee-*.md; do
		rel="agents/$(basename "$file")"
		backup_path "$rel"
		log "install $rel"
		[ "$DRY_RUN" = 1 ] && continue
		mkdir -p "$TARGET/agents"
		cp "$file" "$TARGET/$rel"
	done
}

install_skills() {
	local dir name
	for dir in "$SRC"/skills/coffee-*/; do
		name="$(basename "$dir")"
		backup_path "skills/$name"
		log "install skills/$name"
		[ "$DRY_RUN" = 1 ] && continue
		rm -rf "${TARGET:?}/skills/$name"
		mkdir -p "$TARGET/skills/$name"
		cp -R "$dir/." "$TARGET/skills/$name/"
	done
}

write_block() {
	printf '%s\n' "$BEGIN"
	cat "$1"
	printf '%s\n' "$END"
}

install_rules() {
	local src="$SRC/coffee-AGENTS.md"
	local dst="$TARGET/AGENTS.md"
	local body out

	body=$(mktemp)
	cat "$src" >"$body"
	backup_path "AGENTS.md"

	if [ ! -e "$dst" ]; then
		log "create AGENTS.md"
		[ "$DRY_RUN" = 1 ] && return 0
		write_block "$body" >"$dst"
	elif grep -qF "$BEGIN" "$dst"; then
		log "replace coffee block in AGENTS.md"
		[ "$DRY_RUN" = 1 ] && return 0
		out=$(mktemp)
		awk -v b="$BEGIN" -v e="$END" -v newfile="$body" '
			BEGIN { while ((getline line < newfile) > 0) blk = blk line "\n" }
			index($0, b) { print; printf "%s", blk; skip = 1; next }
			index($0, e) { skip = 0; print; next }
			!skip { print }
		' "$dst" >"$out"
		mv "$out" "$dst"
	elif [ "$(grep -v '^# ' "$dst" | tr -d '[:space:]')" = "$(echo "$(cat "$body")" | grep -v '^# ' | tr -d '[:space:]')" ]; then
		log "rewrite own AGENTS.md as coffee block"
		[ "$DRY_RUN" = 1 ] && return 0
		write_block "$body" >"$dst"
	else
		log "append coffee block to AGENTS.md"
		[ "$DRY_RUN" = 1 ] && return 0
		{
			printf '\n'
			write_block "$body"
		} >>"$dst"
	fi
	rm -f "$body"
}

verify() {
	local refs id dir bad=0

	for dir in "$SRC"/skills/coffee-*/; do
		if [ ! -f "$dir/SKILL.md" ]; then
			log "error: no SKILL.md in $dir"
			bad=1
		fi
	done

	refs=$(mktemp)
	grep -rhoE '`coffee-[a-z0-9-]+`' "$SRC"/agents | tr -d '`' | sort -u >"$refs"
	while read -r id; do
		[ -n "$id" ] || continue
		if [ ! -d "$SRC/skills/$id" ]; then
			log "error: agent references missing skill $id"
			bad=1
		fi
	done <"$refs"
	rm -f "$refs"

	if grep -rnE '`(golang-dev|go-layout|gin-swagger|go-calls|python-dev|javascript-dev|typescript-dev|csharp-dev|lua-dev|contract-first|failure-modes|adr|grill-me|qa-blackbox)`' "$SRC" >/dev/null 2>&1; then
		log "error: found reference to unprefixed skill id"
		bad=1
	fi

	[ "$bad" = 0 ] || exit 1
	log "ok: $(find "$SRC/agents" -name 'coffee-*.md' | wc -l | tr -d ' ') agents, $(find "$SRC/skills" -mindepth 1 -maxdepth 1 -type d -name 'coffee-*' | wc -l | tr -d ' ') skills"
}

restore_backup() {
	local latest="${1%/}" file rel
	if [ -f "$latest/created.txt" ]; then
		while IFS= read -r rel; do
			[ -n "$rel" ] || continue
			rm -rf "${TARGET:?}/$rel"
		done <"$latest/created.txt"
	fi
	while IFS= read -r -d '' file; do
		rel="${file#"$latest"/}"
		case "$rel" in
		agents/coffee-*.md | skills/coffee-*) continue ;;
		esac
		mkdir -p "$TARGET/$(dirname "$rel")"
		cp -R "$file" "$TARGET/$rel"
	done < <(find "$latest" -type f ! -name created.txt -print0)
}

uninstall() {
	local latest
	latest=$(ls -1d "$TARGET"/.coffee-backup/*/ 2>/dev/null | sort | tail -1)
	if [ -z "${latest:-}" ]; then
		log "error: backup not found in $TARGET/.coffee-backup"
		exit 1
	fi
	confirm "Удалить файлы coffee-* и восстановить $latest?"
	log "remove agents/coffee-*.md and skills/coffee-*"
	log "restore from $latest"
	[ "$DRY_RUN" = 1 ] && return 0
	rm -rf "$TARGET"/agents/coffee-*.md "$TARGET"/skills/coffee-*
	restore_backup "$latest"
}

while [ $# -gt 0 ]; do
	case "$1" in
	--dry-run) DRY_RUN=1 ;;
	--force) FORCE=1 ;;
	--uninstall) UNINSTALL=1 ;;
	-h | --help)
		usage
		exit 0
		;;
	*)
		log "unknown option: $1"
		usage
		exit 2
		;;
	esac
	shift
done

log "source: $SRC"
log "target: $TARGET"

verify

if [ "$UNINSTALL" = 1 ]; then
	uninstall
	exit 0
fi

confirm "Установить coffee-* в $TARGET?"

init_backup
install_agents
install_skills
install_rules

log "done"
