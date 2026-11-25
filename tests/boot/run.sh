#!/bin/sh
# Requirement: a Void image with runit-void removed and dinit-void installed boots under dinit to
# login.target, with a getty on the serial console, and powers off cleanly.

# (hole boot-test :tags test :sev blocker :needs (gettys)) nothing boots a Void image with dinit-void yet, so no part of the port is proven.
echo "tests/boot: not built" >&2
exit 1
