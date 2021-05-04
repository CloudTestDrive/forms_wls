# get_load_balancer_ip.py
#
# Script to get the IP address of the loadbalancer
# XXXXXX  Ideally, it should be a hostname passed as paramater in the instance creation
# 
import sys
sys.path.append('/opt/scripts/')
import oci
import databag
load_balancer_id = databag.getLoadbalancerId()
principal = oci.auth.signers.InstancePrincipalsSecurityTokenSigner()
lb_client = oci.load_balancer.LoadBalancerClient(config={}, signer=principal)
response = lb_client.get_load_balancer(load_balancer_id)
print( response.data.ip_addresses[0].ip_address )
