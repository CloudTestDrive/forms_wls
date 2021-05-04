# Copyright 2020, 2021, Oracle Corporation and/or affiliates.  All rights reserved.

locals {
  osms_policy_1 = var.create_policies ? "Allow dynamic-group ${oci_identity_dynamic_group.oci_managed_instances_principal_group[0].name} to use osms-managed-instances in compartment id ${var.compartment_id}" : ""
  osms_policy_2 = var.create_policies ? "Allow dynamic-group ${oci_identity_dynamic_group.oci_managed_instances_principal_group[0].name} to read instance-family in compartment id ${var.compartment_id}" : ""

  ss_policy_statement1 = var.create_policies ? "Allow dynamic-group ${oci_identity_dynamic_group.wlsc_instance_principal_group[0].name} to read secret-bundles in tenancy where target.secret.id = '${var.wls_admin_password_ocid}'" : ""
  ss_policy_statement2 = var.create_policies && var.oci_db_password_ocid!=""? "Allow dynamic-group ${oci_identity_dynamic_group.wlsc_instance_principal_group[0].name} to read secret-bundles in tenancy where target.secret.id = '${var.oci_db_password_ocid}'" : ""
  ss_policy_statement3 = var.create_policies && var.atp_db_password_ocid!=""? "Allow dynamic-group ${oci_identity_dynamic_group.wlsc_instance_principal_group[0].name} to read secret-bundles in tenancy where target.secret.id = '${var.atp_db_password_ocid}'" : ""
  ss_policy_statement4 = var.create_policies && var.app_db_password_ocid!=""? "Allow dynamic-group ${oci_identity_dynamic_group.wlsc_instance_principal_group[0].name} to read secret-bundles in tenancy where target.secret.id = '${var.app_db_password_ocid}'" : ""
  ss_policy_statement5 = var.create_policies && var.idcs_client_secret_ocid!=""? "Allow dynamic-group ${oci_identity_dynamic_group.wlsc_instance_principal_group[0].name} to read secret-bundles in tenancy where target.secret.id = '${var.idcs_client_secret_ocid}'" : ""

  sv_policy_statement1 = var.create_policies ? "Allow dynamic-group ${oci_identity_dynamic_group.wlsc_instance_principal_group[0].name} to manage volume-family in tenancy" : ""
  sv_policy_statement2 = var.create_policies ? "Allow dynamic-group ${oci_identity_dynamic_group.wlsc_instance_principal_group[0].name} to manage instance-family in tenancy" : ""
  sv_policy_statement3 = (var.create_policies && var.ocidb_network_compartment_id != "") ? "Allow dynamic-group ${oci_identity_dynamic_group.wlsc_instance_principal_group[0].name} to manage virtual-network-family in compartment id ${var.ocidb_network_compartment_id}" : ""
  sv_policy_statement4 = (var.create_policies && var.network_compartment_id!= "") ? "Allow dynamic-group ${oci_identity_dynamic_group.wlsc_instance_principal_group[0].name} to manage virtual-network-family in compartment id ${var.network_compartment_id}" : ""

  lb_policy_statement  = var.create_policies ? "Allow dynamic-group ${oci_identity_dynamic_group.wlsc_instance_principal_group[0].name} to manage load-balancers in compartment id ${var.network_compartment_id}" : ""
  atp_policy_statement = ((var.atp_db.is_atp || var.appdb_is_atp_db) && var.create_policies) ? "Allow dynamic-group ${oci_identity_dynamic_group.wlsc_instance_principal_group[0].name} to manage autonomous-transaction-processing-family in tenancy" : ""
  db_policy_statement  = (var.create_policies && var.ocidb_existing_vcn_add_seclist && var.ocidb_network_compartment_id != "") ? "Allow dynamic-group ${oci_identity_dynamic_group.wlsc_instance_principal_group[0].name} to manage virtual-network-family in compartment id ${var.ocidb_network_compartment_id}" : ""
  appdb_policy_needed  = local.db_policy_statement != "" ? var.appdb_network_compartment_id != var.ocidb_network_compartment_id : true
  appdb_policy_statement  = (var.create_policies && local.appdb_policy_needed && var.appdb_existing_vcn_add_seclist && var.appdb_network_compartment_id != "") ? "Allow dynamic-group ${oci_identity_dynamic_group.wlsc_instance_principal_group[0].name} to manage virtual-network-family in compartment id ${var.appdb_network_compartment_id}" : ""
}

resource "oci_identity_policy" "wlsc_secret-service-policy" {
  count = var.create_policies ? 1 : 0

  compartment_id = var.tenancy_id
  description    = "policy to allow access to secrets in vault"
  name           = "${var.label_prefix}-secrets-policy"
  statements     = compact([local.ss_policy_statement1, local.ss_policy_statement2, local.ss_policy_statement3, local.ss_policy_statement4, local.ss_policy_statement5])
}

resource "oci_identity_policy" "wlsc_osms-policy" {
  count = var.create_policies ? 1 : 0

  compartment_id = var.tenancy_id
  description    = "policy to allow osms agent to access os-management service"
  name           = "${var.label_prefix}-osms-policy"
  statements     = compact([local.osms_policy_1, local.osms_policy_2])
}

resource "oci_identity_policy" "wlsc_service-policy" {
  count = var.create_policies ? 1 : 0

  compartment_id = var.tenancy_id
  description    = "policy to access compute instances and block storage volumes"
  name           = "${var.label_prefix}-service-policy"
  statements     = compact([local.sv_policy_statement1, local.sv_policy_statement2, local.sv_policy_statement3, local.sv_policy_statement4])
}

resource "oci_identity_policy" "wlsc_atp-policy" {
  count = (var.atp_db.is_atp || var.appdb_is_atp_db) && var.create_policies ? 1 : 0

  compartment_id = var.tenancy_id
  description    = "policy to allow WebLogic Cloud service to manage ATP DB in compartment"
  name           = "${var.label_prefix}-atp-policy"
  statements     = [local.atp_policy_statement]
}

resource "oci_identity_policy" "wlsc_db-network-policy" {
  count = (var.create_policies && var.ocidb_existing_vcn_add_seclist && var.ocidb_network_compartment_id != "") ? 1 : 0

  compartment_id = var.tenancy_id
  description    = "policy to allow WebLogic Cloud service to manage virtual-network-family in DB compartment"
  name           = "${var.label_prefix}-db-network-policy"
  statements     = [local.db_policy_statement]
}

resource "oci_identity_policy" "wlsc_appdb-network-policy" {
  count = local.appdb_policy_statement != "" ? 1 : 0

  compartment_id = var.tenancy_id
  description    = "policy to allow WebLogic Cloud service to manage virtual-network-family in Application DB compartment"
  name           = "${var.label_prefix}-appdb-network-policy"
  statements     = [local.appdb_policy_statement]
}

resource "oci_identity_policy" "wlsc_lb-policy" {
  count = var.create_policies  && var.add_loadbalancer? 1 : 0

  compartment_id = var.tenancy_id
  description    = "policy to allow WebLogic Cloud service to manage load balancer in WLSC network compartment"
  name           = "${var.label_prefix}-lb-policy"
  statements     = [local.lb_policy_statement]
}