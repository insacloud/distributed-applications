#!/bin/bash
REPO_ROOT="/vagrant"
USER="vagrant"

# Update
apt-get update -y
# apt-get upgrade -y
# Install required packages
apt-get install python-pip python-dev git -y
pip install -Iv ansible==1.9.3
# set permissions
for i in `find . -type f \( -name "hosts" \)`; do    sed -i 's/\r//' $i && chmod +x $i ; done
chown vagrant:vagrant /home/vagrant/.ssh/id_rsa && chmod 600 /home/vagrant/.ssh/id_rsa

# ssh key
mkdir -p /root/.ssh/
su $USER <<EOF
ssh-keygen -y -f ~/.ssh/id_rsa > ~/.ssh/id_rsa.pub
EOF
cat "/home/$USER/.ssh/id_rsa.pub" | tee -a /root/.ssh/authorized_keys
su $USER <<EOF
ssh-keyscan localhost > ~/.ssh/known_hosts
EOF

# Command to deploy
for d in $REPO_ROOT/inventories/*
do
    target=`basename $d`
    read -r -d '' DEPLOY <<EOF
#!/bin/bash
cd "$REPO_ROOT" && ansible-galaxy install -f -r requirements.yml | echo yes && ansible-playbook -i "$REPO_ROOT/inventories/$target" site.yml
EOF
    echo "$DEPLOY" | tee "/usr/local/bin/deploy_$target" > /dev/null
    chmod +x "/usr/local/bin/deploy_$target"
done

su $USER <<EOF
deploy_vagrant
EOF