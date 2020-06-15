Steps for joining the RC6 testnet:

1. Download the release binaries from https://microtick.com/releases/testnet/

2. Extract the archive and verify MD5 checksums.

```
$ tar xf microtick-rc6-linux-x86_64.tar.gz
$ md5sum mtcli
1e7faf1e28d65be8041c3836074fee76  mtcli
$ md5sum mtd
6b07e5e9714a9c132ccf7f87e0caa0fc  mtd
```

3. Ensure the binaries 'mtd' and 'mtcli' are in your PATH

4. Choose a moniker and initialize the working directory:

```
$ mtd init <moniker>
```

5. Copy the genesis.json file in this directory to $HOME/.microtick/mtd/config

6. Edit $HOME/.microtick/mtd/config/config.toml. Change the persistent_peers line to:

```
persistent_peers = "922043cd83af759dd5a0605b32991667e8fd4977@45.79.207.112:26656"
```

7. Start your node

```
$ mtd start
```
