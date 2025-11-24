resource "kubernetes_manifest" "postgres" {
  manifest = {
    "apiVersion" = "postgresql.cnpg.io/v1"
    "kind"       = "Cluster"
    "metadata" = {
      "name"      = "postgres"
      "namespace" = kubernetes_namespace.authentik.metadata[0].name
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
