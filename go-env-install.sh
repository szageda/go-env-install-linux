#!/usr/bin/env bash

# File        : go-env-install.sh
# Description : Simple script to install the Go programming environment
# Copyright   : (c) 2025, Gergely Szabo
# License     : MIT
#
# Supported Platforms and Architectures:
#  - GNU/Linux (amd64)
#
# Supported Shells:
#  - Bash
#
# Usage:
#   1. Make the script executable:
#     chmod +x go-env-install.sh
#   2. Run it:
#     ./go-env-install.sh

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

  if [[ -n "$GO_INSTALL_DIR" && "$GO_VERSION" == "$GO_LATEST_VER" ]]; then
    print_info "You already have the latest Go toolchain version: $GO_VERSION"
    return 0
  fi
  if [[ -n "$GO_INSTALL_DIR" && "$GO_VERSION" != "$GO_LATEST_VER" ]]; then
    print_warn "A new Go toolchain version is available: $GO_LATEST_VER (current: $GO_VERSION)"
    print_info "Run './go-env-update.sh' to update."
    return 0
  fi

  print_info "Do you want to install Go version $GO_LATEST_VER for the current [U]ser or [s]ystem-wide?"
  read -r answer

  case $answer in
    [Uu]|"")
      GO_INSTALL_DIR="$HOME/.local/share"

      print_info "Downloading the latest Go toolchain version..."
      wget "https://go.dev/dl/go$GO_LATEST_VER.linux-amd64.tar.gz" -O /tmp/go.tar.gz
      tar -C "$GO_INSTALL_DIR" -xzf /tmp/go.tar.gz

      if [[ $? == 0 ]]; then
        print_info "\e[1;32mGo has been successfully installed in $GO_INSTALL_DIR/go"
      else
        print_err "Failed to install the latest Go toolchain. Please check the output for details on the error."
        return 1
      fi

      print_warn "Do you want to add Go to your PATH? [Y/n]"
      read -r answer

      case $answer in
        [Yy]|"")
          # TODO: Add support for other shells (e.g., zsh, fish).
          echo "export PATH=\$PATH:$GO_INSTALL_DIR/go/bin" >> "$HOME/.bashrc"
          print_info "\e[1;32mGo has been added to your PATH."
          print_info "Please restart your terminal or run 'source ~/.bashrc' to apply the changes."
          ;;
        [Nn]|*)
          print_warn "Go has been installed, but not added to your PATH. You can add it manually later."
          ;;
      esac
      ;;
    [Ss])
      GO_INSTALL_DIR="/usr/local"

      if [[ $EUID -ne 0 ]]; then
        print_err "This option requires root privileges. Please run the script as root or use sudo."
        return 1
      fi

      print_info "Downloading the latest version..."
      wget "https://go.dev/dl/go$GO_LATEST_VER.linux-amd64.tar.gz" -O /tmp/go.tar.gz
      sudo tar -C "$GO_INSTALL_DIR" -xzf /tmp/go.tar.gz

      if [[ $? == 0 ]]; then
        print_info "\e[1;32mGo has been successfully installed in $GO_INSTALL_DIR/go"
      else
        print_err "Failed to install the latest Go toolchain. Please check the output for details on the error."
        return 1
      fi

      print_warn "Do you want to add Go to your PATH? [Y/n]"
      read -r answer

      case $answer in
        [Yy]|"")
          # TODO: Add support for other shells (e.g., zsh, fish).
          echo "export PATH=\$PATH:$GO_INSTALL_DIR/go/bin" >> "$HOME/.bashrc"
          print_info "\e[1;32mGo has been added to your PATH."
          print_info "Please restart your terminal or run 'source ~/.bashrc' to apply the changes."
          ;;
        [Nn]|*)
          print_warn "Go has been installed, but not added to your PATH. You can add it manually later."
          ;;
      esac
      ;;
    *)
      print_err "Invalid input. Please enter 'u' for user or 's' for system-wide installation."
      ;;
  esac

  return 0
}

main
