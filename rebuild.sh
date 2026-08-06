#!/usr/bin/env bash

nix flake update private-work
nixos-rebuild switch --flake .#e14 --sudo

