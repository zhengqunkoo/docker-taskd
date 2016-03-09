FROM debian:jessie

MAINTAINER Armin Grodon <me@armingrodon.de>

RUN groupadd -r taskd \
    && useradd -r -g taskd taskd

RUN apt-get update \
    && apt-get install -y --no-install-recommends --fix-missing \
        ca-certificates curl \
    && rm -rf /var/lib/apt/lists/*

ENV GOSU_VERSION 1.7
RUN curl -o /usr/local/bin/gosu -fsSL "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture)" \
    && curl -o /usr/local/bin/gosu.asc -fsSL "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture).asc" \
    && export GNUPGHOME="$(mktemp -d)" \
    && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
    && gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
    && rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc \
    && chmod +x /usr/local/bin/gosu \
    && gosu nobody true

ENV TASKD_VERSION 1.1.0
ENV TASKDDATA /var/taskd

RUN apt-get update \
    && apt-get install -y --no-install-recommends --fix-missing \
        build-essential cmake curl gnutls-bin libgnutls28-dev uuid-dev \
    && cd /var \
    && curl -O http://taskwarrior.org/download/taskd-$TASKD_VERSION.tar.gz \
    && tar xzf taskd-$TASKD_VERSION.tar.gz \
    && rm taskd-$TASKD_VERSION.tar.gz \
    && cd taskd-$TASKD_VERSION \
    && cmake -DCMAKE_BUILD_TYPE=release . \
    && make \
    && make install \
    && apt-get remove -y --auto-remove build-essential cmake curl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN mkdir -p /var/taskd/pki \
    && chown -R taskd:taskd /var/taskd
VOLUME /var/taskd
WORKDIR /var/taskd

COPY docker-entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 53589
CMD ["taskd", "server"]
