/*
 * Copyright (c) 2019, 2020, Oracle and/or its affiliates. All rights reserved.
 */

/**
* Variables file with defaults. These can be overridden from environment variables TF_VAR_<variable name>
*/

// Following are generally configured in environment variables - please use env_vars_template to create env_vars and source it as:
// source ./env_vars
// before running terraform init
variable "tenancy_ocid" {
  type        = string
  description = "tenancy id"
}
variable "region" {
    type        = string
    description = "tenancy id"
}

/*
********************
* WLS Instance Config
********************
*/
variable "compartment_ocid" {
  type        = string
  description = "compartment for weblogic instances"
}

// Note: This is the opc user's SSH public key text and not the key file path.
variable "ssh_public_key" {
  type        = string
  description = "public key for ssh access to weblogic instances"
}

variable "service_name" {
  type        = string
  description = "prefix for stack resources"
}

#Provide WLS custom image OCID
#DONOT MODIFY THIS FIELD AS IT IS REFERRED IN HUDSON
variable "instance_image_id" {
default = "ocid1.image.oc1..aaaaaaaanpiba7rmegsez6epen6zodkvwef3fvwjflh2ojbh2ldx7nwnabaa"
}

variable "network_compartment_id" {
  type    = string
  default = ""
  description = "compartment for network resources"
}

# Defines the number of instances to deploy
variable "wls_node_count" {
  type    = number
  default = "1"
  description = "number of weblogic managed servers"
}

variable "wls_node_count_limit" {
  type    = number
  default = "8"
  description = "Maximum number of weblogic managed servers"
}

variable "instance_shape" {
  type        = string
  description = "shape of weblogic VM instances"

}

variable "bastion_instance_shape" {
  type        = string
  default     = "VM.Standard2.1"
  description = "default shape of bastion VM instances"
}

# WLS related input variables
variable "wls_admin_user" {
  type        = string
  default     = "weblogic"
  description = "weblogic admin user"
}

variable "wls_admin_password_ocid" {
  type        = string
  default     = ""
  description = "weblogic admin password"
}

variable "wls_nm_port" {
  type    = string
  default = "5556"
  description = "node manager port"
}

# Port for channel Extern on Admin Server
variable "wls_extern_admin_port" {
  type    = string
  default = "7001"
  description = "weblogic console port"
}

# Port for channel SecureExtern on Admin Server
variable "wls_extern_ssl_admin_port" {
  type    = string
  default = "7002"
  description = "weblogic console ssl port"
}

variable "wls_cluster_mc_port" {
  type    = string
  default = "5555"
  description = "weblogic multi cluster port"
}

# Default channel ports for Admin Server
variable "wls_admin_port" {
  type    = string
  default = "9071"
  description = "weblogic default admin port"
}

variable "wls_ssl_admin_port" {
  type    = string
  default = "9072"
  description = "weblogic external admin ssl port"
}

# Default channel ports for Managed Server
variable "wls_ms_extern_port" {
  type    = string
  default = "7003"
  description = "weblogic managed server external HTTP port"
}

variable "wls_ms_extern_ssl_port" {
  type    = string
  default = "7004"
  description = "weblogic managed server external ssl port"
}

# Port for extern channel on Managed Server
variable "wls_ms_port" {
  type    = string
  default = "9073"
  description = "weblogic managed server port"
}

# Port for SecureExtern channel on Managed Server
variable "wls_ms_ssl_port" {
  type    = string
  default = "9074"
  description = "weblogic managed server ssl port"
}

variable "allow_manual_domain_extension" {
  type = bool
  default = false
  description = "flag indicating that domain will be manually extended for managed servers"
}

variable "wls_expose_admin_port" {
  type = bool
  default = false
  description = "[WARNING] Selecting this option will expose the console to the internet if the default 0.0.0.0/0 CIDR is used. You should change the CIDR range below to allow access to a trusted IP range."
}

variable "wls_admin_port_source_cidr" {
  type = string
  default = "0.0.0.0/0"
  description = "Create a security list to allow access to the WebLogic Administration Console port to the source CIDR range. [WARNING] Keeping the default 0.0.0.0/0 CIDR will expose the console to the internet. You should change the CIDR range to allow access to a trusted IP range."
}

/**
 * Supported versions:
 * 11g - 11.1.1.7
 * 12cRelease213 - 12.2.1.3
 * 12cRelease214 - 12.2.1.4
 */
variable "wls_version" {
  default = "12.2.1.4"
}

/*
********************
General Parameters
********************
*/

// PROD or DEV mode
variable "mode" {
  default = "PROD"
}

variable "log_level" {
  type    = string
  default = "INFO"
}

variable "deploy_sample_app" {
  type    = bool
  default = true
}

variable "create_policies" {
  type = bool
  default = true
}

variable "use_baselinux_marketplace_image" {
  type = bool
  default = true
  description = "flag to indicate marketplace bastion image will be used for bastion instance"
}

variable "bastion_instance_image_id" {
  type = string
  default = ""
  description = "Image ocid for bastion instance"
}

variable "wls_ocpu_count" {
  type = number
  default = 1
  description = "OCPU count for wls instance"
}

#Note: special chars string denotes empty values for tags for validation purposes
#otherwise zipmap function in main.tf fails first for empty strings before validators executed.
variable "defined_tag" {
  type    = string
  default = "~!@#$%^&*()"
  description = "defined resource tag name"
}

variable "defined_tag_value" {
  type    = string
  default = "~!@#$%^&*()"
  description = "defined resource tag value"
}

variable "free_form_tag" {
  type    = string
  default = "~!@#$%^&*()"
  description = "free form resource tag name"
}

variable "free_form_tag_value" {
  type    = string
  default = "~!@#$%^&*()"
  description = "free form resource tag value"
}


