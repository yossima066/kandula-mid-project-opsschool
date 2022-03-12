#!/bin/bash
# sudo apt-get update -y
# sudo apt-get install docker git java-1.8.0 -y
# sudo service docker start
# sudo usermod -aG docker ec2-user

# sudo apt-get -y install java-1.8.0-openjdk git


sudo apt-get install wget apt-transport-https gnupg lsb-release
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -
echo deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main | sudo tee -a /etc/apt/sources.list.d/trivy.list
sudo apt-get update
sudo apt-get install trivy