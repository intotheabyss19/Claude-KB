# Skill: Compress

Regex-based deterministic prose compression for knowledge-base files.
~40-46% reduction with zero external dependencies. No LLM calls, no
network, pure computation.

Attribution:
  Source: github.com/JuliusBrussee/caveman
  License: MIT (c) 2026 Julius Brussee

---

## Usage

Run `prose-compressor.js` on any natural-language file:

```js
const { compress } = require('./prose-compressor');
const { compressed, before, after } = compress(text);
```

Or use `compressDescriptionsInPlace(obj)` to compress string fields
in-place on a JS object (useful for tool descriptions, skill metadata).

Git history is the only undo mechanism — no separate backup.

## What It Does

Strips articles, filler, pleasantries, and hedges while preserving
code blocks, inline code, URLs, paths, identifiers, and version numbers
byte-for-byte. See `compression-rules.md` for the full ruleset.

## Boundaries

- ONLY compress natural language files (.md, .txt, .typ, .typst, .tex, extensionless)
- NEVER modify: .py, .js, .ts, .json, .yaml, .yml, .toml, .env, .lock, .css, .html, .xml, .sql, .sh
- Mixed content: compress ONLY prose sections, leave code untouched
- If unsure whether something is code or prose, leave it unchanged

## Important

Never run compression during lesson authoring. Write lessons in full
clarity first; compress as a separate pass afterward if desired.
