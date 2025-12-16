#!/bin/bash

set -euo pipefail

namespace="$("$TG_CTX_TF_PATH" output -raw token_reviewer_service_account_namespace)"
name="$("$TG_CTX_TF_PATH" output -raw token_reviewer_service_account_name)"
one_year="8760h"

token_reviewer_jwt="$(kubectl create token --duration="$one_year" -n "$namespace" "$name")"

kube_ca="$(kubectl config view --minify --flatten -ojson \
  | jq -r '.clusters[0].cluster."certificate-authority-data"' \
  | base64 -d)"

vault_auth_backend_path="$("$TG_CTX_TF_PATH" output -raw vault_auth_backend_path)"
kubernetes_host="$(kubectl config view --minify --flatten -ojson \
  | jq -r '.clusters[0].cluster.server')"

vault write auth/"$vault_auth_backend_path"/config \
   token_reviewer_jwt="$token_reviewer_jwt" \
   kubernetes_host="$kubernetes_host" \
   kubernetes_ca_cert="$kube_ca"
