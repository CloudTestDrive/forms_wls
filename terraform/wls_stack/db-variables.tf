/*
 * Copyright (c) 2020, Oracle and/or its affiliates. All rights reserved.
 */


/*
********************
OCI DB Config
********************
*/
// Provide DB node count - for node count > 1, WLS AGL datasource will be created
variable "add_JRF" {
  type  = bool
  default = false
  description = "Indicates that JRF domain is requested in UI"
}

variable "ocidb_compartment_id" {
  default = ""
  description = "value for ocidb compartment ocid"
}

variable "ocidb_network_compartment_id" {
  default = ""
  description = "value for ocidb network ocid"
}

variable "ocidb_existing_vcn_id" {
  default = ""
  description = "value for ocidb existing vcn id"
}

variable "ocidb_existing_vcn_add_seclist" {
  type = bool
  default = true
  description = "value for ocidb existing vcn id"
}

variable "ocidb_dbsystem_id" {
  default = ""
  description = "value for oci database system ocid"
}

variable "ocidb_dbhome_id" {
  default = ""
  description = "value for oci database system DB home"
}

variable "ocidb_database_id" {
  default = ""
  description = "value for oci database ocid"
}

variable "ocidb_pdb_service_name" {
  default = ""
  description = "value for oci database pdb name"
}

variable "oci_db_user" {
  default = ""
  description = "value for oci database pdb name"
}

variable "oci_db_password_ocid" {
  default = ""
  description = "value for oci database password OCID"
}

variable "db_port" {
  default = "1521"
  description = "value for oci database port"
}



/*
********************
ATP Parameters
********************
*/

variable "atp_db_compartment_id" {
  default = ""
  description = "value for ATP database compartment ocid"
}

variable "atp_db_id" {
  default = ""
  description = "value for ATP database ocid"
}

variable "atp_db_level" {
  default = "low"
  description = "value for ATP database level"
}

variable "atp_db_password_ocid" {
  default = ""
  description = "value for ATP database password ocid"
}