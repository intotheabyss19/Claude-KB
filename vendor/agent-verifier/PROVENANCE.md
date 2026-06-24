# Provenance — agent-verifier

Third-party skill set, vendored as a **plain copy** (not a git submodule).

- **Source:** https://github.com/Aurite-ai/agent-verifier
- **Pinned commit:** `23d73ad30ad2bed7744e84950a1e5282c53f0149`
- **License:** MIT © 2026 Aurite AI (see `LICENSE`)
- **Vendored on:** 2026-06-25

## What's here

Five skills copied verbatim from `skills/` of the upstream repo:

| Skill | Status | Notes |
|-------|--------|-------|
| `verify-security` | **ACTIVE** (symlinked into both config dirs) | read-only static scan: secrets, dep pinning, injection, info leak, insecure defaults |
| `verify-quality` | dormant (on disk only) | naming, organization, docs |
| `verify-patterns` | dormant | agent loops/retries/tool-registry checks |
| `verify-language` | dormant | type hints, idioms |
| `verification` | dormant | orchestrator that runs all of the above ("verify agent") |

Dormant skills cost **zero tokens** until symlinked. Activate one with:

```sh
for cfg in ~/.claude-personal ~/.claude-work; do
  ln -sfn /home/ysh/Desktop/Obsidian/Prompts/Claude/vendor/agent-verifier/skills/<name> "$cfg/skills/<name>"
done
```

## Why a plain copy and not a submodule

The upstream repo is 6.5 MB — almost entirely a 3.1 MB demo GIF and `.git`
history — to host five 7–12 KB markdown files. A plain copy of just the
skills (48 KB) keeps the KB lean. These are `v1.0.0` pure-markdown skills
that change rarely, so manual updates are cheap.

## Security review summary (2026-06-25)

Reviewed before install (3 independent lenses + synthesis). The two
relevant skills are documentation-only — no bundled scripts, no network
calls; `verify-security` is fully read-only. The "code never leaves your
machine" claim holds for the skills as written. Caveats that do **not**
apply to the active `verify-security` skill:

- The repo's README describes an OPTIONAL external "Kahuna-Enhanced Mode"
  (MCP tools from a separate repo) that *would* send context off-machine.
  We do not install it.
- The dormant `verification` orchestrator reads `.kahuna/context-guide.md`
  as authoritative "rules" (a repo-controllable prompt-injection surface)
  and has a user-gated report-export that runs `mkdir`. Neither ships in
  `verify-security`.

## To update from upstream

```sh
git clone --depth 1 https://github.com/Aurite-ai/agent-verifier /tmp/av
cp -R /tmp/av/skills/. <KB>/vendor/agent-verifier/skills/
# update the pinned commit above; re-apply any local description tuning
```
