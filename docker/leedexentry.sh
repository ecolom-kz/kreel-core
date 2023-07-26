#!/bin/bash
LEEDEXD="/usr/local/bin/witness_node"

# For blockchain download
VERSION=`cat /etc/kreel/version`

## Supported Environmental Variables
#
#   * $LEEDEXD_SEED_NODES
#   * $LEEDEXD_RPC_ENDPOINT
#   * $LEEDEXD_PLUGINS
#   * $LEEDEXD_REPLAY
#   * $LEEDEXD_RESYNC
#   * $LEEDEXD_P2P_ENDPOINT
#   * $LEEDEXD_WITNESS_ID
#   * $LEEDEXD_PRIVATE_KEY
#   * $LEEDEXD_TRACK_ACCOUNTS
#   * $LEEDEXD_PARTIAL_OPERATIONS
#   * $LEEDEXD_MAX_OPS_PER_ACCOUNT
#   * $LEEDEXD_ES_NODE_URL
#   * $LEEDEXD_ES_START_AFTER_BLOCK
#   * $LEEDEXD_TRUSTED_NODE
#

ARGS=""
# Translate environmental variables
if [[ ! -z "$LEEDEXD_SEED_NODES" ]]; then
    for NODE in $LEEDEXD_SEED_NODES ; do
        ARGS+=" --seed-node=$NODE"
    done
fi
if [[ ! -z "$LEEDEXD_RPC_ENDPOINT" ]]; then
    ARGS+=" --rpc-endpoint=${LEEDEXD_RPC_ENDPOINT}"
fi

if [[ ! -z "$LEEDEXD_REPLAY" ]]; then
    ARGS+=" --replay-blockchain"
fi

if [[ ! -z "$LEEDEXD_RESYNC" ]]; then
    ARGS+=" --resync-blockchain"
fi

if [[ ! -z "$LEEDEXD_P2P_ENDPOINT" ]]; then
    ARGS+=" --p2p-endpoint=${LEEDEXD_P2P_ENDPOINT}"
fi

if [[ ! -z "$LEEDEXD_WITNESS_ID" ]]; then
    ARGS+=" --witness-id=$LEEDEXD_WITNESS_ID"
fi

if [[ ! -z "$LEEDEXD_PRIVATE_KEY" ]]; then
    ARGS+=" --private-key=$LEEDEXD_PRIVATE_KEY"
fi

if [[ ! -z "$LEEDEXD_TRACK_ACCOUNTS" ]]; then
    for ACCOUNT in $LEEDEXD_TRACK_ACCOUNTS ; do
        ARGS+=" --track-account=$ACCOUNT"
    done
fi

if [[ ! -z "$LEEDEXD_PARTIAL_OPERATIONS" ]]; then
    ARGS+=" --partial-operations=${LEEDEXD_PARTIAL_OPERATIONS}"
fi

if [[ ! -z "$LEEDEXD_MAX_OPS_PER_ACCOUNT" ]]; then
    ARGS+=" --max-ops-per-account=${LEEDEXD_MAX_OPS_PER_ACCOUNT}"
fi

if [[ ! -z "$LEEDEXD_ES_NODE_URL" ]]; then
    ARGS+=" --elasticsearch-node-url=${LEEDEXD_ES_NODE_URL}"
fi

if [[ ! -z "$LEEDEXD_ES_START_AFTER_BLOCK" ]]; then
    ARGS+=" --elasticsearch-start-es-after-block=${LEEDEXD_ES_START_AFTER_BLOCK}"
fi

if [[ ! -z "$LEEDEXD_TRUSTED_NODE" ]]; then
    ARGS+=" --trusted-node=${LEEDEXD_TRUSTED_NODE}"
fi

## Link the kreel config file into home
## This link has been created in Dockerfile, already
ln -f -s /etc/kreel/config.ini /var/lib/kreel
ln -f -s /etc/kreel/logging.ini /var/lib/kreel

chown -R kreel:kreel /var/lib/kreel

# Get the latest security updates
apt-get update && apt-get upgrade -y -o Dpkg::Options::="--force-confold"

# Plugins need to be provided in a space-separated list, which
# makes it necessary to write it like this
if [[ ! -z "$LEEDEXD_PLUGINS" ]]; then
   exec /usr/bin/setpriv --reuid=kreel --regid=kreel --clear-groups \
     "$LEEDEXD" --data-dir "${HOME}" ${ARGS} ${LEEDEXD_ARGS} --plugins "${LEEDEXD_PLUGINS}"
else
   exec /usr/bin/setpriv --reuid=kreel --regid=kreel --clear-groups \
     "$LEEDEXD" --data-dir "${HOME}" ${ARGS} ${LEEDEXD_ARGS}
fi
