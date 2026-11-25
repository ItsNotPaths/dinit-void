#!/bin/sh
# Fills vendor/ from each repo at its pinned commit. Our changes to a repo live in
# patches/<name>/*.patch, applied in order.
set -eu
cd "$(dirname "$0")"

# vendor/<name>  repo  commit  path in the repo
pins='
dinit-chimera  https://github.com/chimera-linux/dinit-chimera  e7e37f55c672d3db513b9a43c5fec4708b0917bf
sd-tools       https://github.com/chimera-linux/sd-tools       9919e8c2c57b88cf0ddb2182a2b53bce7d0733ac
agetty         https://github.com/chimera-linux/cports         bb959544416d4b474c32a0ec06a7b3f874c9a016  main/nyagetty/files
void-runit     https://github.com/void-linux/void-runit        8a77597c556765b499c7b714ed07e7102a818e18
'

clones=$(mktemp -d)
trap 'rm -rf "$clones"' EXIT

echo "$pins" | while read -r name repo commit path; do
	[ -n "$name" ] || continue
	# One commit, blobs on demand: cports is large and only one folder of it is taken.
	git init -q --bare "$clones/$name"
	git -C "$clones/$name" remote add origin "$repo"
	git -C "$clones/$name" fetch -q --depth 1 --filter=blob:none origin "$commit"
	git -C "$clones/$name" archive -o "$clones/$name.tar" "$commit:${path:-}"
	rm -rf "vendor/$name"
	mkdir -p "vendor/$name"
	tar -x -f "$clones/$name.tar" -C "vendor/$name"
	for change in patches/"$name"/*.patch; do
		if [ -e "$change" ]; then patch -s -p1 -d "vendor/$name" < "$change"; fi
	done
	echo "vendor/$name  $commit"
done
