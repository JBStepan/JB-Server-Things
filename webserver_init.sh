#!/usr/bin/env bash

# Init bash script for Ubuntu 22.04
# For JB Stepan uses
# Version 1.0.0

BLUE='\033[0;34m'
NC='\033[0m' # No Color

printf "${BLUE} [!] Creating user account...${NC}\n"
# This  handles the user account creation
useradd -m -U -s /bin/bash -G sudo admin
passwd admin

printf "${BLUE} [!] Updating system${NC}\n"
# This will update and upgrade the system packages
sudo apt update && apt upgrade -y

printf "${BLUE} [!] Installing packages...${NC}\n"
pkgs=(python3 python3-pip fail2ban ufw nginx)
sudo apt-get -y --ignore-missing install "${pkgs[@]}" 

printf "${BLUE} [!]Enabling firewall...${NC}\n"
# Add more rules in the future
sudo ufw allow openssh
sudo ufw allow http
sudo ufw allow https
sudo ufw enable

printf "${BLUE} [!] Configuring SSH.${NC}\n"
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

jbskey="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC7xo/5Ig9j+5yv+RriZjBwbSTAguOemmMmbi0Xa6tulWd6+J0+yFpeZmyMszwI+jEazFsF1YWm1X7QKpvEIGR0wUxk0eGC+DacWRbDjLq9pVUnDWMwMG4DBu/s6TgYYzbPTkIKoQM1+OBhLTJLeeW9fbw+Y1XSbfHTQlC1+XHxwbh+M6Ilb+GqQLagpBTr1adi9dWrLx8sMcg7ERw9msCg1iLloiVq70cBSV2sxzCPmxUCyyS+PmufDY9Dhw8hLW52q+EBCkOdJbU83w1HOuSpTnX7VrgjlcwC/XnMkfxBvFqqAQ1RyBk+0WhLtbswsVabIymW1hrcTTYpWrgMuXKl jbstepan@jbstepan.com"

mkdir /home/admin/.ssh

touch /home/admin/.ssh/authorized_keys

echo $jbskey > /home/admin/.ssh/authorized_keys

sshd -t
sudo systemctl restart sshd

printf "$${BLUE} [!] Script finished.${NC}\n"
