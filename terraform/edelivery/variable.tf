// Terraform Variables definition 
// Date: 2020 11 08
// Author: Marc Gueury

variable "tenancy_ocid" {
}

variable "user_ocid" {
}

variable "fingerprint" {
}

variable "private_key_path" {
}

variable "region" {
}

variable "compartment_ocid" {
}

variable "ssh_public_key" {
}

variable "ssh_private_key" {
}

variable "db_password" {
}

variable "prefix" {
}

variable "install_mode" {
}

variable "ad_number" {
  default = "3"  
}

variable "ad2_number" {
  default = "2"  
}

variable "instance_shape" {
  default = "VM.Standard.E2.1"
}

variable "server_text" {
  description = "The text the web server should return"
  default     = "WeblogicInstancePool_2020_01_21"
  type        = string
}

# DBSystem specific 
variable "db_system_shape" {
  default = "VM.Standard2.1"
}

variable "db_edition" {
  default = "ENTERPRISE_EDITION"
}

variable "db_version" {
  default = "18.10.0.0"
}

variable "db_disk_redundancy" {
  default = "NORMAL"
}

variable "sparse_diskgroup" {
  default = true
}

variable "n_character_set" {
  default = "AL16UTF16"
}

variable "character_set" {
  default = "AL32UTF8"
}

variable "db_workload" {
  default = "OLTP"
}

variable "pdb_name" {
  default = "pdb1"
}

variable "data_storage_size_in_gb" {
  default = "256"
}

variable "license_model" {
  default = "BRING_YOUR_OWN_LICENSE"
}

variable "instance_pool_size" {
  default = "2"
}

variable "node_count" {
  default = "1"
}

variable "instance_image_ocid" {
  type = map(string)

  default = {
    # See https://docs.us-phoenix-1.oraclecloud.com/images/
    # See https://docs.cloud.oracle.com/iaas/images/image/501c6e22-4dc6-4e99-b045-cae47aae343f/
    # Oracle-provided image "Oracle-Linux-7.7-2019.11.12-0"
    us-phoenix-1   = "ocid1.image.oc1.phx.xxx"
    us-ashburn-1   = "ocid1.image.oc1.iad.xxx"
    eu-frankfurt-1 = "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaa3bu75jht762mfvwroa2gdck6boqwyktztyu5dfhftcycucyp63ma"
    uk-london-1    = "ocid1.image.oc1.uk-london-1.xxx"
  }
}

variable "dns_zone_name_or_id" {
    default = ""
}

variable "dns_build" {
    default = ""
}

// —————————————————————————————————
// From Edelivery
// —————————————————————————————————

variable "vcn" {
}

variable "subnet" {
}

variable "export_set" {
}

variable "mount_target_ip_address" {
}

