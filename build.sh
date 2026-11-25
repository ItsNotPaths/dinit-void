#!/bin/sh
# Builds sd-tools and dinit-chimera with Void's paths and installs them, with void/ and
# void-runit's config files, into DESTDIR.
#     DESTDIR=/path ./build.sh
set -eu
cd "$(dirname "$0")"
destdir=${DESTDIR:?build.sh: set DESTDIR to the root to install into}
[ -d vendor/dinit-chimera ] || {
	echo "build.sh: no vendor/. Run ./download-deps.sh." >&2; exit 1; }

# Void merged sbin into bin, so dinit, init and sulogin are in /usr/bin.
meson_build() {
	name=$1
	shift
	rm -rf "build/$name"
	meson setup "build/$name" "vendor/$name" --prefix=/usr --sbindir=bin --libexecdir=libexec "$@"
	meson compile -C "build/$name"
	DESTDIR=$destdir meson install -q -C "build/$name" --no-rebuild
}
meson_build sd-tools -Dtests=false
meson_build dinit-chimera

# system and boot wait on these; only chimera.conf's tmpfiles make them, at run time.
install -d "$destdir/usr/lib/dinit.d/boot.d" "$destdir/etc/dinit.d/boot.d"

install -m 644 vendor/agetty/agetty "$destdir/usr/lib/dinit.d/agetty"
install -m 644 vendor/agetty/agetty-service "$destdir/usr/lib/dinit.d/agetty-service@"
install -m 755 vendor/agetty/agetty-service.sh "$destdir/usr/lib/agetty-service"
install -m 755 vendor/agetty/agetty-default vendor/agetty/agetty-serial vendor/agetty/dinit-agetty \
	"$destdir/usr/lib/"
ln -sf ../agetty "$destdir/usr/lib/dinit.d/boot.d/agetty"

# Debian's crypttab scripts (debian/2%2.8.6-2), with Chimera's Makefile and patches.
make -C vendor/cryptsetup-scripts DESTDIR="$destdir" VERSION=2.8.6-2 \
	DOCBOOK_XSL=/usr/share/xsl/docbook/manpages/docbook.xsl install

cp -R void/. "$destdir/"
install -m 644 vendor/void-runit/rc.conf "$destdir/etc/rc.conf"
install -m 755 vendor/void-runit/rc.local "$destdir/etc/rc.local"
install -m 755 vendor/void-runit/rc.shutdown "$destdir/etc/rc.shutdown"
ln -sf ../rc-shutdown "$destdir/usr/lib/dinit.d/boot.d/rc-shutdown"

# runit-void owned these; dinit's own take their place.
for command in halt poweroff reboot shutdown; do
	ln -sf "dinit-$command" "$destdir/usr/bin/$command"
done
