/*
 * Copyright (c) 2019, 2020, Oracle and/or its affiliates. All rights reserved.
 */

data "oci_identity_availability_domains" "ADs" {
  compartment_id = var.tenancy_ocid
}
data "oci_identity_tenancy" "tenancy" {
  #Required
  tenancy_id = "${var.tenancy_ocid}"
}
locals {
  num_ads = length(
    data.oci_identity_availability_domains.ADs.availability_domains,
  )
  is_single_ad_region = local.num_ads == 1 ? true : false
}
data "oci_identity_regions" "home-region" {
  filter {
    name   = "key"
    values = ["${data.oci_identity_tenancy.tenancy.home_region_key}"]
  }
}
data "oci_core_instance" "existing_bastion_instance" {
  count = var.existing_bastion_instance_id != "" ? 1: 0

  instance_id = var.existing_bastion_instance_id
}

data "template_file" "ad_names" {
  count    = length(data.oci_identity_availability_domains.ADs.availability_domains)
  template =  (var.instance_shape=="VM.Standard.E3.Flex" || (tonumber(lookup(data.oci_limits_limit_values.compute_shape_service_limits[count.index].limit_values[0], "value")) > 0))?lookup(data.oci_identity_availability_domains.ADs.availability_domains[count.index], "name"):""
}

data "oci_limits_limit_values" "compute_shape_service_limits" {
    count    = length(data.oci_identity_availability_domains.ADs.availability_domains)
    #Required
    compartment_id = var.tenancy_ocid
    service_name = "compute"

    #Optional
    availability_domain = lookup(data.oci_identity_availability_domains.ADs.availability_domains[count.index], "name")
    #format of name field -vm-standard2-2-count
    #ignore flex shapes
    name = var.instance_shape=="VM.Standard.E3.Flex"?"":format("%s-count",replace(var.instance_shape, ".", "-"))
}

data "oci_core_subnet" "wls_subnet" {
  count = var.wls_subnet_id == "" ? 0 : 1

  #Required
  subnet_id = var.wls_subnet_id
}

data "oci_core_subnet" "bastion_subnet" {
  count = var.bastion_subnet_id == "" ? 0 : 1

  #Required
  subnet_id = var.bastion_subnet_id
}
# For querying availability domains given subnet_id
data "oci_core_subnet" "lb_subnet_1_id" {
  count = var.lb_subnet_1_id == "" ? 0 : 1

  #Required
  subnet_id = var.lb_subnet_1_id
}

data "oci_core_subnet" "lb_subnet_2_id" {
  count = var.lb_subnet_2_id == "" ? 0 : 1

  #Required
  subnet_id = var.lb_subnet_2_id
}

data "oci_database_database" "ocidb_database" {
  count = local.is_oci_db ? 1: 0

  #Required
  database_id = var.ocidb_database_id
}

data "oci_database_db_home" "ocidb_db_home" {
  count = local.is_oci_db ? 1: 0

  #Required
  db_home_id = data.oci_database_database.ocidb_database[0].db_home_id
}

data "oci_database_database" "ociappdb_database" {
  count = var.appdb_compartment_id != "" ? 1: 0

  #Required
  database_id = var.appdb_database_id
}

data "oci_database_db_home" "ociappdb_db_home" {
  count = var.appdb_compartment_id != "" ? 1: 0

  #Required
  db_home_id = data.oci_database_database.ociappdb_database[0].db_home_id
}