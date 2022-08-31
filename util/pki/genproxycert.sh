#!/bin/bash
set -e

PKI_PATH="$(dirname "$0")"
FILES_PATH="$PKI_PATH/files"
PROJECT_PATH="$PKI_PATH/../.."
TARGET_PATH="$PROJECT_PATH/docker/proxy/overlay/pki"

[[ ! -d "$FILES_PATH" ]] && mkdir -p "$FILES_PATH"

CRT_PEM_FILE="$FILES_PATH/proxy-crt.pem"
CSR_PEM_FILE="$FILES_PATH/proxy-csr.pem"
KEY_PEM_FILE="$FILES_PATH/proxy-key.pem"

# NOTE: Trusted certificates in iOS 13 and macOS 10.15 have special requirements.
# see https://support.apple.com/en-us/HT210176
VALIDITY_DAYS=735

function print_csr_config() {
  echo '[req]'
  echo 'distinguished_name = req_dn'
  # Fix issue on macOS: 'prompt = no' requires a non-empty distinguished_name section even though
  # command line argument -subj is used.
  echo 'prompt = yes'
  echo 'utf8 = yes'
  echo '[req_dn]'
}

function print_ext_config() {
  echo '[ext]'
  echo 'basicConstraints = CA:FALSE'
  echo 'subjectKeyIdentifier = hash'
  echo 'authorityKeyIdentifier = keyid, issuer'
  echo "keyUsage = digitalSignature, keyEncipherment, keyAgreement"
  echo "extendedKeyUsage = serverAuth"
  echo "subjectAltName = DNS:localhost, DNS:host.docker.internal, IP:127.0.0.1, IP:::1"
}

# Create key pair and certificate signing request
openssl req \
    -new \
    -newkey rsa:4096 \
    -sha256 \
    -subj "/CN=cas.local/O=OBJECT ECM/OU=Development/C=CH/ST=Zürich/L=Zürich" \
    -days "$VALIDITY_DAYS" \
    -nodes \
    -keyout "$KEY_PEM_FILE" \
    -keyform PEM \
    -out "$CSR_PEM_FILE" \
    -outform PEM \
    -config <(print_csr_config) \
    -batch \
    -verbose

# Create certificate:
openssl x509 \
    -req \
    -sha256 \
    -days "$VALIDITY_DAYS" \
    -extensions ext \
    -extfile <(print_ext_config) \
    -signkey "$KEY_PEM_FILE" \
    -in "$CSR_PEM_FILE" \
    -out "$CRT_PEM_FILE"

mkdir -p "$TARGET_PATH"
cp "$CRT_PEM_FILE" "$TARGET_PATH/"
cp "$KEY_PEM_FILE" "$TARGET_PATH/"