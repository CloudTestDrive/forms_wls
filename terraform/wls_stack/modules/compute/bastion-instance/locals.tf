/*
 * Copyright (c) 2021, Oracle and/or its affiliates. All rights reserved.
 */
locals {
  ocpus = length(regexall(var.instance_shape, "^.*Flex"))>0 ? var.ocpu_count: lookup(data.oci_core_shapes.oci_shapes.shapes[0], "ocpus")
}