#!/bin/sh

# Create scripts directory if it doesn't exist
[ ! -d "/home/ec2-user/scripts" ] && /usr/bin/mkdir /home/ec2-user/scripts
/usr/bin/cd /home/ec2-user/scripts/

# Download our scripts from GitHub
/usr/bin/wget -q https://raw.githubusercontent.com/sjbader/terraform_deploy_k8s_ec2/master/scripts/generate_ansible_inventory_file.py
/usr/bin/wget -q https://raw.githubusercontent.com/sjbader/terraform_deploy_k8s_ec2/master/scripts/generate_hosts_file.py

# Run our scripts
/usr/bin/python3 /home/ec2-user/scripts/generate_ansible_inventory_file.py
/usr/bin/python3 /home/ec2-user/scripts/generate_hosts_file.py

# Copy hosts file, otherwise Ansible inventory doesn't resolve hosts
/usr/bin/cp /home/ec2-user/scripts/output/hosts.txt /etc/hosts

# Install Ansible
/usr/bin/amazon-linux-extras enable ansible2
/usr/bin/yum clean metadata
/usr/bin/yum install ansible -y

