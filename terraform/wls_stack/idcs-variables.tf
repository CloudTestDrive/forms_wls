
/*
 * Copyright (c) 2020, Oracle and/or its affiliates. All rights reserved.
 */
variable "is_idcs_selected" {
  type = bool
  default = false
  description = "Indicates that idcs has to be provisioned"
}

variable "idcs_host" {
  default = "identity.oraclecloud.com"
  description = "value for idcs host"

}

variable "idcs_port" {
  default = "443"
  description = "value for idcs port"
}

variable "idcs_tenant" {
  default = ""
  description = "value for idcs tenant"
}

variable "idcs_client_id" {
  default = ""
  description = "value for idcs client id"
}

variable "idcs_client_secret_ocid" {
  default = ""
  description = "value for idcs client secret ocid"
}

variable "idcs_cloudgate_port" {
  default = "9999"
  description = "value for idcs cloud gate port"
}
