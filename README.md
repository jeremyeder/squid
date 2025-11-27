# Squid Caching Proxy for Claude Code

[![CI](https://github.com/jeder/squid/actions/workflows/ci.yml/badge.svg)](https://github.com/jeder/squid/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Local caching proxy to speed up Claude Code sessions by caching web content.

## Features

- 10GB disk cache for web content
- HTTPS support via CONNECT tunneling
- Auto-start on boot (launchd)
- CLI management scripts
- Web-based cache manager
- Balanced caching strategy (respects TTLs)
- Custom Alpine-based container image

## Quickstart

```bash
# Initial setup
./scripts/setup.sh

# Add proxy toggle functions to ~/.zshrc (already done for you!)
source ~/.zshrc

# Enable proxy
proxy-on

# Test
curl -I https://www.redhat.com

# Check status
proxy-status
```

## Management

```bash
# Status and stats
./scripts/squid-status.sh
./scripts/squid-stats.sh

# Control
./scripts/squid-start.sh
./scripts/squid-stop.sh

# Logs
./scripts/squid-logs.sh access  # or cache, store

# Maintenance
./scripts/squid-clear-cache.sh

# Web UI
./scripts/cachemgr-server.sh
open http://localhost:8080/cachemgr.cgi
```

## Claude Code Integration

The proxy is automatically configured for terminal use via shell functions in `~/.zshrc`:

```bash
# Enable proxy for current terminal session
proxy-on

# Launch Claude Code - all HTTP/HTTPS requests will be cached
claude

# Check proxy status
proxy-status

# Disable proxy when done
proxy-off
```

**How it works**: The `proxy-on` function sets standard environment variables (`http_proxy`, `https_proxy`) that Claude Code and other CLI tools automatically respect.

## Testing Cache Effectiveness

```bash
# Enable proxy first
proxy-on

# First request (cache MISS)
time curl -I https://www.redhat.com

# Second request (cache HIT - should be 6x faster!)
time curl -I https://www.redhat.com

# View statistics
./scripts/squid-stats.sh

# Disable when done
proxy-off
```

## Troubleshooting

**Proxy not working:**
```bash
# Check container
podman ps -a | grep squid-proxy

# Check logs
./scripts/squid-logs.sh cache

# Restart
podman restart squid-proxy
```

## Uninstall

```bash
# Stop and remove
podman stop squid-proxy && podman rm squid-proxy
podman volume rm squid-cache squid-logs

# Remove launchd service
launchctl unload ~/Library/LaunchAgents/com.jeder.squid-proxy.plist
rm ~/Library/LaunchAgents/com.jeder.squid-proxy.plist
```
