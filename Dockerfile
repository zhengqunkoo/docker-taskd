FROM debian:jessie

RUN apt-get update && \
    apt-get install -y --no-install-recommends --fix-missing \
      build-essential cmake curl gnutls-bin libgnutls28-dev uuid-dev && \
    rm -rf /var/lib/apt/lists/*
RUN groupadd -r taskd && \
    useradd -r -m -d /var/taskd -g taskd taskd
RUN cd /var && \
    curl -O http://taskwarrior.org/download/taskd-1.1.0.tar.gz && \
    tar xzf taskd-1.1.0.tar.gz && \
    rm taskd-1.1.0.tar.gz && \
    cd taskd-1.1.0 && \
    cmake -DCMAKE_BUILD_TYPE=release . && \
    make && \
    make install

ENV TASKDDATA /var/taskd
USER taskd
RUN taskd init

VOLUME /var/taskd
WORKDIR /var/taskd
COPY docker-entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
EXPOSE 53589
CMD ["taskd", "server"]
