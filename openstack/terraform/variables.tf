# Single Node
variable "singlenode_hostname_ip" {
  type    = "map"
}

variable "vm_domain" {
  type = "string"
}

variable "singlenode_vm_public_ip_pool" {
  type    = "string"
}

variable "singlenode_vm_security_groups" {
  type    = "list"
}

variable "singlenode_vm_image_id" {
  type    = "string"
}

variable "singlenode_vm_flavor_id" {
  type    = "string"
}

variable "singlenode_vm_os_user" {
  type = "string"
}

variable "singlenode_vm_os_password" {
  type = "string"
}

variable "singlenode_vm_disk1_size" {
  type    = "string"
  default = "400"
}

variable "singlenode_vm_disk1_delete_on_termination" {
  type    = "string"
  default = "true"
}

variable "singlenode_vm_disk2_enable" {
  type    = "string"
  default = "false"
}

variable "singlenode_vm_disk2_size" {
  type    = "string"
  default = ""
}

variable "singlenode_vm_disk2_delete_on_termination" {
  type    = "string"
  default = "true"
}

# SSH KEY Information
variable "icp_private_ssh_key" {
  type    = "string"
  default = ""
}

variable "icp_public_ssh_key" {
  type    = "string"
  default = ""
}

# Binary Download Locations
variable "docker_binary_url" {
  type = "string"
}

variable "icp_binary_url" {
  type = "string"
}

variable "icp_version" {
  type    = "string"
  default = "3.1.1"
}

variable "kub_version" {
  type    = "string"
  default = "1.11.0"
}

variable "download_user" {
  type = "string"
  default = ""
}

variable "download_user_password" {
  type = "string"
  default = ""
}

# ICP Settings
variable "enable_kibana" {
  type    = "string"
  default = "true"
}

variable "enable_metering" {
  type    = "string"
  default = "true"
}

variable "enable_monitoring" {
  type    = "string"
  default = "true"
}

variable "icp_cluster_name" {
  type = "string"
}

variable "icp_admin_user" {
  type    = "string"
  default = "admin"
}

variable "icp_admin_password" {
  type    = "string"
  default = "admin"
}

variable "enable_bluemix_install" {
  type    = "string"
  default = "false"
}

variable "bluemix_token" {
  type    = "string"
  default = ""
}

variable "enable_single_node" {
  type    = "string"
  default = "true"
}

variable "enable_vm_va" {
  type    = "string"
  default = "true"
}

variable "enable_vm_management" {
  type    = "string"
  default = "true"
}
