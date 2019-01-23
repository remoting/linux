FROM alpine:3.8
 
WORKDIR /root

ADD Caddyfile /root/Caddyfile
ADD caddy /usr/bin/caddy
ADD startup.sh /root/

RUN apk add curl bash && chmod +x startup.sh

CMD ["startup.sh"]