# Build image with new versions

Find a matching version of lighthoise corresponding to chromium version available: (https://github.com/GoogleChrome/lighthouse/releases)[https://github.com/GoogleChrome/lighthouse/releases]

## setup buildx (if not already done)
```
docker buildx create --name multiplatform-builder
docker buildx use multiplatform-builder
docker buildx inspect --bootstrap
```

## test image locally
```
docker buildx build --load -t scalecommerce/lighthouse:<tag>  .
mkdir reports
docker run -ti --rm -v $(pwd)/reports:/opt/reports scalecommerce/lighthouse:<tag> lighthouse https://www.google.com/
rm -rf reports/*.html
```

## build for all platforms and push image to docker hub
```
docker login
docker buildx build --push --platform linux/amd64,linux/arm64 -t scalecommerce/lighthouse:<tag> .
docker buildx prune
```

## update readme
Replace Versions-section in READMe with the output of
```
docker run --rm -ti scalecommerce/lighthouse:<tag> cat versions.txt
```
