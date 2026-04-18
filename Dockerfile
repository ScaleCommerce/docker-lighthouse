ARG ALPINE_VERSION=3.23.4
FROM alpine:${ALPINE_VERSION}

ENV NODE_ENV=production \
    PATH=/opt/:$PATH

COPY lighthouse lighthouse-quiet help.txt /opt/

WORKDIR /opt

RUN mkdir /opt/reports && \
    echo "PATH=/opt/:$PATH" >> /root/.profile && \
    echo "cat /opt/help.txt" >> /root/.profile && \
    apk add --no-cache bash chromium nodejs npm && \
    npm install lighthouse && \
    npm cache clean --force && \
    LIGHTHOUSE_VER=$(/opt/node_modules/.bin/lighthouse --version) && \
    NODE_VER=$(node -v) && \
    NPM_VER=$(npm -v) && \
    CHROMIUM_VER=$(chromium --version) && \
    apk del --purge npm && \
    . /etc/os-release && \
    { \
      echo "$PRETTY_NAME ($(cat /etc/alpine-release))"; \
      echo "NodeJS version is $NODE_VER"; \
      echo "npm version is $NPM_VER"; \
      echo "Lighthouse version is $LIGHTHOUSE_VER"; \
      echo "$CHROMIUM_VER"; \
      echo ""; \
    } > versions.txt && \
    echo "cat /opt/versions.txt" >> /root/.profile

CMD ["/bin/bash", "-l"]
