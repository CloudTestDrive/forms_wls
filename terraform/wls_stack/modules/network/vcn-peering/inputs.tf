/*
 * Copyright (c) 2019, 2021, Oracle and/or its affiliates. All rights reserved.
 */
variable "tenancy_ocid" {}

variable "region" {}
variable "wls_availability_domain" {}
variable "compartment_ocid" {}
variable "network_compartment_id" {}
variable "instance_shape" {}
variable "instance_image_id" {}
variable "ssh_public_key" {}
variable "service_name" {}

// OCID of the new VCN created for WLS.
variable "wls_vcn_id" {}
// CIDR for new VCN
variable "wls_vcn_cidr" {}

variable "wls_dns_subnet_cidr" {}

//variable "wls_internet_gateway_id" {
//  type = "list"
//}

// OCI DB params for VCN peering
variable "ocidb_compartment_id" {}

variable "ocidb_network_compartment_id" {}

variable "ocidb_dbsystem_id" {}

variable "ocidb_database_id" {}

variable "ocidb_dns_subnet_cidr" {}

variable "ocidb_existing_vcn_id" {}

variable "is_vcn_peering" {
  type = bool
}

//variable "ocidb_subnet_id" {}

variable "bootStrapFile" {
  type    = string
  default = "./modules/network/vcn-peering/userdata/bootstrap"
}

// Private subnet support
variable "assign_public_ip" {
  type = bool
  default = true
}

variable "use_regional_subnet" {}

variable "service_gateway_id" {
}

variable "wls_internet_gateway_id" {
}

variable "wls_subnet_id" {}

variable "wls_vcn_name" {}

variable "use_existing_subnet" {}

variable "defined_tags" {
  type=map
  default = {}
}

variable "freeform_tags" {
  type=map
  default = {}
}


// App DB related Data
variable "appdb_dbsystem_id" {}
variable "appdb_database_id" {}
variable "appdb_compartment_id" {}
variable "appdb_existing_vcn_id" {}
variable "appdb_network_compartment_id" {}

// VCN peering param for App DB
variable "appdb_vcn_peering" {
  type = bool
  default = false
}
variable "appdb_dns_subnet_cidr" {}

variable "appdb_instance_shape" {}


variable "default_flex_ocpus" {
  type = number
  default = 1
}