module "yaml-render" {
  source = "git@github.com:zhenik/tf-render-yaml.git//terraform-template-vector-config?ref=0.1.0"

  helm_conf = {
    aadpodidbinding = "wwwaaaaat"
  }
}

