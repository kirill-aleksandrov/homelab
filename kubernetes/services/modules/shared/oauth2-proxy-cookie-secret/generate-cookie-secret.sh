#!/bin/bash

set -euo pipefail

mount=$TF_VAR_vault_mount_path
secret_name="$("$TG_CTX_TF_PATH" output -raw vault_cookie_secret_secret_name)"

echo "Getting current secret version..."
current_version="$(vault kv metadata get -mount="$mount" -format=json "$secret_name" \
    | jq -r '.data.current_version')"

if [ "$current_version" -ne 1 ]; then
    echo "No action required"
    exit 0
fi

echo "Generating the cookie secret..."
set +o pipefail
cookie_secret="$(LC_ALL=C tr -dc 'A-Za-z0-9!@#$%^&*(\-_=+)' </dev/urandom | head -c 32)"
set -o pipefail

echo "Writing cookie secret to vault..."
vault kv put -mount="$mount" "$secret_name" cookie-secret="$cookie_secret" > /dev/null

echo "Done"
