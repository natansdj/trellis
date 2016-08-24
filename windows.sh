#!/bin/bash
#
# Windows provisioner for Trellis
# heavily modified and based on KSid/windows-vagrant-ansible
# @author Andrea Brandi
# @version 1.0

ANSIBLE_PATH="$(find /vagrant -name 'windows.sh' -printf '%h' -quit)"
export PYTHONUNBUFFERED=1

# Create an ssh key if not already created.
if [ ! -f ~/.ssh/id_rsa ]; then
  echo -e "\n\n\n" | ssh-keygen -t rsa
fi

# Check SSH forwarding agent
echo '
printf "\033[1;33m"
if ! ssh-add -l >/dev/null; then
    printf "See: https://roots.io/trellis/docs/windows/#ssh-forwarding"
fi
printf "\033[0m\n\n"
' >> /home/vagrant/.profile

# Check that add-apt-repository is installed for non-standard Vagrant boxes
if [ ! -f /usr/bin/add-apt-repository ]; then
  sudo apt-get -y update
  echo "Adding add-apt-repository..."
  sudo apt-get -y install software-properties-common
fi

# Install Ansible and its dependencies if not installed.
if [ ! -f /usr/bin/ansible ]; then
  echo "Installing pip..."
  sudo apt-get -y update
  sudo apt-get -y install python-pip
  echo "Installing Ansible with pip..."
  sudo pip install ansible=='2.0.2.0'
  sudo pip install markupsafe
fi

if [ ! -d ${ANSIBLE_PATH}/vendor ]; then
  echo "Running Ansible Galaxy install"
  ansible-galaxy install -r ${ANSIBLE_PATH}/requirements.yml -p ${ANSIBLE_PATH}/vendor/roles
fi

echo "Running Ansible Playbooks"
cd ${ANSIBLE_PATH}/
ansible-playbook dev.yml -e vagrant_version=$1

# Install NodeJS and its dependencies if not installed.
if [ ! -f /usr/bin/nodejs ]; then
  echo "Installing nodejs..."
  sudo apt-get -y install nodejs
  echo "Installing node..."
  sudo apt-get -y install node
fi

# Install NPM and its dependencies if not installed.
if [ ! -f /usr/bin/npm ]; then
  echo "Installing npm..."
  sudo apt-get -y install npm
  sudo npm install --silent -g -y bower gulp
  sudo npm install --silent -g rimraf
fi

# Install unison 2.48.3
if [ ! -f /usr/bin/unison ]; then
  echo "Installing unison"
  sudo apt-get install unison
  #curl -sL https://www.archlinux.org/packages/extra/x86_64/unison/download/unison-2.48.3-2-x86_64.pkg.tar.xz | tar Jx
fi
