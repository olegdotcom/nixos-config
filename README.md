# NixOS configuration

Personal NixOS and Home Manager configuration for `oleg-laptop`, a Framework
Laptop 13 with an AMD Ryzen AI 300-series processor.

The repository is expected at `/home/oleg/core/repo/nixos-config` because the
Neovim plugin lockfile is updated in place from that path.

## Disk layout

`disk-config.nix` declares a fresh-install layout for this laptop:

| Storage | Mount | Purpose |
| --- | --- | --- |
| 10 GiB FAT32 EFI partition | `/boot` | Unencrypted UEFI boot files |
| LUKS2 partition using the remaining space | `/dev/mapper/cryptroot` | Encrypted Btrfs filesystem |
| Btrfs `@root` | `/` | Persistent operating-system state |
| Btrfs `@nix` | `/nix` | Nix store and Nix state |
| Btrfs `@home` | `/home` | User files |
| Btrfs `@persist` | `/persist` | Spare subvolume; no state is redirected here |
| Btrfs `@swap` | `/swap` | Swapfile, including hibernation storage |

The subvolumes share free space; they are not fixed-size partitions. The swapfile
does allocate its configured size. All subvolumes, including `@root` and `@home`,
remain persistent. Neither Impermanence nor Preservation is enabled, and there
are no root resets or scheduled snapshots. `@persist` is mounted early but does
not automatically receive any state. It has no fixed capacity or reserved
allocation.

The LUKS mapping allows discards, so Btrfs's default asynchronous discard and
the existing weekly `fstrim` service can reach the NVMe. This exposes unused-block
patterns on the encrypted device; file contents remain encrypted. The Btrfs
mount options remain `compress=zstd` and `noatime`.

The 10 GiB EFI partition gives boot files substantial headroom on the 2 TB SSD.
`boot.loader.systemd-boot.configurationLimit = 20` caps the boot menu at 20
configurations when the bootloader is updated by `nixos-rebuild switch` or
`boot`. This limit does not delete older generations from the system profile.

Daily garbage collection first runs Nix's built-in
`nix-env --profile /nix/var/nix/profiles/system --delete-generations +20`.
Normally this retains the newest 20 system generations (or all of them if fewer
exist), then GC deletes store paths that are no longer referenced. There is no
age cutoff, so months without updates will not expire the retained history.

The count applies when the daily job runs; rebuilding repeatedly can create
more generations between runs. After a rollback, Nix protects the selected
generation, up to 19 predecessors, and all newer generations, so this safety
exception can also retain more than 20. The boot menu remains separately capped
at 20 entries when the bootloader is updated. This is a generation-count policy,
not a disk-space quota. Other GC roots, including any separate user profiles or
Home Manager history, can retain additional store paths; this hook only prunes
the NixOS system profile.

On the installed system, inspect the timer and retained generations with:

```sh
systemctl list-timers nix-gc.timer
sudo nix-env --profile /nix/var/nix/profiles/system --list-generations
```

Set `diskDevice` to the internal NVMe's whole-disk `/dev/disk/by-id` path before
using Disko. The supplied value is deliberately a placeholder.
`swapSize` is `150G`, a conservative hibernation allocation for this laptop's
128 GiB RAM, rather than a required minimum or a guarantee for every workload.
The space needed depends on memory contents and existing swap use. Leave enough
unused swap for a hibernation image and test resume before relying on it.

Disko generates local filesystem, LUKS-unlock, and swap declarations. Keep those
out of `hardware-configuration.nix`; that file contains hardware detection only.
The existing NAS mounts stay in `configuration.nix`.

## Fresh installation with Disko

This procedure erases the selected internal disk. It is not an in-place ext4 to
Btrfs conversion. Use it from the NixOS USB installer, not from the installed
system. Normal `nixos-rebuild` operations do not run Disko's formatting script.

Apply these repository changes before following this procedure. If preparing
them on another computer, commit/push your installation branch and clone that
branch on the installer. Otherwise make the edits in the live environment.

Boot the installer in UEFI mode and connect to the network. Enter an interactive
root shell with the installation tools in one command:

```sh
sudo -i nix-shell -p git neovim
```

Run every installation command below, through `reboot`, inside this same shell.
`nix-shell` provides tools; it does not grant root privileges on its own. Check
the effective user ID before proceeding; this must print `0`:

```sh
id -u
```

Enable flakes inside this root shell:

```sh
export NIX_CONFIG='experimental-features = nix-command flakes'
```

For a fresh attempt, fetch the config:

```sh
git clone https://github.com/olegdotcom/nixos-config.git /tmp/nixos-config
cd /tmp/nixos-config
```

If `/tmp/nixos-config` already exists from an earlier attempt, preserve that
clone and its disk-device edits. Instead of cloning again, run these commands
inside the root shell so Git and subsequent builds use a root-owned workspace:

```sh
chown -R root:root /tmp/nixos-config
cd /tmp/nixos-config
```

If your changes are on a separate branch, check it out now. Identify the target
disk and verify RAM capacity; do not select the USB installer or a partition symlink:

```sh
lsblk -o NAME,SIZE,MODEL,SERIAL,TRAN,MOUNTPOINTS
ls -l /dev/disk/by-id/nvme-*
free -h
nvim disk-config.nix
```

Set `diskDevice` and `swapSize`. Add any new files to Git so the flake can see
them. `nix flake lock` adds a missing Disko input without intentionally updating
the existing locked dependencies; do not use `nix flake update` for this step.

```sh
git add flake.nix disk-config.nix configuration.nix hardware-configuration.nix
nix flake lock
git add flake.lock
nix flake check --no-build
nix build .#nixosConfigurations.oleg-laptop.config.system.build.diskoScript \
  --out-link ./disko-script
```

The build-result symlink lives inside the root-owned repository directory.
Building and running it in the same root shell keeps ownership consistent
throughout installation and avoids the shared `/tmp` symlink restriction.

Building this script does not format anything. It uses the Disko version pinned
by this flake. Inspect it and confirm that the configured by-id path resolves to
the intended disk. The next command **wipes, formats, and mounts that disk**;
Disko prompts for a new LUKS passphrase. Run it only for the initial formatting,
not when resuming an installation whose filesystems are already mounted:

```sh
./disko-script
```

Continue only after Disko finishes successfully. The filesystems should now be
mounted below `/mnt`. Generate hardware detection without duplicate
filesystem/LUKS declarations:

```sh
findmnt -R /mnt
nixos-generate-config --root /mnt --no-filesystems --show-hardware-config \
  > hardware-configuration.nix
git add hardware-configuration.nix
nix flake check --no-build
```

Remove the temporary build-result symlink, then copy the repository to the
location expected by the existing Neovim config and install from that copy:

```sh
rm -f ./disko-script
mkdir -p /mnt/home/oleg/core/repo/nixos-config
cp -a /tmp/nixos-config/. /mnt/home/oleg/core/repo/nixos-config/
nixos-install --flake /mnt/home/oleg/core/repo/nixos-config#oleg-laptop
nixos-enter --root /mnt -c 'passwd oleg'
chown -R 1000:100 /mnt/home/oleg
reboot
```

Remove the installer during reboot. The configuration still targets the AMD
Ryzen AI 300 Framework; do not reuse this hardware module unchanged for the
Intel backup laptop. Restore personal data, SMB credentials, and any keys
separately. The repository itself does not contain them.

### Verify hibernation

This config enables the systemd initrd. On UEFI, modern systemd can record and
discover the resume device and swapfile offset via `HibernateLocation`; no fixed
`resume_offset` is added here. On the installed system, check the mounts and swap:

```sh
findmnt -t btrfs
swapon --show
sudo cryptsetup luksDump /dev/disk/by-partlabel/disk-main-cryptroot
systemctl hibernate
```

Save work before the first hibernation test, then power on and verify that the
session resumes. After that, `systemctl suspend-then-hibernate` provides a
manual entry point to suspend followed by hibernation. This change does not
alter lid-close policy.

Disko creates the Btrfs swapfile with `btrfs filesystem mkswapfile`, which makes
it preallocated, NOCOW, and uncompressed. Ordinary files retain CoW and Zstd
compression. Do not snapshot or back up `@swap`. Changing `swapSize` later does
not resize an existing file automatically. To resize it later, first close
memory-heavy workloads and successfully deactivate the swapfile, recreate it
with `btrfs filesystem mkswapfile` at the new size, and reactivate it. Update
`swapSize` to match. This does not require repartitioning or reinstalling. Do
not rerun the destructive Disko script just to resize swap. With the automatic
systemd resume mechanism, the next hibernation records the new file location;
any manually configured resume offset would instead need updating.

Separate `@swap` protects snapshot boundaries, not physical allocation
boundaries: active Btrfs swap extents can make scrub and balance skip affected
block groups that may also contain other files.

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
