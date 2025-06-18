output "instance_volumes" {
  description = "Map of instance IDs to their volume configurations"
  value = {
    for instance_id, config in local.instance_volumes : instance_id => {
      os_type = var.instance_os_types[instance_id]
      volumes = config.volumes
    }
  }
}
