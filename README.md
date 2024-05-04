# Freedive

Dive into FreeBSD.

> Status: Planning 

# Develop

Start Freedive server:

  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.


# Deploy

### Create package

```console
mix package.freebsd
```

### Install

```console
pkg install freedive-x.x.x.pkg
```

### Initialize

```console
service freedive enable
service freedive init
```

### Configure

```
vi /usr/local/etc/freedive/freedive.env
```

Modify `HOST`, `BIND` and `PORT` variables to taste.

### Start

```console
service freedive start
```

### Access

Visit [`https://localhost:6443`](https://localhost:6443) 
from your browser from same machine, 
or `https://<HOST>:<PORT>` from remote machine.
