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

data "template_file" "helm_config" {
  template = file("${path.module}/resource/helm.yaml")
  vars     = {
    aadpodidbinding = var.helm_conf.aadpodidbinding
    requests_cpu    = var.helm_conf_resource.requests.cpu
    requests_memory = var.helm_conf_resource.requests.memory

    limits_cpu    = var.helm_conf_resource.limits.cpu
    limits_memory = var.helm_conf_resource.limits.memory

  }
}

data "template_file" "vector_config" {
  template = file("${path.module}/resource/vector-config.yaml")
  vars     = {
    data_dir = "/tmp"
  }
}

#resource "null_resource" "local" {
#  triggers = {
#    template = data.template_file.vector_config.rendered
#  }
#
#  # Render to local file on machine
#  # https://github.com/hashicorp/terraform/issues/8090#issuecomment-291823613
#  provisioner "local-exec" {
#    command = format(
#      "cat <<\"EOF\" > \"%s\"\n%s\nEOF",
#      "vector-config_rendered.yaml",
#      data.template_file.vector_config.rendered
#    )
#  }
#}

resource "local_file" "vector_config_rendered" {
  content = data.template_file.vector_config.rendered
  filename = "vector-config_rendered.yaml"
}

resource "null_resource" "run" {
  triggers = {
    file = data.template_file.vector_config.rendered
  }

  provisioner "local-exec" {
    command = "vector validate --config-yaml ${local_file.vector_config_rendered.filename} && vector test --config-yaml ${local_file.vector_config_rendered.filename}"
  }
}

resource "local_file" "helm_config_rendered" {
  content = <<-EOT
${data.template_file.helm_config.rendered}
  ${indent(2,data.template_file.vector_config.rendered)})
EOT
  filename = "helm-config_rendered.yaml"
}
