#!/bin/sh

WORK=$PWD/chain
REPO=$PWD/validator

MTROOT=$WORK mtd init Moniker

cp $REPO/genesis.json $WORK/mtd/config

rm -rf $WORK/mtd/config/gentx
mkdir $WORK/mtd/config/gentx
cp $REPO/gentx/gentx* $WORK/mtd/config/gentx

MTROOT=$WORK mtd collect-gentxs
MTROOT=$WORK mtd unsafe-reset-all
MTROOT=$WORK mtd start

