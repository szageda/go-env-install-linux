#!/usr/bin/env bash

# File        : go-env-install.sh
# Description : Simple script to install the Go programming environment
# Copyright   : (c) 2025, Gergely Szabo
# License     : MIT
#
# Supported Platforms and Architectures:
#  - GNU/Linux (amd64)
#
# Usage:
#   1. Make the script executable:
#     chmod +x go-env-install.sh
#   2. Run it:
#     ./go-env-install.sh

# Exit on error
set -e

go_install() {
  # Ask the user for the Go installation path
  if [[ -z "$GO_INSTAL_DIR" ]]; then

    # Remove any existing Go installation
    if [[ -d "$HOME/.local/share/go" ]]; then
      echo "Removing existing Go installation in $GO_INSTALL_DIR"
      rm -rf "$HOME/.local/share/go"
    fi
    if [[ -d "/usr/local/go" ]]; then
      echo "Removing existing Go installation in $GO_INSTALL_DIR"
      sudo rm -rf "/usr/local/go"
    fi

    echo -e "\nShall we install Go for the current [U]ser or [s]ystem-wide (requires root)?"
    read -r answer

    case $answer in
      [Uu]|"")
        GO_INSTALL_DIR="$HOME/.local/share"

        # Query the latest Go version
        GO_INSTALL_VER="$(curl -s https://go.dev/VERSION?m=text | grep -oP 'go\K[0-9.]+')"

        echo "Downloading the latest version..."
        wget "https://go.dev/dl/go$GO_INSTALL_VER.linux-amd64.tar.gz" -O /tmp/go.tar.gz

        echo "Installing Go locally in $GO_INSTALL_DIR"
        tar -C "$GO_INSTALL_DIR" -xzf /tmp/go.tar.gz

        if [[ $? == 0 ]]; then
          echo "Go has been successfully installed in $GO_INSTALL_DIR/go"
        else
          echo "Failed to install Go. Please check the logs."
          return 1
        fi

        echo -n "Do you want to add Go to your PATH? [Y/n] "
        read -r answer

        case $answer in
          [Yy]|"")
            # TODO: Add support for other shells (e.g., zsh, fish)
            echo "export PATH=\$PATH:$GO_INSTALL_DIR/go/bin" >> "$HOME/.bashrc"
            echo "Go has been added to your PATH. Please restart your terminal or run 'source ~/.bashrc' to apply the changes."
            ;;
          [Nn])
            echo "Go has been installed, but not added to your PATH. You can add it manually later."
            ;;
          *)
            echo "Invalid input. Quitting."
            return 1
            ;;
        esac
        ;;
      [Ss])
        GO_INSTALL_DIR="/usr/local"

        # Quit if not running as root
        if [[ $EUID -ne 0 ]]; then
          echo "This option requires root privileges. Please run as root or use sudo."
          return 1
        fi

        # Query the latest Go version
        GO_INSTALL_VER="$(curl -s https://go.dev/VERSION?m=text | grep -oP 'go\K[0-9.]+')"

        echo "Downloading the latest version..."
        wget "https://go.dev/dl/go$GO_INSTALL_VER.linux-amd64.tar.gz" -O /tmp/go.tar.gz

        echo "Installing Go locally in $GO_INSTALL_DIR"
        sudo tar -C "$GO_INSTALL_DIR" -xzf /tmp/go.tar.gz

        if [[ $? == 0 ]]; then
          echo "Go has been successfully installed in $GO_INSTALL_DIR/go"
        else
          echo "Failed to install Go. Please check the logs."
          return 1
        fi

        echo -n "Do you want to add Go to your PATH? [Y/n] "
        read -r answer

        case $answer in
          [Yy]|"")
            # TODO: Add support for other shells (e.g., zsh, fish)
            echo "export PATH=\$PATH:$GO_INSTALL_DIR/go/bin" >> "$HOME/.bashrc"
            echo "Go has been added to your PATH. Please restart your terminal or run 'source ~/.bashrc' to apply the changes."
            ;;
          [Nn])
            echo "Go has been installed, but not added to your PATH. You can add it manually later."
            ;;
          *)
            echo "Invalid input. Quitting."
            return 1
            ;;
        esac
        ;;
      *)
        echo "Invalid input. Quitting."
        return 1
        ;;
    esac
  fi

  return 0
}

main() {
  # Declare the variables.
  GO_VERSION="$(go version | awk '{print $3}' | sed 's/go//')"
  GO_INSTALL_DIR="$(command -v go | sed 's|/go.*$||')"
  GO_LATEST_VER="$(curl -s https://go.dev/VERSION?m=text | grep -oP 'go\K[0-9.]+')"

  # Detect if Go is already installed.
  if command -v go &>/dev/null; then
    # Query the current Go version and installation directory.

    echo "Go installation detected. Current version: $GO_VERSION"
    echo "Latest version: $GO_LATEST_VER"

    if [[ "$GO_VERSION" == "$GO_LATEST_VER" ]]; then
      echo "You already have the latest version of Go installed."
      return 0
    else
      echo -e "\nWould you like to update Go? [Y/n]"
      read -r answer

      case $answer in
        [Yy]|"")
          echo "Updating Go to the latest version..."
          go_install
          ;;
        [Nn])
          echo "Keeping the current Go version: $GO_VERSION"
          ;;
        *)
          echo "Invalid input. Quitting."
          return 1
          ;;
      esac
    fi
  else
    echo "Go is not installed. Would you like to install it now? [Y/n]"
    read -r answer

    case $answer in
      [Yy]|"")
        echo "Installing the latest version of Go..."
        go_install
        ;;
      [Nn])
        echo "Skipping Go installation."
        ;;
      *)
        echo "Invalid input. Quitting."
        return 1
        ;;
    esac
  fi

  return 0
}

main