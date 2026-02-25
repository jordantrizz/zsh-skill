#!/usr/bin/env zsh

set -euo pipefail

script_dir="${0:A:h}"
source_dir="$script_dir/skills/zsh-coding-standards"

mode=""
project_root="${PWD}"
dry_run=0

usage() {
  cat <<'EOF'
Usage:
  ./sync-skill.sh --local [project_root] [--dry-run]
  ./sync-skill.sh --global [--dry-run]
  ./sync-skill.sh --both [project_root] [--dry-run]

Options:
  --local       Sync to <project_root>/.copilot/skills/zsh-coding-standards
  --global      Sync to ~/.copilot/skills/zsh-coding-standards
  --both        Sync to both local and global targets
  --dry-run     Show what would be copied without writing
  -h, --help    Show this help
EOF
}

copy_skill_dir() {
  local target_dir="$1"

  if (( dry_run == 1 )); then
    print -- "[dry-run] mkdir -p $target_dir"
    print -- "[dry-run] cp -f $source_dir/SKILL.md $target_dir/SKILL.md"
    print -- "[dry-run] cp -f $source_dir/templates.md $target_dir/templates.md"
    print -- "[dry-run] cp -f $source_dir/snippets.md $target_dir/snippets.md"
    return 0
  fi

  mkdir -p "$target_dir"
  cp -f "$source_dir/SKILL.md" "$target_dir/SKILL.md"
  cp -f "$source_dir/templates.md" "$target_dir/templates.md"
  cp -f "$source_dir/snippets.md" "$target_dir/snippets.md"
  print -- "Synced skill files to: $target_dir"
}

if [[ ! -d "$source_dir" ]]; then
  print -u2 -- "error: source skill directory not found: $source_dir"
  exit 1
fi

while (( $# > 0 )); do
  case "$1" in
    --local)
      mode="local"
      if (( $# > 1 )) && [[ "$2" != --* ]]; then
        project_root="$2"
        shift
      fi
      ;;
    --global)
      mode="global"
      ;;
    --both)
      mode="both"
      if (( $# > 1 )) && [[ "$2" != --* ]]; then
        project_root="$2"
        shift
      fi
      ;;
    --dry-run)
      dry_run=1
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      print -u2 -- "error: unknown argument: $1"
      usage
      exit 2
      ;;
  esac
  shift
done

if [[ -z "$mode" ]]; then
  print -u2 -- "error: one of --local, --global, or --both is required"
  usage
  exit 2
fi

case "$mode" in
  local)
    copy_skill_dir "$project_root/.copilot/skills/zsh-coding-standards"
    ;;
  global)
    copy_skill_dir "$HOME/.copilot/skills/zsh-coding-standards"
    ;;
  both)
    copy_skill_dir "$project_root/.copilot/skills/zsh-coding-standards"
    copy_skill_dir "$HOME/.copilot/skills/zsh-coding-standards"
    ;;
esac