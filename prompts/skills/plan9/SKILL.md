---
name: plan9
description: Work with Plan 9 and 9front, especially installing and operating 9front in QEMU, configuring networking, CPU/auth services, drawterm, rio, and common troubleshooting.
---

# Plan 9 / 9front

Use this skill when helping with Plan 9, 9front, rio, rc, QEMU-based installs, drawterm, CPU/auth server setup, `plan9.ini`, `/lib/ndb/local`, or troubleshooting 9front virtual machines.

## Core Defaults

- Prefer 9front for current Plan 9 work unless the user specifically means Bell Labs Plan 9 or another fork.
- Prefer official 9front docs and artifacts:
  - FQA: `http://fqa.9front.org`
  - Releases: `http://9front.org/releases/`
  - ISO directory: `http://9front.org/iso/`
  - Drawterm: `http://drawterm.9front.org`
- Use 9front's drawterm fork. Do not recommend Russ Cox's `swtch.com/drawterm` for 9front because the security protocols differ.
- For modern x86 hosts, recommend the `amd64.iso` install path unless the user wants a prebuilt qcow2 image.
- For new installs, prefer `hjfs` unless the user has a reason to use `cwfs` or `gefs`.
- For QEMU disks, prefer virtio-scsi because it appears as `/dev/sd00` inside 9front.
- Use a unique QEMU MAC address per VM.
- Prefer 32-bit VESA modes, especially on macOS QEMU, for example `1920x1080x32`.
- Use `ps2intellimouse` for scroll wheel support.

## Vocabulary

- `rio`: 9front's window manager.
- `rc`: 9front's shell.
- `glenda`: default user and hostowner on a fresh install.
- `drawterm`: host-side client for connecting to a 9front CPU server and presenting a graphical session.
- `service=cpu`: `plan9.ini` setting for CPU server mode.
- `factotum`: credential/key management agent.
- `secstore`: encrypted server-side credential store.
- `plan9.ini`: boot configuration on the 9FAT partition, mounted at `/n/9fat/plan9.ini` after `9fs 9fat`.
- `9fat`: FAT boot partition.

## QEMU Install Flow

Create a qcow2 disk:

```sh
qemu-img create -f qcow2 9front.qcow2.img 30G
```

Linux/KVM install command:

```sh
qemu-system-x86_64 -cpu host -enable-kvm -m 2048 \
  -net nic,model=virtio,macaddr=52:54:00:00:EE:03 -net user \
  -device virtio-scsi-pci,id=scsi \
  -drive if=none,id=vd0,file=9front.qcow2.img \
  -device scsi-hd,drive=vd0 \
  -drive if=none,id=vd1,file=9front.amd64.iso \
  -device scsi-cd,drive=vd1,bootindex=0
```

Modern q35 alternative:

```sh
qemu-system-x86_64 -enable-kvm -smp $(nproc) -m 8192 \
  -cpu host -M q35 \
  -cdrom ./9front.amd64.iso \
  -net nic \
  -drive file=9front.raw,format=raw,media=disk,index=0,cache=writeback
```

Headless/VNC install:

```sh
qemu-system-x86_64 -cpu host -enable-kvm -m 4096 \
  -vnc :2 \
  -net nic,model=virtio,macaddr=52:54:00:00:EE:03 -net user \
  -device virtio-scsi-pci,id=scsi \
  -drive if=none,id=vd0,file=9front.qcow2.img \
  -device scsi-hd,drive=vd0 \
  -drive if=none,id=vd1,file=9front.iso \
  -device scsi-cd,drive=vd1,bootindex=0
```

`-vnc :2` listens on host port `5902`.

## Installer Walkthrough

At boot, accept the default boot device and use `glenda`, then run:

```rc
inst/start
```

Work through installer steps in order:

- `partdisk`: choose the qcow2 disk, usually `sd00`; use `mbr`; write and quit.
- `prepdisk`: accept the default partition; write and quit.
- `mountfs`: choose default partition/cache and name the partition.
- `configdist`: choose `local`.
- `confignet`: DHCP is usually fine.
- `mountdist`: use defaults.
- `copydist`: wait for files to copy.
- `ndbsetup`: set the system name.
- `tzsetup`: choose timezone.
- `bootsetup`: keep defaults unless the user knows they need changes.
- Reboot when prompted.

During install or first boot, use:

```text
mouseport=ps2intellimouse
vgasize=1920x1080x32
```

## Normal Boot

After installation, remove the ISO drive:

```sh
qemu-system-x86_64 -cpu host -enable-kvm -m 2048 \
  -net nic,model=virtio,macaddr=52:54:00:00:EE:03 -net user \
  -device virtio-scsi-pci,id=scsi \
  -drive if=none,id=vd0,file=9front.qcow2.img \
  -device scsi-hd,drive=vd0
```

For mouse accuracy in graphical QEMU sessions, append:

```sh
-device qemu-xhci,id=xhci -device usb-tablet,bus=xhci.0
```

For AC97 audio:

```sh
-audiodev id=alsa,driver=alsa -device AC97,audiodev=alsa
```

## Networking Inside 9front

Get DHCP manually:

```rc
ip/ipconfig
```

Test HTTP connectivity with:

```rc
hget http://example.com > /dev/null
```

With QEMU user-mode networking, external ICMP ping may fail even when TCP works.

For persistent networking:

- Terminal mode: add `ip/ipconfig` to `/rc/bin/termrc` before the DNS section.
- CPU server mode: add `ip/ipconfig` to `/rc/bin/cpurc` or `/rc/bin/cpurc.local`.

Network database file:

```text
/lib/ndb/local
```

Example QEMU user-network stanza, with mandatory tabs below `ipnet=`:

```text
auth=QemuTerm authdom=9front
ipnet=9front ip=10.0.2.0 ipmask=255.255.255.0
	ipgw=10.0.2.2
	dns=8.8.8.8
	auth=QemuTerm
	dnsdom=9front
	cpu=QemuTerm
	fs=QemuTerm
sys=QemuTerm ether=52540000ee03 ip=10.0.2.15
```

Rules:

- `auth` and `cpu` should match the system name.
- `authdom` must match the boot/auth prompt domain.
- `ipnet` uses the subnet address, not the host IP.
- Keep an empty line at end of `/lib/ndb/local`.
- Use `netaudit` to verify the configuration.

## CPU/Auth Server Setup

Mount the boot partition and edit `plan9.ini`:

```rc
9fs 9fat
acme /n/9fat/plan9.ini
```

Add or change:

```ini
service=cpu
```

For hjfs boot:

```ini
bootargs=local!/dev/sd00/fs -m 256 -A -a tcp!*!564
```

For unattended hjfs boot:

```ini
nobootprompt=local!/dev/sd00/fs -m 256 -A -a tcp!*!564
user=glenda
```

For cwfs:

```ini
bootargs=local!/dev/sd00/fscache -a tcp!*!564
```

First CPU-mode boot may show `bad nvram key`, `bad authentication id`, or `bad authentication domain`. This is normal on a new install. Respond:

```text
authid: glenda
authdom: 9front
secstore key: <press Enter unless configured>
password: <glenda password>
```

Set the password:

```rc
auth/changeuser glenda
```

Start graphics manually after a CPU-mode boot:

```rc
termrc
rio
```

Typical CPU/auth services in `/rc/bin/cpurc` or `/rc/bin/cpurc.local`:

```rc
ip/ipconfig
serviced=/rc/bin/service
auth/keyfs -wp -m /mnt/keys /adm/keys
auth/cron >>/sys/log/cron >[2=1] &
aux/listen -q -t /rc/bin/service.auth -d $serviced tcp
```

Important service files:

- `/rc/bin/service/tcp17019`: CPU server.
- `/rc/bin/service.auth/tcp567`: auth server.

## Secstore

Create and enable secstore:

```rc
mkdir /adm/secstore
chmod 770 /adm/secstore
auth/secstored
auth/secuser glenda
```

Initialize the user's factotum file if login reports that it does not exist:

```rc
touch factotum
auth/secstore -p factotum
```

## Adding Users

```rc
auth/keyfs
auth/changeuser USER
auth/secuser USER
echo newuser USER >> /srv/hjfs.cmd
```

Then log in as the user and run:

```rc
/sys/lib/newuser
```

## Drawterm

Required ports:

- `567`: auth server.
- `17019`: CPU server.
- `564`: secstore / 9P access.
- `17020`: optional filesystem export.

Minimum for drawterm is often `567` and `17019`; full functionality commonly needs `564`, `567`, `17019`, and `17020`.

QEMU with high-port auth remap:

```sh
qemu-system-x86_64 -cpu host -enable-kvm -m 2048 \
  -net nic,model=virtio,macaddr=52:54:00:00:EE:03 \
  -net user,hostfwd=tcp::17019-:17019,hostfwd=tcp::17567-:567 \
  -device virtio-scsi-pci,id=scsi \
  -drive if=none,id=vd0,file=9front.qcow2.img \
  -device scsi-hd,drive=vd0
```

Drawterm with low ports:

```sh
drawterm -h 127.0.0.1 -u glenda
```

Drawterm with remapped auth port:

```sh
drawterm -a 'tcp!localhost!17567' -h localhost -s localhost -u glenda
```

When using remapped ports, specify `-s` for secstore explicitly if secstore also needs a remapped address.

For remote sessions, add this after `fn cpu% { $* }` in `/usr/glenda/lib/profile` when appropriate:

```rc
if(! webcookies >[2]/dev/null)
    webcookies -f /tmp/webcookies
webfs
plumber
rio -i riostart
bind -ac /mnt/term $home/term
```

## Minimal Drawterm Test Setup

Inside 9front:

```rc
touch $home/lib/keys
auth/keyfs -p $home/lib/keys
auth/changeuser -p glenda
auth/factotum -n
echo 'key proto=dp9ik dom=9front user='$user' !password=PASS' >/mnt/factotum/ctl
aux/listen1 -t 'tcp!*!rcpu' /rc/bin/service/tcp17019 &
```

From host:

```sh
drawterm -h 127.0.0.1 -u glenda
```

Then run `rio` in the drawterm shell.

## Apple Silicon / ARM64 QEMU

Use the 9front `arm64.qcow2` image on ARM hosts. It is serial-console only; use drawterm for GUI after setup. It needs U-Boot.

Build U-Boot:

```sh
git clone https://source.denx.de/u-boot/u-boot.git
cd u-boot
make qemu_arm64_defconfig
make -j$(nproc) CROSS_COMPILE=aarch64-linux-gnu-
```

Run with HVF on macOS:

```sh
qemu-system-aarch64 \
  -M virt,accel=hvf \
  -cpu host \
  -smp 2 -m 4096 \
  -bios u-boot.bin \
  -device virtio-net-pci-non-transitional,netdev=net0 \
  -netdev user,id=net0,hostfwd=tcp::17019-:17019,hostfwd=tcp::17567-:567 \
  -drive if=none,id=vd0,file=9front.arm64.qcow2 \
  -device virtio-blk-pci-non-transitional,drive=vd0 \
  -nographic \
  -serial stdio
```

On modern QEMU, if the virt machine has ECAM/high-memory issues, try:

```sh
-M virt-10.1,accel=hvf,highmem=off
```

## Troubleshooting

- Mouse drift in VNC/QEMU: add USB tablet support and use `ps2intellimouse`.
- No scroll wheel: use `ps2intellimouse`, not plain `ps2`.
- Network unavailable after reboot: run `ip/ipconfig`, then persist it in `termrc` or `cpurc`.
- `ip/ping google.com` fails under `-net user`: use `hget`; QEMU SLIRP filters external ICMP.
- Drawterm hangs or times out: check firewall, forward `564`, `567`, `17019`, `17020`, and verify `/lib/ndb/local` with `netaudit`.
- `bad nvram key` on first CPU-mode boot: normal; answer auth prompts and continue.
- `secstore: remote file factotum does not exist`: run `touch factotum` and `auth/secstore -p factotum`.
- macOS QEMU graphics corruption: use `x32` color depth, for example `vgasize=1920x1080x32`.
- Virtio-scsi disk paths are `/dev/sd00`; virtio-blk paths are commonly `/dev/sdF0`.
- Low ports `564` and `567` require privileges on Linux; use QEMU high-port `hostfwd` remapping when not running as root.

## Quick Reference

```rc
inst/start
ip/ipconfig
hget http://example.com > /dev/null
9fs 9fat
acme /n/9fat/plan9.ini
fshalt -r
fshalt
netaudit
ndb/query sys SYSNAME
auth/changeuser glenda
termrc
rio
aux/mouse ps2intellimouse
echo intellimouse > /dev/mousectl
@{rfork n; aux/realemu; aux/vga -m vesa -l 1920x1080x32}
```

## File Reference

- `/n/9fat/plan9.ini`: boot config.
- `/lib/ndb/local`: network database.
- `/rc/bin/termrc`: terminal startup.
- `/rc/bin/cpurc`: CPU server startup.
- `/rc/bin/cpurc.local`: local CPU startup override.
- `/rc/bin/service/tcp17019`: CPU server service.
- `/rc/bin/service.auth/tcp567`: auth service.
- `/usr/glenda/lib/profile`: user profile.
- `/usr/glenda/bin/rc/riostart`: rio startup script.
- `/adm/keys`: auth key database.
- `/adm/secstore`: secstore directory.
- `/srv/hjfs.cmd`: hjfs command pipe.
- `/dev/mousectl`: mouse control.
- `/mnt/factotum/ctl`: factotum control.
- `$home/lib/keys`: per-user key file.
