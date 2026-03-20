---
name: chrome-devtools-cli
description: Uses the chrome-mcp-cli command-line tool to control Chrome DevTools from the terminal. Use when the user wants browser automation, page inspection, screenshots, network inspection, console inspection, or performance tracing through the CLI instead of MCP tools.
---

# Chrome DevTools CLI

This skill uses the `chrome-mcp-cli` binary from the `chrome-devtools-cli` package.

## When to Use This Skill

Use this skill when the user wants to:

- Inspect or automate a page from the terminal
- Capture screenshots or accessibility snapshots
- Inspect console messages or network requests
- Run JavaScript in the page context
- Record and analyze performance traces
- Use Chrome DevTools capabilities without MCP integration

## Requirements

Before using the CLI, Chrome must be running with remote debugging enabled on port `9222`.

macOS:

```bash
/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --remote-debugging-port=9222 --user-data-dir=/tmp/chrome-profile-stable
```

If Chrome is already running normally, close it first or launch a separate debug profile.

## Core Commands

General usage:

```bash
chrome-mcp-cli --help
chrome-mcp-cli --commands
chrome-mcp-cli <command> -h
chrome-mcp-cli <command> '<json arguments>'
```

Common commands:

- `list_pages`
- `select_page`
- `new_page`
- `navigate_page`
- `take_snapshot`
- `take_screenshot`
- `click`
- `fill`
- `fill_form`
- `hover`
- `press_key`
- `evaluate_script`
- `list_console_messages`
- `list_network_requests`
- `performance_start_trace`
- `performance_stop_trace`
- `performance_analyze_insight`
- `wait_for`

## Workflow Patterns

### Basic page interaction

1. Ensure Chrome is running with `--remote-debugging-port=9222`
2. Run `chrome-mcp-cli list_pages`
3. If needed, create or select a page with `new_page` or `select_page`
4. Navigate with `navigate_page`
5. Use `take_snapshot` to get current page structure and element `uid`s
6. Interact with `click`, `fill`, `hover`, `press_key`, or `drag`

### Prefer snapshots over screenshots

- Use `take_snapshot` first for automation and text inspection
- Use `take_screenshot` when the user needs visual verification or an image artifact

### Debugging workflow

1. `navigate_page` to the target URL
2. `wait_for` expected text if needed
3. `list_console_messages` for JavaScript/runtime errors
4. `list_network_requests` for failed or slow requests
5. `evaluate_script` for state the CLI does not expose directly

### Performance workflow

1. `performance_start_trace '{}'
2. Reproduce the interaction in the page
3. `performance_stop_trace '{}'`
4. Use `performance_analyze_insight` on returned insight IDs if needed

## Examples

Navigate to a page:

```bash
chrome-mcp-cli navigate_page '{"url":"https://example.com","type":"url"}'
```

Create a new page:

```bash
chrome-mcp-cli new_page '{"url":"https://example.com"}'
```

Take a snapshot:

```bash
chrome-mcp-cli take_snapshot '{}'
```

Take a screenshot:

```bash
chrome-mcp-cli take_screenshot '{"fullPage":true,"filePath":"/tmp/page.png"}'
```

Evaluate JavaScript:

```bash
chrome-mcp-cli evaluate_script '{"function":"() => document.title"}'
```

List console messages:

```bash
chrome-mcp-cli list_console_messages '{}'
```

List network requests:

```bash
chrome-mcp-cli list_network_requests '{}'
```

## Guidance

- Use the Bash tool for all `chrome-mcp-cli` commands
- Quote JSON arguments with single quotes in the shell
- Use absolute paths for saved screenshots or files
- If a command fails, check whether Chrome is running with remote debugging enabled
- If element interaction fails, take a fresh snapshot to get current `uid`s

## Limitations

- This is a CLI wrapper, not native MCP tooling inside the agent runtime
- State lives in the Chrome debug session, so restarting Chrome can change page indexes and context
- Some workflows may require multiple sequential shell commands rather than direct tool calls
