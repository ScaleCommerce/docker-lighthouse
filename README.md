# Chromium headless and lighthouse

This image is mainly for automated testing. It provides:

* [Chromium headless](https://chromium.googlesource.com/chromium/src/+/lkgr/headless/README.md)
* [Lighthouse](https://developers.google.com/web/tools/lighthouse/)

## Example usage

get lighthouse report as html in current directory
```
docker run -ti --rm -v $(pwd):/opt/reports scalecommerce/lighthouse lighthouse https://www.google.com/
````

get lighthouse report as json on stdout
```
docker run -ti --rm scalecommerce/lighthouse lighthouse --output json --output-path stdout https://www.google.com/
```

don't limit network and emulate desktop
```
docker run -ti --rm -v $(pwd):/opt/reports scalecommerce/lighthouse lighthouse https://www.google.com/ --throttling-method provided --preset desktop
```

## Versions
```
NodeJS version is v22.16.0
npm version is 11.3.0
Lighthouse version is 12.8.0
Chromium 138.0.7204.93 Alpine Linux
```