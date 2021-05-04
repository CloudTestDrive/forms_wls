/*
 * Copyright (c) 2020, Oracle and/or its affiliates. All rights reserved.
 */

/*
********************
OCI DB Config for AppDB
********************
*/

variable "configure_app_db" {
  type  = bool
  default = false
  description = "Indicates that Application Database is requested."
}

variable "appdb_compartment_id" {
  default = ""
  description = "value for ocidb compartment ocid"
}

variable "appdb_network_compartment_id" {
  default = ""
  description = "value for ocidb network ocid"
}

variable "appdb_existing_vcn_id" {
  default = ""
  description = "value for ocidb existing vcn id"
}

variable "appdb_existing_vcn_add_seclist" {
  type = bool
  default = true
  description = "value for ocidb existing vcn id"
}

variable "appdb_dbsystem_id" {
  default = ""
  description = "value for oci database system ocid"
}

variable "appdb_dbhome_id" {
  default = ""
  description = "value for oci database system DB home"
}

variable "appdb_database_id" {
  default = ""
  description = "value for oci database ocid"
}

variable "appdb_pdb_service_name" {
  default = ""
  description = "value for oci database pdb name"
}

variable "app_db_user" {
  default = ""
  description = "value for oci database user name"
}

variable "app_db_password_ocid" {
  default = ""
  description = "value for oci database password OCID"
}

variable "appdb_port" {
  default = "1521"
  description = "value for oci database port"
}



/*
********************
ATP Parameters for AppDB
********************
*/

variable "app_atp_db_compartment_id" {
  default = ""
  description = "value for ATP database compartment ocid"
}

variable "app_atp_db_id" {
  default = ""
  description = "value for ATP database ocid"
}

variable "app_atp_db_user" {
  default = ""
  description = "value for oci database user name"
}

variable "app_atp_db_level" {
  default = "low"
  description = "value for ATP database level"
}

variable "app_atp_db_password_ocid" {
  default = ""
  description = "value for ATP database password ocid"
}

// VCN Peering related variables

variable "appdb_wls_dns_subnet_cidr" {
  default = ""
  description = "CIDR value of  the subnet to be used for DNS instance"
}

variable "ociappdb_dns_subnet_cidr" {
  default = ""
  description = "CIDR value of the subnet to be used for DB DNS instance"
}

variable "appdbdns_instance_shape" {
  default = ""
  description = "Shape of the DNS instance"
}
