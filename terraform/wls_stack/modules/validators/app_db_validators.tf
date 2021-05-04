/*
 * Copyright (c) 2020, Oracle and/or its affiliates. All rights reserved.
 */

locals {
  has_app_db_password = var.app_db_password_ocid!=""

  #appdb password OCID validation
  invalid_app_db_password_msg  = "WLSC-ERROR: The value for App DB User Password [app_db_password_ocid] is not valid. The value must begin with ocid1 followed by resource type, e.g. ocid1.vaultsecret."
  validate_app_db_password      = local.has_app_db_password ? length(regexall("^ocid1.vaultsecret.", var.app_db_password_ocid)) > 0 ? null : local.validators_msg_map[local.invalid_app_db_password_msg] : null
}
