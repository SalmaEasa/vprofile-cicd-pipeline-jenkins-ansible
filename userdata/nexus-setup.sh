#!/bin/bash
set -e

yum install java-17-amazon-corretto wget -y

mkdir -p /opt/nexus/
mkdir -p /tmp/nexus/
cd /tmp/nexus/

NEXUSURL="https://cdn.download.sonatype.com/repository/downloads-prod-group/3/nexus-3.75.1-01-unix.tar.gz"
wget -L $NEXUSURL -O nexus.tar.gz
tar xzvf nexus.tar.gz
NEXUSDIR=$(ls /tmp/nexus/ | grep nexus-)
rm -rf nexus.tar.gz
cp -r /tmp/nexus/* /opt/nexus/

id nexus &>/dev/null || useradd nexus
chown -R nexus:nexus /opt/nexus

cat <<EOT > /etc/systemd/system/nexus.service
[Unit]
Description=nexus service
After=network.target

[Service]
Type=forking
LimitNOFILE=65536
ExecStart=/opt/nexus/$NEXUSDIR/bin/nexus start
ExecStop=/opt/nexus/$NEXUSDIR/bin/nexus stop
User=nexus
Restart=on-abort

[Install]
WantedBy=multi-user.target
EOT

echo 'run_as_user="nexus"' > /opt/nexus/$NEXUSDIR/bin/nexus.rc
systemctl daemon-reload
systemctl start nexus
systemctl enable nexus
