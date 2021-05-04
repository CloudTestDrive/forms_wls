/*
 * Copyright (c) 2019, 2021, Oracle and/or its affiliates. All rights reserved.
 */
locals{
  shape = var.is_vcn_peering ? var.instance_shape : var.appdb_instance_shape
}

resource "oci_core_security_list" "wls_dns_security_list" {
  count = (var.is_vcn_peering || var.appdb_vcn_peering) ? 1:0

  #Required
  compartment_id = var.network_compartment_id
  vcn_id         = var.wls_vcn_id
  display_name   = "${var.service_name}-wls_dns_security_list"

  // allow outbound traffic on all ports for all protocols
  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"       // All protocols and all ports
  }

  // allow inbound ssh traffic
  ingress_security_rules {
    protocol  = "6"         // tcp
    source    = "0.0.0.0/0"
    stateless = false

    tcp_options {
      min = 22
      max = 22
    }
  }

  // allow inbound icmp type 3 traffic (required for SSH)
  // To enable MTU negotiation for ingress internet traffic,
  // make sure to allow type 3 ("Destination Unreachable")
  // code 4 ("Fragmentation Needed and Don't Fragment was Set").
  ingress_security_rules {
    protocol  = "1"         // ICMP
    source    = "0.0.0.0/0"
    stateless = false

    icmp_options {
      #Required
      type = "3"
      code = "4"
    }
  }

  // allow inbound traffic to DNS port 53 for UDP protocol for WLS VCN CIDR
  ingress_security_rules {
    protocol  = "17"                  // udp
    source    = var.wls_vcn_cidr == "" ? lookup(data.oci_core_vcns.wls_vcn[0].virtual_networks[0], "cidr_block") : var.wls_vcn_cidr
    stateless = false

    udp_options {
      min = 53
      max = 53
    }
  }

  ingress_security_rules {
    protocol  = "6"                  // tcp
    source    = var.wls_vcn_cidr == "" ? lookup(data.oci_core_vcns.wls_vcn[0].virtual_networks[0], "cidr_block") : var.wls_vcn_cidr
    stateless = false

    tcp_options {
      min = 53
      max = 53
    }
  }

  // allow inbound traffic to DNS port 53 for UDP protocol for OCI DB VCN CIDR
  ## AppDB and InfraDB Peering related notes.
  # We may have a situation where only appDB is peering but InfraDB is not. In that case, the lookup in the "source"
  # attribute below results in an error. Same situation for the case where InfraDB is peering and AppDB is not.
  # To cover this, we will do a if condition and switch to the other DB type if the one attempted is empty. This will
  # result in duplicate ingress rules but that is allowed. Logic is based on the fact that if we reach here either AppDB
  # or InfraDB is peering or both of them are peering.
  ingress_security_rules {
    protocol  = "17"                    // udp
    source    = var.is_vcn_peering ? lookup(data.oci_core_vcns.ocidb_vcn[0].virtual_networks[0],"cidr_block") : lookup(data.oci_core_vcns.appdb_vcn[0].virtual_networks[0],"cidr_block")
    stateless = false

    udp_options {
      min = 53
      max = 53
    }
  }

  ingress_security_rules {
    protocol  = "6"                    // tcp
    source    = var.is_vcn_peering ? lookup(data.oci_core_vcns.ocidb_vcn[0].virtual_networks[0],"cidr_block") : lookup(data.oci_core_vcns.appdb_vcn[0].virtual_networks[0],"cidr_block")
    stateless = false

    tcp_options {
      min = 53
      max = 53
    }
  }

  // allow inbound traffic to DNS port 53 for UDP protocol for App DB VCN CIDR. Fall back to InfraDB if appDB is not peered.
  ingress_security_rules {
    protocol  = "17"                    // udp
    source    = var.appdb_vcn_peering ? lookup(data.oci_core_vcns.appdb_vcn[0].virtual_networks[0],"cidr_block") : lookup(data.oci_core_vcns.ocidb_vcn[0].virtual_networks[0],"cidr_block")
    stateless = false

    udp_options {
      min = 53
      max = 53
    }
  }

  ingress_security_rules {
    protocol  = "6"                    // tcp
    source    = var.appdb_vcn_peering ? lookup(data.oci_core_vcns.appdb_vcn[0].virtual_networks[0],"cidr_block") : lookup(data.oci_core_vcns.ocidb_vcn[0].virtual_networks[0],"cidr_block")
    stateless = false

    tcp_options {
      min = 53
      max = 53
    }
  }

  defined_tags = var.defined_tags
  freeform_tags = var.freeform_tags
}

resource "oci_core_dhcp_options" "wls-dns-dhcp-options" {
  count          = (var.is_vcn_peering || var.appdb_vcn_peering) ? 1:0
  compartment_id = var.network_compartment_id
  vcn_id         = var.wls_vcn_id
  display_name   = "${var.service_name}-wls-dns-dhcp-option"

  // required
  options {
    type        = "DomainNameServer"
    server_type = "VcnLocalPlusInternet"
  }

  defined_tags = var.defined_tags
  freeform_tags = var.freeform_tags
}

resource "oci_core_subnet" "wls-dns-subnet-newvcn" {
  count = (var.is_vcn_peering || var.appdb_vcn_peering) && var.wls_vcn_name != "" ? 1:0

  availability_domain = var.use_regional_subnet?"":var.wls_availability_domain
  cidr_block          = var.wls_dns_subnet_cidr
  display_name        = "${var.service_name}-wls-dns-subnet-${var.wls_availability_domain}"
  dns_label           = local.dns_label
  compartment_id      = var.network_compartment_id
  vcn_id              = var.wls_vcn_id
  security_list_ids   = [oci_core_security_list.wls_dns_security_list[0].id]

  // Using the route table created with rule for LPG
  route_table_id  = (var.is_vcn_peering && var.appdb_vcn_peering) ? oci_core_route_table.wls-app-infra-db-public-route-table-newvcn[0].id : (var.is_vcn_peering && !var.appdb_vcn_peering) ? oci_core_route_table.wls-public-route-table-newvcn[0].id : oci_core_route_table.wls-appdb-public-route-table-newvcn[0].id
  dhcp_options_id = oci_core_dhcp_options.wls-dns-dhcp-options[0].id
}

resource "oci_core_subnet" "wls-dns-subnet-existingvcn" {
  count = (var.is_vcn_peering || var.appdb_vcn_peering) && var.wls_vcn_name == "" ? 1:0

  availability_domain = var.use_regional_subnet?"":var.wls_availability_domain
  cidr_block          = var.wls_dns_subnet_cidr
  display_name        = "${var.service_name}-wls-dns-subnet-${var.wls_availability_domain}"
  dns_label           = local.dns_label
  compartment_id      = var.network_compartment_id
  vcn_id              = var.wls_vcn_id
  security_list_ids   = [oci_core_security_list.wls_dns_security_list[0].id]

  // Using the route table created with rule for LPG

  route_table_id  = (var.is_vcn_peering && var.appdb_vcn_peering) ? oci_core_route_table.wls-infra-app-db-public-route-table-existingvcn[0].id : (var.is_vcn_peering && !var.appdb_vcn_peering) ? oci_core_route_table.wls-public-route-table-existingvcn[0].id : oci_core_route_table.wls-appdb-public-route-table-existingvcn[0].id
  dhcp_options_id = oci_core_dhcp_options.wls-dns-dhcp-options[0].id

  defined_tags = var.defined_tags
  freeform_tags = var.freeform_tags
}

resource "oci_core_instance" "wls_dns_vm-newvcn" {
  count = (var.is_vcn_peering || var.appdb_vcn_peering) && var.wls_vcn_name != ""? 1:0

  // Adding explicit dependency on OCI DB DNS VM to be created first so the DNS setup on WLS DNS VM is proper.
  depends_on          = [oci_core_instance.ocidb_dns_vm]
  availability_domain = var.wls_availability_domain
  compartment_id      = var.compartment_ocid
  display_name        = "${var.service_name}-wlsdns-${count.index}"
  shape               = local.shape

  shape_config {
    ocpus = length(regexall(local.shape, "^.*Flex"))>0 ? var.default_flex_ocpus:  lookup(data.oci_core_shapes.oci_shapes_with_wls_ad[0].shapes[0], "ocpus")
  }
  create_vnic_details {
    subnet_id        = oci_core_subnet.wls-dns-subnet-newvcn[0].id
    display_name     = "primaryvnic"
    assign_public_ip = true
    hostname_label   = "${var.service_name}-wlsdns-vnic-${count.index}"
  }

  source_details {
    source_type = "image"
    source_id   = var.instance_image_id

    # Apply this to set the size of the boot volume that's created for this instance.
    # Otherwise, the default boot volume size of the image is used.
    # This should only be specified when source_type is set to "image".
    #boot_volume_size_in_gbs = "60"
  }

  metadata = {
    ssh_authorized_keys = "${var.ssh_public_key}\n${tls_private_key.dns_opc_key[0].public_key_openssh}"
  }

  timeouts {
    create = "60m"
  }
}

resource "oci_core_instance" "wls_dns_vm-existingvcn" {
  count = (var.is_vcn_peering || var.appdb_vcn_peering) && var.wls_vcn_name == ""? 1:0

  // Adding explicit dependency on OCI DB DNS VM to be created first so the DNS setup on WLS DNS VM is proper.
  depends_on          = [oci_core_instance.ocidb_dns_vm]
  availability_domain = var.wls_availability_domain
  compartment_id      = var.compartment_ocid
  display_name        = "${var.service_name}-wlsdns-${count.index}"
  shape               = local.shape

  shape_config {
    ocpus = length(regexall(local.shape, "^.*Flex"))>0 ? var.default_flex_ocpus:  lookup(data.oci_core_shapes.oci_shapes_with_wls_ad[0].shapes[0], "ocpus")
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.wls-dns-subnet-existingvcn[0].id
    display_name     = "primaryvnic"
    assign_public_ip = true
    hostname_label   = "${var.service_name}-wlsdns-vnic-${count.index}"
  }

  source_details {
    source_type = "image"
    source_id   = var.instance_image_id

    # Apply this to set the size of the boot volume that's created for this instance.
    # Otherwise, the default boot volume size of the image is used.
    # This should only be specified when source_type is set to "image".
    #boot_volume_size_in_gbs = "60"
  }

  metadata = {
    ssh_authorized_keys = "${var.ssh_public_key}\n${tls_private_key.dns_opc_key[0].public_key_openssh}"
  }

  timeouts {
    create = "60m"
  }

  defined_tags = var.defined_tags
  freeform_tags = var.freeform_tags
}
