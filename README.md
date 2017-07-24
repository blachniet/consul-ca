## Disclaimer

**I am not a security or TLS professional!** You should have your security team review this code before using its results in any production system.

## Overview

This project defines scripts and configurations that generate and sign certificates for [encrypting Consul RPC communications with TLS](https://www.consul.io/docs/agent/encryption.html). It also generates a Certificate Authority certificate and key which is used to sign the agent certificates.

## Usage

1. Update the cert subj parameters in bootstrap.sh
2. Update the Consul parameters in bootstrap.sh to reflect your Consul datacenter and domain names
3. Execute `./bootstrap.sh`. After the script completes, the `files/` directory contains certificates and keys for your certificate authority (`ca.[crt|key]`>), Consul server agent (`server.[crt|key]`), and non-server Consul agent (`agent.[crt|key]`).
4. Follow the instructions in [RPC Encryption with TLS](https://www.consul.io/docs/agent/encryption.html#rpc-encryption-with-tls) to use your new certificates

## Generate More Certificates

If you need to generate more agent certificates after running bootstrap.sh:

```bash
openssl genrsa -out files/mycert.key 4096
openssl req -new -key files/mycert.key -out files/mycert.csr -sha256
openssl ca -batch -config ca.conf -notext -in files/mycert.csr -out files/mycert.crt
```

*Remember to set the "Common Name" to `server.<datacenter>.<domain>` if you want to use the certificate on a Consul server agent in order to pass the [`verify_server_hostname`](https://www.consul.io/docs/agent/options.html#verify_server_hostname) test
.*

## Generate PKCS12

If you need to install your certificate and key in the Windows or Mac certificate store, you will need a [PCKS #12](https://en.wikipedia.org/wiki/PKCS_12) file. The example below creates a PCKS #12 file from the agent certificate and key.

```bash
openssl pkcs12 -export -out files/agent.p12 -inkey files/agent.key -in files/agent.crt
```

## Notes

- Consul server certs are generated with the "Common Name" set to `server.<datacenter>.<domain>` in order to pass the [`verify_server_hostname`](https://www.consul.io/docs/agent/options.html#verify_server_hostname) test
- RSA private keys are generated with 4096 bit long modulus
- Certs are created with a 10 year expiration date
- Certs are signed using SHA-256 hashing algorithm

## Resources

- @teeram - created the script that bootstrap.sh was based on and provided guidance 
- [Consul: Adding TLS to Consul using Self Signed Certificates]( http://russellsimpkins.blogspot.com/2015/10/consul-adding-tls-using-self-signed.html) - Russel Simpkins
- [OpenSSL Certificate Authority](https://jamielinux.com/docs/openssl-certificate-authority/create-the-root-pair.html) - Jamie Nguyen
- [How To Secure Consul with TLS Encryption on Ubuntu 14.04](https://www.digitalocean.com/community/tutorials/how-to-secure-consul-with-tls-encryption-on-ubuntu-14-04) - Justin Ellingwood
- [Gradually sunsetting SHA-1](https://security.googleblog.com/2014/09/gradually-sunsetting-sha-1.html)