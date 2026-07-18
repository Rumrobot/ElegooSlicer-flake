# ElegooSlicer-flake

[![CI](https://img.shields.io/github/actions/workflow/status/Rumrobot/ElegooSlicer-flake/ci.yml?branch=main&label=CI)](https://github.com/Rumrobot/ElegooSlicer-flake/actions/workflows/ci.yml)
[![Update sources](https://img.shields.io/github/actions/workflow/status/Rumrobot/ElegooSlicer-flake/update.yml?label=update)](https://github.com/Rumrobot/ElegooSlicer-flake/actions/workflows/update.yml)
[![Version](https://img.shields.io/github/v/tag/Rumrobot/ElegooSlicer-flake?sort=semver&label=version)](https://github.com/Rumrobot/ElegooSlicer-flake/tags)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue)](LICENSE)
[![Built with Nix](https://img.shields.io/badge/built%20with-nix-5277C3?logo=nixos&logoColor=white)](https://nixos.org)

A Nix flake that packages the official [ElegooSlicer](https://github.com/ELEGOO-3D/ElegooSlicer) AppImage releases for `x86_64-linux`.

Versions are automatically updated daily.

## Usage

Run it directly:

```sh
nix run github:Rumrobot/ElegooSlicer-flake
```

Or add it to your flake inputs:

```nix
inputs.elegoo-slicer.url = "github:Rumrobot/ElegooSlicer-flake";
```

and put the package in your system/home packages:

```nix
# NixOS
environment.systemPackages = [ inputs.elegoo-slicer.packages.${pkgs.system}.default ];

# home-manager
home.packages = [ inputs.elegoo-slicer.packages.${pkgs.system}.default ];
```

To pin a specific version, use its tag (available from `v1.5.2.2`):

```nix
inputs.elegoo-slicer.url = "github:Rumrobot/ElegooSlicer-flake/v1.5.2.2";
```

### NVIDIA workaround

Like the [OrcaSlicer](https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/by-name/or/orca-slicer/package.nix) package, this flake includes a fix for rendering issues/crashes/laggy behaviour on NVIDIA systems:

```nix
inputs.elegoo-slicer.packages.${pkgs.system}.default.override { withNvidiaGLWorkaround = true; }
```

## Development

`nix develop` (or direnv) enables the devshell with the lint tools and [Task](https://taskfile.dev), and installs the pre-commit hooks.

Run `task -l` to see available tasks.
