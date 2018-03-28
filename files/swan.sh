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

# Install strongswan
apt install -y strongswan strongswan-plugin-eap-mschapv2

cat <<EOF >> /etc/sysctl.conf
net.ipv4.ip_forward = 1
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0
net.ipv4.tcp_max_syn_backlog = 1280
net.ipv4.icmp_echo_ignore_broadcasts = 1
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.all.secure_redirects = 0
net.ipv4.conf.all.log_martians = 1
net.ipv4.conf.default.accept_source_route = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.default.secure_redirects = 0
net.ipv4.icmp_echo_ignore_broadcasts = 1
net.ipv4.icmp_ignore_bogus_error_responses = 1
net.ipv4.tcp_syncookies = 1
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1
net.ipv4.tcp_mtu_probing = 1
EOF

cat <<EOF | sudo tee /home/ubuntu/conf.tpl
config setup
  strictcrlpolicy=no
  charondebug=all
conn %default
  ikelifetime=60m
  keylife=20m
  rekeymargin=3m
  keyingtries=1
  keyexchange=ikev1
  dpdaction=restart
  ike=aes128-sha1-modp1024!
  authby=psk
  esp=aes128-sha1-modp1024!
  auto=start
  left=%defaultroute
  leftid=$(curl http://169.254.169.254/latest/meta-data/public-ipv4)
  leftsubnet=172.16.0.0/16
{{- range tree "king-swan/@dc1" }}
conn {{ .Key }}
{{- with \$d := .Value | parseJSON }}
  right={{ \$d.tunnel_ip }}
  rightsubnet={{ \$d.cidr_block }}
{{- end }}
{{- end }}
EOF

cat <<EOF | sudo tee /home/ubuntu/secrets.tpl
{{- range tree "king-swan/@dc1" }}
{{- with \$d := .Value | parseJSON }}
{{ \$d.tunnel_ip }} : PSK "{{ \$d.psk }}"
{{- end }}
{{- end }}
EOF

cat <<EOF | sudo tee /home/ubuntu/consul-template.hcl
consul {
    address = "king-consul.devscake.com:8500"
    retry {
        enabled = true
        attempts = 10
        backoff = "1s"
        max_backoff = "1m"
    }
}
syslog {
    enabled = true
    facility = "LOCAL5"
}
template {
    source = "/home/ubuntu/conf.tpl"
    destination = "/etc/ipsec.conf"
    error_on_missing_key = true
    backup = true
}
template {
    source = "/home/ubuntu/secrets.tpl"
    destination = "/etc/ipsec.secrets"
    error_on_missing_key = true
    backup = true
    command = "ipsec restart"
}
EOF

cat <<EOF | sudo tee /lib/systemd/system/consul-template.service
[Unit]
Description=consul-template agent
Requires=network-online.target
After=network-online.target
[Service]
User=root
Group=root
Restart=on-failure
ExecStart=/usr/local/bin/consul-template -config "/home/ubuntu/consul-template.hcl"
ExecReload=/bin/kill -HUP $MAINPID
KillSignal=SIGINT
[Install]
WantedBy=multi-user.target
EOF

ln -sf /lib/systemd/system/consul-template.service /etc/systemd/system/consul-template.service
service consul-template start
