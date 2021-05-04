/*
 * Copyright (c) 2019, 2021, Oracle and/or its affiliates. All rights reserved.
 */
variable original_service_name {}
variable service_name_prefix {}
variable numVMInstances {}
variable wls_node_count_limit {}
variable vcn_name {}
variable existing_vcn_id {}
variable wls_subnet_cidr {}
variable lb_subnet_1_cidr {}
variable lb_subnet_2_cidr {}
variable bastion_subnet_cidr {}
variable assign_public_ip {
  type = bool
}
variable is_bastion_instance_required {}
variable existing_bastion_instance_id {}
variable bastion_ssh_private_key {}
variable add_load_balancer {}
variable instance_shape {}
variable wls_ocpu_count {}
variable wls_admin_user {}
variable wls_admin_password {}

variable wls_nm_port {}
variable wls_cluster_mc_port {}

variable wls_ms_port {}
variable wls_ms_ssl_port {}
variable wls_console_port {}
variable wls_console_ssl_port {}

variable wls_extern_admin_port {}
variable wls_extern_ssl_admin_port {}

variable wls_edition {}

variable wls_availability_domain_name {}
variable lb_availability_domain_name1 {}
variable lb_availability_domain_name2 {}

variable lb_max_bandwidth{
  type= number
}

variable lb_min_bandwidth{
  type= number
}

// WLS version and artifacts
variable wls_version {}

//variable oci_db_params {
//  type="map"
//}
//variable atp_db_params {
//  type="map"
//}

variable "log_level" {}

variable "wls_subnet_id" {}

variable "lb_subnet_1_id" {}

variable "lb_subnet_2_id" {}

variable "is_lb_private" {}

variable "bastion_subnet_id" {}

variable "wls_admin_port_source_cidr" {
  type = string
}

variable "wls_expose_admin_port" {
  type = bool
}

// OCI DB Params
variable "ocidb_compartment_id" {}

variable "ocidb_dbsystem_id" {}
variable "ocidb_database_id" {}
variable "ocidb_pdb_service_name" {}
variable "oci_db_password_ocid" {}

variable "is_oci_db" {
  default = false
}

// ATP DB params
variable "is_atp_db" {
  type    = bool
  default = false
}

variable "atp_db_id" {}
variable "atp_db_level" {}
variable "atp_db_compartment_id" {}
variable "app_db_password_ocid" {}

// Common DB params
variable "db_user" {}

variable "db_password" {}

variable "db_port" {
  default = "1521"
}

variable "network_compartment_id" {}
variable "ocidb_network_compartment_id" {}
// vcn peering variables
variable "disable_infra_db_vcn_peering" {
  type    = bool
  default = false
  description = "Indicates use of virtual cloud network peering if Infra DB and WLS are different virtual cloud networks and already peered"
}

variable "disable_app_db_vcn_peering" {
  type    = bool
  default = false
  description = "Indicates use of virtual cloud network peering if App DB and WLS are different virtual cloud networks and already peered"
}

variable "use_local_vcn_peering" {
  type = bool
}
variable "ocidb_existing_vcn_id" {}
variable "ocidb_dns_subnet_cidr" {}
variable "wls_dns_subnet_cidr" {}
variable "ocidb_version" {}
variable "app_ocidb_version" {}

variable "use_regional_subnet" {
  type = bool
}
//App DB
variable "configure_app_db" {
  type = bool
}
//IDCS
variable is_idcs_selected {
  type = bool
}
variable idcs_host {}
variable idcs_tenant {}
variable idcs_client_id {}
variable idcs_client_secret {}
variable idcs_cloudgate_port {}

variable defined_tag {
}

variable defined_tag_value {
}

variable freeform_tag {
}

variable freeform_tag_value {
}
