#!/bin/sh

# Generate Certificate for main authority, master-key, configure environment
# It will approve certificates of other participants (services)
DESTINATION=./ssl
CANAME=ca
WORKDIR=$DESTINATION/$CANAME
mkdir -p $WORKDIR
openssl genpkey -algorithm ed25519 -out $WORKDIR/$CANAME.key
openssl req -x509 -new -nodes -key $WORKDIR/$CANAME.key -days 1826 -out $WORKDIR/$CANAME.crt -subj '/C=UA/ST=Kyiv/L=Kyiv/O=Goit/OU=IT/CN=Test CA Cert' -addext "subjectAltName = DNS:localhost"

# YOUR APPS KEYS
SERVICE=acra-client
WORKDIR=$DESTINATION/$SERVICE
mkdir -p $WORKDIR
openssl genpkey -algorithm ed25519 -out $WORKDIR/$SERVICE.key
openssl req -new -nodes -key $WORKDIR/$SERVICE.key -out $WORKDIR/$SERVICE.csr -subj "/C=UA/ST=Kyiv/L=Kyiv/O=Goit/OU=IT/CN=Test Node Cert ($SERVICE)"
cat > $WORKDIR/$SERVICE.v3.ext << EOF
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment
subjectAltName = @alt_names

[alt_names]
DNS.1 = localhost
DNS.2 = $SERVICE
EOF
openssl x509 -req -in $WORKDIR/$SERVICE.csr -CA $DESTINATION/$CANAME/$CANAME.crt -CAkey $DESTINATION/$CANAME/$CANAME.key -CAcreateserial -out $WORKDIR/$SERVICE.crt -days 730 -extfile $WORKDIR/$SERVICE.v3.ext

# Server's certs
SERVICE=acra-server
WORKDIR=$DESTINATION/$SERVICE
mkdir -p $WORKDIR
openssl genpkey -algorithm ed25519 -out $WORKDIR/$SERVICE.key
openssl req -new -nodes -key $WORKDIR/$SERVICE.key -out $WORKDIR/$SERVICE.crt -subj "/C=UA/ST=Kyiv/L=Kyiv/O=Goit/OU=IT/CN=Test Node Cert ($SERVICE)"
cat > $WORKDIR/$SERVICE.v3.ext << EOF
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment
subjectAltName = @alt_names
authorityInfoAccess = OCSP;URI:http://127.0.0.1:8888
crlDistributionPoints=crldp1_section

[crldp1_section]
fullname=URI:http://127.0.0.1:8889/crl.pem

[alt_names]
DNS.1 = localhost
DNS.2 = $SERVICE
EOF
openssl x509 -req -in $WORKDIR/$SERVICE.crt -CA $DESTINATION/$CANAME/$CANAME.crt -CAkey $DESTINATION/$CANAME/$CANAME.key -CAcreateserial -out $WORKDIR/$SERVICE.crt -days 730 -extfile $WORKDIR/$SERVICE.v3.ext

# MySql certificates
SERVICE=mysql
WORKDIR=$DESTINATION/$SERVICE
mkdir -p $WORKDIR
openssl genpkey -algorithm ed25519 -out $WORKDIR/$SERVICE.key
openssl req -new -nodes -key $WORKDIR/$SERVICE.key -out $WORKDIR/$SERVICE.csr -subj "/C=UA/ST=Kyiv/L=Kyiv/O=Goit/OU=IT/CN=Test Node Cert ($SERVICE)"
cat > $WORKDIR/$SERVICE.v3.ext << EOF
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment
subjectAltName = @alt_names

[alt_names]
DNS.1 = localhost
DNS.2 = $SERVICE
EOF
openssl x509 -req -in $WORKDIR/$SERVICE.csr -CA $DESTINATION/$CANAME/$CANAME.crt -CAkey $DESTINATION/$CANAME/$CANAME.key -CAcreateserial -out $WORKDIR/$SERVICE.crt -days 730 -extfile $WORKDIR/$SERVICE.v3.ext

ACRA_DOCKER_IMAGE_TAG=0.95.0
docker run --rm -v $DESTINATION:/keys/  cossacklabs/acra-keymaker:${ACRA_DOCKER_IMAGE_TAG} --keystore=v1 --generate_master_key=/keys/master.key
sudo chown $(whoami) $DESTINATION/master.key
ACRA_MASTER_KEY=$(cat $DESTINATION/master.key | base64)
cp ./auxiliary/env.template ./.env
sed -i "s|^ACRA_SERVER_MASTER_KEY=.*|ACRA_SERVER_MASTER_KEY=${ACRA_MASTER_KEY}|" "./.env"
