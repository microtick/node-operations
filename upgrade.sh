#!/bin/sh

# Note: this upgrade script requires 'jq' to be installed

TRANSFORMS='.genesis_time="'2020-03-23T15:00:00Z'"'
TRANSFORMS+='|.chain_id="'microtickzone-a2'"'
TRANSFORMS+='|.app_state.microtick.markets+=[{name:"ATOMUSD",description:"Crypto - Atom"},{name:"ETHGAS",description:"Commodity - Ethereum Gas Price"}]'
TRANSFORMS+='|.consensus_params.block.time_iota_ms="1000"'

# Revert transaction B063A6A0D98201EC85D199A080FE94EFE3836C0FD5F6906280871D27FC592B40
# 
# This transaction was a test to determine how to send tokens to the community fund. It causes
# the distribution module's balance to fail an invariant test when using the export as a genesis file
TXSENDER=micro1pjtxlrflsyqtwyqkay3u5rz3flhchnedxkcjgj
TXRECIPIENT=micro1jv65s3grqf6v6jl3dp4t6c9t9rk99cd848emst
TXAMT=1000000
TXDENOM=udai
TRANSFORMS+='|.app_state.bank.balances[]|=(select(.address=="'$TXRECIPIENT'").coins[]|=(select(.denom=="'$TXDENOM'").amount|=(tonumber-'$TXAMT'|tostring)))'
TRANSFORMS+='|.app_state.bank.balances[]|=(select(.address=="'$TXSENDER'").coins[]|=(select(.denom=="'$TXDENOM'").amount|=(tonumber+'$TXAMT'|tostring)))'

jq "$TRANSFORMS" $1 
