#!/bin/bash

# Tailscale login script
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up --authkey tskey-auth
