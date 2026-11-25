this is a vibeslopped reference repo for chimera's dinit ported
to void, only used by [fig](https://github.com/ItsNotPaths/fig).
this will not be well maintained or high quality, if you know or 
are maintaining a proper dinit-void repo, lmk and i can nuke this.

[dinit](https://github.com/davmac314/dinit)

[dinit-chimera](https://github.com/chimera-linux/dinit-chimera)

| Folder | What |
|---|---|
| `vendor/` | dinit-chimera, [sd-tools](https://github.com/chimera-linux/sd-tools) (`sd-tmpfiles`), Chimera's agetty services from [cports](https://github.com/chimera-linux/cports), and [void-runit](https://github.com/void-linux/void-runit), each at a pinned commit. `download-deps.sh` fills it. |
| `patches/<name>/` | our changes to a vendored repo, applied in order |
| `void/` | the Void side, copied over the install root: dinit-chimera's helpers in `/usr/libexec`, service files in `/usr/lib/dinit.d`, and the `/etc` files runit-void used to own |
| `tests/` | boot tests in QEMU |

Void's own `dinit` package provides the `dinit` binary and `dinitctl`.
dinit-void does not build dinit.

## Status

Musl is the main target, since Chimera is a musl system; glibc is built too.
It has not booted yet. The gettys, `/etc/crypttab`, the console settings from
`rc.conf` and the daemon services (dbus, dhcpcd, sshd, wpa_supplicant, acpid)
are not done.

## Build

On Void, musl or glibc, with these packages: `gcc meson ninja pkg-config
libkmod-devel libcap-devel acl-devel dinit`.

```
./download-deps.sh
DESTDIR=/some/root ./build.sh
```

`build.sh` installs into `DESTDIR` and refuses to run without it. It builds
against the libc of the machine it runs on, so a musl root needs a musl build
machine or container.

## Putting it on a Void system

Do this in a VM or a chroot. The steps below are what the port needs, not a
tested procedure.

- `/usr/bin/init`, `halt`, `poweroff`, `reboot` and `shutdown` belong to
  `runit-void`, and dinit-void replaces all five. `base-system` depends on
  `runit-void`, so it has to be removed by force (`xbps-remove -F runit-void`)
  and kept out with `ignorepkg=runit-void` in `/etc/xbps.d/`.
- Removing runit-void also removes `/etc/rc.conf`, `/etc/rc.local`,
  `/etc/hostname` and `/etc/locale.conf` if they were never edited.
  dinit-void installs its own copies.
- Void's packages ship runit services in `/etc/sv`, which dinit does not read.
  Each daemon you want needs a dinit service file, enabled with
  `dinitctl enable <name>` or a link in `/etc/dinit.d/boot.d/`.
- A root filesystem on LUKS is opened by dracut in the initramfs, so that part
  does not depend on the init system.

## Credits and licences

- dinit-chimera and Chimera's agetty services: q66 and the Chimera Linux
  developers, BSD-2-Clause.
- sd-tools: forked from systemd, LGPL-2.1.
- void-runit: the Void Linux developers, public domain.
