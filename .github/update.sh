#!/bin/sh
set -eu

cd "$(dirname "$0")/.."

api=https://api.github.com/repos/ELEGOO-3D/ElegooSlicer/releases/latest
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT INT TERM

release=$tmp/release.json
entries=$tmp/entries.jsonl
out=$tmp/sources.json

curl -fsSL "$api" > "$release"
version=$(jq -r .tag_name "$release")
: > "$entries"

jq -c '.assets[] | {name, url: .browser_download_url}' "$release" |
while IFS= read -r asset; do
  name=$(printf '%s\n' "$asset" | jq -r .name)
  url=$(printf '%s\n' "$asset" | jq -r .url)

  case "$name" in
    *.AppImage) system=x86_64-linux ;;
    *Mac_arm64*.dmg) system=aarch64-darwin ;;
    *Mac_x86_64*.dmg) system=x86_64-darwin ;;
    *) continue ;;
  esac

  prefetch_output=$(nix store prefetch-file --json "$url")
  sha256=$(printf '%s\n' "$prefetch_output" | jq -r .hash)

  jq -n \
    --arg system "$system" \
    --arg version "$version" \
    --arg url "$url" \
    --arg sha256 "$sha256" \
    '{($system): {version: $version, url: $url, sha256: $sha256}}' >> "$entries"
done

jq -s 'add' "$entries" > "$out"
jq -e 'length > 0' "$out" > /dev/null

mv "$out" sources.json
