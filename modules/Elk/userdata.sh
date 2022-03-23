#!/bin/bash
set -e

echo "INFO: userdata started"

# elasticsearch
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-oss-7.10.2-amd64.deb
dpkg -i elasticsearch-*.deb
systemctl enable elasticsearch
systemctl start elasticsearch

sleep 5

sudo echo "http.host: 0.0.0.0" >> /etc/elasticsearch/elasticsearch.yml
echo 'discovery.type: single-node' >> /etc/elasticsearch/elasticsearch.yml
systemctl restart elasticsearch

# http.host: 0.0.0.0


# kibana
wget https://artifacts.elastic.co/downloads/kibana/kibana-oss-7.10.2-amd64.deb
dpkg -i kibana-*.deb
echo 'server.host: "0.0.0.0"' > /etc/kibana/kibana.yml
echo "http.port: 9200" >> /etc/elasticsearch/elasticsearch.yml
echo "discovery.type: single-node" >> /etc/elasticsearch/elasticsearch.yml
systemctl enable kibana
systemctl start kibana

# filebeat
wget https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-oss-7.11.0-amd64.deb
dpkg -i filebeat-*.deb


sudo mv /etc/filebeat/filebeat.yml /etc/filebeat/filebeat.yml.BCK

cat <<\EOF > /etc/filebeat/filebeat.yml
filebeat.inputs:
  - type: log
    enabled: false
    paths:
      - /var/log/auth.log

filebeat.modules:
  - module: system
    syslog:
      enabled: false
    auth:
      enabled: false

filebeat.config.modules:
  path: ${path.config}/modules.d/*.yml
  reload.enabled: false

setup.dashboards.enabled: false

setup.template.name: "filebeat"
setup.template.pattern: "filebeat-*"
setup.template.settings:
  index.number_of_shards: 1

processors:
  - add_host_metadata:
      when.not.contains.tags: forwarded
  - add_cloud_metadata: ~

output.elasticsearch:
  hosts: [ "localhost:9200" ]
  index: "filebeat-%{[agent.version]}-%{+yyyy.MM.dd}"
## OR
#output.logstash:
#  hosts: [ "127.0.0.1:5044" ]
EOF

sleep 60


## install consul

echo "Grabbing IPs..."
PRIVATE_IP=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)

sleep 5
echo "Installing dependencies..."
apt-get -q update

sleep 5

echo "Installing dependencies..."
apt-get -yq install unzip dnsmasq

sleep 10

echo "Configuring dnsmasq..."
cat << EODMCF >/etc/dnsmasq.d/10-consul
# Enable forward lookup of the 'consul' domain:
server=/consul/127.0.0.1#8600
EODMCF

sleep 10
echo "systemctl restart dnsmasq"
systemctl restart dnsmasq

sleep 10

echo "/etc/systemd/resolved.conf"
cat << EOF >/etc/systemd/resolved.conf
[Resolve]
DNS=127.0.0.1
Domains=~consul
EOF
sleep 10

echo "systemctl restart systemd-resolved.service"
systemctl restart systemd-resolved.service

sleep 10
echo "Fetching Consul..."
cd /tmp
curl -sLo consul.zip https://releases.hashicorp.com/consul/1.4.0/consul_1.4.0_linux_amd64.zip

sleep 20

echo "Installing Consul..."
unzip consul.zip >/dev/null
chmod +x consul
mv consul /usr/local/bin/consul
sleep 10

# Setup Consul
echo "mkdir"
mkdir -p /opt/consul
sleep 3
mkdir -p /etc/consul.d
sleep 3
mkdir -p /run/consul
sleep 3

echo "tee /etc/consul.d/config.json"
tee /etc/consul.d/config.json > /dev/null <<EOF
{
  "advertise_addr": "$PRIVATE_IP",
  "data_dir": "/opt/consul",
  "datacenter": "opsschool",
  "encrypt": "uDBV4e+LbFW3019YKPxIrg==",
  "disable_remote_exec": true,
  "disable_update_check": true,
  "leave_on_terminate": true,
  "retry_join": ["provider=aws tag_key=consul_server tag_value=true"],
  "node_name": "Elk-server",
  "enable_script_checks": true,
  "server": false
}
EOF
sleep 10
# Create user & grant ownership of folders
echo "useradd consul"
useradd consul
chown -R consul:consul /opt/consul /etc/consul.d /run/consul

sleep 15
# Configure consul service
echo "Configure consul service"
tee /etc/systemd/system/consul.service > /dev/null <<EOF
[Unit]
Description=Consul service discovery agent
Requires=network-online.target
After=network.target

[Service]
User=consul
Group=consul
PIDFile=/run/consul/consul.pid
Restart=on-failure
Environment=GOMAXPROCS=2
ExecStart=/usr/local/bin/consul agent -pid-file=/run/consul/consul.pid -config-dir=/etc/consul.d
ExecReload=/bin/kill -s HUP \$MAINPID
KillSignal=SIGINT
TimeoutStopSec=5

[Install]
WantedBy=multi-user.target
EOF

sleep 20

systemctl daemon-reload
systemctl enable consul.service
systemctl start consul.service

sleep 25
echo "elk json"
tee /etc/consul.d/elk.json > /dev/null <<EOF
{
"services": [
    {
    "name":"elastic",
    "tags": [
        "server"
    ],
    "port": 9200,
    "checks": [
        {
        "name": "HTTP health",
        "tcp": "localhost:9200",
        "interval": "5s",
        "timeout": "10s"
        }
    ]
    }
]
}
EOF

sleep 10
echo "systemctl reload consul"
systemctl reload consul


sleep 15

echo "Install Node Exporter"
### Install Node Exporter
wget https://github.com/prometheus/node_exporter/releases/download/v0.18.1/node_exporter-0.18.1.linux-amd64.tar.gz -O /tmp/node_exporter.tgz
mkdir -p /opt/prometheus
tar zxf /tmp/node_exporter.tgz -C /opt/prometheus

sleep 10
echo "Configure node exporter service"
# Configure node exporter service
tee /etc/systemd/system/node_exporter.service > /dev/null <<EOF
[Unit]
Description=Prometheus node exporter
Requires=network-online.target
After=network.target

[Service]
ExecStart=/opt/prometheus/node_exporter-0.18.1.linux-amd64/node_exporter
KillSignal=SIGINT
TimeoutStopSec=5

[Install]
WantedBy=multi-user.target
EOF
sleep 10

systemctl daemon-reload
systemctl enable node_exporter.service
systemctl start node_exporter.service






 