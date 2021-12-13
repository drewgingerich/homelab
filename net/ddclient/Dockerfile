FROM linuxserver/ddclient
RUN apk update && apk add gettext 
COPY render-conf.sh /config/custom-cont-init.d/
COPY ddclient.conf.tpl /config/