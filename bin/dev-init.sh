#!/bin/sh

if [ -f freedive.toml ] ; then
  echo "[ok] Config: freedive.toml"
else
    echo "[create] Config: freedive.toml"
    CWD="$( pwd | tr '/' '\/')"
    SECRET_KEY_BASE="$( openssl rand -hex 32 | tr -d '\n' )"
    cp "freedive.toml.sample" "freedive.toml"
    sed -i '' -e "s/CHANGE-ME/${SECRET_KEY_BASE}/g" "freedive.toml"
fi

if [ -f tls.key ] ; then
  echo "[ok] TLS keys for https endpoint"
else
  echo "[create] TLS keys for https endpoint"
  cat > request.txt <<EOF
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
CN = localhost
[v3_req]
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names
[alt_names]
DNS.1 = localhost
IP.1 = 127.0.0.1
EOF
  openssl req \
    -new -nodes -x509 -days 36500 -newkey rsa:2048 \
    -keyout tls.key -out tls.crt -config request.txt
fi

mix deps.get
mix ecto.setup
