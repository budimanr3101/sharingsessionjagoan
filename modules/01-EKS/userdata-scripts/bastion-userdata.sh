#!/bin/bash
yum -y remove awscli
yum -y install git telnet 

#Install Kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

#Kubectl Bash Auto-Completion
kubectl completion bash > /etc/bash_completion.d/kubectl

#Install Helm CLI
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh

#Helm CLI Bash Auto-completion
helm completion bash > /etc/bash_completion.d/helm

#Install AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install

#AWS CLI Auto-Completion
complete -C '/usr/local/bin/aws_completer' aws
