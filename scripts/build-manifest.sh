#!/bin/bash
# Scans images/<gallery-folder>/ subfolders and writes images/manifest.json
# describing every gallery and its photos.
#
# Per gallery folder, you can optionally add a gallery.json with:
#   { "title": "Custom Title", "cover": "some-photo.jpg" }
# Anything you leave out (or the whole file) falls back to:
#   - title: the folder name, dashes/underscores turned into spaces, capitalized
#   - cover: the first photo in the folder, alphabetically
#
# A gallery folder with no image files in it is skipped entirely.
set -e

IMG_DIR="images"
OUT="$IMG_DIR/manifest.json"
galleries="[]"

shopt -s nullglob

for dir in "$IMG_DIR"/*/; do
  [ -d "$dir" ] || continue
  slug=$(basename "$dir")

  auto_title=$(echo "$slug" | sed -E 's/[-_]+/ /g' | sed -E 's/(^|[[:space:]])([a-z])/\1\U\2/g')

  meta_file="${dir}gallery.json"
  custom_title=""
  custom_cover=""
  if [ -f "$meta_file" ]; then
    custom_title=$(jq -r '.title // empty' "$meta_file" 2>/dev/null || true)
    custom_cover=$(jq -r '.cover // empty' "$meta_file" 2>/dev/null || true)
  fi
  title="${custom_title:-$auto_title}"

  photos="[]"
  first_photo=""

  for f in "$dir"*; do
    [ -f "$f" ] || continue
    fname=$(basename "$f")
    [ "$fname" = "gallery.json" ] && continue

    ext="${fname##*.}"
    ext_lower=$(echo "$ext" | tr '[:upper:]' '[:lower:]')
    case "$ext_lower" in
      jpg|jpeg|png|gif|webp|svg|avif) ;;
      *) continue ;;
    esac

    [ -z "$first_photo" ] && first_photo="$fname"

    p_title=$(echo "${fname%.*}" | sed -E 's/[-_]+/ /g' | sed -E 's/(^|[[:space:]])([a-z])/\1\U\2/g')
    tag=$(echo "$ext" | tr '[:lower:]' '[:upper:]')
    src="images/${slug}/${fname}"

    photo_obj=$(jq -n --arg src "$src" --arg title "$p_title" --arg tag "$tag" \
      '{src:$src,title:$title,tag:$tag}')
    photos=$(echo "$photos" | jq --argjson p "$photo_obj" '. + [$p]')
  done

  photos=$(echo "$photos" | jq 'sort_by(.src)')
  count=$(echo "$photos" | jq 'length')

  # skip empty galleries
  if [ "$count" -eq 0 ]; then
    continue
  fi

  cover_file="${custom_cover:-$first_photo}"
  cover="images/${slug}/${cover_file}"

  gallery_obj=$(jq -n \
    --arg slug "$slug" \
    --arg title "$title" \
    --arg cover "$cover" \
    --argjson count "$count" \
    --argjson photos "$photos" \
    '{slug:$slug,title:$title,cover:$cover,count:$count,photos:$photos}')

  galleries=$(echo "$galleries" | jq --argjson g "$gallery_obj" '. + [$g]')
done

echo "$galleries" | jq 'sort_by(.slug)' > "$OUT"
echo "Wrote $OUT with $(jq 'length' "$OUT") galleries"
