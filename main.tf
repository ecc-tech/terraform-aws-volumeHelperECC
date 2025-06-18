locals {
  # Default mount points
  default_mounts = {
    windows = ["C:"]
    linux   = ["/"]
  }
}

data "aws_instance" "instances" {
  for_each    = toset(var.instance_ids)
  instance_id = each.value
}

locals {
  # Get all volume attachments from instance data
  volume_attachments = flatten([
    for inst_id, inst in data.aws_instance.instances : [
      for vol in inst.ebs_block_device : {
        instance_id = inst_id
        volume_id   = vol.volume_id
        device     = vol.device_name
      }
    ]
  ])

  # Create instance volumes map
  instance_volumes = {
    for instance_id in var.instance_ids : instance_id => {
      os_type = var.instance_os_types[instance_id]
      volumes = distinct(concat(
        local.default_mounts[var.instance_os_types[instance_id]],
        [
          for attachment in local.volume_attachments :
          var.instance_os_types[instance_id] == "windows"
          ? format("%s:", upper(substr(coalesce(
              lookup(data.aws_instance.instances[instance_id].tags, format("Letter_%s", attachment.volume_id), ""),
              element(split("", "DEFGHIJKLMNOPQRSTUVWXYZ"), index(local.volume_attachments, attachment))
            ), 0, 1)))
          : format("/data%d", index(local.volume_attachments, attachment) + 1)
          if attachment.instance_id == instance_id
        ]
      ))
    }
  }
}
