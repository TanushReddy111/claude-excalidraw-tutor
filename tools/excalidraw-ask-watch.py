#!/usr/bin/env python3
"""Watch the Excalidraw canvas for notes that start with "@claude" and print one JSON line per new note.

Used by the Code Explainer output style through Claude Code's Monitor tool.
Read-only: it only GETs /api/elements. Handled note ids are kept in a seen-file so restarts don't repeat them.
"""
import json, os, sys, time, urllib.request

URL = os.environ.get("EXPRESS_SERVER_URL", "http://127.0.0.1:3000") + "/api/elements"
SEEN = os.path.expanduser("~/.cache/excalidraw-ask/seen.txt")
INTERVAL = float(os.environ.get("ASK_POLL_SECONDS", "2"))
SETTLE = 3  # polls a note's text must stay unchanged, so half-typed notes aren't sent

def load_seen():
    try:
        return set(open(SEEN).read().split())
    except FileNotFoundError:
        return set()

def elements():
    with urllib.request.urlopen(URL, timeout=5) as r:
        d = json.load(r)
    return d.get("elements", d) if isinstance(d, dict) else d

def main():
    os.makedirs(os.path.dirname(SEEN), exist_ok=True)
    seen, pending, once = load_seen(), {}, "--once" in sys.argv
    while True:
        try:
            for e in elements():
                t = (e.get("text") or "").strip()
                if e.get("type") != "text" or e.get("isDeleted") or not t.lower().startswith("@claude") or len(t) < len("@claude") + 3 or e["id"] in seen:
                    continue
                prev, n = pending.get(e["id"], (None, 0))
                n = n + 1 if prev == t else 1
                pending[e["id"]] = (t, n)
                if n >= SETTLE or once:
                    print(json.dumps({"id": e["id"], "text": t, "x": e.get("x"), "y": e.get("y"),
                                      "containerId": e.get("containerId"), "frameId": e.get("frameId")}), flush=True)
                    seen.add(e["id"]); pending.pop(e["id"], None)
                    with open(SEEN, "a") as f:
                        f.write(e["id"] + "\n")
        except Exception as ex:  # canvas restarting or unreachable: report once per failure, keep polling
            print(json.dumps({"error": str(ex)[:200]}), flush=True)
            time.sleep(10)
        if once:
            return
        time.sleep(INTERVAL)

if __name__ == "__main__":
    main()
