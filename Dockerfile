FROM alpine:latest

ENV NODE_ENV=production \
    WORKDIR=/opt \
    PATH=/opt/:/opt/node_modules/.bin/:$PATH

COPY lighthouse help.txt versions.txt $WORKDIR/

WORKDIR $WORKDIR

RUN adduser -S node && \
    mkdir $WORKDIR/reports && \
    chown -R node:nogroup /opt && \
    echo "PATH=/opt/:/opt/node_modules/.bin/:$PATH" >> /home/node/.profile && \
    echo "cat $WORKDIR/help.txt" >> /home/node/.profile && \
    echo "cat $WORKDIR/versions.txt" >> /home/node/.profile && \
    apk add --no-cache bash chromium nodejs npm

USER node

RUN npm install lighthouse && \
    npm prune && \
    npm cache clean --force && \
    echo "NodeJS version is $(node -v)" >> versions.txt && \
    echo "npm version is $(npm -v)" >> versions.txt && \
    echo "Lighthouse version is $(npm info lighthouse version)" >> versions.txt && \
    echo $(chromium --version) >> versions.txt && \
    echo "" >> versions.txt

CMD ["/bin/bash", "-l"]