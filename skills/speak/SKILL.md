---
name: speak
description: Speak your replies out loud with the Mac's voice, and hold a two-way spoken conversation (e.g. voice tutor/teacher). Use when the user says talk to me, use your voice, say it out loud, read this aloud, be my voice teacher, or asks for a spoken/voice session.
---
# Skill: Speak (voice out, optional voice in)

Give this terminal session a voice. Two capabilities:

## 1. Speak a line (universal — works in ANY session, zero setup)
Pipe text through macOS `say`:

```bash
say -v "Samantha" -r 180 "Your spoken line here."
```

- Keep spoken lines SHORT and natural (1–3 sentences) — it's speech, not an essay. Strip markdown/URLs/code
  before speaking. Don't narrate tool use.
- Voices: `Samantha` (clear US female, default), `Tom`/`Alex` (US male), `Aman`/`Rishi` (en-IN), `Daniel` (en-GB).
  List all with `say -v '?'`. Let the user pick; remember their choice for the session.
- Use this whenever the user wants you to talk: "say that", "read it aloud", "reply with your voice", or as
  each turn of a spoken conversation below.

## 2. Two-way spoken conversation (you speak, the user answers)
You DRIVE: speak a line/question, get the user's answer, react, continue. Stay in character for role-play
(teacher who probes and gets exasperated, interviewer, quizmaster…). Keep spoken turns concise. Continue until
the user says "stop" / "that's enough" / "we're done".

**Getting the user's answer — pick the best available:**

- **Typed answer (reliable everywhere):** speak your question with `say`, then just wait for the user's typed
  reply like normal. This alone is a great spoken-teacher experience (you ask out loud, they type). Default to
  this unless the user wants to answer by voice.

- **Spoken answer (full voice loop):** run the bundled bridge so the user answers BY VOICE. It loads Whisper
  once (snappy) and, per turn, speaks your line then captures + transcribes their reply.
  1. Start it once (background), from a dir where it can import an STT — the Sheru project is ideal
     (`~/Projects/Sheru`, VAD + Whisper):
     ```bash
     cd ~/Projects/Sheru && nohup uv run python /Users/yash/Desktop/Obsidian/Prompts/Claude/skills/speak/voice_bridge.py > /tmp/voice_bridge.log 2>&1 &
     # wait for "voice bridge ready" in /tmp/voice_bridge.log
     ```
     No Sheru project? The bridge falls back to `ffmpeg` capture + `whisper-cli` (needs a ggml model); if that
     isn't set up, use the typed-answer mode above instead.
  2. Each turn — write your line, trigger, read back the transcript:
     ```bash
     printf '%s' "Your spoken line/question." > /tmp/voice_say.txt; rm -f /tmp/voice_done; touch /tmp/voice_go
     for i in $(seq 1 300); do [ -f /tmp/voice_done ] && break; sleep 0.2; done; cat /tmp/voice_heard.txt
     ```
     The printed transcript is the user's spoken reply — react to it, then do the next turn.
  3. Stop the bridge when done: `printf '%s' "__QUIT__" > /tmp/voice_say.txt; touch /tmp/voice_go`.

**Notes**
- One mic at a time: if Sheru (or another mic app) is actively listening, pause it so it doesn't fight the
  bridge for the mic. Sheru is push-to-talk, so idle is fine.
- Never let the same line get spoken twice; write the file, trigger once, wait for `voice_done`.
- If the transcript is empty (nothing heard / timed out), say so out loud and re-ask, or drop to typed answers.
