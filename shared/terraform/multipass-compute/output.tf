output "instance_ips" {
  value = [for instance in data.multipass_instance.instance : instance.ipv4]
}

output "instance_names" {
  value = [for instance in data.multipass_instance.instance : instance.name]
}

output "ssh_key" {
  value = var.instance_ssh_key
}
