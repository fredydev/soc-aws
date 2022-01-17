variable "aws_region" {
  description = "AWS region"
  default     = "eu-west-3"
}

variable "profile_member_account" {
  description = "AWS member account profile"
  type        = string
  default     = "cagip-cyb-dev/SysAdmin" # get the account name from account_configuratio tfvars to do it 
}

variable "azure_sentinel_api" {
  description = "Azure Sentinel api where are sent securityhub event catch by eventBridge"
  type        = string
  default     = "https://${var.azure_workspace_id}.ods.opinsights.azure.com/api/logs"
}

#ToDo: that vars are retrieved from account_configuration .tfvars
variable "entity" {
  description = "Retrieved from account_configuration .tfvars name of the entity"
  type        = string

}

variable "account_type" {
  description = "Retrieved from account_configuration .tfvars 'account type': either prd or hprd"
  type        = string

}

variable "aws_account_alias_requested" {
  description = "Retrieved from account_configuration .tfvars"
  type        = string
}

variable "member_email_contact" {
  description = "Retrieved from account_configuration .tfvars"
  type        = string
}

variable "azure_workspace_id" {
  description = "Azure  workspace  id"
  type        = string
  sensitive   = true
}

variable "environment" {
  description = "env where the infrastructure will be deployed"
  type        = string
}

variable "azure_workspace_key" {
  description = "Azure workspace key"
  type        = string
  sensitive   = true
}

variable "azure_workspace_logtype" {
  description = "Azure workspace log type"
  type        = string
  sensitive   = true
}
