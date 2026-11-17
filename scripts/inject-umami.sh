#!/bin/sh
# Подставляет Umami website ID из переменной окружения Netlify UMAMI_WEBSITE_ID.
# Если переменная не задана, тег Umami убирается из собранных страниц,
# чтобы на сайт не уходили запросы с заглушкой вместо ID.
# Работает с каталогом публикации (по умолчанию site) и не меняет файлы в git.
set -eu
DIR="${1:-site}"
ID="${UMAMI_WEBSITE_ID:-}"

find "$DIR" -name '*.html' | while read -r f; do
  if ! grep -q 'cloud.umami.is' "$f"; then continue; fi
  tmp="$f.tmp"
  if [ -n "$ID" ]; then
    case "$ID" in *[!A-Za-z0-9-]*) echo "UMAMI_WEBSITE_ID содержит недопустимые символы" >&2; exit 1;; esac
    sed "s/UMAMI_WEBSITE_ID/$ID/g" "$f" > "$tmp"
  else
    grep -v 'cloud.umami.is' "$f" > "$tmp"
  fi
  mv "$tmp" "$f"
done

if [ -n "$ID" ]; then echo "Umami: ID подставлен"; else echo "Umami: UMAMI_WEBSITE_ID не задан, тег убран"; fi
