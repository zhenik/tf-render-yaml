module "yaml-render" {
# https://www.terraform.io/language/modules/sources#modules-in-package-sub-directories
#  source = "git@github.com:zhenik/tf-render-yaml.git//terraform-template-vector-config?ref=0.2.0"
  source = "git@github.com:zhenik/tf-render-yaml.git//terraform-template-vector-config?ref=0.1.0"

  helm_conf = {
    aadpodidbinding = "wwwaaaaat"
  }
}

#output "rendered_helm_config" {
#  value = module.yaml-render.rendered
#}

