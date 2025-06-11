#!/usr/bin/env bash

# File        : go-env-update.sh
# Description : Simple script to update the Go programming environment
# Copyright   : (c) 2025, Gergely Szabo
# License     : MIT
#
# Supported Platforms and Architectures:
#  - GNU/Linux (amd64)
#
# Supported Shells:
#  - Bash
#
# Not Supported Installation Paths:
#  - Directories that require root privileges other than /usr/local.
#
# Usage:
#   1. Make the script executable:
#     chmod +x go-env-update.sh
#   2. Run it:
#     ./go-env-update.sh

set -e

print_err() {
  echo -e "\e[1;31m$1\e[0m" >&2
}
print_info() {
  echo -e "\e[1;37m$1\e[0m" >&1
}
print_warn() {
  echo -e "\e[1;33m$1\e[0m" >&1
}

main() {
  GO_VERSION="$(go version 2>/dev/null | \
  awk '{print $3}' | \
  sed 's/go//')"

  GO_INSTALL_DIR="$(command -v go 2>/dev/null | \
  sed 's|/go.*$||')"
  
  GO_LATEST_VER="$(curl -s https://go.dev/VERSION?m=text | \
  grep -oP 'go\K[0-9.]+')"

  if [[ -z "$GO_INSTALL_DIR" ]]; then
    print_err "Go toolchain is not installed."
    print_info "Run './go-env-install.sh' to install it."
    return 0
  fi

  if [[ "$GO_VERSION" == "$GO_LATEST_VER" ]]; then
    print_info "You already have the latest Go toolchain version: $GO_VERSION"
    return 0
  fi

  if [[ "$GO_INSTALL_DIR" == "/usr/local" && $EUID -ne 0 ]]; then
    print_warn "Detected system-wide installation."
    print_err "This option requires root privileges. Please run the script as root or use sudo."
    return 1
  fi

  print_info "Are you sure to update the Go toolchain ($GO_VERSION -> $GO_LATEST_VER)? [y/N]"
  read -r answer

  case $answer in
    # Only proceed if the user explicitly confirms.
    [Yy])
      print_info "Proceeding with the update..."
      ;;
    *)
      print_info "Update cancelled."
      return 0
      ;;
  esac

  print_info "Dowloading the latest Go toolchain version..."
  wget "https://go.dev/dl/go$GO_LATEST_VER.linux-amd64.tar.gz" -O /tmp/go.tar.gz

  if [[ $? != 0 ]]; then
    print_err "Failed to download the latest Go toolchain. Please check the output for details on the error."
  fi

  if [[ "$GO_INSTALL_DIR" == "/usr/local" ]]; then
    sudo rm -rf "$GO_INSTALL_DIR/go" &>/dev/null
    sudo tar -C "$GO_INSTALL_DIR" -xzf /tmp/go.tar.gz
  else
    rm -rf "$GO_INSTALL_DIR/go" &>/dev/null
    tar -C "$GO_INSTALL_DIR" -xzf /tmp/go.tar.gz
  fi

  if [[ $? == 0 ]]; then
    print_info "\e[1;32mGo has been successfully updated."
  else
    print_err "Failed to update to the latest Go version. Please check the output for details on the error."
    return 1
  fi

  return 0
}

main
