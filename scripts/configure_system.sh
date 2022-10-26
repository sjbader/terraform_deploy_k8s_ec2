#!/bin/sh

# Create scripts directory if it doesn't exist
[ ! -d "/home/ec2-user/scripts" ] && /usr/bin/mkdir /home/ec2-user/scripts

# Download our scripts from GitHub
/usr/bin/cd /home/ec2-user/scripts/
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

# Create ansible directory if it doesn't exist
[ ! -d "/home/ec2-user/ansible" ] && /usr/bin/mkdir /home/ec2-user/ansible

# Download Ansible playbooks
/usr/bin/cd /home/ec2-user/ansible/
/usr/bin/wget -q https://raw.githubusercontent.com/sjbader/terraform_deploy_k8s_ec2/master/ansible/update_ansible_config.yml
/usr/bin/wget -q https://raw.githubusercontent.com/sjbader/terraform_deploy_k8s_ec2/master/ansible/copy_hosts_file.yml
/usr/bin/wget -q https://raw.githubusercontent.com/sjbader/terraform_deploy_k8s_ec2/master/ansible/yum_update_all_hosts.yml

# Run the Ansible playbooks
/usr/bin/ansible-playbook -i /home/ec2-user/scripts/output/ansible_hosts.txt /home/ec2-user/ansible/update_ansible_config.yml
/usr/bin/ansible-playbook --private-key /home/ec2-user/keys/ssh_key.pem -i /home/ec2-user/scripts/output/ansible_hosts.txt /home/ec2-user/ansible/copy_hosts_file.yml
/usr/bin/ansible-playbook --private-key /home/ec2-user/keys/ssh_key.pem -i /home/ec2-user/scripts/output/ansible_hosts.txt /home/ec2-user/ansible/yum_update_all_hosts.yml

