#!/bin/bash

cd -- "$1" 2>/dev/null || exit 0
branch=$(git branch --show-current 2>/dev/null) || exit 0
[ -n "$branch" ] || branch=$(git rev-parse --short HEAD 2>/dev/null)

changes=$(git status --porcelain 2>/dev/null) || exit 0

staged=$(printf '%s\n' "$changes" | awk 'substr($0,1,1) ~ /[MADRC]/ { n++ } END { print n+0 }')
modified=$(printf '%s\n' "$changes" | awk 'substr($0,2,1) ~ /[MD]/ { n++ } END { print n+0 }')
untracked=$(printf '%s\n' "$changes" | awk 'substr($0,1,2) == "??" { n++ } END { print n+0 }')
conflicts=$(printf '%s\n' "$changes" | awk 'substr($0,1,2) ~ /^(DD|AU|UD|UA|DU|AA|UU)$/ { n++ } END { print n+0 }')

printf '#[fg=color4,bold] 󰊢 %s' "$branch"

[ "$staged" -gt 0 ] && printf ' #[fg=green]+%s' "$staged"
[ "$modified" -gt 0 ] && printf ' #[fg=yellow]！%s' "$modified"
[ "$untracked" -gt 0 ] && printf ' #[fg=cyan]?%s' "$untracked"
[ "$conflicts" -gt 0 ] && printf ' #[fg=red]󰞇%s' "$conflicts"

if git rev-parse --abbrev-ref '@{upstream}' >/dev/null 2>&1; then
    counts=$(git rev-list --left-right --count '@{upstream}...HEAD' 2>/dev/null)
    behind=${counts%%	*}
    ahead=${counts##*	}
    [ "${ahead:-0}" -gt 0 ] 2>/dev/null && printf ' #[fg=green]⇡%s' "$ahead"
    [ "${behind:-0}" -gt 0 ] 2>/dev/null && printf ' #[fg=red]⇣%s' "$behind"
fi

