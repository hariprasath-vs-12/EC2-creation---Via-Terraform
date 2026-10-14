#!/bin/bash
# Runs once at first boot as root (Ubuntu). Output is logged to /var/log/user-data.log
set -euxo pipefail
exec > >(tee -a /var/log/user-data.log) 2>&1
export DEBIAN_FRONTEND=noninteractive

# 1. Update and upgrade packages, install nginx, unzip and curl
apt-get update -y
apt-get upgrade -y
apt-get install -y nginx unzip curl

# 2. Install AWS CLI v2 (skipped if already present)
if ! command -v aws >/dev/null 2>&1; then
  cd /tmp
  curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-$(uname -m).zip" -o awscliv2.zip
  unzip -q awscliv2.zip
  ./aws/install
  rm -rf aws awscliv2.zip
fi
aws --version

# 3. Start nginx now and on every boot
systemctl enable --now nginx
