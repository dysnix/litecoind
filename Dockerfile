FROM debian:stretch-slim

ENV LITECOIN_VERSION 0.17.1

ENV LITECOIN_URL https://download.litecoin.org/litecoin-$LITECOIN_VERSION/linux/litecoin-$LITECOIN_VERSION-x86_64-linux-gnu.tar.gz

ARG USER_ID
ARG GROUP_ID

ENV HOME /home/litecoin

# add user with specified (or default) user/group ids
ENV USER_ID ${USER_ID:-1000}
ENV GROUP_ID ${GROUP_ID:-1000}

RUN groupadd -g ${GROUP_ID} litecoin \
	&& useradd -u ${USER_ID} -g litecoin -s /bin/bash -m -d ${HOME} litecoin

RUN set -ex \
	&& apt-get update \
	&& apt-get install -qq --no-install-recommends ca-certificates wget gosu \
	&& rm -rf /var/lib/apt/lists/*

# install litecoin binaries
RUN set -ex \
	&& cd /tmp \
	&& wget -qO litecoin.tar.gz "$LITECOIN_URL" \
	&& tar -xzvf litecoin.tar.gz -C /usr/local --strip-components=1 --exclude=*-qt \
	&& rm -rf /tmp/*

COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["litecoind"]
