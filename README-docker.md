# Docker Container

This repository comes with built-in Dockerfile to support docker
containers. This README serves as documentation.

## Dockerfile Specifications

The `Dockerfile` performs the following steps:

1. Obtain base image (phusion/baseimage:0.10.1)
2. Install required dependencies using `apt-get`
3. Add kreel-core source code into container
4. Update git submodules
5. Perform `cmake` with build type `Release`
6. Run `make` and `make_install` (this will install binaries into `/usr/local/bin`
7. Purge source code off the container
8. Add a local kreel user and set `$HOME` to `/var/lib/kreel`
9. Make `/var/lib/kreel` and `/etc/kreel` a docker *volume*
10. Expose ports `8980` and `4776`
11. Add default config from `docker/default_config.ini` and
    `docker/default_logging.ini`
12. Add an entry point script
13. Run the entry point script by default

The entry point simplifies the use of parameters for the `witness_node`
(which is run by default when spinning up the container).

### Supported Environmental Variables

* `$KREELD_SEED_NODES`
* `$KREELD_RPC_ENDPOINT`
* `$KREELD_PLUGINS`
* `$KREELD_REPLAY`
* `$KREELD_RESYNC`
* `$KREELD_P2P_ENDPOINT`
* `$KREELD_WITNESS_ID`
* `$KREELD_PRIVATE_KEY`
* `$KREELD_TRACK_ACCOUNTS`
* `$KREELD_PARTIAL_OPERATIONS`
* `$KREELD_MAX_OPS_PER_ACCOUNT`
* `$KREELD_ES_NODE_URL`
* `$KREELD_TRUSTED_NODE`

### Default config

The default configuration is:

    p2p-endpoint = 0.0.0.0:4776
    rpc-endpoint = 0.0.0.0:8980
    bucket-size = [60,300,900,1800,3600,14400,86400]
    history-per-size = 1000
    max-ops-per-account = 100
    partial-operations = true

# Docker Compose

With docker compose, multiple nodes can be managed with a single
`docker-compose.yaml` file:

    version: '3'
    services:
     main:
      # Image to run
      image: kreel/kreel-core:latest
      #
      volumes:
       - ./docker/conf/:/etc/kreel/
      # Optional parameters
      environment:
       - KREELD_ARGS=--help


    version: '3'
    services:
     fullnode:
      # Image to run
      image: kreel/kreel-core:latest
      environment:
      # Optional parameters
      environment:
       - KREELD_ARGS=--help
      ports:
       - "0.0.0.0:8980:8980"
      volumes:
      - "kreel-fullnode:/var/lib/kreel"


# Registry

This container is properly registered with Ghrc container registry as:

* [kreel-chain/kreel-core](ghcr.io/kreel-chain/kreel-core)

Going forward, every release tag as well as all pushes to `testnet`
will be built into ready-to-run containers, there.

# Docker Compose

One can use docker compose to setup a trusted full node together with a
delayed node like this:

```
version: '3'
services:

 fullnode:
  image: ghrc.io/kreel-chain/kreel-core:latest
  ports:
   - "0.0.0.0:8980:8980"
  volumes:
  - "kreel-fullnode:/var/lib/kreel"

 delayed_node:
  image: kreel/kreel-core:latest
  environment:
   - 'KREELD_PLUGINS=delayed_node witness'
   - 'KREELD_TRUSTED_NODE=ws://fullnode:8980'
  ports:
   - "0.0.0.0:8981:8980"
  volumes:
  - "kreel-delayed_node:/var/lib/kreel"
  links:
  - fullnode

volumes:
 kreel-fullnode:
```
