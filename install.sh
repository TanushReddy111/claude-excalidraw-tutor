#!/usr/bin/env bash
# Install the Study Tutor and Code Explainer output styles for Claude Code (Linux / macOS).
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
dest="$HOME/.claude"

mkdir -p "$dest/output-styles" "$dest/tools"
cp "$here"/output-styles/*.md "$dest/output-styles/"
cp "$here"/tools/excalidraw-ask-watch.py "$dest/tools/"
chmod +x "$dest/tools/excalidraw-ask-watch.py"
echo "installed styles to $dest/output-styles and the watcher to $dest/tools"

if ! command -v claude >/dev/null; then
  echo "claude (Claude Code) not found on PATH; install it, then run:"
  echo "  claude mcp add excalidraw --scope user -- npx -y mcp-excalidraw-server"
  exit 0
fi
if claude mcp list 2>/dev/null | grep -q '^excalidraw:'; then
  echo "excalidraw MCP server already registered"
else
  claude mcp add excalidraw --scope user -- npx -y mcp-excalidraw-server
fi
npx -y mcp-excalidraw-server install-skill
echo "done. Restart claude, run /output-style, and open http://127.0.0.1:3000"
