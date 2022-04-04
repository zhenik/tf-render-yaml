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


#output "rendered" {
#  value = data.template_file.helm_config.rendered
#}
