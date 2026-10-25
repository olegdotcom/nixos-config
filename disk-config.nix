let
  # Set this to the whole internal NVMe, not the USB installer or a partition.
  # Discover it with: lsblk -o NAME,SIZE,MODEL,SERIAL,TRAN,MOUNTPOINTS
  # Then select its whole-disk symlink from /dev/disk/by-id/nvme-*.
  diskDevice = "/dev/disk/by-id/REPLACE_WITH_INTERNAL_NVME_ID";

  # Conservative hibernation allocation for this laptop's 128 GiB RAM.
  # The required free swap depends on workload; this is not a kernel minimum.
  # This is allocated disk space, not a dynamically sized sparse file.
  swapSize = "150G";

  mountOptions = [
    "compress=zstd"
    "noatime"
  ];
in
{
  disko.devices.disk.main = {
    type = "disk";
    device = diskDevice;
    content = {
      type = "gpt";
      partitions = {
        ESP = {
          size = "10G";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = [ "umask=0077" ];
          };
        };
        cryptroot = {
          size = "100%";
          content = {
            type = "luks";
            name = "cryptroot";
            # Allow Btrfs async discard and periodic fstrim to reach the NVMe.
            settings.allowDiscards = true;
            extraFormatArgs = [
              "--type"
              "luks2"
            ];
            # Disko prompts for a passphrase; no secret is stored in the repo.
            content = {
              type = "btrfs";
              extraArgs = [ "-f" ];
              subvolumes = {
                "@root" = {
                  mountpoint = "/";
                  inherit mountOptions;
                };
                "@nix" = {
                  mountpoint = "/nix";
                  inherit mountOptions;
                };
                "@home" = {
                  mountpoint = "/home";
                  inherit mountOptions;
                };
                "@persist" = {
                  mountpoint = "/persist";
                  inherit mountOptions;
                };
                "@swap" = {
                  mountpoint = "/swap";
                  inherit mountOptions;
                  # Disko uses btrfs filesystem mkswapfile: this file is
                  # preallocated, NOCOW, and uncompressed. Do not snapshot it.
                  swap.swapfile.size = swapSize;
                };
              };
            };
          };
        };
      };
    };
  };

  # Keep this spare subvolume available early; no state is redirected here.
  # Every subvolume, including @root and @home, remains persistent.
  fileSystems."/persist".neededForBoot = true;
}
