/*
 * Copyright (c) 2019, 2021, Oracle and/or its affiliates. All rights reserved.
 */
/*
* ORM only requires region to be defined for provider.
* https://docs.cloud.oracle.com/iaas/Content/ResourceManager/Tasks/usingconsole.htm
*/

provider "oci" {
  version = "=4.7.0"
  region  = var.region
}

provider "oci" {
  version = "=4.7.0"
  alias   = "home"
  region  = local.home_region
}

