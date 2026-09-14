# VS Code configuration

These files make the repository usable from a VS Code agent session. The short
version: register the Edev launcher over MCP, and let the agent return
`ImageRef` values from a Luau script.

## Files

- `mcp.json` -- workspace MCP server. Registers `edev mcp` as the `eguidev`
  server. VS Code starts it from the Chat view (or `MCP: List Servers`), and
  the `eguidev` server then exposes `start`, `stop`, `restart`, and `status`.
  A lifecycle result carries the app endpoint that serves `script_api` and
  `script_eval`.
- `tasks.json` -- one-shot CLI equivalents, including screenshot capture with
  `--out-dir tmp/eguidev-screenshots`. Run `Tasks: Run Task`.
- `settings.json` -- `.luau` association, Rust Analyzer features/clippy
  wiring, and `target`/`tmp` excludes so search stays fast.
- `extensions.json` -- rust-analyzer, CodeLLDB, Even Better TOML, and the Luau
  language server plus Stylua.
- `launch.json` -- debug the demo app, or attach to an app that
  `edev fixture NAME` left running.

## How an agent sees a screenshot

Two independent paths; the first needs no filesystem access at all.

1. **MCP image content blocks.** A `script_eval` result turns every `ImageRef`
   reachable from the returned value into an MCP `image` block (base64 PNG or
   JPEG). Return the image; the agent renders it.

   ```luau
   eguidev.fixture("basic.empty")
   return { root = eguidev.root:screenshot({ format = "png" }) }
   ```

2. **Files on disk.** `edev eval SCRIPT --out-dir DIR` writes the same images
   next to the script, or into `DIR`, and the agent reads them as image files:

   ```sh
   edev eval examples/screenshot.luau --out-dir tmp/eguidev-screenshots
   ```

`examples/screenshot.luau` implements both: it captures every viewport (or one
widget via `--arg widget=ID`) and returns a label-to-`ImageRef` table.

## Environment notes

- On Linux without a display, run the CLI through `xvfb-run` with
  `LIBGL_ALWAYS_SOFTWARE=1`; the `headless Linux` capture task does this.
  MCP sessions cannot inject those variables, so launch VS Code itself from a
  shell that already has `DISPLAY` set (`Xvfb :99 & export DISPLAY=:99`).
- On macOS, child-viewport screenshot fallback needs Screen Recording
  permission for the process that runs `edev`.
- `mcp.json` uses the installed `edev` binary so the server starts without a
  workspace build. To build the launcher from this checkout instead, use
  `"command": "cargo"` with
  `"args": ["run", "--locked", "--bin", "edev", "--", "mcp"]`.
