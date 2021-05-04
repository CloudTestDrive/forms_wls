# Home directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"/..
cd $DIR

# Maximum 4 characters (6 due to limitation of DB_NAME length)
#                      (4 due to limitation of RCU prefix to 12 characters)
export PREFIX=oblg
# Used during the creation of the ATP database
export TF_VAR_db_password=BEstrO0ng_#12

# General OCI settings
export TF_VAR_tenancy_ocid=ocid1.tenancy.oc1..aaaaaaaatcgoxmy5ygsarzpb6wtr7slzviel2vczxgaabcdefghijklm
export TF_VAR_user_ocid=ocid1.user.oc1..aaaaaaaarkxpe2xf5yx6vhangt4okjub2dczqx2cpes3dabcdefghijklm
export TF_VAR_compartment_ocid=ocid1.compartment.oc1..aaaaaaaa5dhfjfsbdcz5ikajnlsjqufpjooywjdmac5dabcdefghijklm
export TF_VAR_fingerprint=$(cat ~/.oci/oci_api_key_fingerprint)
export TF_VAR_private_key_path=~/.oci/oci_api_key.pem
export TF_VAR_ssh_public_key=$(cat ~/.ssh/id_rsa.pub)
export TF_VAR_ssh_private_key=$(cat ~/.ssh/id_rsa)
export TF_VAR_region=eu-frankfurt-1

# WLS_STACK 
export TF_VAR_wls_admin_password_ocid=ocid1.vaultsecret.oc1.eu-frankfurt-1.amaaaaaasu25dsyaa5gk4nzbcjpbex4uehuropwf4r25abcdefghijklm
export TF_VAR_atp_db_password_ocid=ocid1.vaultsecret.oc1.eu-frankfurt-1.amaaaaaasu25dsyax6tclkwwrflvj356givw7uegfmbxabcdefghijklm
export TF_VAR_prefix=$PREFIX
export TF_VAR_install_mode=ATP
export TF_VAR_wls_node_count=1

# DNS
# export TF_VAR_dns_zone_name_or_id=ocid1.dns-zone.oc1..408c278890a140fb86642550af6dd978
# export TF_VAR_dns_build=${PREFIX}build.orablog.org
# export TF_VAR_dns_lb=${PREFIX}lb.orablog.org

# IDCS
export TF_VAR_is_idcs_selected=false	
export TF_VAR_idcs_tenant=idcs-cedcabd3bef6418c96358b5a7a20a437
export TF_VAR_idcs_client_id=24bfdc1ea5eb4b00a13e4393e90bc1ac
export TF_VAR_idcs_client_secret_ocid=ocid1.vaultsecret.oc1.eu-frankfurt-1.amaaaaaasu25dsyanag377c5mtxo6wffski6rjjupjxukjkxrxjwulg6xvgq
# Client ID 24bfdc1ea5eb4b00a13e4393e90bc1ac
# Client Secret 3449b273-2602-4844-a810-e39e9f8a991d

# read from edelivery/terraform.tfstate
if [ -f "terraform/edelivery/terraform.tfstate" ]; then
  export TF_VAR_build_public_ip=`jq -r '.resources[] | select(.name=="orablog_build") | .instances[0].attributes.public_ip' terraform/edelivery/terraform.tfstate`
  export TF_VAR_subnet=`jq -r '.resources[] | select(.name=="orablog_subnet") | .instances[0].attributes.id' terraform/edelivery/terraform.tfstate`
  export TF_VAR_subnet_ad=`jq -r '.resources[] | select(.name=="orablog_subnet_ad") | .instances[0].attributes.id' terraform/edelivery/terraform.tfstate`
  export TF_VAR_subnet_ad2=`jq -r '.resources[] | select(.name=="orablog_subnet_ad2") | .instances[0].attributes.id' terraform/edelivery/terraform.tfstate`
  export TF_VAR_subnet_priv=`jq -r '.resources[] | select(.name=="orablog_subnet_priv") | .instances[0].attributes.id' terraform/edelivery/terraform.tfstate`
  export TF_VAR_vcn=`jq -r '.resources[] | select(.name=="orablog_vcn") | .instances[0].attributes.id' terraform/edelivery/terraform.tfstate`
  export TF_VAR_export_set=`jq -r '.resources[] | select(.name=="orablog_export_set") | .instances[0].attributes.id' terraform/edelivery/terraform.tfstate`
  export mount_ip_address=`jq -r '.resources[] | select(.name=="orablog_mount_target") | .instances[0].attributes.ip_address' terraform/edelivery/terraform.tfstate`
  export TF_VAR_mount_software=${mount_ip_address}:/software
  export TF_VAR_atp_db_id=`jq -r '.resources[] | select(.name=="orablog_atp") | .instances[0].attributes.id' terraform/edelivery/terraform.tfstate`
fi