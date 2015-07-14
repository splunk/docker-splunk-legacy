FROM alpine:latest

MAINTAINER Denis Gladkikh <docker-splunk@denis.gladkikh.email>

ENV SPLUNK_PRODUCT splunk
ENV SPLUNK_VERSION 6.2.4
ENV SPLUNK_BUILD 271043
ENV SPLUNK_FILENAME splunk-${SPLUNK_VERSION}-${SPLUNK_BUILD}-Linux-x86_64.tgz

ENV SPLUNK_HOME /opt/splunk
ENV SPLUNK_GROUP splunk
ENV SPLUNK_USER splunk
ENV SPLUNK_BACKUP_DEFAULT_ETC /var/opt/splunk

# add splunk:splunk user
RUN addgroup -S ${SPLUNK_GROUP} \
    && adduser -SDH -G ${SPLUNK_GROUP} ${SPLUNK_USER}

# Download official Splunk release, verify checksum and unzip in /opt/splunk
# Also backup etc folder, so it will be later copied to the linked volume
RUN apk add --update-cache curl sudo \
    && mkdir -p ${SPLUNK_HOME} \
    && curl -so /tmp/${SPLUNK_FILENAME} https://download.splunk.com/products/splunk/releases/${SPLUNK_VERSION}/${SPLUNK_PRODUCT}/linux/${SPLUNK_FILENAME} \
    && curl -so /tmp/${SPLUNK_FILENAME}.md5 https://download.splunk.com/products/splunk/releases/${SPLUNK_VERSION}/${SPLUNK_PRODUCT}/linux/${SPLUNK_FILENAME}.md5 \
    && (cd /tmp \
        && cat /tmp/${SPLUNK_FILENAME}.md5 | awk -F "= " '{print $2"  "$1}' | sed 's/MD5\((.*)\)/\1/' | tr -d '()' > /tmp/${SPLUNK_FILENAME}.md5 \
        && md5sum -c ${SPLUNK_FILENAME}.md5) \
    && tar xzf /tmp/${SPLUNK_FILENAME} -C ${SPLUNK_HOME}/../ \
    && rm /tmp/${SPLUNK_FILENAME} \
    && rm /tmp/${SPLUNK_FILENAME}.md5 \
    && apk del curl \
    && mkdir -p /var/opt/splunk \
    && cp -R ${SPLUNK_HOME}/etc ${SPLUNK_BACKUP_DEFAULT_ETC} \
    && rm -fR ${SPLUNK_HOME}/etc \
    && chown -R ${SPLUNK_USER}:${SPLUNK_GROUP} ${SPLUNK_HOME} \
    && chown -R ${SPLUNK_USER}:${SPLUNK_GROUP} ${SPLUNK_BACKUP_DEFAULT_ETC} \
    && rm -rf /var/cache/apk/*

COPY entrypoint.sh /sbin/entrypoint.sh
RUN chmod +x /sbin/entrypoint.sh

# Ports Splunk Web, Splunk Daemon, KVStore, Splunk Indexing Port, Network Input
EXPOSE 8000/tcp 8089/tcp 8191/tcp 9997/tcp 514/udp

WORKDIR /opt/splunk

# Configurations folder, var folder for everyting (indexes, logs, kvstore)
VOLUME [ "/opt/splunk/etc", "/opt/splunk/var" ]

ENTRYPOINT ["/sbin/entrypoint.sh"]
CMD ["start-service"]
