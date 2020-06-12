FROM debian:stretch-slim

ARG USER_ID
ARG GROUP_ID

ENV HOME /home/litecoin

# add user with specified (or default) user/group ids
ENV USER_ID ${USER_ID:-1000}
ENV GROUP_ID ${GROUP_ID:-1000}

ENV VERSION 0.18.1
ENV SHASUM 540f5add987a58fe051dbe5691b3da2fd8f8594a0f5e3443864607c075ff588a
ENV ARCH x86_64-linux-gnu
ENV IGNORE_FAILED_TESTS true

RUN groupadd -g ${GROUP_ID} litecoin \
	&& useradd -u ${USER_ID} -g litecoin -s /bin/bash -m -d ${HOME} litecoin

# grab gosu for easy step-down from root
RUN set -x && apt-get update && \
    apt-get install -y --no-install-recommends \
      ca-certificates \
      wget \
      gosu && \
    cd /tmp && \
    wget https://download.litecoin.org/litecoin-${VERSION}/SHA256SUMS.asc && \
    wget https://download.litecoin.org/litecoin-${VERSION}/linux/litecoin-${VERSION}-${ARCH}.tar.gz && \
    echo "$SHASUM  SHA256SUMS.asc" | sha256sum --check && \
    sha256sum --ignore-missing --check SHA256SUMS.asc && \
    tar -xf litecoin-${VERSION}-${ARCH}.tar.gz && \
    echo "Running tests ..." && \
    litecoin-${VERSION}/bin/test_litecoin || ${IGNORE_FAILED_TESTS} && \
    install -m 0755 -D -t /usr/local/bin litecoin-${VERSION}/bin/litecoind && \
    install -m 0755 -D -t /usr/local/bin litecoin-${VERSION}/bin/litecoin-cli && \
    install -m 0755 -D -t /usr/local/bin litecoin-${VERSION}/bin/litecoin-tx && \
    install -m 0755 -D -t /usr/local/bin litecoin-${VERSION}/bin/litecoin-wallet && \
    cd / && \
    apt-get purge -y \
    		ca-certificates \
    		wget && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR ${HOME}
COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["litecoind"]
