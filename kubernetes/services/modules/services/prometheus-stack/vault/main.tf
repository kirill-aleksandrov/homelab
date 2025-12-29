resource "vault_mount" "prometheus" {
  path = "prometheus"
  type = "kv-v2"
  options = {
    version = "2"
  }
}

resource "vault_mount" "alertmanager" {
  path = "alertmanager"
  type = "kv-v2"
  options = {
    version = "2"
  }
}

resource "vault_mount" "grafana" {
  path = "grafana"
  type = "kv-v2"
  options = {
    version = "2"
  }
}
