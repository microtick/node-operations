# State Sync - client script
Script to bootstrap the syncing when a new peer/validator join to Microtick Stargate version

## The problem...
When a new peer try to join to a running chain maybe could take days to sync completly

## The solution...
Deploying the new State Sync function on seed servers could help to boost the sync of new peers/validators.
Microtick seeds server will include this function from MainNet block 1

## Usage
Download the script:

```
wget https://raw.githubusercontent.com/microtick/validator/testnet-stargate-1/state_sync/statesync_client_mtm.sh
chmod +x statesync_client_mtm.sh
```

As a previous step before launch the script, edit it with `nano` tool and change the rpc_peers if it needed. 
* Then launch the script (CTLR + C to stop it):
`statesync_client_mtm.sh`


## Credits 
Joe Bowman won the bounty about State Sync implementation
https://github.com/microtick/bounties/tree/main/statesync
