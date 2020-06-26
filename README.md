# RC6-2 Testnet Instructions

```mermaid
graph TD;
  New[New Validators] --> Step1[Step 1. Initialization];
  Step1 -- before network start* --> Step2[Step 2. Genesis account];
  Existing[Existing Validators] --> Step3[Step 3. Genesis transaction]
  Step2 --> Step3;
  Step3 --> Step4[Step 4. Running node]
  Step1 -- after network start** --> Step4
  Step4 -- only validators that joined after network start** --> Step5[Step 5. Create Validator]
```

## Step 1 - Initialization

If you DO NOT yet have a running node, perform the following SETUP steps:

SETUP-1. Download the release binaries from https://microtick.com/releases/testnet/

SETUP-2. Extract the archive and verify MD5 checksums.

```
$ tar xf microtick-rc6-linux-x86_64.tar.gz
$ md5sum mtcli
1e7faf1e28d65be8041c3836074fee76  mtcli
$ md5sum mtd
6b07e5e9714a9c132ccf7f87e0caa0fc  mtd
```

SETUP-3. Ensure the binaries 'mtd' and 'mtcli' are in your PATH

SETUP-4. Choose a moniker and initialize the working directory:

```
$ mtd init <moniker>
```

SETUP-5. Create a validator key

```
$ mtcli keys add validator
```

## Step 2 Genesis Account - COMPLETE BY Saturday, June 20, 2020 11:00 pm UTC

New validators should perform the following ACCOUNT steps:

ACCOUNT-1. Find your validator address

```
$ mtcli keys show validator -a
micro17x67yaxc4vgxmpn6pqpczqh7l8942wvyhfqe6w
```

ACCOUNT-2. Send your address (the output from the previous command) as the subject line to: mjackson@microtick.com

All public genesis accounts will be awarded 20000 stake tokens (TICK)

## Step 3 Genesis Transaction - COMPLETE BY Sunday, June 21, 2020 11:00 pm UTC

All validators should perform the following GENTX steps:

GENTX-1. **VERY IMPORTANT** After midnight UTC Saturday night, ensure sure you have the final genesis.json with all the starting account balances:

```
$ git clone https://gitlab.com/microtick/validator.git
$ cd validator
$ git checkout testnet-rc6-2
$ git pull
```

GENTX-2. Copy the final genesis.json file in this directory to $HOME/.microtick/mtd/config (backup the existing one if desired)

```
$ cp genesis.json $HOME/.microtick/mtd/config
```

GENTX-3. Remove any existing gentxs:

```
$ rm -r $HOME/.microtick/mtd/config/gentx
```

GENTX-4. Choose your parameters (https://hub.cosmos.network/master/validators/validator-faq.html) and create your genesis tx (this assumes you have your validator key set up using mtcli)

```
$ mtd gentx --amount <self delegation amount> 
            --commission-rate <your commission rate> 
            --commission-max-rate <max rate>
            --commission-max-change-rate <max change rate>
            --min-self-delegation <self delegation parameter>
            
            ... include any other parameters such as website, details, identity, security contact, etc ...
            
            --name <your validator key's name as shown by 'mtcli keys list'>
            
Genesis transaction written to "~/.microtick/mtd/config/gentx/gentx-xyz.json"
```

Example values:
```
amount: 1000000utick (1 million uticks = 1 tick)
commission rate: 0.1 (for 10% commission)
commission max rate: 0.2 (for 20% commission)
min self delegation: 1 (for 1 tick)
```

GENTX-5. Email your gentx file (the output of the previous step indicated by the filename in quotes on the last line) as an attachment to mjackson@microtick.com

## Step 4 - Running Node - COMPLETE PRIOR TO Monday, June 22, 2020 11:00 pm UTC

All validators should perform the following RUNTIME steps

RUNTIME-1. **VERY IMPORTANT** After midnight UTC Sunday night, update to the latest genesis.json that includes everyone's gentxs.

```
$ git pull
$ cp genesis.json $HOME/.microtick/mtd/config
```

RUNTIME-2. Edit $HOME/.microtick/mtd/config/config.toml. Change the persistent_peers line to:

```
persistent_peers = "922043cd83af759dd5a0605b32991667e8fd4977@45.79.207.112:26656,f9c90511c9fd061a6cb5111c86648603622384d0@microtick.spanish-node.es:6868"
```

RUNTIME-3. Start your node and leave it online for genesis time. You do not need to be present or awake at genesis time, as long as your node is running.

```
$ mtd unsafe-reset-all
$ mtd start
```

## Step 5 - Create Validator

**Only validators that synced their runtime nodes (Step 4) after the network started need to do this step**

CREATE-1. Wait until node is synced. Make sure 'jq' is installed (```apt-get install jq``` on debian / ubuntu). The following command should return 'false' when synced:

```
$ mtcli status | jq .sync_info.catching_up
false
```

CREATE-2. Join the Microtick telegram channel and request 20,000 stake.

CREATE-3. Choose your parameters (https://hub.cosmos.network/master/validators/validator-faq.html) and create your validator:

```
$ mtcli tx staking create-validator --amount <self delegation amount>
                                    --pubkey $(mtd tendermint show-validator)
                                    --moniker <the name you'll call your validator> 
                                    --commission-rate <rate>
                                    --commission-max-rate <max rate> 
                                    --commission-max-change-rate <max change rate> 
                                    --min-self-delegation <min self delegation>
                                    --from $(mtcli keys show validator -a)
```

Example values:
```
amount: 1000000utick (1 million uticks = 1 tick)
commission rate: 0.1 (for 10% commission)
commission max rate: 0.2 (for 20% commission)
min self delegation: 1 (for 1 tick)
name: "My Cool Validator" (do not use this for real, think up something better...)
```
