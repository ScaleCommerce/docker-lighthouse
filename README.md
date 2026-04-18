# Chromium headless and lighthouse

This image is mainly for automated testing. It provides:

* [Chromium headless](https://chromium.googlesource.com/chromium/src/+/lkgr/headless/README.md)
* [Lighthouse](https://developers.google.com/web/tools/lighthouse/)

## Pull the latest image

```
docker pull ghcr.io/scalecommerce/docker-lighthouse:latest
```

Browse all available tags: [github.com/ScaleCommerce/docker-lighthouse/pkgs/container/docker-lighthouse](https://github.com/ScaleCommerce/docker-lighthouse/pkgs/container/docker-lighthouse)

## Example usage

get lighthouse report as html in current directory
```
docker run -ti --rm -v $(pwd):/opt/reports ghcr.io/scalecommerce/docker-lighthouse lighthouse https://www.google.com/
````

get lighthouse report as json on stdout (clean JSON, safe to pipe into a parser)
```
docker run --rm ghcr.io/scalecommerce/docker-lighthouse lighthouse-quiet https://www.google.com/
```

don't limit network and emulate desktop
```
docker run -ti --rm -v $(pwd):/opt/reports ghcr.io/scalecommerce/docker-lighthouse lighthouse https://www.google.com/ --throttling-method provided --preset desktop
```

## Versions
```
Alpine Linux v3.23 (3.23.4)
NodeJS version is v24.14.1
npm version is 11.11.0
Lighthouse version is 13.1.0
Chromium 147.0.7727.55 Alpine Linux
```
