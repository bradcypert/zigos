#!/bin/bash
set -e # Exit immediately on any error

echo "==> Building kernel..."
zig build

echo "==> Creating ISO directory structure..."
rm -rf iso_root
mkdir -p iso_root/boot/limine
mkdir -p iso_root/EFI/BOOT

echo "==> Copying kernel..."
cp zig-out/bin/kernel iso_root/boot/kernel

echo "==> Copying Limine bootloader files..."
# These files ship with the limine package.
# limine-bios.sys     = BIOS stage 2 bootloader (loaded by limine-bios-cd.bin)
# limine-bios-cd.bin  = El Torito BIOS boot image
# limine-uefi-cd.bin  = El Torito UEFI boot image
# BOOTX64.EFI         = UEFI bootloader application
cp /usr/share/limine/limine-bios.sys iso_root/boot/limine/
cp /usr/share/limine/limine-bios-cd.bin iso_root/boot/limine/
cp /usr/share/limine/limine-uefi-cd.bin iso_root/boot/limine/
cp /usr/share/limine/BOOTX64.EFI iso_root/EFI/BOOT/

echo "==> Writing Limine config..."
cat >iso_root/boot/limine/limine.conf <<'EOF'
timeout: 0

  /ZIGOS
  COMMENT: ZigOS Minimal Kernel
  PROTOCOL: limine
  KERNEL_PATH: boot():/boot/kernel
EOF

echo "==> Building ISO with xorriso..."
xorriso -as mkisofs \
  -b boot/limine/limine-bios-cd.bin \
  -no-emul-boot -boot-load-size 4 -boot-info-table \
  --efi-boot boot/limine/limine-uefi-cd.bin \
  -efi-boot-part --efi-boot-image \
  --protective-msdos-label \
  iso_root -o zigos.iso 2>/dev/null

echo "==> Installing Limine BIOS boot code into ISO..."
# This embeds the Limine MBR/GPT boot code into the ISO's partition table.
limine bios-install zigos.iso

echo "==> Done! Boot with: qemu-system-x86_64 -cdrom zigos.iso -m 128M"
