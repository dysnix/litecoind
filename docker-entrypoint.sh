#!/bin/bash
set -e
GOSU="gosu litecoin"
# don't use gosu when id is not 0
if [ "$(id -u)" -ne "0" ];then
  GOSU=""
fi
if [[ "$1" == "litecoin-cli" || "$1" == "litecoin-tx" || "$1" == "litecoind" || "$1" == "litecoin-wallet" ]]; then
	exec $GOSU "$@"
else
  exec $GOSU litecoind "$@"
fi
