# Chromium headless and lighthouse

This image is mainly for automated testing. It provides:

* [Chromium headless](https://chromium.googlesource.com/chromium/src/+/lkgr/headless/README.md)
* [Lighthouse](https://developers.google.com/web/tools/lighthouse/)

## Pull the latest image

```
docker pull ghcr.io/scalecommerce/docker-lighthouse:latest
```

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
Alpine Linux v3.22
NodeJS version is v22.16.0
npm version is 11.3.0
Lighthouse version is 12.8.2
Chromium 141.0.7390.76
```