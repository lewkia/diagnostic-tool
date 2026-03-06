# CLAUDE.md — Razer IT Diagnostic Tool

## Project Overview

Single-file static web application for IT endpoint diagnostics. No build step, no backend, no Node.js — one `index.html` served by nginx in Docker.

## File Structure

```
diagnostic-tool/
├── index.html      # Entire application (HTML + CSS + JS)
├── Dockerfile      # nginx:alpine serving on port 8080
├── README.md       # Setup and logo replacement guide
└── CLAUDE.md       # This file
```

## Tech Stack

- **Frontend**: Vanilla HTML5 / CSS3 / JavaScript (ES2020+)
- **PDF Export**: jsPDF 2.5.1 + html2canvas 1.4.1 (CDN)
- **Fonts**: Google Fonts — Rajdhani, Orbitron
- **Server**: nginx:alpine (Docker only)
- **Port**: 8080

## Architecture

Everything lives in `index.html`. The structure is:

1. `<style>` — All CSS (Razer dark theme, animations, layout)
2. `<body>` — Header, export bar, loading bar, main sections, footer, toast, PDF overlay
3. `<script>` — All application logic

### JavaScript Modules (in-file, not ES modules)

| Section | Purpose |
|---|---|
| `CONFIG` | Editable configuration: servers, ports, emails |
| Clock | `updateClock()` — live header clock, 1s interval |
| Utilities | `showToast`, `getBadge`, `getIcon`, `timeout` |
| System Info | `gatherSysInfo`, `detectBrowser`, `detectOS`, `fetchPublicIp` |
| Network Checks | `runNetworkChecks` — internet, DNS, VPN, latency |
| Server Checks | `runServerChecks` — HTTP fetch ping per server |
| Port Checks | `runPortChecks` — WebSocket-based port probing |
| Summary | `updateSummary` — calculates health score |
| Export | `copyReport`, `downloadTxt`, `savePdf`, `buildReport` |
| Email | `emailSupport` — mailto with pre-filled report body |
| Runner | `runDiagnostics` — orchestrates all checks with progress |

## Key Design Decisions

### Browser-Based "Ping"
Browsers cannot send ICMP. Server reachability is tested via `fetch()` with `mode: 'no-cors'`. A fast response (or CORS error) indicates a live host; a timeout indicates unreachable. This produces false negatives if HTTP is blocked on a server that's otherwise live.

### Port Detection
Uses WebSocket connections (`ws://host:port`). A rapid `onerror` (< 3s) is interpreted as "port open but refusing WS upgrade". A timeout is treated as closed/filtered. This is an approximation — strict firewalls may cause false negatives.

### VPN Detection
Compares the public IP (from `api.ipify.org`) against RFC1918 and common VPN IP prefixes. If the public IP is private, VPN is inferred. Adjust `CONFIG.vpnPrefixes` for your environment.

### PDF Export
`html2canvas` captures `#main-content` at 1.5x scale. `jsPDF` adds a green header bar and handles multi-page layout. The PDF is A4 portrait.

## Color Tokens

| Token | Hex | Usage |
|---|---|---|
| Background | `#0a0a0a` | Page background |
| Card | `#111111` | Section cards |
| Accent Primary | `#00ff00` | Razer green — borders, text, badges |
| Accent Secondary | `#44d62c` | Subtitles, links |
| Pass | `#00ff00` | Pass status |
| Fail | `#ff0000` | Fail status |
| Warn | `#ffcc00` | Warning status |
| Border | `#1a1a1a` | Default card borders |

## Modifying Configuration

Edit the `CONFIG` object inside `<script>` in `index.html`:

```javascript
const CONFIG = {
  servers: [
    { name: 'My Server', ip: '10.0.0.1' },
    // ...
  ],
  ports: [
    { port: 443, service: 'HTTPS', host: '10.0.0.1' },
    // ...
  ],
  // ...
};
```

## Docker Commands

```bash
# Build
docker build -t razer-diagnostic .

# Run
docker run -d -p 8080:8080 --name razer-diag razer-diagnostic

# Stop & remove
docker stop razer-diag && docker rm razer-diag
```

## External Dependencies (CDN)

If the environment has no internet access, download these and serve locally:

- `https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js`
- `https://cdnjs.cloudflare.com/ajax/libs/html2canvas/1.4.1/html2canvas.min.js`
- Google Fonts: Rajdhani + Orbitron

Update the `<link>` and `<script>` tags in `index.html` to point to local copies.

## Known Limitations

1. **No real ICMP ping** — uses HTTP fetch approximation
2. **Port checks are approximate** — WebSocket heuristic, not TCP SYN
3. **Username not available** — browsers have no access to OS username
4. **CORS restrictions** — some servers may block cross-origin requests, causing false FAIL results
5. **Public IP fetch requires internet** — `api.ipify.org` must be reachable
