# Microtick chain migration instructions

We're planning an upgrade to the Microtick network to add a few new markets.

This is a guide for validator operators to prepare to upgrade from `microtickzone-a1` 
to `microtickzone-a2`. The Microtick team will post the new genesis file as a reference, 
but we recommend that validator operators use these instructions to verify genesis file.

## Key details
- Block Height 3,419,720 (targeting Mar 23 at 15:00 UTC)
- Software update to handle staking amounts for slashed delegations, and a security patch.
- Update to the genesis file (new markets and revert an invalid Tx)
- No other parameter or account changes
- Clearing the state (less disk space)

We haven't launched the governance proposal yet. When we do, **voting will only last for only 48 hours.**

If the proposal `Microtick-a2 Upgrade Proposal` passes, the target time for the upgrade procedure is
on `March 18, 2021 at or around 15:00 UTC`. Since block times vary, the precise block height will be `3,343,200`.
Precisely, this means block 3,343,200 will be the last block signed for the microtickzone-a1 chain.

  - [Preliminary](#preliminary)
  - [Risks](#risks)
  - [Recovery](#recovery)
  - [Upgrade Procedure](#upgrade-procedure)
  - [Notes for Service Providers](#notes-for-service-providers)

## Preliminary

Minor changes have been made to the Microtick software to handle a security patch and state exports. 
This upgrade is primarily intended to reset the state of the chain,
requiring less disk space and making it easier for a node to recover. We will also add some additional markets.
This will not yet be the Stargate upgrade.

## Risks

As a validator performing the upgrade procedure on your consensus nodes carries a heightened risk of
equivocation (aka double-signing) and with it, the slashing penalty of 5% of your staked TICK.
The most important parts of this procedure are 1) verifying your software version and 
2) verifying the genesis file hash before your validator begins signing blocks.

The riskiest thing that an operator can do is to discover a mistake and repeat the upgrade
procedure again during the network startup. If you discover a mistake in your process, 
wait for the network to start before correcting it. If the network is halted and you have
started with a different genesis file than the expected one, get help from the Microtick team
before resetting your validator.

## Impacts on Market Participants

Some validators are also participating in price discovery, placing quotes and taking positions with trades.
When state is exported, quotes and trades do not propagate to the new chain.  Instead, quotes are cancelled
and the token backing in the quote is refunded to the quote's provider as part of the export. Trades are
halted and the backing is refunded to the short counterparty. No trade settlement is performed based on any
positions that might be in-the-money at the time of the upgrade, and the premium originally paid is not
refunded (such funds may not be available since they are not escrowed as part of the trade contract).

Because of this, it is fine to continue to place quotes and contribute to the consensus price by placing quotes
of all time durations, right up to the time of the chain upgrade. However, trades placed with an expiration 
after the expected upgrade time will have no profit potential in terms of settlement payout. (If the chain 
upgrade is in 30 minutes, do not buy a 1-hour call!)

## Recovery

Prior to exporting the `microtickzone-a1` state, we advise operators to take a full data snapshot at the
export height before proceeding. Snapshotting depends heavily on infrastructure, but generally this
can be done by backing up the `.mtcli` and `.mtd` directories.

It is critically important to back-up the `.mtd/data/priv_validator_state.json` file after stopping your mtd process. This file is updated every block as your validator participates in a consensus rounds. This critical file is necessary to prevent double-signing, in case the upgrade fails and the previous chain needs to be restarted.

## Upgrade Procedure

__Note__: It is assumed you are currently operating a full-node running v1.0.0 of the Microtick software.

- The version/commit hash of Microtick v1.0.0: `13c5059c68a7322fa6da41d6031ebc8d3f9f575b`
- The upgrade height as agreed upon by governance: **3,343,200**

1. Verify you are currently running the correct version (v0.34.6+) of Microtick:

   ```bash
   $ mtd version --long
   name: Microtick
   server_name: mtd
   client_name: mtcli
   version: v1.0.0
   commit: 13c5059c68a7322fa6da41d6031ebc8d3f9f575b
   ```

2. Export existing state from `microtickzone-a1`:

   **NOTE**: We recommend that validator operators take a full data snapshot at the export
   height before proceeding in case the upgrade does not go as planned, or in case an insufficient
   amount of voting power comes online within an agreed upon amount of time. If we need to relaunch
   microtickzone-a1, the chain will fallback see [Recovery](#recovery) for how to proceed.

   Before exporting state via the following command, the `mtd` binary must be stopped:

   ```bash
   $ mtd export --for-zero-height --height=3343200 > mt_genesis_export.json
   ```

3. Verify the SHA256 of the (sorted) exported genesis file:

   ```bash
   $ jq -S -c -M '' mt_genesis_export.json | shasum -a 256
   [PLACEHOLDER]  mt_genesis_export.json
   ```
   
4. Verify you are still running the correct version (v1.0.0) of Microtick:

   ```bash
   $ mtd version --long
   name: Microtick
   server_name: mtd
   client_name: mtcli
   version: v1.0.0
   commit: 13c5059c68a7322fa6da41d6031ebc8d3f9f575b
   ```

5. Migrate exported state:

   ```bash
   $ ./microtick-1-migration mt_genesis_export.json > new_genesis.json
   ```
   
6. Verify the SHA256 of the final genesis JSON:

   ```bash
   $ jq -S -c -M '' new_genesis.json | shasum -a 256
   [PLACEHOLDER]  new_genesis.json
   ```

7. Copy the new genesis into place (if and only if the checksum you get matches the consensus)

   ```bash
   $ cp new_genesis.json $MTROOT/mtd/config/genesis.json
   ```

8. Reset state:

   **NOTE**: Be sure you have a complete backed up state of your node before proceeding with this step.
   See [Recovery](#recovery) for details on how to proceed.

   ```bash
   $ mtd unsafe-reset-all
   ```

