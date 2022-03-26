# Freedive

Web-UI to configure and manage FreeBSD hosts.

- Mobile-first UI
- Manage workstations 
  - Laptops
  - Desktops
- Manage servers
  - Baremetal / hardware
  - Virtual Machines / VPS / cloud instances

Freedive is a wrapper around utilities included in the base system and third-party packages.
It sets up FreeBSD as an appliance and may modify/replace configuration.
Prefer to install Freedive on a new FreeBSD system that has not been configured manually.

Freedive expects:

- ZFS root pool
- FreeBSD 13.0-RELEASE 
- A new install to configure as an appliance

As of v0.1.0, Freedive supports:

- Boot Environments (`bectl`)
- Notifications ( https://pushover.net )

Roadmap:

- Time synchronisation (`openntpd`)
- Harden SSH, manage users, generate ssh config snippets (`sshd`)
- System update, auto-update (`freebsd-update`)
- Remote backups, restore/rollback (`restic`)
- Forward syslog to UI, filters and notificatios (`syslog-ng`)
- Firewall (`pf`)
- ZFS datasets (`zfs`)
- ZFS zpools (`zpool`)
- Network interfaces (`ifconfig`)
- Screen brightness on Thinkpad X280 (and more) laptops (`intel_backlight`)
- SMART status
- Battery status
- devd events
- Run shell scripts on any Freedive event/status
- FreeBSD Jails (`jail`)
  - Full / clone jails
  - Packages: search, install, remove, lock, update, auto-update (`pkg`)
  - VNET, DHCP, IPv4, IPv6, DNS, NAT for jail networking
  - Mount paths from host into jails
  - Forward syslog to host
  - Backup/restore via restic
  - Automatic system updates
  - Pin, edit configuration/text files
  - Web terminal
  - SSH bastion on host

There is no ETA on any future feature.

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
