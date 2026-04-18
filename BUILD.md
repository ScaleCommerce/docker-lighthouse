# Release a new version

Two steps:

### 1. Build locally and test

```
./build-local.sh
```

Builds the image for the host arch, reads the bundled Lighthouse version from `versions.txt` inside the image, and smoke-tests it against the URLs listed in `smoke-urls.txt` (or `smoke-urls.example.txt` if you haven't created a personal copy). Fast — only what you need to know whether a new Lighthouse version works.

### 2. Release

```
./release.sh           # commit, tag, push — triggers CI to publish
./release.sh --no-push # stop after commit + tag
```

Reuses the `lighthouse-build:local` image produced in step 1. Refreshes the Versions block in `README.md`, commits `Build Version X.Y.Z`, tags `vX.Y.Z`, pushes branch + tag.

The tag push triggers `.github/workflows/release.yml`, which builds multi-arch (amd64/arm64) and publishes to `ghcr.io/scalecommerce/docker-lighthouse:<version>` and `:latest`.

Preconditions for `release.sh`: clean tree, on `main`, `build-local.sh` run first.

## Manual multi-arch build (fallback)

Only use this if CI is broken. You'll need a GitHub Personal Access Token with `write:packages`:

```
echo $GH_PAT | docker login ghcr.io -u <github-user> --password-stdin
docker buildx create --name multiplatform-builder --use   # first time only
docker buildx build --push --platform linux/amd64,linux/arm64 \
  -t ghcr.io/scalecommerce/docker-lighthouse:<tag> .
```
