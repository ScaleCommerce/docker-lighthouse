# Build image with new versions

## setup buildx (if not already done)
```
docker buildx create --name multiplatform-builder
docker buildx use multiplatform-builder
docker buildx inspect --bootstrap
```

## build multi arch image
```
docker buildx build --platform linux/amd64,linux/arm64 -t scalecommerce/lighthouse:<tag> .
```

## test image locally
```
docker buildx build --load -t scalecommerce/lighthouse:<tag>  .
docker run -ti --rm -v $(pwd):/opt/reports scalecommerce/lighthouse:<tag> lighthouse https://www.google.com/
```

## push image to docker hub
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