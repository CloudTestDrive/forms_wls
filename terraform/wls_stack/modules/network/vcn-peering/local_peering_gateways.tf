/*
 * Copyright (c) 2019 Oracle and/or its affiliates. All rights reserved.
 */
resource "oci_core_local_peering_gateway" "ocidb_local_peering_gateway" {
  count = var.is_vcn_peering?1:0

  #Required
  compartment_id = lookup(data.oci_database_db_systems.ocidb_db_systems[0].db_systems[0], "compartment_id")
  vcn_id         = var.ocidb_existing_vcn_id

  #Optional
  display_name = "${var.service_name}-dbsystem-lpg"

  defined_tags = var.defined_tags
  freeform_tags = var.freeform_tags
}

resource "oci_core_local_peering_gateway" "appdb_local_peering_gateway" {
  count = var.appdb_vcn_peering ?1:0

  #Required
  compartment_id = lookup(data.oci_database_db_systems.appdb_db_systems[0].db_systems[0], "compartment_id")
  vcn_id         = var.appdb_existing_vcn_id

  #Optional
  display_name = "${var.service_name}-appdb-dbsystem-lpg"

  defined_tags = var.defined_tags
  freeform_tags = var.freeform_tags
}

resource "oci_core_local_peering_gateway" "wls_local_peering_gateway" {
  count = var.is_vcn_peering?1:0

  #Required
  compartment_id = var.network_compartment_id
  vcn_id         = var.wls_vcn_id

  #Optional
  display_name = "${var.service_name}-wls-lpg"

  #Peer WLS and OCI DB LPGs
  peer_id = oci_core_local_peering_gateway.ocidb_local_peering_gateway[0].id

  defined_tags = var.defined_tags
  freeform_tags = var.freeform_tags
}

resource "oci_core_local_peering_gateway" "appdb_wls_local_peering_gateway" {
  count = var.appdb_vcn_peering ?1:0

  #Required
  compartment_id = var.network_compartment_id
  vcn_id         = var.wls_vcn_id

  #Optional
  display_name = "${var.service_name}-appdb-wls-lpg"

  #Peer WLS and OCI DB LPGs
  peer_id = oci_core_local_peering_gateway.appdb_local_peering_gateway[0].id

  defined_tags = var.defined_tags
  freeform_tags = var.freeform_tags
}

/*
 The route table below assumes DB is in public subnet.
 TODO handle the case when DB system could be in private subnet.
*/
resource "oci_core_route_table" "ocidb-route-table" {
  count                      = var.is_vcn_peering ? 1:0

  compartment_id = lookup(data.oci_database_db_systems.ocidb_db_systems[0].db_systems[0], "compartment_id")
  vcn_id         = var.ocidb_existing_vcn_id
  display_name   = "${var.service_name}-dbsystem-routetable"

  # Direct all traffic for WLS VCN to local OCI DB LPG
  route_rules {
    destination       = var.wls_vcn_cidr == "" ? lookup(data.oci_core_vcns.wls_vcn[0].virtual_networks[0], "cidr_block") : var.wls_vcn_cidr
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_local_peering_gateway.ocidb_local_peering_gateway[0].id
  }

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = lookup(data.oci_core_internet_gateways.ocidb_vcn_internet_gateway[0].gateways[0], "id")
  }

  defined_tags = var.defined_tags
  freeform_tags = var.freeform_tags
}

resource "oci_core_route_table" "appdb-route-table" {
  count                      = var.appdb_vcn_peering ? 1:0

  compartment_id = lookup(data.oci_database_db_systems.appdb_db_systems[0].db_systems[0], "compartment_id")
  vcn_id         = var.appdb_existing_vcn_id
  display_name   = "${var.service_name}-appdb-dbsystem-routetable"

  # Direct all traffic for WLS VCN to local OCI DB LPG
  route_rules {
    destination       = var.wls_vcn_cidr == "" ? lookup(data.oci_core_vcns.wls_vcn[0].virtual_networks[0], "cidr_block") : var.wls_vcn_cidr
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_local_peering_gateway.appdb_local_peering_gateway[0].id
  }

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = lookup(data.oci_core_internet_gateways.appdb_vcn_internet_gateway[0].gateways[0], "id")
  }

  defined_tags = var.defined_tags
  freeform_tags = var.freeform_tags
}


/*
* Associate the new route table for OCI DB with its subnet.
*/
resource "oci_core_route_table_attachment" "ocidb_route_table_attachment" {
  count                      = var.is_vcn_peering ? 1:0
  #Required
  subnet_id = lookup(data.oci_database_db_systems.ocidb_db_systems[0].db_systems[0], "subnet_id")
  route_table_id =oci_core_route_table.ocidb-route-table[0].id
}

/*
* Associate the new route table for App DB with its subnet.
*/
resource "oci_core_route_table_attachment" "appdb_route_table_attachment" {
  count = var.appdb_vcn_peering ? 1:0
  #Required
  subnet_id = lookup(data.oci_database_db_systems.appdb_db_systems[0].db_systems[0], "subnet_id")
  route_table_id =oci_core_route_table.appdb-route-table[0].id
}

/*
* Creates route table for public subnet using internet gateway when creating a new VCN
* - internet gateway is created.
* This route table is attached to both WLSC instances (in case of public subnet only) and also to
* WLS DNS instance (always as it uses public subnet in any case).
*/
# Case 1: Only Infra DB is Peering
resource "oci_core_route_table" "wls-public-route-table-newvcn" {
  count = (var.is_vcn_peering && !var.appdb_vcn_peering) && var.wls_vcn_name != ""? 1: 0

  compartment_id = var.network_compartment_id
  vcn_id         = var.wls_vcn_id
  display_name   = "${var.service_name}-public-routetable"

  route_rules {
    destination       = lookup(data.oci_core_vcns.ocidb_vcn[0].virtual_networks[0],"cidr_block")
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_local_peering_gateway.wls_local_peering_gateway[0].id
  }

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = var.wls_internet_gateway_id
  }
}

# We had to duplicate the routetable because we cannot have duplicate/empty destinations for route_rules unlike sec-rules.
# Case 2: Only App DB is Peering
resource "oci_core_route_table" "wls-appdb-public-route-table-newvcn" {
  count = (var.appdb_vcn_peering && !var.is_vcn_peering) && var.wls_vcn_name != ""? 1: 0

  compartment_id = var.network_compartment_id
  vcn_id         = var.wls_vcn_id
  display_name   = "${var.service_name}-appdb-public-routetable"

  route_rules {
    destination       = lookup(data.oci_core_vcns.appdb_vcn[0].virtual_networks[0],"cidr_block")
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_local_peering_gateway.appdb_wls_local_peering_gateway[0].id
  }

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = var.wls_internet_gateway_id
  }
}

# Case 3: Both App & Infra DB are Peering
resource "oci_core_route_table" "wls-app-infra-db-public-route-table-newvcn" {
  count = var.appdb_vcn_peering && var.is_vcn_peering && var.wls_vcn_name != ""? 1: 0

  compartment_id = var.network_compartment_id
  vcn_id         = var.wls_vcn_id
  display_name   = "${var.service_name}-infra-app-db-public-routetable"

  route_rules {
    destination       = lookup(data.oci_core_vcns.appdb_vcn[0].virtual_networks[0],"cidr_block")
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_local_peering_gateway.appdb_wls_local_peering_gateway[0].id
  }

  route_rules {
    destination       = lookup(data.oci_core_vcns.ocidb_vcn[0].virtual_networks[0],"cidr_block")
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_local_peering_gateway.wls_local_peering_gateway[0].id
  }

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = var.wls_internet_gateway_id
  }
}

// Only assign to WLSC instance when using public subnet.
# Case 1: Only Infra DB is peering. Attach corresponding route table.
resource "oci_core_route_table_attachment" "wls_public_route_table_attachment-newvcn" {
  count = var.assign_public_ip && (var.is_vcn_peering && !var.appdb_vcn_peering) && var.wls_vcn_name != ""? 1: 0
  #Required
  subnet_id = var.wls_subnet_id
  route_table_id =oci_core_route_table.wls-public-route-table-newvcn[0].id
}

# See comment above wls-appdb-public-route-table-newvcn resource definition.
# Case 2: Only AppDB is peering.
resource "oci_core_route_table_attachment" "wls_appdb-public_route_table_attachment-newvcn" {
  count = var.assign_public_ip && (var.appdb_vcn_peering && !var.is_vcn_peering) && var.wls_vcn_name != ""? 1: 0
  #Required
  subnet_id = var.wls_subnet_id
  route_table_id =oci_core_route_table.wls-appdb-public-route-table-newvcn[0].id
}

# Case 3: Both InfraDB and AppDB are peering.
resource "oci_core_route_table_attachment" "wls_infra_app_db-public_route_table_attachment-newvcn" {
  count = var.assign_public_ip && var.appdb_vcn_peering && var.is_vcn_peering && var.wls_vcn_name != ""? 1: 0
  #Required
  subnet_id = var.wls_subnet_id
  route_table_id =oci_core_route_table.wls-app-infra-db-public-route-table-newvcn[0].id
}

## Repeat the above (1 peering Vs 2 Peer adjustments) for existing VCN case.
resource "oci_core_route_table" "wls-public-route-table-existingvcn" {
  count = (var.is_vcn_peering && !var.appdb_vcn_peering) && var.wls_vcn_name == ""? 1: 0

  compartment_id = var.network_compartment_id
  vcn_id         = var.wls_vcn_id
  display_name   = "${var.service_name}-public-routetable"

  route_rules {
    destination       = lookup(data.oci_core_vcns.ocidb_vcn[0].virtual_networks[0],"cidr_block")
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_local_peering_gateway.wls_local_peering_gateway[0].id
  }

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = lookup(data.oci_core_internet_gateways.wls_vcn_internet_gateway[0].gateways[0], "id")
  }
}

# See comment above wls-appdb-public-route-table-newvcn resource definition.
resource "oci_core_route_table" "wls-appdb-public-route-table-existingvcn" {
  count = (var.appdb_vcn_peering && !var.is_vcn_peering) && var.wls_vcn_name == ""? 1: 0

  compartment_id = var.network_compartment_id
  vcn_id         = var.wls_vcn_id
  display_name   = "${var.service_name}-appdb-public-routetable"

  route_rules {
    destination       = lookup(data.oci_core_vcns.appdb_vcn[0].virtual_networks[0],"cidr_block")
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_local_peering_gateway.appdb_wls_local_peering_gateway[0].id
  }

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = lookup(data.oci_core_internet_gateways.wls_vcn_internet_gateway[0].gateways[0], "id")
  }
}

resource "oci_core_route_table" "wls-infra-app-db-public-route-table-existingvcn" {
  count = (var.appdb_vcn_peering && var.is_vcn_peering) && var.wls_vcn_name == ""? 1: 0

  compartment_id = var.network_compartment_id
  vcn_id         = var.wls_vcn_id
  display_name   = "${var.service_name}-infra-app-db-public-routetable"

  route_rules {
    destination       = lookup(data.oci_core_vcns.appdb_vcn[0].virtual_networks[0],"cidr_block")
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_local_peering_gateway.appdb_wls_local_peering_gateway[0].id
  }

  route_rules {
    destination       = lookup(data.oci_core_vcns.ocidb_vcn[0].virtual_networks[0],"cidr_block")
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_local_peering_gateway.wls_local_peering_gateway[0].id
  }

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = lookup(data.oci_core_internet_gateways.wls_vcn_internet_gateway[0].gateways[0], "id")
  }
}

// Only assign to WLSC instance when using public subnet.
resource "oci_core_route_table_attachment" "wls_public_route_table_attachment-existingvcn" {
  count = var.assign_public_ip && (var.is_vcn_peering && !var.appdb_vcn_peering) && var.wls_vcn_name == "" ? 1: 0
  #Required
  subnet_id = var.wls_subnet_id
  route_table_id =oci_core_route_table.wls-public-route-table-existingvcn[0].id
}

resource "oci_core_route_table_attachment" "wls_appdb-public_route_table_attachment-existingvcn" {
  count = var.assign_public_ip && (!var.is_vcn_peering && var.appdb_vcn_peering) && var.wls_vcn_name == "" ? 1: 0
  #Required
  subnet_id = var.wls_subnet_id
  route_table_id =oci_core_route_table.wls-appdb-public-route-table-existingvcn[0].id
}

resource "oci_core_route_table_attachment" "wls_infra_app_db-public_route_table_attachment-existingvcn" {
  count = var.assign_public_ip && (var.is_vcn_peering && var.appdb_vcn_peering) && var.wls_vcn_name == "" ? 1: 0
  #Required
  subnet_id = var.wls_subnet_id
  route_table_id =oci_core_route_table.wls-infra-app-db-public-route-table-existingvcn[0].id
}

## Repeat for Private New VCN case.
# Case 1: Only InfraDB is Peering
resource "oci_core_route_table" "wls-private-route-table-newvcn" {
  count = !var.assign_public_ip && (var.is_vcn_peering && !var.appdb_vcn_peering) && var.wls_vcn_name != ""? 1: 0

  compartment_id = var.network_compartment_id
  vcn_id         = var.wls_vcn_id
  display_name   = "${var.service_name}-private-routetable"

  route_rules {
    destination       = lookup(data.oci_core_vcns.ocidb_vcn[0].virtual_networks[0],"cidr_block")
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_local_peering_gateway.wls_local_peering_gateway[0].id
  }

  route_rules {
    destination       = lookup(data.oci_core_services.tf_services.services[0], "cidr_block")
    destination_type  = "SERVICE_CIDR_BLOCK"
    network_entity_id = var.service_gateway_id
  }

  defined_tags = var.defined_tags
  freeform_tags = var.freeform_tags
}

# Case 2: Only AppDB is Peering
resource "oci_core_route_table" "wls-appdb-private-route-table-newvcn" {
  count = !var.assign_public_ip && (!var.is_vcn_peering && var.appdb_vcn_peering) && var.wls_vcn_name != ""? 1: 0

  compartment_id = var.network_compartment_id
  vcn_id         = var.wls_vcn_id
  display_name   = "${var.service_name}-appdb-private-routetable"

  route_rules {
    destination       = lookup(data.oci_core_vcns.appdb_vcn[0].virtual_networks[0],"cidr_block")
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_local_peering_gateway.appdb_wls_local_peering_gateway[0].id
  }

  route_rules {
    destination       = lookup(data.oci_core_services.tf_services.services[0], "cidr_block")
    destination_type  = "SERVICE_CIDR_BLOCK"
    network_entity_id = var.service_gateway_id
  }

  defined_tags = var.defined_tags
  freeform_tags = var.freeform_tags
}

# Case 3: Both InfraDB & AppDB are Peering
resource "oci_core_route_table" "wls-infra-app-db-private-route-table-newvcn" {
  count = !var.assign_public_ip && (var.is_vcn_peering && var.appdb_vcn_peering) && var.wls_vcn_name != ""? 1: 0

  compartment_id = var.network_compartment_id
  vcn_id         = var.wls_vcn_id
  display_name   = "${var.service_name}-infra-app-db-private-routetable"

  route_rules {
    destination       = lookup(data.oci_core_vcns.appdb_vcn[0].virtual_networks[0],"cidr_block")
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_local_peering_gateway.appdb_wls_local_peering_gateway[0].id
  }

  route_rules {
    destination       = lookup(data.oci_core_vcns.ocidb_vcn[0].virtual_networks[0],"cidr_block")
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_local_peering_gateway.wls_local_peering_gateway[0].id
  }

  route_rules {
    destination       = lookup(data.oci_core_services.tf_services.services[0], "cidr_block")
    destination_type  = "SERVICE_CIDR_BLOCK"
    network_entity_id = var.service_gateway_id
  }

  defined_tags = var.defined_tags
  freeform_tags = var.freeform_tags
}

# Case 1: Only InfraDB is Peering
resource "oci_core_route_table_attachment" "wls_private_route_table_attachment-newvcn" {
  count = !var.assign_public_ip && (var.is_vcn_peering && !var.appdb_vcn_peering) && var.wls_vcn_name != ""? 1: 0
  #Required
  subnet_id = var.wls_subnet_id
  route_table_id =oci_core_route_table.wls-private-route-table-newvcn[0].id
}

resource "oci_core_route_table_attachment" "wls_appdb_private_route_table_attachment-newvcn" {
  count = !var.assign_public_ip && (!var.is_vcn_peering && var.appdb_vcn_peering) && var.wls_vcn_name != ""? 1: 0
  #Required
  subnet_id = var.wls_subnet_id
  route_table_id =oci_core_route_table.wls-appdb-private-route-table-newvcn[0].id
}

resource "oci_core_route_table_attachment" "wls_infra_app_db_private_route_table_attachment-newvcn" {
  count = !var.assign_public_ip && (var.is_vcn_peering && var.appdb_vcn_peering) && var.wls_vcn_name != ""? 1: 0
  #Required
  subnet_id = var.wls_subnet_id
  route_table_id =oci_core_route_table.wls-infra-app-db-private-route-table-newvcn[0].id
}

# Repeat for Private Subnet with Exiting VCN case.
# Case 1: Only InfraDB is Peering
resource "oci_core_route_table" "wls-private-route-table-existingvcn" {
  count = !var.assign_public_ip && (var.is_vcn_peering && !var.appdb_vcn_peering) && var.wls_vcn_name == ""? 1: 0

  compartment_id = var.network_compartment_id
  vcn_id         = var.wls_vcn_id
  display_name   = "${var.service_name}-private-routetable"

  route_rules {
    destination       = lookup(data.oci_core_vcns.ocidb_vcn[0].virtual_networks[0],"cidr_block")
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_local_peering_gateway.wls_local_peering_gateway[0].id
  }

  route_rules {
    destination       = lookup(data.oci_core_services.tf_services.services[0], "cidr_block")
    destination_type  = "SERVICE_CIDR_BLOCK"
    network_entity_id = lookup(data.oci_core_service_gateways.wls_vcn_service_gateway[0].service_gateways[0], "id")
  }

  defined_tags = var.defined_tags
  freeform_tags = var.freeform_tags
}

# Case 2: Only AppDB is Peering
resource "oci_core_route_table" "wls-appdb-private-route-table-existingvcn" {
  count = !var.assign_public_ip && (!var.is_vcn_peering && var.appdb_vcn_peering) && var.wls_vcn_name == ""? 1: 0

  compartment_id = var.network_compartment_id
  vcn_id         = var.wls_vcn_id
  display_name   = "${var.service_name}-appdb-private-routetable"

  route_rules {
    destination       = lookup(data.oci_core_vcns.appdb_vcn[0].virtual_networks[0],"cidr_block")
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_local_peering_gateway.appdb_wls_local_peering_gateway[0].id
  }

  route_rules {
    destination       = lookup(data.oci_core_services.tf_services.services[0], "cidr_block")
    destination_type  = "SERVICE_CIDR_BLOCK"
    network_entity_id = lookup(data.oci_core_service_gateways.wls_vcn_service_gateway[0].service_gateways[0], "id")
  }

  defined_tags = var.defined_tags
  freeform_tags = var.freeform_tags
}

# Case 3: Both InfraDB & AppDB are Peering
resource "oci_core_route_table" "wls-infra-app-db-private-route-table-existingvcn" {
  count = !var.assign_public_ip && (var.is_vcn_peering && var.appdb_vcn_peering) && var.wls_vcn_name == ""? 1: 0

  compartment_id = var.network_compartment_id
  vcn_id         = var.wls_vcn_id
  display_name   = "${var.service_name}-infra-app-db-private-routetable"

  route_rules {
    destination       = lookup(data.oci_core_vcns.appdb_vcn[0].virtual_networks[0],"cidr_block")
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_local_peering_gateway.appdb_wls_local_peering_gateway[0].id
  }

  route_rules {
    destination       = lookup(data.oci_core_services.tf_services.services[0], "cidr_block")
    destination_type  = "SERVICE_CIDR_BLOCK"
    network_entity_id = lookup(data.oci_core_service_gateways.wls_vcn_service_gateway[0].service_gateways[0], "id")
  }

  route_rules {
    destination       = lookup(data.oci_core_vcns.ocidb_vcn[0].virtual_networks[0],"cidr_block")
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_local_peering_gateway.wls_local_peering_gateway[0].id
  }

  defined_tags = var.defined_tags
  freeform_tags = var.freeform_tags
}

# Repeat for route table attachment.
resource "oci_core_route_table_attachment" "wls_private_route_table_attachment-existingvcn" {
  count = !var.assign_public_ip && (var.is_vcn_peering && !var.appdb_vcn_peering ) && var.wls_vcn_name == ""? 1: 0
  #Required
  subnet_id = var.wls_subnet_id
  route_table_id =oci_core_route_table.wls-private-route-table-existingvcn[0].id
}

resource "oci_core_route_table_attachment" "wls_appdb_private_route_table_attachment-existingvcn" {
  count = !var.assign_public_ip && (!var.is_vcn_peering && var.appdb_vcn_peering) && var.wls_vcn_name == ""? 1: 0
  #Required
  subnet_id = var.wls_subnet_id
  route_table_id =oci_core_route_table.wls-appdb-private-route-table-existingvcn[0].id
}

resource "oci_core_route_table_attachment" "wls_infra_app_db_private_route_table_attachment-existingvcn" {
  count = !var.assign_public_ip && (var.is_vcn_peering && var.appdb_vcn_peering) && var.wls_vcn_name == ""? 1: 0
  #Required
  subnet_id = var.wls_subnet_id
  route_table_id =oci_core_route_table.wls-infra-app-db-private-route-table-existingvcn[0].id
}