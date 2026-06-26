---
name: bash-expert
description: >
  Safe, portable bash scripting patterns: strict-mode, quoting,
  trap cleanup, rg-over-grep, jq/rg JSON parsing. Use when
  writing or reviewing shell scripts.
---

# Bash Expert

> Fish/zsh sections pruned — the Bash tool executes via bash. Original
> cross-shell version: github.com/rd-mg/architect-ai (skills/bash-expert).

## Strict mode header (every script, no exceptions)
```bash
#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
```

## Variable quoting (always)
```bash
# WRONG
rm -rf $TMPDIR
echo $MY_VAR

# RIGHT
rm -rf "${TMPDIR}"
echo "${MY_VAR}"
```

## rg instead of grep (grep -r forbidden — slow, ignores .gitignore)
```bash
rg "pattern" --type go
rg -l "pattern" .                          # file list only
rg -c "pattern" --type py                  # count per file
rg -w "exactFunction" --type go            # word boundary
rg -C 3 "pattern" --type go                # 3 lines context
rg --json "pattern" . | jq '.data.lines.text'  # for parsing
rg -U "multi.*\nline" --type go            # multi-line
rg -l "pattern" -g "!vendor/" -g "!node_modules/"  # exclude dirs
```

## Error handling
```bash
# Trap for cleanup
cleanup() { local e=$?; rm -f "${TMPFILE:-}"; exit "${e}"; }
trap cleanup EXIT INT TERM

# Check command availability
for cmd in rg jq; do
  command -v "${cmd}" > /dev/null || { echo "ERROR: ${cmd} not found" >&2; exit 127; }
done

# Capture stdout + stderr
output=$(some_command 2>&1) || { echo "Failed: ${output}" >&2; exit 1; }
```

## Safe file operations
```bash
# Atomic write
tmp=$(mktemp)
cat > "${tmp}" << 'EOF'
content
EOF
mv "${tmp}" "${target}"

# Check existence before read
[ -f "${file}" ] || { echo "Missing: ${file}" >&2; exit 1; }

# Never: rm -rf without quoting and validation
[ -n "${DIR}" ] && [ -d "${DIR}" ] && rm -rf "${DIR}"
```

## rg optimization patterns

### Domain-specific search
```bash
rg "pattern" --type go -g "!*_test.go" -g "!vendor/"   # backend only
rg "pattern" --type py -g "models/*.py" -g "!tests/"   # models only
rg "pattern" --type xml -g "views/*.xml"               # views only
```

### Negative assertion (security — pattern MUST NOT exist)
```bash
rg -l "forbidden_pattern" . && echo "SECURITY VIOLATION" || echo "CLEAN"
```

### Count to estimate scope before starting
```bash
AFFECTED=$(rg -l "old_function_name" --type go | wc -l)
echo "Estimated ${AFFECTED} files to change"
[ "${AFFECTED}" -gt 10 ] && echo "WARN: large scope — consider splitting"
```

### JSON structured output for parsing
```bash
rg --json "function_name" --type go \
  | jq -r 'select(.type=="match") | "\(.data.path.text):\(.data.line_number)"'
```
