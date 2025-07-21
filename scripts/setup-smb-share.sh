#!/bin/bash

# This script sets up the necessary files and directories for the TrueNAS SMB share mount.
# It should be run once to prepare the system.

# Exit immediately if a command exits with a non-zero status.
set -e

# Define paths
MOUNT_POINT="/mnt/nas"
CRED_FILE="/etc/nixos/smb-credentials"
SHARE_DIRS=(
  "oleg_files"
  "oleg_photos"
  "shared_files"
  "shared_photos"
)

# 1. Create the mount point directories
echo "Creating mount point directories in $MOUNT_POINT..."
for dir in "${SHARE_DIRS[@]}"; do
  sudo mkdir -p "$MOUNT_POINT/$dir"
done
echo "Mount point directories created."
echo

# 2. Create the credentials file
echo "Please enter your SMB credentials for the TrueNAS share."
read -p "Username: " username
read -s -p "Password: " password
echo

# Create the credentials file with the correct format using a temporary file
# to securely handle the content before moving it to a root-owned location.
TEMP_CRED_FILE=$(mktemp)
echo "username=$username" > "$TEMP_CRED_FILE"
echo "password=$password" >> "$TEMP_CRED_FILE"

echo "Moving credentials to $CRED_FILE..."
sudo mv "$TEMP_CRED_FILE" "$CRED_FILE"

# Set secure permissions for the credentials file
sudo chmod 600 "$CRED_FILE"

echo
echo "Credentials file created at $CRED_FILE and permissions set to 600."
echo
echo "Setup complete."
echo "Run 'sudo nixos-rebuild switch' to apply all changes."
