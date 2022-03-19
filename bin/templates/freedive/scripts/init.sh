#!/bin/sh

# generate keys for tls 
# generate and inject phoenix secret key in freedive.toml
# setup postgres
# generate auth token to register new user
# setup whatever else is needed

mkdir -p /var/db/freedive
if [ -f /var/db/freedive/tls.key ] ; then
  echo "[ok] TLS keys for https endpoint"
else
  echo "[create] TLS keys for https endpoint"
  cat > /var/db/freedive/request.txt <<INNER_EOF
[req]
default_bits = 4096
default_md = sha256
distinguished_name = req_distinguished_name
x509_extensions = v3_req
prompt = no
[req_distinguished_name]
C = NA
ST = NA
L = NA
O = NA
OU = NA
CN = freedive.local
[v3_req]
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names
[alt_names]
DNS.1 = freedive.local
DNS.2 = localhost
IP.1 = 127.0.0.1
INNER_EOF
  openssl req -new -nodes -x509 -days 36500 -newkey rsa:2048 -keyout /var/db/freedive/tls.key -out /var/db/freedive/tls.crt -config /var/db/freedive/request.txt 
fi

if [ -f /var/db/etc/freedive.toml ] ; then
  echo "[ok] Config: /usr/local/etc/freedive.toml"
else
  echo "[create] Config: /usr/local/etc/freedive.toml"
  echo "[create] Secret-key for web server"
  SECRET_KEY="$( openssl rand -base64 128 | strings | grep -o '[[:alnum:]]' | head -n 64 | tr -d '\n'; echo )"
  cp /usr/local/etc/freedive.toml.sample /usr/local/etc/freedive.toml
  sed -i '' -e "s/CHANGE-ME/${SECRET_KEY}/g" /usr/local/etc/freedive.toml
  chown root:wheel /usr/local/etc/freedive.toml
  chmod 600 /usr/local/etc/freedive.toml
fi
