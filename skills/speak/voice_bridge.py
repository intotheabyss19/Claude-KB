"""Voice bridge for the `speak` skill: lets a Claude Code session hold a SPOKEN conversation.
Loads STT once, then per request SPEAKS Claude's line (macOS `say`) and LISTENS for the user's reply,
writing the transcript to a file Claude reads back.

Backends (auto-detected):
  1. Sheru (run from ~/Projects/Sheru): VAD mic capture + Whisper — snappy, stops on silence. Preferred.
  2. Portable fallback: ffmpeg fixed-window capture + whisper-cli (needs a ggml model). Clumsier; if no model
     is found it errors and Claude should fall back to typed answers.

Protocol (files in /tmp):
  voice_say.txt   <- Claude's line to speak ('__QUIT__' to stop)
  voice_go        <- touch to trigger a speak+listen turn
  voice_heard.txt -> transcript of the user's spoken reply
  voice_done      -> written when the transcript is ready
"""
import os
import subprocess
import sys
import tempfile
import time
import warnings

warnings.filterwarnings("ignore")

SAY_F, GO_F, HEARD_F, DONE_F = "/tmp/voice_say.txt", "/tmp/voice_go", "/tmp/voice_heard.txt", "/tmp/voice_done"
VOICE = os.environ.get("VOICE_NAME", "Samantha")
RATE = os.environ.get("VOICE_RATE", "180")


def _make_listener():
    """Return a capture()->str function. Prefer Sheru's VAD+Whisper; else ffmpeg + whisper-cli."""
    for path in ("/Users/yash/Projects/Sheru/src", os.path.join(os.path.expanduser("~"), "Projects/Sheru/src")):
        if os.path.isdir(path):
            sys.path.insert(0, path)
            try:
                from sheru.stt import Transcriber
                from sheru.audio import capture_once, ListenerConfig, preferred_device
                stt = Transcriber().load()
                cfg = ListenerConfig(vad_threshold=0.35, min_speech_s=0.3, end_silence_s=0.9,
                                     device=preferred_device())

                def cap():
                    a = capture_once(max_wait=30.0, cfg=cfg)
                    return (stt.transcribe(a) if a is not None else "").strip()
                print("backend: Sheru VAD+Whisper", flush=True)
                return cap
            except Exception as e:
                print("Sheru backend unavailable:", e, flush=True)
                break
    # portable fallback: ffmpeg fixed window + whisper-cli
    whisper = subprocess.run(["command", "-v", "whisper-cli"], capture_output=True, text=True, shell=False)
    model = next((m for m in [
        os.path.expanduser("~/.cache/whisper/ggml-base.en.bin"),
        "/opt/homebrew/share/whisper-cpp/ggml-base.en.bin",
    ] if os.path.exists(m)), None)

    def cap():
        wav = tempfile.mktemp(suffix=".wav")
        subprocess.run(["ffmpeg", "-y", "-f", "avfoundation", "-i", ":default", "-t", "15",
                        "-ar", "16000", "-ac", "1", wav], capture_output=True)
        if not model:
            return ""            # no STT model -> Claude should use typed answers
        r = subprocess.run(["whisper-cli", "-m", model, "-f", wav, "-nt", "-otxt", "-of", wav], capture_output=True)
        try:
            return open(wav + ".txt", encoding="utf-8").read().strip()
        except Exception:
            return ""
    print("backend: ffmpeg + whisper-cli (fixed 15s window)", flush=True)
    return cap


def main():
    listen = _make_listener()
    print("voice bridge ready", flush=True)
    last_go = 0.0
    while True:
        try:
            if os.path.exists(GO_F) and os.path.getmtime(GO_F) > last_go:
                last_go = os.path.getmtime(GO_F)
                line = open(SAY_F, encoding="utf-8").read().strip() if os.path.exists(SAY_F) else ""
                if line == "__QUIT__":
                    print("bridge quitting", flush=True)
                    break
                if line:
                    subprocess.run(["say", "-v", VOICE, "-r", RATE, line])
                text = listen()
                with open(HEARD_F, "w", encoding="utf-8") as f:
                    f.write(text)
                with open(DONE_F, "w") as f:
                    f.write(str(time.time()))
                print(f"heard: {text!r}", flush=True)
            time.sleep(0.15)
        except Exception as e:
            print("bridge error:", e, flush=True)
            time.sleep(0.3)


if __name__ == "__main__":
    main()
