# Provenance — ai-skills (sanjay3290)

Third-party skill, vendored as a **plain copy of the `postgres` skill only**.

- **Source:** https://github.com/sanjay3290/ai-skills
- **Pinned commit:** `cde1c8385ead64df501c9b214e63d7ba9b283ff9`
- **License:** see `LICENSE` (Apache-2.0)
- **Vendored on:** 2026-06-30

## What's here / what's deliberately NOT

Copied: `skills/postgres/` only (SKILL.md, README.md, requirements.txt,
connections.example.json, .gitignore, scripts/query.py). Every other skill in
the upstream repo was left behind — vendor narrowly.

## Security review (query.py) — passed 2026-06-30

Read-only enforcement is **real**, not regex theater:
- `conn.set_session(readonly=True, autocommit=True)` — PostgreSQL rejects every
  write at the session level regardless of how the query parses. The
  `is_read_only()` prefix check is only defense-in-depth.
- Single-statement guard (rejects stacked `;`), 30s statement timeout, 10k-row
  fetch cap, credential sanitization on auth errors.
- No `shell=True`, `eval`, `os.system`, `subprocess`, file writes, or network
  beyond the psycopg2 connection. Auto-runs nothing on its own.

**Operational caveat:** credentials live in a plaintext `connections.json`
(skill dir or `~/.config/claude/postgres-connections.json`); `chmod 600` it.
`connections.json` is gitignored by the skill's own `.gitignore` — never commit
real creds. `connections.example.json` is the safe template.

## Runtime dependency

`scripts/query.py` needs `psycopg2-binary` (see `requirements.txt`). NOT
installed at vendor time — `pip install -r requirements.txt` before first use.

## Active subset

`postgres` (symlinked into both config dirs) — see `skills/REGISTRY.md`.

## To update

Re-copy `skills/postgres/` from upstream, re-review `query.py`, bump the pinned
commit above.
