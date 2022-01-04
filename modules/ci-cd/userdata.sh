#!/bin/bash
sudo apt-get update -y
sudo apt-get install docker git java-1.8.0 -y
sudo service docker start
sudo usermod -aG docker ec2-user

sudo apt-get -y install java-1.8.0-openjdk git
