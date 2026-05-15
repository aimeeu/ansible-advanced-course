variable "instance_image" {
  description = "The Multipass image to use."
  type        = string
  default     = "24.04"
}

variable "instance_name_prefix" {
  description = "The name prefix to use when filtering Multipass instances."
  type        = string
  default     = "instance"
}

variable "instance_count" {
  description = "The number of instances to start."
  type        = number
  default     = 2
}

variable "instance_cpus" {
  description = "The number of CPUs to assign the instance."
  type        = number
  default     = 4
}

variable "instance_memory" {
  description = "The memory to assign the instance."
  type        = string
  default     = "4GiB"
}

variable "instance_disk" {
  description = "The size of disk to allocate to the instances."
  type        = string
  default     = "15GiB"
}

variable "instance_ssh_key" {
  description = "The SSH key to add to the instance."
  type        = string
}

variable "instance_ssh_user" {
  description = "The SSH user to add the key from instance_ssh_key to."
  type        = string
  default     = "ubuntu"
}

variable "ansible_user" {
  description = "The user Ansible uses for connectivity."
  type        = string
  default     = "ubuntu"
}

variable "ansible_group_name" {
  description = "The name of the Ansible group to associate all instances to."
  type        = string
  default     = "default"
}
