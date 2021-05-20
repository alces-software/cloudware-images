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
[gateway]
localhost    ansible_connection=local
EOF

cd /tmp/playbook
echo "  ignore_errors: True" >> openflight.yml
ansible-playbook -i /tmp/ansibleinv --extra-vars "cluster_name=placeholder munge_key=ReplaceMe compute_nodes=cnode01" openflight.yml

# Preconfigure desktop environments
for i in chrome gnome kde terminal xfce xterm ; do 
    /opt/flight/bin/flight desktop prepare $i
done

# Preconfigure software envs
for i in conda easybuild gridware modules singularity spack ; do 
    /opt/flight/bin/flight env create $i
    /opt/flight/bin/flight env purge --yes $i
done

# Remove ansible 
rm -rf /tmp/ansibleinv /tmp/playbook
