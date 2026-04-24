module "label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  namespace = "lab"
  stage     = "dev"
  name      = "fitness"
}