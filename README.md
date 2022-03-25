# Freedive

Web-UI to configure and manage FreeBSD workstations and servers on amd64 as well as arm64.
Use Freedive to manage FreeBSD hosts from the comfort of your browser.
No scripts or YAML configuration involved.

As of v0.1.0, Freedive supports:

- Boot Environments

## Try

Download latest package from https://github.com/hiway/freedive/releases/

Install:

```console
pkg install freedive-VERSION.pkg
```

Initialize, migrate and create user:

```console
service freedive enable
service freedive init
service freedive migrate

service freedive create_user
Email: address@example.com
Password: passphrase-or-long-random-string

service freedive start
```

If you installed on your workstation: https://localhost:8443/

To access Freedive via ssh, open ssh tunnel:

```console
ssh -L 8443:localhost:8443 user@hostname
```

Then access at: https://localhost:8443/

To access via VPN, update the `host` and `bind` fields under https section of `/usr/local/etc/freedive.toml`.

```toml
[https]
host = "hostname.private"
bind = "10.0.0.1"
```

After updating the configuration, restart the service.

```console
service freedive restart
```

Now you can visit https://hostname.private:8443/ to access Freedive.

## Develop

  * Setup your dev environment with `sh bin/dev-init.sh`
  * Start Freedive with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit http://localhost:4000 from your browser.
