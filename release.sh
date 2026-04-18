#!/usr/bin/env bash
set -euo pipefail

# Step 2 of 2: refresh README, commit "Build Version X.Y.Z", tag vX.Y.Z,
# push branch + tag. The tag push triggers the release workflow which
# builds multi-arch and publishes to ghcr.io.
#
# Must be run AFTER ./build-local.sh succeeded — reuses the lighthouse-build:local
# image that build-local.sh produced.
#
# Flags:
#   --no-push    stop after commit + tag (don't push to origin)

cd "$(dirname "$0")"

PUSH=1
for arg in "$@"; do
  case "$arg" in
    --no-push) PUSH=0 ;;
    *) echo "unknown flag: $arg" >&2; exit 2 ;;
  esac
done

IMAGE_LOCAL="lighthouse-build:local"
IMAGE_INPUT_FILES=(Dockerfile lighthouse lighthouse-quiet help.txt)

log() { printf '\n→ %s\n' "$*"; }

# -- preflight ---------------------------------------------------------------

if [[ -n "$(git status --porcelain)" ]]; then
  echo "working tree is dirty — commit or stash first" >&2
  exit 1
fi
branch=$(git rev-parse --abbrev-ref HEAD)
if [[ "$branch" != "main" ]]; then
  echo "not on main (on $branch) — refusing to tag a release" >&2
  exit 1
fi

# A release push will carry any pre-existing unpushed commits on main with it
# (main is linear, so they're ancestors of the release commit). Refuse up
# front so the release only ever publishes what's already on origin/main plus
# the one commit we're about to make.
git fetch --quiet origin main
ahead=$(git rev-list --count origin/main..HEAD)
if [[ "$ahead" -ne 0 ]]; then
  echo "local main has $ahead unpushed commit(s) — push or reset them before releasing" >&2
  git log --oneline origin/main..HEAD >&2
  exit 1
fi

# Enforce that ./build-local.sh produced and smoke-tested the image that is
# about to be released. The marker file is written only after all smoke tests
# pass; the two checks below catch post-hoc tampering.
if [[ ! -f .build-verified ]]; then
  echo "no .build-verified marker — run ./build-local.sh first (smoke tests must pass)" >&2
  exit 1
fi
# shellcheck source=/dev/null
source .build-verified
if ! docker image inspect "$IMAGE_LOCAL" >/dev/null 2>&1; then
  echo "no $IMAGE_LOCAL image — re-run ./build-local.sh" >&2
  exit 1
fi
current_image_sha=$(docker inspect --format '{{.Id}}' "$IMAGE_LOCAL")
if [[ "$current_image_sha" != "$image_sha" ]]; then
  echo "$IMAGE_LOCAL has been rebuilt since .build-verified was written — re-run ./build-local.sh" >&2
  exit 1
fi
current_content_hash=$(shasum -a 256 "${IMAGE_INPUT_FILES[@]}" | shasum -a 256 | awk '{print $1}')
if [[ "$current_content_hash" != "$content_hash" ]]; then
  echo "Dockerfile or a wrapper changed since ./build-local.sh — re-run it so the image reflects the committed code" >&2
  exit 1
fi

# -- extract version ---------------------------------------------------------

VERSIONS_TXT=$(docker run --rm "$IMAGE_LOCAL" cat versions.txt)
VERSION=$(printf '%s\n' "$VERSIONS_TXT" | awk '/^Lighthouse version is/ {print $NF}')
if [[ -z "$VERSION" ]]; then
  echo "could not extract Lighthouse version from versions.txt" >&2
  exit 1
fi
ALPINE_VERSION=$(docker run --rm "$IMAGE_LOCAL" cat /etc/alpine-release)
if [[ -z "$ALPINE_VERSION" ]]; then
  echo "could not extract Alpine version from image" >&2
  exit 1
fi
log "releasing Lighthouse $VERSION on Alpine $ALPINE_VERSION"

if git rev-parse "v$VERSION" >/dev/null 2>&1; then
  echo "tag v$VERSION already exists — nothing to release" >&2
  exit 1
fi

# -- pin Alpine version in Dockerfile ---------------------------------------

# Rewrite the ARG default so CI (which builds without --build-arg) uses the
# exact same Alpine version we just tested locally.
if ! grep -q '^ARG ALPINE_VERSION=' Dockerfile; then
  echo "Dockerfile is missing 'ARG ALPINE_VERSION=' line" >&2
  exit 1
fi
sed -i.bak -E "s|^ARG ALPINE_VERSION=.*|ARG ALPINE_VERSION=$ALPINE_VERSION|" Dockerfile
rm -f Dockerfile.bak

# -- refresh README Versions block ------------------------------------------

line=$(grep -n '^## Versions$' README.md | head -1 | cut -d: -f1)
if [[ -z "$line" ]]; then
  echo "README.md has no '## Versions' section to refresh" >&2
  exit 1
fi
{
  head -n "$line" README.md
  printf '```\n'
  printf '%s\n' "$VERSIONS_TXT" | sed '/^[[:space:]]*$/d'
  printf '```\n'
} > README.md.new
mv README.md.new README.md

# -- commit, tag, push -------------------------------------------------------

git add Dockerfile README.md
if git diff --cached --quiet; then
  log "no file changes — tagging current HEAD"
else
  git commit -m "Build Version $VERSION"
fi
git tag "v$VERSION"
log "committed + tagged v$VERSION"

if [[ $PUSH -eq 0 ]]; then
  log "done (--no-push). run: git push origin main && git push origin v$VERSION"
  exit 0
fi

log "pushing origin main and tag v$VERSION"
git push origin main
git push origin "v$VERSION"
log "done. CI will build and publish ghcr.io/scalecommerce/docker-lighthouse:$VERSION"
