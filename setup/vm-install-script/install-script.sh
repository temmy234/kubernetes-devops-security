#!/bin/bash

set -e

echo "🔧 Starting DevOps setup on Azure VM (Ubuntu 18.04)..."

#######################################
# 1. Customize the terminal prompt
#######################################
echo "🎨 Customizing terminal prompt..."
cat <<'EOPROMPT' >> ~/.bashrc

# Custom colorful prompt
force_color_prompt=yes
PS1='\[\e[01;36m\]\u\[\e[01;37m\]@\[\e[01;33m\]\H\[\e[01;37m\]:\[\e[01;32m\]\w\[\e[01;37m\]\$\[\033[0;37m\] '
EOPROMPT
source ~/.bashrc

#######################################
# 2. System cleanup and update
#######################################
echo "🧹 Cleaning up and updating system..."
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get autoremove -y
sudo systemctl daemon-reexec

#######################################
# 3. Install Docker
#######################################
echo "🐳 Installing Docker..."
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) stable"

sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io
sudo usermod -aG docker $USER

#######################################
# 4. Install Maven
#######################################
echo "📦 Installing Maven..."
sudo apt-get install -y maven

#######################################
# 5. Install Kubernetes tools
#######################################
echo "☸️ Setting up Kubernetes repository..."
curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF

sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

echo "🚫 Disabling swap (required for Kubernetes)..."
sudo swapoff -a
sudo sed -i '/ swap / s/^/#/' /etc/fstab

#######################################
# 6. Install Jenkins
#######################################
echo "🧰 Installing Jenkins..."
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -
sudo sh -c 'echo deb https://pkg.jenkins.io/debian-stable binary/ > \
    /etc/apt/sources.list.d/jenkins.list'

sudo apt-get update
sudo apt-get install -y openjdk-11-jdk jenkins

sudo systemctl enable jenkins
sudo systemctl start jenkins

#######################################
# Done!
#######################################
echo "✅ DevOps setup complete!"
echo "🔐 Jenkins initial password:"
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
echo
echo "🌐 Access Jenkins at: http://<your-server-ip>:8080"
