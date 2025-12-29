#!/bin/bash

set -euo pipefail

authentik_url=$TF_VAR_authentik_url
authentik_token=$TF_VAR_authentik_token
name=$TF_VAR_name
mount=$TF_VAR_vault_mount_path
secret_name="$("$TG_CTX_TF_PATH" output -raw vault_client_secret_secret_name)"
provider_id="$("$TG_CTX_TF_PATH" output -raw authentik_provider_id)"

echo "Getting current secret version..."
current_version="$(vault kv metadata get -mount="$mount" -format=json "$secret_name" \
    | jq -r '.data.current_version')"

if [ "$current_version" -ne 1 ]; then
    echo "No action required"
    exit 0
fi

echo "Generating the secret key..."
set +o pipefail
client_secret="$(LC_ALL=C tr -dc 'A-Za-z0-9!@#$%^&*(\-_=+)' </dev/urandom | head -c 50)"
set -o pipefail

echo "Updating oauth2 provider client secret..."
curl -o /dev/null -s -f -L -X PATCH "${authentik_url}/api/v3/providers/oauth2/${provider_id}/" \
    -H 'Content-Type: application/json' \
    -H 'Accept: application/json' \
    -H "Authorization: Bearer ${authentik_token}" \
    -d "{
        \"client_secret\": \"${client_secret}\"
    }"

echo "Writing client secret to vault..."
vault kv patch -mount="$mount" "$secret_name" client-secret="$client_secret" > /dev/null

echo "Done"
