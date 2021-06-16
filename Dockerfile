FROM debian:bullseye

RUN echo "\ndeb http://deb.debian.org/debian unstable main" >> /etc/apt/sources.list

#update and accept all prompts
RUN apt-get update && apt-get install -y \
  supervisor \
  rdiff-backup \
  screen \
  rsync \
  git \
  curl \
  rlwrap \
  openjdk-16-jre-headless \
  ca-certificates-java \
  build-essential \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN curl https://nodejs.org/dist/v8.9.4/node-v8.9.4-linux-x64.tar.gz -o /tmp/node.tar.gz

RUN mkdir -p /usr/nodejs && cd /usr/nodejs && tar -xf /tmp/node.tar.gz

RUN ln -s /usr/nodejs/node-v8.9.4-linux-x64/bin/node /usr/bin/node
RUN ln -s /usr/nodejs/node-v8.9.4-linux-x64/bin/npm /usr/bin/npm
RUN ln -s /usr/nodejs/node-v8.9.4-linux-x64/bin/npx /usr/bin/npx

RUN npm i -g npm@6

#download mineos from github
RUN mkdir /usr/games/minecraft \
  && cd /usr/games/minecraft \
  && git clone --depth=1 https://github.com/hexparrot/mineos-node.git -b 1.3.0 . \
  && cp mineos.conf /etc/mineos.conf \
  && chmod +x webui.js mineos_console.js service.js

WORKDIR /usr/games/minecraft

RUN npm config set unsafe-perm true
#build npm deps and clean up apt for image minimalization
RUN chmod 777 -R /usr/games/minecraft && chmod 777 -R /root && npm install

#configure and run supervisor
# RUN cp /usr/games/minecraft/init/supervisor_conf /etc/supervisor/conf.d/mineos.conf
WORKDIR /usr/games/minecraft
CMD ["node", "webui.js"]
# CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf"]

#entrypoint allowing for setting of mc password
COPY entrypoint.sh /entrypoint.sh
RUN chmod 777 /entrypoint.sh && chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 8443 25565-25570
VOLUME /var/games/minecraft