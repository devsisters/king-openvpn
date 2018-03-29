#!/bin/bash

# Strict mode (http://redsymbol.net/articles/unofficial-bash-strict-mode/)
set -euo pipefail; IFS=$'\n\t'
# Echo all commands
set -x

chown ubuntu:ubuntu -R /home/ubuntu

apt update -y
DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" upgrade
apt install -y apt-transport-https \
  htop dstat ack-grep silversearcher-ag chrony

# chronyd config
echo "server 169.254.169.123 prefer iburst" >> /etc/chrony/chrony.conf

# Use Asia/Seoul timezone
ln -sf /usr/share/zoneinfo/Asia/Seoul /etc/localtime

# Install awscli
curl https://bootstrap.pypa.io/get-pip.py | python3
pip install --upgrade awscli

download () {
    RESOURCE_PATH="/tmp/resources"
    RESOURCE_URL="$1"
    BASENAME="$${RESOURCE_URL##*/}"
    
    mkdir -p "$RESOURCE_PATH"
    if [ ! -f "$RESOURCE_PATH/$BASENAME" ]; then
        curl -fLo "$RESOURCE_PATH/$BASENAME" "$RESOURCE_URL"
    fi
}

# Install consul-template
download "https://releases.hashicorp.com/consul-template/0.19.4/consul-template_0.19.4_linux_amd64.tgz"
tar -ozxvf /tmp/resources/consul-template_0.19.4_linux_amd64.tgz -C /usr/local/bin/

# Install ripgrep
download "https://github.com/BurntSushi/ripgrep/releases/download/0.7.1/ripgrep-0.7.1-x86_64-unknown-linux-musl.tar.gz"
tar -ozxvf /tmp/resources/ripgrep-0.7.1-x86_64-unknown-linux-musl.tar.gz -C /tmp/ ripgrep-0.7.1-x86_64-unknown-linux-musl/{rg,complete/rg.bash-completion}
mv /tmp/ripgrep-0.7.1-x86_64-unknown-linux-musl/rg /usr/local/bin/
mv /tmp/ripgrep-0.7.1-x86_64-unknown-linux-musl/complete/rg.bash-completion /etc/bash_completion.d/
rmdir \
    /tmp/ripgrep-0.7.1-x86_64-unknown-linux-musl/complete \
      /tmp/ripgrep-0.7.1-x86_64-unknown-linux-musl

# Install jq
download "https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64"
mkdir -p "resources/jq-linux64"

mv /tmp/resources/jq-linux64 /usr/local/bin/jq
chmod +x /usr/local/bin/jq

# Install consul
download "https://releases.hashicorp.com/consul/1.0.3/consul_1.0.3_linux_amd64.zip"
apt install -y unzip
unzip /tmp/resources/consul_1.0.3_linux_amd64.zip -d /usr/local/bin/

cat <<EOF | sudo tee /home/ubuntu/consul.config.json
{
    "data_dir": "/home/ubuntu/consul",
    "log_level": "INFO",
    "server": true,
    "retry_join": ["provider=aws tag_key=ConsulJoin tag_value=v1"],
    "bind_addr": "0.0.0.0",
    "client_addr": "$(curl http://169.254.169.254/latest/meta-data/local-ipv4)",
    "advertise_addr": "$(curl http://169.254.169.254/latest/meta-data/local-ipv4)",
    "bootstrap_expect": 3,
    "ui": true
}
EOF

cat <<EOF | sudo tee /lib/systemd/system/consul.service
[Unit]
Description=consul agent
Requires=network-online.target
After=network-online.target
[Service]
Environment=GOMAXPROCS=2
Restart=on-failure
ExecStart=/usr/local/bin/consul agent -config-file=/home/ubuntu/consul.config.json
ExecReload=/bin/kill -HUP $MAINPID
KillSignal=SIGINT
[Install]
WantedBy=multi-user.target
EOF

ln -sf /lib/systemd/system/consul.service /etc/systemd/system/consul.service
service consul start
