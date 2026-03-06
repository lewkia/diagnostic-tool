# Razer IT Diagnostic Tool

A self-contained, browser-based IT diagnostic tool with Razer gaming aesthetics. No backend required — pure HTML/CSS/JavaScript.

---

## Quick Start

### Run with Docker (recommended)

```bash
# Build the image
docker build -t razer-diagnostic .

# Run on port 8080
docker run -d -p 8080:8080 --name razer-diag razer-diagnostic

# Open in browser
# http://localhost:8080
```

### Run without Docker

Simply open `index.html` in Chrome or Edge directly, or serve it with any static web server:

```bash
# Using Python
python -m http.server 8080

# Using Node.js (npx)
npx serve . -p 8080
```

---

## Replacing the Logo

1. Place your logo image (PNG recommended) in the same folder as `index.html`, named `razer-logo.png`.

2. Open `index.html` and find this comment (around line 140):

   ```html
   <!-- REPLACE LOGO: change the div below to:
        <img src="razer-logo.png" height="60" style="width:60px;object-fit:contain;border:none;box-shadow:none;"> -->
   ```

3. Replace the `<div id="logo-placeholder">LOGO</div>` element with:

   ```html
   <img src="razer-logo.png" height="60" style="width:60px;object-fit:contain;border:none;box-shadow:none;">
   ```

4. If using Docker, also uncomment this line in the `Dockerfile`:

   ```dockerfile
   COPY razer-logo.png /usr/share/nginx/html/razer-logo.png
   ```

   Then rebuild: `docker build -t razer-diagnostic .`

---

## Configuration

Edit the `CONFIG` object near the top of the `<script>` block in `index.html`:

| Setting | Description |
|---|---|
| `companyName` | Your company name |
| `itEmail` | IT support email address |
| `helpdeskUrl` | Helpdesk portal URL |
| `appName` | Name of the primary application |
| `servers` | List of servers to connectivity-check |
| `ports` | List of ports to probe on the app server |
| `vpnPrefixes` | IP prefixes that indicate VPN connectivity |

---

## Features

- **Auto-run** on page load with animated green progress bar
- **System Info**: browser, OS, screen, timezone, public IP, RAM, CPU cores
- **Network Checks**: internet, DNS, VPN detection, latency
- **Server Connectivity**: HTTP-based reachability for each configured server
- **Port Checks**: WebSocket-based port probing
- **Summary Banner**: health score (0–100%), color-coded (green/yellow/red)
- **Export**: copy to clipboard, download TXT, save as PDF (jsPDF + html2canvas)
- **Email IT Support**: pre-fills email body with full diagnostic report
- **Re-Run**: re-run all checks at any time

---

## Browser Compatibility

| Browser | Supported |
|---|---|
| Google Chrome 90+ | Yes |
| Microsoft Edge 90+ | Yes |
| Firefox | Partial (some port checks limited) |
| Safari | Partial |

> **Note:** Due to browser security restrictions, ICMP ping is not available. Server reachability is tested via HTTP fetch. Port checks use WebSocket connections. Results may show false negatives for servers that block HTTP/WebSocket on those ports.

---

## Docker Stop / Remove

```bash
docker stop razer-diag
docker rm razer-diag
docker rmi razer-diagnostic
```
