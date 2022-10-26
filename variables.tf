variable "aws_region" {
  type = string
  default = ""
}

variable "lab_number" {
  type = string
  default = ""
}

variable "bastion_ami_id" {
  type = string
  default = ""
}

variable "bastion_instance_type" {
  type = string
  default = ""
}

variable "bastion_key_name" {
  type = string
  default = ""
}

variable "master_ami_id" {
  type = string
  default = ""
}

variable "master_instance_type" {
  type = string
  default = ""
}

variable "master_key_name" {
  type = string
  default = ""
}

variable "worker_ami_id" {
  type = string
  default = ""
}

variable "worker_instance_type" {
  type = string
  default = ""
}

variable "worker_key_name" {
  type = string
  default = ""
}

variable "availability_zone_names" {
  type    = list(string)
  default = [""]
}

variable "public_subnets" {
  type    = list(string)
  default = [""]
}

variable "private_subnets" {
  type    = list(string)
  default = [""]
}

variable "bastion_ingress_cidr" {
  type    = list(string)
  default = [""]
}

variable "ssh_key" {
  type = string
  default = ""
}