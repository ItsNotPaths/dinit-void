#!/bin/sh
# Requirement: a LUKS disk listed in /etc/crypttab, with a keyfile, is opened at boot and mounted
# from fstab, and is closed again at shutdown.

# (hole crypt-test :tags (crypt test) :sev gap :needs (boot-test)) no test opens an encrypted disk at boot.
echo "tests/crypt: not built" >&2
exit 1
