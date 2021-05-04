variable "marketplace_source_images" {
  type = map(object({
    ocid = string
    is_pricing_associated = bool
    compatible_shapes = set(string)
  }))
  default = {
    main_mktpl_image = {
      ocid = "ocid1.image.oc1..aaaaaaaanpiba7rmegsez6epen6zodkvwef3fvwjflh2ojbh2ldx7nwnabaa"
      is_pricing_associated = true
      compatible_shapes = []
    }
    baselinux_instance_image = {
      ocid = "ocid1.image.oc1..aaaaaaaanvui7teqxr7mkiyta2gw5ollzdhxi7nl2yijlowker5qwxfgjj2q"
      is_pricing_associated = false
      compatible_shapes = []
    }
  }
}
