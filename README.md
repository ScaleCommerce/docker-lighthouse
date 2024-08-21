# Chromium headless and lighthouse

This image is mainly for automated testing. It provides:

* [Chromium headless](https://chromium.googlesource.com/chromium/src/+/lkgr/headless/README.md)
* [Lighthouse](https://developers.google.com/web/tools/lighthouse/)

## Example usage

```
# get lighthouse report as html in current directory
docker run -ti --rm -v $(pwd):/opt/reports scalecommerce/chrome-headless lighthouse https://www.google.com/

# get lighthouse report as json on stdout
docker run -ti --rm scalecommerce/chrome-headless lighthouse --output json --output-path stdout https://www.google.com/


# don't limit network and emulate desktop
docker run -ti --rm -v $(pwd):/opt/reports scalecommerce/chrome-headless lighthouse https://www.google.com/ --throttling-method provided --preset desktop

```

## Versions
```
NodeJS version is v20.15.1
npm version is 10.8.0
Lighthouse version is 12.2.0
Chromium 127.0.6533.99 Alpine Linux
```