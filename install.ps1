# Install the Study Tutor and Code Explainer output styles for Claude Code (Windows).
$ErrorActionPreference = "Stop"
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$dest = Join-Path $env:USERPROFILE ".claude"

New-Item -ItemType Directory -Force -Path (Join-Path $dest "output-styles"), (Join-Path $dest "tools") | Out-Null
Copy-Item (Join-Path $here "output-styles\*.md") (Join-Path $dest "output-styles") -Force
Copy-Item (Join-Path $here "tools\excalidraw-ask-watch.py") (Join-Path $dest "tools") -Force
Write-Host "installed styles to $dest\output-styles and the watcher to $dest\tools"

if (-not (Get-Command claude -ErrorAction SilentlyContinue)) {
    Write-Host "claude (Claude Code) not found on PATH; install it, then run:"
    Write-Host "  claude mcp add excalidraw --scope user -- npx -y mcp-excalidraw-server"
    exit 0
}
if ((claude mcp list 2>$null) -match '^excalidraw:') {
    Write-Host "excalidraw MCP server already registered"
} else {
    claude mcp add excalidraw --scope user -- npx -y mcp-excalidraw-server
}
npx -y mcp-excalidraw-server install-skill
Write-Host "done. Restart claude, run /output-style, and open http://127.0.0.1:3000"
