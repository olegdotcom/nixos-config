#!/bin/bash

# One-time setup for the NAS mount points and SMB credentials.

set -e

MOUNT_POINT="/mnt/nas"
CRED_FILE="/etc/nixos/smb-credentials"
SHARE_DIRS=(
  "core"
  "dump"
  "photos"
)

echo "Creating mount point directories in $MOUNT_POINT..."
for dir in "${SHARE_DIRS[@]}"; do
  sudo mkdir -p "$MOUNT_POINT/$dir"
done
echo "Mount point directories created."
echo

echo "Please enter your SMB credentials for the TrueNAS share."
read -p "Username: " username
read -s -p "Password: " password
echo

# Write credentials to a private temporary file before moving it into place.
TEMP_CRED_FILE=$(mktemp)
echo "username=$username" > "$TEMP_CRED_FILE"
echo "password=$password" >> "$TEMP_CRED_FILE"

echo "Moving credentials to $CRED_FILE..."
sudo mv "$TEMP_CRED_FILE" "$CRED_FILE"

sudo chmod 600 "$CRED_FILE"

echo
echo "Credentials file created at $CRED_FILE and permissions set to 600."
echo
echo "Setup complete."
echo "Run 'sudo nixos-rebuild switch' to apply all changes."
