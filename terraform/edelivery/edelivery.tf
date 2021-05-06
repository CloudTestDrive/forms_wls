// Terraform Edelivery Helper
// Date: 2020 11 08
// Author: Marc Gueury

// -- OCI Provider ----------------------------------------------------------
provider "oci" {
//  tenancy_ocid     = var.tenancy_ocid
//  user_ocid        = var.user_ocid
//  fingerprint      = var.fingerprint
//  private_key_path = var.private_key_path
  region           = var.region
}

// -- VCN -------------------------------------------------------------------
resource "oci_core_vcn" "orablog_vcn" {
  cidr_block     = "10.0.0.0/16"
  compartment_id = var.compartment_ocid
  display_name   = "${var.prefix}Vcn"
  dns_label      = "${var.prefix}vcn"
}

// -- SECURITY_LIST ---------------------------------------------------------
resource "oci_core_security_list" "orablog_security_list" {
  display_name   = "public"
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.orablog_vcn.id

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
  }

  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"
    tcp_options {
      max = "22"
      min = "22"
    }
    #udp_options = <<Optional value not found in discovery>>
  }

  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"
    tcp_options {
      min = 80
      max = 80
    }
  }

  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"
    tcp_options {
      min = 443
      max = 443
    }
  }

  // Forms port
  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"
    tcp_options {
      min = 9001
      max = 9001
    }
  }

  ingress_security_rules {
    protocol = "6"
    source   = "10.0.0.0/16"
    tcp_options {
      min = 2048
      max = 2050
    }
  }

  ingress_security_rules {
    protocol = "17"
    source   = "10.0.0.0/16"
    udp_options {
      min = 2048
      max = 2048
    }
  }

  ingress_security_rules {
    protocol = "6"
    source   = "10.0.0.0/16"
    tcp_options {
      min = 111
      max = 111
    }
  }

  ingress_security_rules {
    protocol = "6"
    source   = "10.0.0.0/16"
    tcp_options {
      min = 8140
      max = 8140
    }
  }

  # DB connection between machines
  ingress_security_rules {
    protocol = "6"
    source   = "10.0.0.0/16"
    tcp_options {
      min = 1521
      max = 1522
    }
  }

  # Weblogic connection between machines
  ingress_security_rules {
    protocol = "6"
    source   = "10.0.0.0/16"
    tcp_options {
      min = 7000
      max = 10000
    }
  }

  ingress_security_rules {
    protocol = "17"
    source   = "10.0.0.0/16"
    udp_options {
      min = 111
      max = 111
    }
  }
}

// -- AVAILIBILITY_DOMAIN ----------------------------------------------------
data "oci_identity_availability_domain" "ad" {
  compartment_id = var.tenancy_ocid
  ad_number      = var.ad_number
}

// -- AVAILIBILITY_DOMAIN ----------------------------------------------------
data "oci_identity_availability_domain" "ad2" {
  compartment_id = var.tenancy_ocid
  ad_number      = var.ad2_number
}

// -- INTERNET_GATEWAY ------------------------------------------------------
resource "oci_core_internet_gateway" "orablog_internet_gateway" {
  compartment_id = var.compartment_ocid
  display_name   = "${var.prefix}InternetGateway"
  vcn_id         = oci_core_vcn.orablog_vcn.id
}

// -- NAT_GATEWAY ------------------------------------------------------
resource "oci_core_nat_gateway" "orablog_nat_gateway" {
  compartment_id = var.compartment_ocid
  display_name   = "${var.prefix}NatGateway"
  vcn_id         = oci_core_vcn.orablog_vcn.id
}

// -- ROUTE_TABLE -----------------------------------------------------------
resource "oci_core_route_table" "orablog_route_table" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.orablog_vcn.id
  display_name   = "${var.prefix}RouteTable"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.orablog_internet_gateway.id
  }
}

// -- ROUTE_TABLE -----------------------------------------------------------
resource "oci_core_route_table" "orablog_route_table_priv" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.orablog_vcn.id
  display_name   = "${var.prefix}RouteTable"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.orablog_nat_gateway.id
  }
}

// -- SUBNET ----------------------------------------------------------------
resource "oci_core_subnet" "orablog_subnet" {
  cidr_block        = "10.0.0.0/24"
  display_name      = "${var.prefix}Subnet"
  dns_label         = "${var.prefix}subnet"
  security_list_ids = [oci_core_security_list.orablog_security_list.id]
  compartment_id    = var.compartment_ocid
  vcn_id            = oci_core_vcn.orablog_vcn.id
  route_table_id    = oci_core_route_table.orablog_route_table.id
  dhcp_options_id   = oci_core_vcn.orablog_vcn.default_dhcp_options_id
}

resource "oci_core_subnet" "orablog_subnet_ad" {
  availability_domain = data.oci_identity_availability_domain.ad.name
  cidr_block          = "10.0.2.0/24"
  display_name        = "${var.prefix}SubnetAD"
  dns_label           = "${var.prefix}subnetad"
  security_list_ids   = [oci_core_security_list.orablog_security_list.id]
  compartment_id      = var.compartment_ocid
  vcn_id              = oci_core_vcn.orablog_vcn.id
  route_table_id      = oci_core_route_table.orablog_route_table.id
  dhcp_options_id     = oci_core_vcn.orablog_vcn.default_dhcp_options_id
}

resource "oci_core_subnet" "orablog_subnet_ad2" {
  availability_domain = data.oci_identity_availability_domain.ad2.name
  cidr_block          = "10.0.3.0/24"
  display_name        = "${var.prefix}SubnetAD2"
  dns_label           = "${var.prefix}subnetad2"
  security_list_ids   = [oci_core_security_list.orablog_security_list.id]
  compartment_id      = var.compartment_ocid
  vcn_id              = oci_core_vcn.orablog_vcn.id
  route_table_id      = oci_core_route_table.orablog_route_table.id
  dhcp_options_id     = oci_core_vcn.orablog_vcn.default_dhcp_options_id
}

resource "oci_core_subnet" "orablog_subnet_priv" {
  cidr_block        = "10.0.4.0/24"
  display_name      = "${var.prefix}SubnetPriv"
  dns_label         = "${var.prefix}SubnetPriv"
  security_list_ids = [oci_core_security_list.orablog_security_list.id]
  compartment_id    = var.compartment_ocid
  vcn_id            = oci_core_vcn.orablog_vcn.id
  route_table_id    = oci_core_route_table.orablog_route_table_priv.id
  dhcp_options_id   = oci_core_vcn.orablog_vcn.default_dhcp_options_id
  prohibit_public_ip_on_vnic = true
}

// -- FSS -------------------------------------------------------------------
resource "oci_file_storage_file_system" "orablog_software" {
  #Required
  availability_domain = data.oci_identity_availability_domain.ad.name
  compartment_id      = var.compartment_ocid

  #Optional
  display_name = "${var.prefix}Software"
}

// -- Mount Target -----------------------------------------------------------
resource "oci_file_storage_mount_target" "orablog_mount_target" {
  #Required
  availability_domain = data.oci_identity_availability_domain.ad.name
  compartment_id      = var.compartment_ocid
  subnet_id           = oci_core_subnet.orablog_subnet_ad.id
  ip_address          = "10.0.2.250"
}

resource "oci_file_storage_export_set" "orablog_export_set" {
  # Required
  mount_target_id = oci_file_storage_mount_target.orablog_mount_target.id
  # Optional
  display_name = "${var.prefix}ExportSet"
}

resource "oci_file_storage_export" "orablog_software_export" {
  #Required
  export_set_id  = oci_file_storage_export_set.orablog_export_set.id
  file_system_id = oci_file_storage_file_system.orablog_software.id
  path           = "/software"
}

// -- build ------------------------------------------------------------
data "template_file" "user_data_build" {
  template = file("./user_data_build.sh")

  vars = {
    mount_ip_adress = oci_file_storage_mount_target.orablog_mount_target.ip_address
    server_text     = var.server_text
  }
}

resource "oci_core_instance" "orablog_build" {
  compartment_id      = var.compartment_ocid
  shape               = var.instance_shape
  display_name        = "${var.prefix}Build"
  availability_domain = data.oci_identity_availability_domain.ad.name

  create_vnic_details {
    assign_public_ip       = true
    display_name           = "build"
    skip_source_dest_check = false
    subnet_id              = oci_core_subnet.orablog_subnet.id
  }

  source_details {
    source_type = "image"
    source_id   = var.instance_image_ocid.eu-frankfurt-1
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    user_data           = base64encode(data.template_file.user_data_build.rendered)
    prefix              = var.prefix
  }

  provisioner "file" {
    connection {
      agent       = false
      timeout     = "5m"
      user        = "opc"
      private_key = var.ssh_private_key
      host        = oci_core_instance.orablog_build.*.public_ip[0]
    }
    source      = "${path.module}/../../mnt_software.zip"
    destination = "/tmp/mnt_software.zip"
  }
}

// ------------------------ Autonomous database -----------------------------
resource "oci_database_autonomous_database" "orablog_atp" {
  #Required
  admin_password           = var.db_password
  compartment_id           = var.compartment_ocid
  cpu_core_count           = "1"
  data_storage_size_in_tbs = "1"
  db_name                  = "${var.prefix}atp"

  #Optional
  db_workload                                    = "OLTP"
  display_name                                   = "${var.prefix}atp"
  is_auto_scaling_enabled                        = "false"
  license_model                                  = var.license_model
  is_preview_version_with_service_terms_accepted = "false"
  count                                          = var.install_mode == "ATP" ? 1 : 0
}

// Copy the wallet to ../../wallet.zip
resource "local_file" "autonomous_database_wallet_file" {
  content_base64 = oci_database_autonomous_database_wallet.autonomous_database_wallet[0].content
  filename       = "../../${var.prefix}atp_wallet.zip"
  count = var.install_mode == "ATP" ? 1 : 0
}

resource "oci_database_autonomous_database_wallet" "autonomous_database_wallet" {
  autonomous_database_id = oci_database_autonomous_database.orablog_atp[0].id
  password               = var.db_password
  base64_encode_content  = "true"
  count = length(oci_database_autonomous_database.orablog_atp)
}

// -- DNS -------------------------------------------------------------------

resource "oci_dns_rrset" "orablog_dns_rrset" {
  count  = var.dns_zone_name_or_id != "" ? 1 : 0
  zone_name_or_id = var.dns_zone_name_or_id
  domain          = var.dns_build
  rtype           = "A"

  items {
    domain = var.dns_build
    rtype  = "A"
    rdata  = oci_core_instance.orablog_build.*.public_ip[0]
    ttl    = 3600
  }
}

// -- OUTPUT ----------------------------------------------------------------
output "mount_target_IPs" {
  value = [oci_file_storage_mount_target.orablog_mount_target.ip_address]
}

output "build_public_ip" {
  value = [oci_core_instance.orablog_build.*.public_ip]
}

output "autonomous_database_connection_strings" {
  value = oci_database_autonomous_database.orablog_atp[0].connection_strings[0].all_connection_strings
}

output "autonomous_database_wallet" {
  value = "${var.prefix}atp_wallet.zip"
}
