nrjcoin.tools
=============

nrjcoin toolset for automation nrjcoin server

```shell
usage: nrjtool -asUubir
-a: all
-s: setup nrjcoin user
-U: install/update system and dependencies
-u: install/update nrjcoin src
-b: build nrjcoind
-i: install nrjcoind
-r: start/restart nrjcoind
-t: start/restart nrjcoind in testnet
example: "nrjtool -a" to setup a fresh machine
example: "nrjtool -ubir" to fetch src, build and install nrjcoind
```

change config files! 

_DO_NOT_USE_THIS_CONFIG_OR_YOU_WILL_GET_ROBBED_

```ini
testnet=0
rpcuser=%user%
rpcpassword=%password%
rpcport=10332
server=1
listen=1
daemon=1
gen=1
rpcallowip=127.0.0.1
```


