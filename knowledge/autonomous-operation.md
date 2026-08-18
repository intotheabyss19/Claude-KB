# Autonomous Operation

Running long stretches with the user away. Both lessons below cost real hours
before they were understood.

## Contents
- Keep an unattended session alive with a heartbeat Monitor
- Long agent runs die unattended; checkpoint to disk and keep the stream noisy

---

### Keep an unattended session alive with a heartbeat Monitor

**Context:** the user leaves for hours - asleep, out, "busy for 2-3 hours" - and
asks you to keep working.

**Problem:** the main loop only runs when something wakes it. Background agents
wake you when they finish, but between them nothing does, so the session quietly
stops and the entire absence is wasted. This is invisible while it happens: there
is no error, just silence.

**Fix:** arm a persistent Monitor before starting, and stop it with TaskStop when
they return.

    Monitor({persistent: true, timeout_ms: 3600000,
             description: "heartbeat every 10min",
             command: 'while true; do echo "heartbeat $(date -u +%H:%MZ) - <standing instruction>"; sleep 600; done'})

Each emitted line arrives as a notification and re-invokes you, so **the line IS
the wake instruction** - write what to DO on waking ("check submissions, fix
failures, keep building"), not the word "heartbeat". Ten minutes is a reasonable
default: frequent enough that a stall costs little, rare enough to stay cheap.

Two habits that make it actually work:
- Never end an unattended turn on a blocking question; they are not there to
  answer it. At a genuine fork, take the reversible option, state the assumption,
  and keep moving.
- Stop the heartbeat when they return, or it fires for the rest of the session.

*Automated by the `heartbeat-guard` UserPromptSubmit hook, which fires on both
departure and return language. See rule 10 in `docs/working-rules.md`; the hook is
the backstop, the rule is primary.*

---

### Long agent runs die unattended; checkpoint to disk and keep the stream noisy

**Context:** delegating multi-hour work to subagents while nobody is watching.

**Problem:** two distinct failure modes, both of which destroy the run's output
rather than just delaying it. A stall watchdog kills an agent after ~10 minutes
with no output, which is exactly what a long silent reasoning pass looks like. And
a dropped network connection terminates the agent outright (`ENOTFOUND`), taking
anything it was holding in context with it. In one session four agents died this
way, two mid-writeup.

**Fix:** make the work survive the agent.
- Tell the agent to keep a running `PROGRESS.md` and append every few minutes -
  what it just measured, the number, what it is about to try. This doubles as the
  stream traffic that prevents the stall kill.
- Tell it to prefer many short tool calls over one long silent think.
- Tell it to write results to disk as it goes rather than holding them for a final
  report.

Then when an agent dies, harvest the directory instead of mourning the run: the
files and the progress log are usually all there. Several "failed" agents in that
session had in fact finished the work and died during the writeup.
