# NixOS configuration

Personal NixOS and Home Manager configuration for `oleg-laptop`, a Framework
Laptop 13 with an AMD Ryzen AI 300-series processor.

The repository is expected at `/home/oleg/core/repo/nixos-config` because the
Neovim plugin lockfile is updated in place from that path.

## Apply the configuration

```sh
cd /home/oleg/core/repo/nixos-config
nix flake check
sudo nixos-rebuild switch --flake .#oleg-laptop
```

The greetd configuration is intentionally retained but temporarily disabled in
`configuration.nix`.

## Update dependencies

```sh
nix flake update
nix flake check
sudo nixos-rebuild switch --flake .#oleg-laptop
```

To format the Nix files:

```sh
nix fmt
```

To roll back the active system:

```sh
sudo nixos-rebuild switch --rollback
```

## SMB shares

The NAS is configured at `192.168.10.12`, with the local alias `nas.local`.
Create the root-owned credentials file and mount-point directories once:

```sh
./scripts/setup-smb-share.sh
```

The credentials file is stored at `/etc/nixos/smb-credentials` and is not
tracked by Git.

## Fastfetch

Fastfetch intentionally uses its built-in default output. No Fastfetch or
Neofetch configuration is managed by this repository.
