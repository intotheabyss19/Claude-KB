# Tooling

## Contents
- Map large/unfamiliar codebases with graphify
- Artifact links show "page not found" — auth mismatch, not a broken link

### Artifact links show "page not found" — auth mismatch, not a broken link

**Context:** Claude Code publishes an Artifact; user opens the URL and gets
"page not found". User concluded artifacts never work.

**Problem:** Artifacts are private to the Claude account that published them,
and claude.ai renders "page not found" (not "no access") for a logged-out or
wrong-account viewer. Terminal ctrl/cmd-clicks open the DEFAULT browser — on
this Mac that is Zen (`app.zen-browser.zen`), which isn't signed into
claude.ai — while Brave, signed in as the owning account
(satyaranjanb821@gmail.com), renders the same URL fine. Looks like a dead
link; it's an auth mismatch in the browser that happened to open it.

**Fix:** Sign into claude.ai with the owning account in the default browser
(or make the signed-in browser the default / paste the URL there). When
handing the user an artifact URL, say it opens only in a browser signed into
the owning Claude account; if they report "not found", check default-browser
handler (`plutil -p ~/Library/Preferences/com.apple.LaunchServices/com.apple.launchservices.secure.plist`,
look for the https `LSHandlerRoleAll`) and login state before touching the
artifact itself. Verify rendering with claude-in-chrome when in doubt.

### Map large/unfamiliar codebases with graphify

**Context:** Onboarding to a big/unfamiliar code project where reading every
file blows the context budget. graphify (`graphifyy` on PyPI, command
`graphify`) parses a folder — code (tree-sitter), docs, PDFs, images, video —
into a queryable knowledge graph. Installed as an agent skill + optional MCP
server.

**Problem:** Default `graphify install` writes the skill to
`~/.claude/skills/graphify/`, which violates the "keep `~/.claude` vanilla"
rule (see [[repo-overview]] Distribution). A plain install lands in the wrong
config dir and is not picked up by the harness, which uses `~/.claude-work`
and `~/.claude-personal`.

**Fix:** The CLI honors `CLAUDE_CONFIG_DIR` (`__main__.py`). Install once per
config dir:
```bash
uv tool install graphifyy
CLAUDE_CONFIG_DIR=~/.claude-work     graphify install
CLAUDE_CONFIG_DIR=~/.claude-personal graphify install
```
Per project: `/graphify .` → writes `graphify-out/` (graph.html, GRAPH_REPORT.md,
graph.json). Point the project's CLAUDE.md/AGENTS.md at GRAPH_REPORT.md so the
agent reads the map before grepping. `graphify update .` refreshes the graph
AST-only (free, no LLM cost); first full build does LLM enrichment (API cost).

**Do NOT graph this KB.** The KB is small, hand-curated markdown with authored
`[[links]]` — auto-graphing it is noise and contradicts the lean-KB principle.
graphify is for big CODE/doc corpora, not the KB itself. Gitignore `graphify-out/`
per project; never commit graph artifacts into the KB.

**Source:** github.com/safishamsi/graphify (MIT, PyPI `graphifyy`)
