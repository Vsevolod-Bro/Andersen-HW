variable "aws_access_key" {}

variable "aws_secret_key" {}

variable "aws_key_name" {}

variable "DB_pass" {}

variable "region" {}

variable "pref" {
  default = "and02"
}

variable "cidr_main" {
  default = "172.16.0.0/16"
}

#--- Public Subnets
variable "cidr_pub_A" {
  description = "Public Subnet AZ-A"
  default     = "172.16.100.0/24"
}
variable "cidr_pub_B" {
  description = "Public Subnet AZ-B"
  default     = "172.16.101.0/24"
}

#--- Private Web Subnets
variable "cidr_pr_A" {
  description = "Private Subnet AZ-A"
  default     = "172.16.200.0/24"
}
variable "cidr_pr_B" {
  description = "Private Subnet AZ-B"
  default     = "172.16.201.0/24"
}

#--- Private RDS Subnets
variable "cidr_pr_DB_A" {
  description = "Private DataBase Subnet AZ-A"
  default     = "172.16.210.0/24"
}
variable "cidr_pr_DB_B" {
  description = "Private DataBase Subnet AZ-B"
  default     = "172.16.211.0/24"
}
