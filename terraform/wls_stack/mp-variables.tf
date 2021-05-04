/*
 * Copyright (c) 2020, 2021, Oracle and/or its affiliates. All rights reserved.
 */

/* Please do not change these values */

variable "mp_baselinux_instance_image_id" {
  default = "ocid1.image.oc1..aaaaaaaaz2lna7kxzzcyaocm36as5xvqy7unzvbnknexgp76n5g3cv4bdadq"
}

variable "mp_baselinux_listing_id" {
  default = "ocid1.appcataloglisting.oc1..aaaaaaaacicjx6jviqczqow567tadr5ju7iy2m4vx6opyra6thql55n2nnvq"
}

variable "mp_baselinux_listing_resource_version" {
  default = "21.1.2-210212171245"
}

/*
********************
Marketplace UI Parameters
********************
*/
# Controls if we need to subscribe to marketplace PIC image and accept terms & conditions - defaults to true
variable "use_marketplace_image" {
  type    = bool
default = true
}

variable "mp_listing_id" {
default = "ocid1.appcataloglisting.oc1..aaaaaaaajl5w3d76x5vdc4n7oqjpsxh4jtwivclvvp6gj4em3kufju6sftga"
}

variable "mp_listing_resource_version" {
default = "21.1.3-210316164607"
}

# Used in UI instead of assign_weblogic_public_ip
variable "subnet_type" {
  default = "Use Public Subnet"
}

# Used in UI instead of use_regional_subnet
variable "subnet_span" {
  default = "Regional Subnet"
}

variable "vcn_strategy" {
  default = ""
}

variable "subnet_strategy_existing_vcn" {
  default = ""
}

variable "subnet_strategy_new_vcn" {
  default = ""
}

variable "db_strategy" {
  default = "No Database"
}

variable "use_advanced_wls_instance_config" {
  type    = bool
  default = false
}

variable "appdb_strategy" {
  default = "No Database"
}
