# Squid Proxy - Claude Code Instructions

## Project Overview

Local Squid caching proxy for Claude Code sessions. Runs in Podman, auto-starts via launchd.

## Development Workflow

- **Branch Strategy**: GitHub Flow (feature branches, PR to main)
- **MANDATORY**: Always check branch with `git branch --show-current` before any file modifications

## Pre-commit Checks

```bash
# Validate Squid config
podman exec squid-proxy squid -k parse

# Shellcheck all scripts
shellcheck scripts/*.sh

# Test basic functionality
curl -x http://localhost:3128 -I http://example.com
```

## Common Tasks

**Update Squid config:**
1. Edit `config/squid.conf`
2. Validate: `podman exec squid-proxy squid -k parse`
3. Reload: `podman exec squid-proxy squid -k reconfigure`

**Update SSL cert (annual rotation):**
1. `./scripts/gen-certs.sh`
2. Reinstall in keychain
3. Restart container

## Testing

```bash
# End-to-end test
./scripts/squid-status.sh
curl -x http://localhost:3128 -I https://www.redhat.com
./scripts/squid-stats.sh
```

## Critical Files

1. **config/squid.conf** - All caching behavior, SSL bump, ACLs
2. **scripts/setup.sh** - Orchestrates entire setup
3. **launchd/com.jeder.squid-proxy.plist** - Auto-start service
4. **scripts/gen-certs.sh** - SSL certificate generation

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
