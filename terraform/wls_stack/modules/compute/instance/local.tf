/*
 * Copyright (c) 2020, Oracle and/or its affiliates. All rights reserved.
 */

locals {
  host_label = "${var.compute_name_prefix}-${var.vnic_prefix}"
  ad_names   = compact(data.template_file.ad_names.*.rendered)

  is_oci_db         = trimspace(var.ocidb_dbsystem_id)!= ""?true: false
  is_oci_app_db     = trimspace(var.appdb_dbsystem_id)!= "" ? true : false
  is_atp_db         = trimspace(var.atp_db_id)!=""? true: false
  is_atp_app_db     = trimspace(var.app_atp_db_id)!=""? true: false
  is_apply_JRF      = local.is_oci_db || local.is_atp_db? true: false
  is_configure_appdb= local.is_oci_app_db || local.is_atp_app_db
  num_fault_domains = length(data.oci_identity_fault_domains.wls_fault_domains.fault_domains)
  wls_subnet_cidr   = (var.wls_subnet_id == "") ? var.wls_subnet_cidr : data.oci_core_subnet.wls_subnet[0].cidr_block

  # Default to "ASM" if storage_management is not found. This attribute is not there for baremetal and Exadata.
  db_options            = local.is_oci_db ? lookup(data.oci_database_db_systems.ocidb_db_systems[0].db_systems[0], "db_system_options", []) : []
  db_storage_management = local.is_oci_db && length(local.db_options) > 0 ? lookup(local.db_options[0], "storage_management", "ASM") : "ASM"
  appdb_options = local.is_oci_app_db ? lookup(data.oci_database_db_systems.appdb_db_systems[0].db_systems[0], "db_system_options", []) : []
  appdb_storage_management = local.is_oci_app_db && length(local.appdb_options) > 0 ? lookup(local.appdb_options[0], "storage_management", "ASM") : "ASM"

  # Private IP based provisioning
  infradb_node_count      = var.disable_infra_db_vcn_peering ? length(data.oci_database_db_nodes.ocidb_dbNode_list[0].db_nodes) : 0
  infradb_scanip_count    = var.disable_infra_db_vcn_peering ? length(data.oci_database_db_systems.ocidb_db_systems[0].db_systems[0].scan_ip_ids) : 0
  infradb_scanip_list     = local.infradb_node_count != 0 ? join("," , data.oci_core_private_ip.infra_db_scan_ip.*.ip_address) : ""
  infradb_private_ip_list = var.disable_infra_db_vcn_peering ? local.infradb_node_count > 1 ? join("," , data.oci_core_vnic.oci_db_vnic.*.private_ip_address) : data.oci_core_vnic.oci_db_vnic_single_node[0].private_ip_address : ""
  infradb_hostname_list   = var.disable_infra_db_vcn_peering ? local.infradb_node_count > 1 ? join("," , data.oci_core_vnic.oci_db_vnic.*.hostname_label) : data.oci_core_vnic.oci_db_vnic_single_node[0].hostname_label : ""
  appdb_node_count        = var.disable_app_db_vcn_peering ? length(data.oci_database_db_nodes.appdb_dbNode_list[0].db_nodes) : 0
  appdb_scanip_count      = var.disable_app_db_vcn_peering ? length(data.oci_database_db_systems.appdb_db_systems[0].db_systems[0].scan_ip_ids) : 0
  appdb_scan_ip_list      = local.appdb_scanip_count != 0 ? join("," , data.oci_core_private_ip.app_db_scan_ip.*.ip_address) : ""
  appdb_prviate_ip_list   = var.disable_app_db_vcn_peering ? local.appdb_node_count > 1 ? join("," , data.oci_core_vnic.app_db_vnic.*.private_ip_address) : data.oci_core_vnic.app_db_vnic_single_node[0].private_ip_address : ""
  appdb_hostname_list     = var.disable_app_db_vcn_peering ? local.appdb_node_count > 1 ? join("," , data.oci_core_vnic.app_db_vnic.*.hostname_label) : data.oci_core_vnic.app_db_vnic_single_node[0].hostname_label : ""
  }