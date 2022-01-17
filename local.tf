locals {
  project = "connexion-soc"
  name    = "${local.project}-${var.environment}"
  tags = {
    Name    = local.name
    Owner   = "cagip_cyb_squad_native@ca-gip.fr"
    Entity  = "CA-GIP"
    Product = local.project
  }
}
