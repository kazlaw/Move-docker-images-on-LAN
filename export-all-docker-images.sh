#!/bin/bash

# Output file name
OUTPUT_FILE="all-docker-images.tar"

# Get all image IDs and tags for specific repositories
IMAGES=$(docker images --format '{{.Repository}}:{{.Tag}}' \
  | grep -E '^(openmrs/|testag/|postgres|mariadb|redis|n8nio/n8n|testag|testag/superset|httpd)' \
  | grep -v '<none>')

# Add images by ID for those with <none> tags
UNTAGGED_IDS=$(docker images --format '{{.ID}} {{.Repository}}:{{.Tag}}' \
  | grep -E '^(.* )?(openmrs/|testtag/|postgres|mariadb|redis|n8nio/n8n|testag|testag/superset|httpd):<none>' \
  | awk '{print $1}')

echo "[*] Exporting tagged images..."
for img in $IMAGES; do
  echo " → $img"
done

echo "[*] Including untagged images by ID..."
for id in $UNTAGGED_IDS; do
  echo " → $id"
done

# Save everything into one tarball
docker save -o "$OUTPUT_FILE" $IMAGES $UNTAGGED_IDS

if [ $? -eq 0 ]; then
  echo "[✓] Docker images exported to $OUTPUT_FILE"
else
  echo "[x] Docker export failed!"
  exit 1
fi

# Serve over HTTP
echo "[*] Starting HTTP server on port 8000..."
echo "→ From other PC: wget http://<this-pc-ip>:8000/$OUTPUT_FILE"
python3 -m http.server 8000
