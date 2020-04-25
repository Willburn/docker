FROM ubuntu:19.10 AS builder

ENV NODE_VERSION="1.11.0"
ENV CABAL_VERSION="cabal-install-3.0"
ENV GHC_VERSION="ghc-8.6.5"
ENV PATH=/usr/sbin:/usr/bin:/usr/local/bin:/sbin:/bin:/opt/cabal/bin:/opt/ghc/bin/
RUN apt update -y && \
    apt-get install -y software-properties-common && \
    add-apt-repository ppa:hvr/ghc -y && \
    apt update -y && \
    apt-get install -y ${CABAL_VERSION} ${GHC_VERSION} && \
    apt-get -y install curl build-essential pkg-config libffi-dev libgmp-dev libssl-dev libtinfo-dev libsystemd-dev zlib1g-dev git

WORKDIR /usr/src
RUN git clone --recurse-submodules https://github.com/input-output-hk/cardano-node
WORKDIR /usr/src/cardano-node
RUN git fetch --tags
RUN git checkout ${NODE_VERSION}
RUN cabal update
RUN cabal build cardano-node
RUN cabal build cardano-cli
RUN cp /usr/src/cardano-node/dist-newstyle/build/x86_64-linux/${GHC_VERSION}/cardano-node-${NODE_VERSION}/x/cardano-node/build/cardano-node/cardano-node /usr/local/bin/
RUN cp /usr/src/cardano-node/dist-newstyle/build/x86_64-linux/${GHC_VERSION}/cardano-cli-${NODE_VERSION}/x/cardano-cli/build/cardano-cli/cardano-cli /usr/local/bin/

FROM ubuntu:20.04

MAINTAINER "Eystein Hansen <eysteinsofus@gmail.com>"

ENV SERVICE_NAME "cardano-node"

RUN apt update -y && \
    apt-get clean -y && \
    apt-get autoremove -y

# Note you bind your local lan port to this exposed container port
EXPOSE 3000

COPY --from=builder /usr/local/bin/cardano-node /usr/local/bin/
COPY --from=builder /usr/local/bin/cardano-cli /usr/local/bin
COPY usr/local/bin/* /usr/local/bin/

RUN mkdir -p /srv/cardano/

RUN useradd -c "Cardano node user" \
            -d /srv/cardano/cardano-node/ \
            -m \
            -r \
            -s /bin/nologin \
            cardano-node

USER cardano-node

RUN mkdir srv/cardano/cardano-node/storage && \
    mkdir srv/cardano/cardano-node/config && \
    mkdir srv/cardano/cardano-node/logs &&\
    mkdir srv/cardano/cardano-node/sockets && \
    mkdir -p srv/cardano/cardano-node/etc/secrets

WORKDIR /srv/cardano/cardano-node/

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

CMD ['cardano-node', 'run', '--config', '/srv/cardano/cardano-node/config/nodeconf.yaml', '--database-path', '/srv/cardano/cardano-node/storage/db', '--port', '3000', '--socket-path', '/srv/cardano/cardano-node/sockets/pbft_node.socket', '--topology', '/srv/cardano/cardano-node/config/topology.json']
