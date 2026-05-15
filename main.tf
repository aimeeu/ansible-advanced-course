module "server" {
  source = "./shared/terraform/multipass-compute"

  ansible_group_name   = "server"
  instance_count       = 2
  instance_cpus        = 2
  instance_memory      = "4GiB"
  instance_name_prefix = "server"
  instance_ssh_key     = file("~/.ssh/id_rsa.pub")

}

resource "local_file" "ansible_inventory" {
  content = templatefile("./shared/terraform/inventory.tmpl", {
    servers = zipmap(
      module.server.instance_names,
      module.server.instance_ips
    )
    clients = {}
  })
  filename = "./ansible/inventory.ini"
}

output "details" {
  value = <<EOH
SSH commands:
  Servers:
%{for ip in module.server.instance_ips~}
    - ssh -o "IdentitiesOnly=yes" -i ~/.ssh/id_rsa ubuntu@${ip}
%{endfor~}



EOH
}
