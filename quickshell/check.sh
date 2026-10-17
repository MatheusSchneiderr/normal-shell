#!/usr/bin/env bash
# Checks the rules in rules.md. Prints one line per finding; exit status 1 if any.
cd "$(dirname "$0")" || exit 2
fail=0
report() { echo "$1"; fail=1; }

# 1. hand-styled text and inputs outside components/
while IFS= read -r l; do report "raw Text/TextInput (use Label/TextField): $l"; done < <(grep -rnE "^\s*(Text|TextInput) \{" --include=*.qml modules shell | grep -v "components/")
# 3. hex colours, glyph escapes and pixel literals outside the token files
while IFS= read -r l; do report "hex colour outside Theme: $l"; done < <(grep -rnE '"#[0-9a-fA-F]{6,8}"' --include=*.qml components modules shell services shell.qml)
while IFS= read -r l; do report "glyph escape outside Icons: $l"; done < <(grep -rnE '\\u[0-9a-fA-F]{4}' --include=*.qml components modules shell services shell.qml | grep -v "u258[0-9a-f]\|u2582\|u2584\|u2586\|u2588\|\\\\u203a\|\\\\u2190")
while IFS= read -r l; do report "literal icon character outside Icons: $l"; done < <(grep -rnP '[\x{E000}-\x{F8FF}\x{F0000}-\x{FFFFD}]' --include=*.qml components modules shell services shell.qml)
while IFS= read -r l; do report "magic pixel size (use a Theme token): $l"; done < <(grep -rnE "(width|height|preferredWidth|preferredHeight|implicitWidth|implicitHeight): *[0-9]{2,4}\b" --include=*.qml components modules shell services shell.qml)
# 4. bare Process outside Cmd and the streaming exception
while IFS= read -r l; do report "bare Process (use Cmd): $l"; done < <(grep -rnE "^\s*Process \{" --include=*.qml components modules shell services | grep -v "services/Cmd.qml\|workspaces/Pager.qml")
# 2. modules must not import other modules
for f in $(find modules -name '*.qml'); do
  own=$(echo "$f" | cut -d/ -f2)
  while IFS= read -r l; do
    m=${l##*import qs.modules.}
    [ "$m" != "$own" ] && report "cross-module import in $f: $l"
  done < <(grep -E "^import qs\.modules\." "$f")
done
# 6. Theme/Icons used without 'import qs'
for f in $(find components modules shell services -name '*.qml'); do
  grep -qE "\bTheme\b|\bIcons\b" "$f" && ! grep -qE "^import qs$" "$f" && report "missing 'import qs' in $f"
done
# 7. Quickshell.Io next to Toggle, reserved type names
for f in $(find . -name '*.qml'); do
  grep -q "^import Quickshell.Io" "$f" && grep -qE "^\s*Toggle \{" "$f" && report "Quickshell.Io with Toggle breaks the type: $f"
done
find . -name 'Region.qml' -o -name 'State.qml' | while read -r f; do report "reserved type name: $f"; done

# 8. color tokens only on the kind of element they belong to (text, icon, fill, line)
while IFS= read -r l; do report "color token: $l"; done < <(lua dev/token-kinds.lua .)

[ $fail -eq 0 ] && echo "check.sh: ok"
exit $fail
