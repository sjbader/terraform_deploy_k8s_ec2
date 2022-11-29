output "private_subnets_arns" {
  description = "ARN of private subnets created"
  value       = module.vpc.private_subnet_arns
}

output "public_subnets_arns" {
  description = "ARN of public subnets created"
  value       = module.vpc.public_subnet_arns
}

output "bastion_hostname" {
  description = "The (public) DNS hostname of the bastion host"
  value       = module.ec2_bastion_host.public_dns
}

output "bastion_ip" {
  description = "The (public) IP of the bastion host"
  value       = module.ec2_bastion_host.public_ip
}

output "master_hostname" {
  description = "The (private) DNS hostname of the master host"
  value       = values(module.ec2_master_node).*.private_dns
}

output "master_ip" {
  description = "The (private) IP of the master host"
  value       = values(module.ec2_master_node).*.private_ip
}

output "worker_hostname" {
  description = "The (private) DNS hostname of the worker host"
  value       = values(module.ec2_worker_node).*.private_dns
}

output "worker_ip" {
  description = "The (private) IP of the worker host"
  value       = values(module.ec2_worker_node).*.private_ip
}
