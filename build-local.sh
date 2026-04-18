#!/usr/bin/env bash
set -euo pipefail

# Step 1 of 2: build the image locally (host arch) and smoke-test Lighthouse
# against a few URLs. If this passes, run ./release.sh to publish.

cd "$(dirname "$0")"

# Invalidate any previous verification marker up front — it only gets rewritten
# below if the whole build+smoke run succeeds.
rm -f .build-verified

IMAGE_LOCAL="lighthouse-build:local"
# Files baked into the image; hashed into .build-verified so release.sh can
# detect post-hoc edits.
IMAGE_INPUT_FILES=(Dockerfile lighthouse lighthouse-quiet help.txt)

if [[ -f "smoke-urls.txt" ]]; then
  SMOKE_URLS_FILE="smoke-urls.txt"
elif [[ -f "smoke-urls.example.txt" ]]; then
  SMOKE_URLS_FILE="smoke-urls.example.txt"
  echo "note: using smoke-urls.example.txt (copy to smoke-urls.txt to customize)" >&2
else
  echo "no smoke-urls.txt or smoke-urls.example.txt found" >&2
  exit 1
fi
SMOKE_URLS=()
while IFS= read -r line; do
  [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue
  SMOKE_URLS+=("$line")
done < "$SMOKE_URLS_FILE"
if [[ ${#SMOKE_URLS[@]} -eq 0 ]]; then
  echo "$SMOKE_URLS_FILE has no URLs" >&2
  exit 1
fi

log() { printf '\n→ %s\n' "$*"; }

log "resolving latest Alpine version"
docker pull -q alpine:latest >/dev/null
ALPINE_VERSION=$(docker run --rm alpine:latest cat /etc/alpine-release)
if [[ -z "$ALPINE_VERSION" ]]; then
  echo "could not resolve Alpine version" >&2
  exit 1
fi
log "Alpine $ALPINE_VERSION"

log "building $IMAGE_LOCAL (host arch)"
docker build --build-arg "ALPINE_VERSION=$ALPINE_VERSION" -t "$IMAGE_LOCAL" .

VERSIONS_TXT=$(docker run --rm "$IMAGE_LOCAL" cat versions.txt)
VERSION=$(printf '%s\n' "$VERSIONS_TXT" | awk '/^Lighthouse version is/ {print $NF}')
if [[ -z "$VERSION" ]]; then
  echo "could not extract Lighthouse version from versions.txt" >&2
  printf '%s\n' "$VERSIONS_TXT" >&2
  exit 1
fi
log "built Lighthouse $VERSION"

for url in "${SMOKE_URLS[@]}"; do
  log "smoke: $url"
  json=$(docker run --rm "$IMAGE_LOCAL" lighthouse-quiet "$url" --only-categories=performance)
  score=$(printf '%s' "$json" | python3 -c '
import json, sys
d = json.loads(sys.stdin.read())
s = d.get("categories", {}).get("performance", {}).get("score")
if not isinstance(s, (int, float)):
    sys.exit(1)
print(s)
')
  if [[ -z "$score" ]]; then
    echo "smoke test FAILED for $url" >&2
    exit 1
  fi
  printf '   performance score: %s\n' "$score"
done

IMAGE_SHA=$(docker inspect --format '{{.Id}}' "$IMAGE_LOCAL")
CONTENT_HASH=$(shasum -a 256 "${IMAGE_INPUT_FILES[@]}" | shasum -a 256 | awk '{print $1}')
{
  echo "image_sha=$IMAGE_SHA"
  echo "content_hash=$CONTENT_HASH"
  echo "alpine_version=$ALPINE_VERSION"
  echo "lighthouse_version=$VERSION"
} > .build-verified

log "OK: Lighthouse $VERSION passed smoke tests"
log "next: ./release.sh"
