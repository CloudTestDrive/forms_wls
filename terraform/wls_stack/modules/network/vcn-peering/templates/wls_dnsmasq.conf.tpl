server=/${ocidb_zone}/${ocidb_dns_private_ip}
# The following is for the AppDB
server=/${appdb_zone}/${appdb_dns_private_ip}
cache-size=0
log-facility=/var/log/dnsmasq.log
log-queries
