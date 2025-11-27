#!/bin/bash
set -euo pipefail

CERT_DIR="$(cd "$(dirname "$0")/.." && pwd)/certs"
mkdir -p "$CERT_DIR"

# Generate 4096-bit RSA CA certificate (10-year validity)
openssl req -new -newkey rsa:4096 -sha256 -days 3650 -nodes -x509 \
    -extensions v3_ca \
    -keyout "$CERT_DIR/squid-ca.key" \
    -out "$CERT_DIR/squid-ca.pem" \
    -subj "/C=US/ST=NC/L=Raleigh/O=Red Hat/OU=Engineering/CN=Squid Proxy CA"

# Secure private key
chmod 600 "$CERT_DIR/squid-ca.key"
chmod 644 "$CERT_DIR/squid-ca.pem"

echo "✓ SSL certificates generated in $CERT_DIR"
echo "  - CA cert: squid-ca.pem"
echo "  - Private key: squid-ca.key (600 permissions)"
