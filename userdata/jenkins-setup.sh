#!/bin/bash
# 1. Update system package repository definitions
sudo apt-get update -y

# 2. Install Jenkins runtime core dependencies (Java 21 & Build Tools)
sudo apt-get install openjdk-21-jdk maven git -y

# 3. Pull down the updated, valid Jenkins GPG repository key
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key | sudo tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null
  
# 4. Add the official debian stable repository configuration 
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null

# 5. Synchronize packet indexing targets & complete core app setup
sudo apt-get update -y
sudo apt-get install jenkins -y

# 6. Safety check: Force systemd environment baseline to map explicitly to Java 21
sudo mkdir -p /etc/systemd/system/jenkins.service.d/
cat << 'EOF' | sudo tee /etc/systemd/system/jenkins.service.d/override.conf
[Service]
Environment="JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64"
EOF

# 7. Reload configurations and initiate the automated deployment lifecycle daemon
sudo systemctl daemon-reload
sudo systemctl enable jenkins
sudo systemctl start jenkins
###
