#!/bin/bash

set -euo pipefail

echo "Getting current secret version..."
current_version="$(vault kv metadata get -mount=authentik -format=json secret-key \
    | jq -r '.data.current_version')"

if [ "$current_version" -ne 1 ]; then
    echo "No action required"
    exit 0
fi

echo "Generating and writing the secret key..."
set +o pipefail
secret_key="$(LC_ALL=C tr -dc 'A-Za-z0-9!@#$%^&*(\-_=+)' </dev/urandom | head -c 50)"
set -o pipefail
mount="$("$TG_CTX_TF_PATH" output -raw vault_secret_key_mount_path)"
vault kv put -mount="$mount" secret-key secret-key="$secret_key" > /dev/null

echo "Done"
