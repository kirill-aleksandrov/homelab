resource "kubernetes_manifest" "postgres" {
  manifest = {
    "apiVersion" = "postgresql.cnpg.io/v1"
    "kind"       = "Cluster"
    "metadata" = {
      "name"      = "postgres"
      "namespace" = var.namespace
    }
    "spec" = {
      "bootstrap" = {
        "initdb" = {
          "database" = "authentik"
          "owner"    = "authentik"
        }
      }
      "instances" = 3
      "storage" = {
        "storageClass" = "topolvm-provisioner"
        "size"         = "1Gi"
      }
    }
  }
}
