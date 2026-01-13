#!/bin/sh

# Variables
BASE_DIR="/mnt/us/extensions/kindle_copyparty"
TAILSCALE_DIR="$BASE_DIR/tailscale"
TAILSCALE_BIN_DIR="$TAILSCALE_DIR/bin"
TAILSCALE_LOGS="$TAILSCALE_DIR/logs"
ZIPS_DIR="$BASE_DIR/zips"
AUTH_KEY_FILE="$TAILSCALE_DIR/config/auth_key.txt"
TAILSCALE_URL="https://pkgs.tailscale.com/stable/tailscale_1.92.5_arm.tgz"
TAILSCALED_LOG_FILE="$TAILSCALE_LOGS/tailscaled_start_log.txt"
TAILSCALE_LOG_FILE="$TAILSCALE_LOGS/tailscale_start_log.txt"

# Check required files 
if [ -f "$BASE_DIR/kindle_copyparty.sh" ] && \
   [ -f "$BASE_DIR/start_kindle_copyparty.sh" ] && \
   [ -f /etc/upstart/kindle_copyparty.conf ] && \
   [ -f "$BASE_DIR/kindle_copyparty.ext3" ]; then

    # Create dirs
    mkdir -p "$TAILSCALE_BIN_DIR" "$TAILSCALE_LOGS" "$ZIPS_DIR" "$(dirname "$AUTH_KEY_FILE")"

    # Download Tailscale 
    curl -L -o "$ZIPS_DIR/tailscale.tgz" "$TAILSCALE_URL"
    if [ $? -ne 0 ]; then
        echo "Error: Failed to download Tailscale."
        exit 1
    fi

    # Extract bins
    TOPDIR=$(tar -tzf "$ZIPS_DIR/tailscale.tgz" | head -1 | cut -d/ -f1)
    tar -xzvf "$ZIPS_DIR/tailscale.tgz" -C "$TAILSCALE_BIN_DIR" "$TOPDIR/tailscale" "$TOPDIR/tailscaled" --strip-components=1
    chmod +x "$TAILSCALE_BIN_DIR/tailscale" "$TAILSCALE_BIN_DIR/tailscaled"

    TAILSCALE="$TAILSCALE_BIN_DIR/tailscale"
    TAILSCALED="$TAILSCALE_BIN_DIR/tailscaled"

    # Auth key checking and handling
    if [ -f "$AUTH_KEY_FILE" ]; then
        AUTH_KEY=$(tr -d '[:space:]' < "$AUTH_KEY_FILE")
    else
        echo "Tailscale auth key not found."
        # Keep prompting until a non-empty key is provided
        while [ -z "$AUTH_KEY" ]; do
            read -p "Please paste your auth key here: " AUTH_KEY
            AUTH_KEY=$(echo "$AUTH_KEY" | tr -d '[:space:]')
        done
        echo "$AUTH_KEY" > "$AUTH_KEY_FILE"
        chmod 600 "$AUTH_KEY_FILE"
    fi

    # Start tailscaled
    "$TAILSCALED" -tun userspace-networking -no-logs-no-support > "$TAILSCALED_LOG_FILE" 2>&1 &

    # Start Tailscaled and Tailscale
    "$TAILSCALE" up --auth-key="$AUTH_KEY" >> "$TAILSCALE_LOG_FILE" 2>&1

    # Launch Kindle Copyparty
    sh "$BASE_DIR/start_kindle_copyparty.sh"

else
    fbink -pmh -y -5 "Error: Required files missing. Deploy Alpine first!"
fi
