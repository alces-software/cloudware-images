#!/bin/bash

#
# Runs openflight ansible playbook on self as a compute node
#

# Install prereqs
yum -y install epel-release
yum -y install ansible git 

# Run playbook
git clone https://github.com/openflighthpc/openflight-ansible-playbook /tmp/playbook

cat << EOF > /tmp/ansibleinv
[nodes]
localhost    ansible_connection=local
EOF

cd /tmp/playbook
echo "  ignore_errors: True" >> openflight.yml
ansible-playbook -i /tmp/ansibleinv --extra-vars "cluster_name=placeholder munge_key=ReplaceMe compute_nodes=cnode01" openflight.yml

# Remove ansible 
rm -rf /tmp/ansibleinv /tmp/playbook
