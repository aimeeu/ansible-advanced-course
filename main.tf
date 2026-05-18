module "web" {
  source = "./shared/terraform/multipass-compute"

  ansible_group_name   = "web"
  instance_count       = 1
  instance_cpus        = 2
  instance_memory      = "4GiB"
  instance_name_prefix = "web"
  instance_ssh_key     = file("~/.ssh/id_rsa.pub")

}

module "database" {
  source = "./shared/terraform/multipass-compute"

  ansible_group_name   = "database"
  instance_count       = 1
  instance_cpus        = 2
  instance_memory      = "4GiB"
  instance_name_prefix = "database"
  instance_ssh_key     = file("~/.ssh/id_rsa.pub")

}

resource "local_file" "ansible_inventory" {
  content = templatefile("./shared/terraform/inventory.tmpl", {
    web = zipmap(
      module.web.instance_names,
      module.web.instance_ips
    )
    database = zipmap(
      module.database.instance_names,
      module.database.instance_ips
    )
  })
  filename = "./ansible/inventory.ini"
}

output "details" {
  value = <<EOH
SSH commands:
  Web Servers:
%{for ip in module.web.instance_ips~}
    - ssh -o "IdentitiesOnly=yes" -i ~/.ssh/id_rsa ubuntu@${ip}
%{endfor~}

  Database Servers:
%{for ip in module.database.instance_ips~}
    - ssh -o "IdentitiesOnly=yes" -i ~/.ssh/id_rsa ubuntu@${ip}
%{endfor~}

EOH
}
