#!/bin/bash
# Scans images/ and writes images/manifest.json listing every image file.
# Title = filename with dashes/underscores turned into spaces and words capitalized.
# Tag = file extension, uppercased.
set -e

IMG_DIR="images"
OUT="$IMG_DIR/manifest.json"
entries=()

for f in "$IMG_DIR"/*; do
  fname=$(basename "$f")
  [ "$fname" = "manifest.json" ] && continue
  [ -f "$f" ] || continue

  ext="${fname##*.}"
  ext_lower=$(echo "$ext" | tr '[:upper:]' '[:lower:]')
  case "$ext_lower" in
    jpg|jpeg|png|gif|webp|svg|avif) ;;
    *) continue ;;
  esac

  base="${fname%.*}"
  title=$(echo "$base" | sed -E 's/[-_]+/ /g' | sed -E 's/(^|[[:space:]])([a-z])/\1\U\2/g')
  tag=$(echo "$ext" | tr '[:lower:]' '[:upper:]')

  entries+=("{\"src\":\"images/${fname}\",\"title\":\"${title}\",\"tag\":\"${tag}\"}")
done

{
  echo "["
  count=${#entries[@]}
  if [ "$count" -gt 0 ]; then
    IFS=$'\n' sorted=($(printf '%s\n' "${entries[@]}" | sort))
    last=$((count - 1))
    for i in "${!sorted[@]}"; do
      if [ "$i" -eq "$last" ]; then
        printf '  %s\n' "${sorted[$i]}"
      else
        printf '  %s,\n' "${sorted[$i]}"
      fi
    done
  fi
  echo "]"
} > "$OUT"

echo "Wrote $OUT with $count entries"
