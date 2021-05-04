variable "mount_software" {
  type    = string
  default = "NOT_SET1"
}

output "FORM_URL" {
  value = format("https://%s/forms/frmservlet?config=dept", oci_load_balancer_load_balancer.wls-loadbalancer.*.ip_addresses[0][0])
}

/*
output "LB_IP" {
  value = oci_load_balancer_load_balancer.wls-loadbalancer.*.ip_addresses[0][0]
}
*/
