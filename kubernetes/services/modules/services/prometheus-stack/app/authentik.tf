resource "authentik_group" "prometheus" {
  name = "Prometheus"
}

resource "authentik_group" "alertmanager" {
  name = "Alertmanager"
}

resource "authentik_group" "grafana_admins" {
  name = "Grafana Admins"
}

resource "authentik_group" "grafana_editors" {
  name = "Grafana Editors"
}

resource "authentik_group" "grafana_viewers" {
  name = "Grafana Viewers"
}
