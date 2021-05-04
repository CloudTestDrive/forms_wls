# Copyright 2020, 2021, Oracle Corporation and/or affiliates.  All rights reserved.


locals {
  compartment = format("instance.compartment.id='%s'", var.compartment_id)
  dg_instances = join(", ", formatlist("instance.id='%s'",var.instance_ocids))
  osms_rule = format("ANY { %s }",local.dg_instances)
}

resource "oci_identity_dynamic_group" "wlsc_instance_principal_group" {
  count = var.create_policies ? 1 : 0
  compartment_id = var.tenancy_id
  description    = "dynamic group to allow access to resources"
  matching_rule  = "ALL { ${local.compartment} }"
  name           = "${var.label_prefix}-wlsc-principal-group"

  lifecycle {
    ignore_changes = [matching_rule]
  }
}

resource "oci_identity_dynamic_group" "oci_managed_instances_principal_group" {
  count = var.create_policies ? 1 : 0
  compartment_id = var.tenancy_id
  description    = "dynamic group to allow instances to call osms services"
  matching_rule  = local.osms_rule
  name           = "${var.label_prefix}-osms-instance-principal-group"
}