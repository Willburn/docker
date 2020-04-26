#!/usr/bin/env bash
set -e

if [ -z "$CNODEIPV4" ]; then
  cat >&2 <<EOF
A CNODEIPV4 is required to run this container, for example docker run -e CNODEIPV4=XX.XX.XX.XX
EOF
  exit 1
fi
cardano-node run \
          --config /srv/cardano/cardano-node/config/nodeconf.yaml \
          --database-path /srv/cardano/cardano-node/storage/db \
          --port 3000 \
          --socket-path /srv/cardano/cardano-node/sockets/pbft_node.socket \
          --topology /srv/cardano/cardano-node/config/topology.json \
          --host-addr $CNODEIPV4
exec "$@"
