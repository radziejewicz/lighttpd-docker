FROM alpine:3.18

RUN apk update && \
    apk add --no-cache \
    lighttpd \
    openssl \
    curl && \
    rm -rf /var/cache/apk/*

RUN mkdir /etc/lighttpd/ssl/ && \
	openssl req -x509 -newkey rsa:4096 -keyout /tmp/key.pem -out /tmp/cert.pem -days 365 -subj '/CN=localhost' -nodes -sha256 && \
	cat /tmp/key.pem /tmp/cert.pem > /etc/lighttpd/ssl/localhost.pem && \
	rm /tmp/key.pem /tmp/cert.pem && \
	chmod 400 /etc/lighttpd/ssl/localhost.pem

COPY config/lighttpd/*.conf /etc/lighttpd/

HEALTHCHECK --interval=1m --timeout=1s \
  CMD curl -f http://localhost/ || exit 1

EXPOSE 80 443

VOLUME /etc/lighttpd/
VOLUME /var/www/

ENTRYPOINT ["/usr/sbin/lighttpd", "-D", "-f", "/etc/lighttpd/lighttpd.conf"]