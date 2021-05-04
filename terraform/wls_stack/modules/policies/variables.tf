# Copyright 2020, 2021, Oracle Corporation and/or affiliates.  All rights reserved.

variable "tenancy_id" {}

variable "compartment_id" {}

variable "label_prefix" {}

variable "create_policies" {
  type    = bool
  default = true
}

variable "add_loadbalancer" {
  type = bool
}

variable "atp_db" {
  type = object({
    is_atp         = bool
    compartment_id = string
  })
}

//Add security list to existing db vcn
variable "ocidb_existing_vcn_add_seclist" {
  type = bool
}

//DB System Network Compartment
variable "ocidb_network_compartment_id" {}

#wlsc network compartment
variable "network_compartment_id" {}

# App DB Network Compartment
variable "appdb_network_compartment_id" {}

#Add security list to existing app db vcn
variable "appdb_existing_vcn_add_seclist" {
  type = bool
}

variable "appdb_is_atp_db" {
  type    = bool
  default = false
}



#password ocids
variable "wls_admin_password_ocid" {
  type = string
}

variable "oci_db_password_ocid" {
  type    = string
  default = ""
}

variable "atp_db_password_ocid" {
  type    = string
  default = ""
}

variable "app_db_password_ocid" {
  type    = string
  default = ""
}

variable "idcs_client_secret_ocid" {
  type    = string
  default = ""
}

variable "instance_ocids" {
  type = list
}