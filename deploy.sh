#!/usr/bin/env bash
set -euo pipefail

echo "Cleaning previously generated files"
rm -rf ./public

echo "Generating static files"
hugo

echo "Running rsync"
rync -avz public/ cianjohnston.ie:/home/user-data/www/default