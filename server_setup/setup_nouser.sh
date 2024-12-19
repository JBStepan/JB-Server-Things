#!/usr/bin/env bash

BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Put the name of your already existing non root user
username=""
firewall_enable=false

printf "${BLUE} [!] Updating system ⬆️...${NC}\n"
# This will update and upgrade the system packages
apt update && apt upgrade -y

printf "${BLUE} [!] Installing packages 📦...${NC}\n"
pkgs=(fail2ban ufw git curl)
apt-get -y --ignore-missing install "${pkgs[@]}" 

# Add Docker's official GPG key:
printf "${BLUE} [!] Installing Docker 🐳...${NC}\n"
apt-get update
apt-get install ca-certificates curl -y
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null
apt update

apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

printf "${BLUE} [!]Enabling firewall 🔥...${NC}\n"
# Add more rules in the future
sudo ufw allow ssh
sudo ufw enable

printf "${BLUE} [!] Configuring SSH 🐚...${NC}\n"
# Change someconfig in SSH
sed -i -e '/^\(#\|\)PermitRootLogin/s/^.*$/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i -e '/^\(#\|\)PasswordAuthentication/s/^.*$/PasswordAuthentication no/' /etc/ssh/sshd_config
sed -i -e '/^\(#\|\)KbdInteractiveAuthentication/s/^.*$/KbdInteractiveAuthentication no/' /etc/ssh/sshd_config
sed -i -e '/^\(#\|\)ChallengeResponseAuthentication/s/^.*$/ChallengeResponseAuthentication no/' /etc/ssh/sshd_config
sed -i -e '/^\(#\|\)MaxAuthTries/s/^.*$/MaxAuthTries 2/' /etc/ssh/sshd_config
sed -i -e '/^\(#\|\)AllowTcpForwarding/s/^.*$/AllowTcpForwarding no/' /etc/ssh/sshd_config
sed -i -e '/^\(#\|\)X11Forwarding/s/^.*$/X11Forwarding no/' /etc/ssh/sshd_config
sed -i -e '/^\(#\|\)AllowAgentForwarding/s/^.*$/AllowAgentForwarding no/' /etc/ssh/sshd_config
sed -i -e '/^\(#\|\)AuthorizedKeysFile/s/^.*$/AuthorizedKeysFile .ssh\/authorized_keys/' /etc/ssh/sshd_config

jbskey="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC7xo/5Ig9j+5yv+RriZjBwbSTAguOemmMmbi0Xa6tulWd6+J0+yFpeZmyMszwI+jEazFsF1YWm1X7QKpvEIGR0wUxk0eGC+DacWRbDjLq9pVUnDWMwMG4DBu/s6TgYYzbPTkIKoQM1+OBhLTJLeeW9fbw+Y1XSbfHTQlC1+XHxwbh+M6Ilb+GqQLagpBTr1adi9dWrLx8sMcg7ERw9msCg1iLloiVq70cBSV2sxzCPmxUCyyS+PmufDY9Dhw8hLW52q+EBCkOdJbU83w1HOuSpTnX7VrgjlcwC/XnMkfxBvFqqAQ1RyBk+0WhLtbswsVabIymW1hrcTTYpWrgMuXKl"

mkdir /home/$username/.ssh

touch /home/$username/.ssh/authorized_keys

echo $jbskey > /home/$username/.ssh/authorized_keys

sshd -t
sudo systemctl restart sshd

timedatectl set-timezone America/Chicago

printf "${BLUE} [!] Script finished ✅.${NC}\n"
