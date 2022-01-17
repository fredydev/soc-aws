#########################
#        Tags
#########################

module "tagging" {
  source = "git::https://scm.saas.cagip.group.gca/hybridation/terraform/aws/modules/terraform-aws-tags.git"

  #Prefix tag
  aws_env        = var.account_type    # Use a trigram for Environment.
  aws_appli_name = "Infra"  # Infra for LandingZone purpose. Use Product|Bu abbreviation for other usages.

  #Resource tag
  environment = var.aws_account_alias_requested
  product     = split("-",var.aws_account_alias_requested)[1] #ToDO: aws_account_alias_requested = "caas-basedoc-hprd" => prendre que la valeur entre les 2 '-'
  entity      = var.entity
  owner       = var.member_email_contact
  bu          = "NDC"
  component   = "soc_connector"
  origin      = "Terraform"
  aws_region  = var.aws_region
  cagipadmin  = "Admin"
  managed     = "CYB"
}
