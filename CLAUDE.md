# CLAUDE.md

## About This File

Agent guidance — decisions and gotchas that can't be inferred from the code. Keep it minimal; every line competes for the agent's attention and biases its behavior. If it's in the code (Dockerfile, `BUILD.md`, the wrapper scripts), it doesn't belong here. When updating, ask for each line: "would removing this cause an agent to make a mistake?"

## Project overview

Docker image bundling Alpine + Chromium + Node + Lighthouse, published to `ghcr.io/scalecommerce/docker-lighthouse`. No app code — a `Dockerfile`, two bash wrappers (`lighthouse`, `lighthouse-quiet`), and release scripts.

## Release flow

`./build-local.sh` (host-arch build + smoke tests) then `./release.sh` (commit, tag, push). Both every time, in that order — `release.sh` enforces it via a `.build-verified` marker that `build-local.sh` writes only after smoke tests pass, and refuses to proceed if the image or the image-input files have changed since. The tag push triggers `.github/workflows/release.yml`, which builds multi-arch and publishes to ghcr.io. **Don't invoke `docker buildx` by hand to publish** — you skip the smoke tests and bypass the Alpine-version pinning. The raw buildx commands in `BUILD.md` are emergency fallback only.

## Don't hand-edit `ARG ALPINE_VERSION` in the Dockerfile

`release.sh` rewrites it to the exact Alpine patch version that was tested locally, so CI publishes the same Alpine you smoke-tested. Editing by hand breaks that guarantee. To bump Alpine, just re-run the release flow — `build-local.sh` resolves `alpine:latest` at build time.
