#! /usr/bin/env bash
set -e
jp2a --colors --height=25 ./backstage/packages/app/public/android-chrome-192x192.png

echo ''

echo '🚀 Welcome to the Backstage Devbox environment!'

gum format -- "# Scripts"
echo '🛠️ {{ Bold (Italic (Foreground "122" "make run")) }} to run backstage as a local app directly...' | gum format -t template
echo ''
echo '🚢 {{ Bold (Italic (Foreground "122" "make docker-build-multi")) }} to build the backstage/Dockerfile...' | gum format -t template
echo ''
gum format -- "# Included Packages" \
                " - nodejs (v20.18.1)" \
                "- docker (v27.5.1)" \
                "- jp2a (v1.1.0)" \
                "- gum (v0.15.2)"
echo ''
exit 0