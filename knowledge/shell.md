# Shell / bash reference

`rg`/`jq` scoping + parsing patterns worth not re-deriving. Hygiene boilerplate
(strict-mode, quoting, traps) omitted — table-stakes, applied by default.
Source: rd-mg/architect-ai bash-expert (fish pruned). Bash tool runs bash.

## rg scoping (prefer over `grep -r` — faster, .gitignore-aware)
```bash
rg -l "pattern" .                                  # file list only
rg -c "pattern" --type py                          # count per file
rg -w "exactFunction" --type go                    # word boundary
rg -C 3 "pattern" --type go                        # context lines
rg -U "multi.*\nline" --type go                    # multi-line
rg "pattern" --type go -g "!*_test.go" -g "!vendor/"   # scope + exclude
rg -l "pat" -g "!node_modules/" -g "!dist/"        # exclude dirs
```

## rg → jq structured parsing (for scripting over matches)
```bash
rg --json "function_name" --type go \
  | jq -r 'select(.type=="match") | "\(.data.path.text):\(.data.line_number)"'
```

## Estimate scope before a large edit
```bash
AFFECTED=$(rg -l "old_name" --type go | wc -l)
[ "${AFFECTED}" -gt 10 ] && echo "WARN: ${AFFECTED} files — consider splitting"
```

## Security negative-assertion (pattern MUST NOT exist)
```bash
rg -l "forbidden_pattern" . && echo "VIOLATION" || echo "CLEAN"
```

## Safe-script skeleton (only when authoring a committed .sh)
```bash
#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
cleanup() { local e=$?; rm -f "${TMPFILE:-}"; exit "${e}"; }
trap cleanup EXIT INT TERM
# atomic write: tmp=$(mktemp); …; mv "${tmp}" "${target}"
```
