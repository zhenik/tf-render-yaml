variable "helm_conf" {
  type = object({
    aadpodidbinding = string
  })
  default = {
    aadpodidbinding = "management-managed-identity"
  }
}
variable "helm_conf_resource" {
  type = object({
    requests = object({
      cpu    = string
      memory = string
    })
    limits = object({
      cpu    = string
      memory = string
    })
  })
  default = {
    requests = {
      cpu    = "200m"
      memory = "64Mi"
    }
    limits = {
      cpu    = "200m"
      memory = "256Mi"
    }
  }
}

locals {
  pre_helm_config = templatefile("${path.module}/resource/helm.yaml",
    {
      aadpodidbinding = var.helm_conf.aadpodidbinding
      requests_cpu    = var.helm_conf_resource.requests.cpu
      requests_memory = var.helm_conf_resource.requests.memory

      limits_cpu    = var.helm_conf_resource.limits.cpu
      limits_memory = var.helm_conf_resource.limits.memory
    }
  )

  vector_config = file("${path.module}/resource/vector-config.yaml")
}

resource "local_file" "vector_config_rendered" {
  content = local.vector_config
  filename = "vector-config_rendered.yaml"
}

resource "null_resource" "run" {
  triggers = {
    file = local.vector_config
  }

  provisioner "local-exec" {
    #command = "vector validate --config-yaml ${local_file.vector_config_rendered.filename} && vector test --config-yaml ${local_file.vector_config_rendered.filename}"
    command = "vector test --config-yaml ${local_file.vector_config_rendered.filename}"
  }
}

resource "local_file" "helm_full_config_rendered" {
  content = <<-EOT
${local.pre_helm_config}
  ${indent(2,local.vector_config)}
EOT
  filename = "helm-full-config_rendered.yaml"
}
