/*
 * Copyright (c) 2019, 2021, Oracle and/or its affiliates. All rights reserved.
 */

/**
* Network related variables
*/

variable "wls_vcn_name" {
  default = ""
  description = "Name of new virtual cloud network"
}

variable "wls_existing_vcn_id" {
  default = ""
  description = "OCID of existing virtual cloud network"
}


variable "wls_availability_domain_name" {
  type        = string
  default     = ""
  description = "availablility domain for weblogic vm instances"
}

// Specify an LB AD 1 if lb is requested
variable "lb_subnet_1_availability_domain_name" {
  type        = string
  default = ""
  description = "availablility domain for load balancer"
}

// Specify an LB AD 2 if lb is requested
variable "lb_subnet_2_availability_domain_name" {
  type        = string
  default = ""
  description = "availablility domain for load balancer"
}

variable "wls_vcn_cidr" {
  default = "10.0.0.0/16"
  description = "CIDR for new virtual cloud network"
}

variable "add_load_balancer" {
  type = bool
  default = false
  description = "Adds of load balancer to stack"
}

variable "wls_subnet_name" {
  default = "wl-subnet"
}

variable "wls_subnet_cidr" {
  default = ""
}

variable "lb_subnet_1_name" {
  default = "lb-sbnet-1"
}

variable "lb_subnet_1_cidr" {
  default = ""
}

variable "lb_subnet_2_name" {
  default = "lb-sbnet-2"
}

variable "lb_subnet_2_cidr" {
  default = ""
}

variable "use_regional_subnet" {
  type = bool
  default = true
  description = "Indicates use of regional subnets (preferred) instead of AD specific subnets"
}

variable "volume_name" {
  default = ""
}

variable "assign_weblogic_public_ip" {
  type = bool
  default = true
  description = "Indicates use of private subnets"
}

variable "bastion_subnet_cidr" {
  default = ""
  description = "CIDR for bastion subnet"
}

variable "bastion_subnet_name" {
  default = "bsubnet"
}

variable "wls_subnet_id" {
  default = ""
  description = "OCID for existing subnet for weblogic instances"
}

variable "is_bastion_instance_required" {
  default = true
  description = "Creates bastion for the stack"
}

# existing bastion instance support
variable "existing_bastion_instance_id" {
  type    = string
  default = ""
  description = "OCID for existing bastion instance"
}

variable "bastion_ssh_private_key" {
  type    = string
  default = ""
  description = "Private ssh key for existing bastion instance"
}

variable "lb_subnet_1_id" {
  default = ""
  description = "OCID for existing regional or AD subnet for primary load balancer"
}

variable "lb_subnet_2_id" {
  default = ""
  description = "OCID for existing AD subnet for secondary load balancer"
}

variable "bastion_subnet_id" {
  default = ""
  description = "OCID for existing subnet for bastion instance"
}

variable "lb_max_bandwidth" {
  type = number
  default = 400
  description = "Maximum bandwidth for the load balancer"
}

variable "lb_min_bandwidth" {
  type        = number
  default     = 10
  description = "Minimum bandwidth for the load balancer"
}

variable "is_lb_private" {
  type = bool
  default = false
  description = "Indicates use of private load balancer"
}

/*
********************
Local VCN Peering Parameters
********************
*/
// If criteria for VCN peering is met and this feature flag is set, only then VCN peering will be done.

variable "disable_infra_db_vcn_peering" {
  type = bool
  default = false
  description = "Indicates use of virtual cloud network peering if Infra DB and WLS are different virtual cloud networks and already peered"
}

variable "disable_app_db_vcn_peering" {
  type = bool
  default = false
  description = "Indicates use of virtual cloud network peering if App DB and WLS are different virtual cloud networks and already peered"
}

variable "use_local_vcn_peering" {
  type = bool
  default = true
  description = "Indicates use of virtual cloud network peering if DB and WLS are different virtual cloud networks"
}

variable "wls_dns_subnet_cidr" {
  default = ""
  description = "CIDR value of  the subnet to be used for DNS instance"
}

variable "ocidb_dns_subnet_cidr" {
  default = ""
  description = "CIDR value of the subnet to be used for DB DNS instance"
}

variable "dns_instance_shape" {
  default = ""
  description = "Shape of the DNS instance"
}

