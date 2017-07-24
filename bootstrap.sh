set -e

# Cert subj parameters
COUNTRY="US"
STATE="Hawaii"
ORG="Internet Widgits Pty Ltd"
CN="example.org"
EMAIL="john.doe@example.org"
SUBJ_BASE="/C=${COUNTRY}/ST=${STATE}/O=${ORG}/emailAddress=${EMAIL}"

# Consul parameters
CONSUL_DC="dc1"
CONSUL_DOMAIN="consul"

# Create the -subj arg for each cert
CA_SUBJ="/CN=${CN}${SUBJ_BASE}"
SERVER_SUBJ="/CN=server.${CONSUL_DC}.${CONSUL_DOMAIN}${SUBJ_BASE}"
AGENT_SUBJ="/CN=agent.${CONSUL_DC}.${CONSUL_DOMAIN}${SUBJ_BASE}"

# Create the directories/files needed for the CA
mkdir -p files
mkdir -p state
echo "000a" > state/serial
touch state/certindex

# Generate a CA key and certificate
openssl genrsa -out files/ca.key 4096
openssl req -x509 -new -nodes -key files/ca.key -subj "$CA_SUBJ" -days 3650 -out files/ca.crt -sha256

# Generate keys and certificates for Consul servers
openssl genrsa -out files/server.key 4096
openssl req -new -key files/server.key -subj "$SERVER_SUBJ" -out files/server.csr -sha256
openssl ca -batch -config ca.conf -notext -in files/server.csr -out files/server.crt

# Generate keys and certificates for non-server Consul agents
openssl genrsa -out files/agent.key 4096
openssl req -new -key files/agent.key -subj "$AGENT_SUBJ" -out files/agent.csr -sha256
openssl ca -batch -config ca.conf -notext -in files/agent.csr -out files/agent.crt

# Clean up csrs
rm files/*.csr