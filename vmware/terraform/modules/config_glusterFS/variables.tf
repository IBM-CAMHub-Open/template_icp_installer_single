variable "vm_ipv4_address_str"  { type = "string" }
variable "vm_ipv4_address_list" { type = "list" }
variable "dependsOn"            { type = "string" default = "true" description = "Boolean for dependency" }
// variable "gluster_device"   { type = "string" }
variable "enable_glusterFS"     { type = "string"  description = "Enable GlusterFS on Worker nodes?"}
variable "random"               { type = "string" }
variable "vm_os_password"       { type = "string"  description = "Operating System Password for the Operating System User to access virtual machine"}
variable "vm_os_user"           { type = "string"  description = "Operating System user for the Operating System User to access virtual machine"}
variable "private_key"          { }
variable "boot_vm_ipv4_address" { type = "string"}