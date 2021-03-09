#!/bin/bash
set -e
# Microtick State Sync client config #.

DIR="$HOME/.microtick/"
if [ -d "$DIR" ]; then

  echo "Error... bcnad folder ${DIR} exist.... delete it and try again if your are sure about it. "
  exit 1
fi

wget https://microtick.com/releases/testnet/stargate/mtm-v2-rc4-linux-x86_64.tar.gz
tar -xzvf mtm-v2-rc4-linux-x86_64.tar.gz
mv mtm-v2-rc4 mtm
chmod +x mtm
./mtm init New_peer --chain-id microtick-testnet-rc4
wget https://microtick.com/releases/testnet/stargate/genesis.json 
mv genesis.json $HOME/.microtick/config/
# At this moment: config state sync & launch the syncing (all previous config need to be performed) 

DOMAIN_1=lunesfullnode.com
NODE1_IP=$(dig $DOMAIN_1 +short)
RPC1="http://$NODE1_IP"
P2P_PORT1=26656
RPC_PORT1=26657

DOMAIN_2=testnet.microtick.zone
NODE2_IP=$(dig $DOMAIN_2 +short)
RPC2="http://$NODE2_IP"
RPC_PORT2=26657
P2P_PORT2=26656

INTERVAL=1000

LATEST_HEIGHT=$(curl -s $RPC1:$RPC_PORT1/block | jq -r .result.block.header.height);
BLOCK_HEIGHT=$(($(($LATEST_HEIGHT / $INTERVAL)) * $INTERVAL));
if [ $BLOCK_HEIGHT -eq 0 ]; then
  echo "Error: Cannot state sync to block 0; Latest block is $LATEST_HEIGHT and must be at least $INTERVAL; wait a few blocks!"
  exit 1
fi

TRUST_HASH=$(curl -s "$RPC1:$RPC_PORT1/block?height=$BLOCK_HEIGHT" | jq -r .result.block_id.hash)
if [ "$TRUST_HASH" == "null" ]; then
  echo "Error: Cannot find block hash. This shouldn't happen :/"
  exit 1
fi

NODE1_ID=$(curl -s "$RPC1:$RPC_PORT1/status" | jq -r .result.node_info.id)
NODE2_ID=$(curl -s "$RPC2:$RPC_PORT2/status" | jq -r .result.node_info.id)

sed -i.bak -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1true| ; \
s|^(rpc_servers[[:space:]]+=[[:space:]]+).*$|\1\"http://$NODE1_IP:$RPC_PORT1,http://$NODE2_IP:$RPC_PORT2\"| ; \
s|^(trust_height[[:space:]]+=[[:space:]]+).*$|\1$BLOCK_HEIGHT| ; \
s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"| ; \
s|^(persistent_peers[[:space:]]+=[[:space:]]+).*$|\1\"${NODE1_ID}@${NODE1_IP}:${P2P_PORT1},${NODE2_ID}@${NODE2_IP}:${P2P_PORT2}\"| ; \
s|^(seeds[[:space:]]+=[[:space:]]+).*$|\1\"${NODE1_ID}@${NODE1_IP}:${P2P_PORT1},${NODE2_ID}@${NODE2_IP}:${P2P_PORT2}\"|" $HOME/.microtick/config/config.toml

sed -E -i 's/minimum-gas-prices = \".*\"/minimum-gas-prices = \"0.025stake\"/' $HOME/.microtick/config/app.toml

./mtm unsafe-reset-all
#rm -f $HOME/./bcna/config/addrbook.json
./mtm start
