export TF_VAR_network_compartment_id=$TF_VAR_compartment_ocid
export TF_VAR_service_name=$PREFIX
# variable "network_compartment_id" {
export TF_VAR_instance_shape="VM.Standard.E2.2"
# export TF_VAR_allow_manual_domain_extension=true
export TF_VAR_wls_version=12.2.1.4
export TF_VAR_vcn_strategy="Use Existing VCN"	
export TF_VAR_wls_existing_vcn_id=$TF_VAR_vcn
export TF_VAR_subnet_strategy_new_vcn="Use Existing Subnet"
# export TF_VAR_subnet_span="AD Specific Subnet"
# export TF_VAR_subnet_type="Use Private Subnet"
export TF_VAR_is_bastion_instance_required=false
export TF_VAR_wls_subnet_id=$TF_VAR_subnet
export TF_VAR_lb_subnet_1_id=$TF_VAR_subnet
# export TF_VAR_lb_subnet_1_id=$TF_VAR_subnet_ad
# export TF_VAR_lb_subnet_2_id=$TF_VAR_subnet_ad2
export TF_VAR_use_advanced_wls_instance_config=true	
export TF_VAR_lb_shape=100Mbps	
export TF_VAR_add_load_balancer=true	
export TF_VAR_wls_subnet_cidr=10.0.10.0/24	
export TF_VAR_lb_subnet_1_cidr=10.0.11.0/24	
export TF_VAR_deploy_sample_app=false

# ATP
export TF_VAR_add_JRF=true
export TF_VAR_atp_db_compartment_id=$TF_VAR_compartment_ocid
export TF_VAR_db_strategy=Autonomous Transaction Processing Database

# Forms
export TF_VAR_wls_ms_port=9001

