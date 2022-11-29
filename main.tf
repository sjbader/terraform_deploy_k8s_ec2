terraform {
  cloud {
    organization = "sjbader-test"

    workspaces {
      name = "terraform-deploy-k8s-ec2"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = var.aws_region
}

# This will create our VPC with 3 private and 3 public subnets (1 per AZ)
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "K8S-NATIVE-POD-${var.lab_number}"
  cidr = "10.0.0.0/16"

  azs                  = var.availability_zone_names
  private_subnets      = var.private_subnets
  public_subnets       = var.public_subnets
  enable_dns_hostnames = true
  enable_nat_gateway   = true
  single_nat_gateway   = true

  tags = {
    Terraform   = "true"
    Environment = "K8S-NATIVE-POD-${var.lab_number}"
  }

  igw_tags = {
    name = "test-igw"
  }
}

# Create our bastion host instance in first public subnet (AZ)
module "ec2_bastion_host" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 4.0"

  name = "K8S-NATIVE-POD-${var.lab_number}-BASTION"

  ami                    = var.bastion_ami_id
  instance_type          = var.bastion_instance_type
  key_name               = var.bastion_key_name
  monitoring             = true
  subnet_id              = module.vpc.public_subnets[0]
  vpc_security_group_ids = [module.bastion_sg.security_group_id]
  #user_data_base64       = "${var.master_base64_user_data}"
  #user_data               = data.template_file.user_data.rendered
  user_data_base64 = base64encode(templatefile("${path.module}/bastion_user_data.tmpl", {
    ssh_key         = var.ssh_key
    pod             = var.lab_number
    master_hostname = join(",", values(module.ec2_master_node).*.private_dns)
    master_ip       = join(",", values(module.ec2_master_node).*.private_ip)
    worker_hostname = join(",", values(module.ec2_worker_node).*.private_dns)
    worker_ip       = join(",", values(module.ec2_worker_node).*.private_ip)
  }))
  user_data_replace_on_change = true
  tags = {
    Terraform   = "true"
    Environment = "K8S-NATIVE-POD-${var.lab_number}"
  }
}

# Create our master node instances in private subnets (AZ)
module "ec2_master_node" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 4.0"

  for_each = toset(["1"])

  name = "K8S-NATIVE-POD-${var.lab_number}-MASTER-${each.key}"

  ami                    = var.master_ami_id
  instance_type          = var.master_instance_type
  key_name               = var.master_key_name
  monitoring             = true
  subnet_id              = module.vpc.private_subnets["${each.key}" - 1]
  vpc_security_group_ids = [module.master_sg.security_group_id]
  #user_data_base64       = "${var.master_base64_user_data}"
  user_data_base64 = base64encode(templatefile("${path.module}/hostname.yaml", {
    fqdn = "pod${var.lab_number}-master${each.key}.local"
  }))
  user_data_replace_on_change = true
  source_dest_check           = false

  tags = {
    Terraform   = "true"
    Environment = "K8S-NATIVE-POD-${var.lab_number}"
  }
}

# Create our worker node instances in private subnets (AZ)
module "ec2_worker_node" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 4.0"

  for_each = toset(["1", "2"])

  name = "K8S-NATIVE-POD-${var.lab_number}-WORKER-${each.key}"

  ami                    = var.worker_ami_id
  instance_type          = var.worker_instance_type
  key_name               = var.worker_key_name
  monitoring             = true
  subnet_id              = module.vpc.private_subnets["${each.key}" - 1]
  vpc_security_group_ids = [module.worker_sg.security_group_id]
  #user_data_base64       = "${var.worker_base64_user_data}"
  user_data_base64 = base64encode(templatefile("${path.module}/hostname.yaml", {
    fqdn = "pod${var.lab_number}-worker${each.key}.local"
  }))
  user_data_replace_on_change = true
  source_dest_check           = false

  tags = {
    Terraform   = "true"
    Environment = "K8S-NATIVE-POD-${var.lab_number}"
  }
}

# Create security group for Bastion host
module "bastion_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "K8S-NATIVE-POD-${var.lab_number}-BASTION-SG"
  description = "Security group for Bastion host"
  vpc_id      = module.vpc.vpc_id

  tags = {
    Terraform = "true"
  }

  ingress_cidr_blocks = var.bastion_ingress_cidr
  ingress_rules       = ["https-443-tcp", "ssh-tcp", "all-icmp"]
  egress_rules        = ["all-all"]
}

# Create security group for master hosts
module "master_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "K8S-NATIVE-POD-${var.lab_number}-MASTER-SG"
  description = "Security group for master hosts"
  vpc_id      = module.vpc.vpc_id

  tags = {
    Terraform = "true"
  }

  ingress_with_source_security_group_id = [
    {
      rule                     = "ssh-tcp"
      source_security_group_id = module.bastion_sg.security_group_id
    },
    {
      rule                     = "all-icmp"
      source_security_group_id = module.bastion_sg.security_group_id
    },
    {
      rule                     = "all-all"
      source_security_group_id = module.worker_sg.security_group_id
    }
  ]
  egress_rules = ["all-all"]
}

# Create security group for worker hosts
module "worker_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "K8S-NATIVE-POD-${var.lab_number}-WORKER-SG"
  description = "Security group for worker hosts"
  vpc_id      = module.vpc.vpc_id

  tags = {
    Terraform = "true"
  }

  ingress_cidr_blocks = ["10.0.0.0/16"]
  ingress_rules       = ["all-all"]
  egress_rules        = ["all-all"]
}
