variable "instance_ids" {
  description = "List of EC2 instance IDs"
  type        = list(string)
}

variable "instance_os_types" {
  description = "Map of instance IDs to their OS types (windows or linux)"
  type        = map(string)
}

# output "instance_volumes" {
#   description = "Map of instance IDs to their volume configurations"
#   value       = local.instance_volumes
# }
