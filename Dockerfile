FROM alpine:latest

ENV NODE_ENV=production \
    LIGHTHOUSE_VERSION=12.8.2 \
    PATH=/opt/:$PATH

COPY lighthouse lighthouse-quiet help.txt /opt/

WORKDIR /opt

RUN mkdir /opt/reports && \
    echo "PATH=/opt/:$PATH" >> /root/.profile && \
    echo "cat /opt/help.txt" >> /root/.profile && \
    apk update && \
    apk add --no-cache bash chromium nodejs npm && \
    apk cache clean && \
    rm -rf /var/cache/apk && \
    npm install lighthouse@"$LIGHTHOUSE_VERSION" && \
    npm prune && \
    npm cache clean --force && \
    set -o allexport && source /etc/os-release && set +o allexport && \
    echo $PRETTY_NAME >> versions.txt && \
    echo "NodeJS version is $(node -v)" >> versions.txt && \
    echo "npm version is $(npm -v)" >> versions.txt && \
    echo "Lighthouse version is $(/opt/node_modules/.bin/lighthouse --version)" >> versions.txt && \
    echo $(chromium --version) >> versions.txt && \
    echo "" >> versions.txt && \
    echo "cat /opt/versions.txt" >> /root/.profile

CMD ["/bin/bash", "-l"]
