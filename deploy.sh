#!/usr/bin/env bash

echo "Cleaning previously generated files"
rm -rf ./public

echo "Generating static files"
hugo

echo "Running rsync"
rsync -avz public/ cianjohnston.ie:/home/user-data/www/default