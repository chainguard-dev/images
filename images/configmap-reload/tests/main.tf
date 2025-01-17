terraform {
  required_providers {
    oci  = { source = "chainguard-dev/oci" }
    helm = { source = "hashicorp/helm" }
  }
}

variable "digest" {
  description = "The image digest to run tests over."
}

data "oci_string" "ref" { input = var.digest }

data "oci_exec_test" "version" {
  digest = var.digest
  script = "docker run --rm $IMAGE_NAME -h"
}

resource "helm_release" "dex" {
  name = "configmap-reload"

  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "alertmanager"

  values = [jsonencode({
    configmapReload = {
      image = {
        tag        = data.oci_string.ref.pseudo_tag
        repository = data.oci_string.ref.registry_repo
      }
      enabled = true
    }
  })]
}
