# Squid Proxy - Claude Code Instructions

## Project Overview

Local Squid caching proxy for Claude Code sessions. Uses custom Alpine-based container, runs in Podman, auto-starts via launchd. HTTPS support via CONNECT tunneling (no SSL bumping/MITM).

## Development Workflow

- **Branch Strategy**: GitHub Flow (feature branches, PR to main)
- **MANDATORY**: Always check branch with `git branch --show-current` before any file modifications

## Pre-commit Checks

**MANDATORY: Run before every commit**

```bash
# Shellcheck all scripts (same as CI)
shellcheck scripts/*.sh

# Validate Squid config (same as CI)
podman exec squid-proxy squid -k parse

# Test basic functionality
curl -x http://localhost:3128 -I http://example.com
```

**Note**: GitHub Actions CI runs these same checks automatically on push/PR.

## Common Tasks

**Update Squid config:**
1. Edit `config/squid.conf`
2. Validate: `podman exec squid-proxy squid -k parse`
3. Reload: `podman exec squid-proxy squid -k reconfigure`

**Rebuild container image:**
1. Make changes to `Containerfile`
2. `podman build -t localhost/squid:latest .`
3. `podman stop squid-proxy && podman rm squid-proxy`
4. Recreate container with new image (see `scripts/setup.sh`)

## Testing

```bash
# End-to-end test
./scripts/squid-status.sh
curl -x http://localhost:3128 -I https://www.redhat.com
./scripts/squid-stats.sh
```

## Critical Files

1. **config/squid.conf** - All caching behavior, refresh patterns, ACLs
2. **Containerfile** - Custom Alpine Squid container image
3. **scripts/setup.sh** - Orchestrates entire setup (builds image, creates container)
4. **launchd/com.jeder.squid-proxy.plist** - Auto-start service

## Rollback Procedure

If proxy causes issues with Claude Code:

```bash
# Disable temporarily
unset http_proxy https_proxy

# Stop permanently
podman stop squid-proxy
launchctl unload ~/Library/LaunchAgents/com.jeder.squid-proxy.plist

# Re-enable later
launchctl load ~/Library/LaunchAgents/com.jeder.squid-proxy.plist
export http_proxy=http://localhost:3128
export https_proxy=http://localhost:3128
```
