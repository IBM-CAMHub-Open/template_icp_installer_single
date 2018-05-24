provider "vsphere" {
  version              = "~> 1.3"
  allow_unverified_ssl = "true"
}

provider "random" {
  version = "~> 1.0"
}

provider "local" {
  version = "~> 1.1"
}

provider "null" {
  version = "~> 1.0"
}

provider "tls" {
  version = "~> 1.0"
}

resource "random_string" "random-dir" {
  length  = 8
  special = false
}

resource "tls_private_key" "generate" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

resource "null_resource" "create-temp-random-dir" {
  provisioner "local-exec" {
    command = "${format("mkdir -p  /tmp/%s" , "${random_string.random-dir.result}")}"
  }
}

module "deployVM_singlenode" {
  source = "github.com/IBM-CAMHub-Open/template_icp_modules//vmware_provision"

  #######
  vsphere_datacenter    = "${var.vsphere_datacenter}"
  vsphere_resource_pool = "${var.vsphere_resource_pool}"

  #######
  count = "${length(var.singlenode_vm_ipv4_address)}"

  #######
  // vm_folder = "${module.createFolder.folderPath}"

  vm_vcpu                    = "${var.singlenode_vcpu}"
  vm_name                    = "${var.singlenode_prefix_name}"
  vm_memory                  = "${var.singlenode_memory}"
  vm_template                = "${var.singlenode_vm_template}"
  vm_os_password             = "${var.singlenode_vm_os_password}"
  vm_os_user                 = "${var.singlenode_vm_os_user}"
  vm_domain                  = "${var.vm_domain}"
  vm_folder                  = "${var.vm_folder}"
  vm_private_ssh_key         = "${length(var.icp_private_ssh_key) == 0 ? "${tls_private_key.generate.private_key_pem}"     : "${var.icp_private_ssh_key}"}"
  vm_public_ssh_key          = "${length(var.icp_public_ssh_key)  == 0 ? "${tls_private_key.generate.public_key_openssh}"  : "${var.icp_public_ssh_key}"}"
  vm_network_interface_label = "${var.vm_network_interface_label}"
  vm_ipv4_gateway            = "${var.singlenode_vm_ipv4_gateway}"
  vm_ipv4_address            = "${var.singlenode_vm_ipv4_address}"
  vm_ipv4_prefix_length      = "${var.singlenode_vm_ipv4_prefix_length}"
  vm_adapter_type            = "${var.vm_adapter_type}"
  vm_disk1_size              = "${var.singlenode_vm_disk1_size}"
  vm_disk1_datastore         = "${var.singlenode_vm_disk1_datastore}"
  vm_disk1_keep_on_remove    = "${var.singlenode_vm_disk1_keep_on_remove}"
  vm_disk2_enable            = "${var.singlenode_vm_disk2_enable}"
  vm_disk2_size              = "${var.singlenode_vm_disk2_size}"
  vm_disk2_datastore         = "${var.singlenode_vm_disk2_datastore}"
  vm_disk2_keep_on_remove    = "${var.singlenode_vm_disk2_keep_on_remove}"
  vm_dns_servers             = "${var.vm_dns_servers}"
  vm_dns_suffixes            = "${var.vm_dns_suffixes}"
  random                     = "${random_string.random-dir.result}"
  enable_vm                  = "${var.enable_single_node}"
}

module "push_hostfile" {
  # source               = "${var.github_location}/modules/config_hostfile"
  source               = "github.com/IBM-CAMHub-Open/template_icp_modules//config_hostfile"
  private_key          = "${length(var.icp_private_ssh_key) == 0 ? "${tls_private_key.generate.private_key_pem}" : "${var.icp_private_ssh_key}"}"
  vm_os_password       = "${var.singlenode_vm_os_password}"
  vm_os_user           = "${var.singlenode_vm_os_user}"
  vm_ipv4_address_list = "${concat(var.singlenode_vm_ipv4_address)}"
  random               = "${random_string.random-dir.result}"
  dependsOn            = "${module.deployVM_singlenode.dependsOn}"
}

module "icphosts" {
  # source            = "${var.github_location}/modules/config_icphosts"
  source                = "github.com/IBM-CAMHub-Open/template_icp_modules//config_icphosts"
  master_public_ips     = "${join(",", var.singlenode_vm_ipv4_address)}"
  proxy_public_ips      = "${join(",", var.singlenode_vm_ipv4_address)}"
  management_public_ips = "${join(",", var.singlenode_vm_ipv4_address)}"
  worker_public_ips     = "${join(",", var.singlenode_vm_ipv4_address)}"
  va_public_ips         = "${join(",", var.singlenode_vm_ipv4_address)}"
  enable_vm_management  = "${var.enable_vm_management}"
  enable_vm_va          = "${var.enable_vm_va}"
  random                = "${random_string.random-dir.result}"
}

module "icp_prereqs" {
  # source               = "${var.github_location}/modules/config_icp_prereqs"
  source               = "github.com/IBM-CAMHub-Open/template_icp_modules//config_icp_prereqs"
  private_key          = "${length(var.icp_private_ssh_key) == 0 ? "${tls_private_key.generate.private_key_pem}" : "${var.icp_private_ssh_key}"}"
  vm_os_password       = "${var.singlenode_vm_os_password}"
  vm_os_user           = "${var.singlenode_vm_os_user}"
  vm_ipv4_address_list = "${concat(var.singlenode_vm_ipv4_address)}"
  random               = "${random_string.random-dir.result}"
  dependsOn            = "${module.deployVM_singlenode.dependsOn}"
}

module "icp_download_load" {
  # source               = "${var.github_location}/modules/config_icp_download"
  source                 = "github.com/IBM-CAMHub-Open/template_icp_modules//config_icp_download"
  private_key            = "${length(var.icp_private_ssh_key) == 0 ? "${tls_private_key.generate.private_key_pem}" : "${var.icp_private_ssh_key}"}"
  vm_os_password         = "${var.singlenode_vm_os_password}"
  vm_os_user             = "${var.singlenode_vm_os_user}"
  vm_ipv4_address_list   = "${concat(var.singlenode_vm_ipv4_address)}"
  docker_url             = "${var.docker_binary_url}"
  icp_url                = "${var.icp_binary_url}"
  icp_version            = "${var.icp_version}"
  download_user          = "${var.download_user}"
  download_user_password = "${var.download_user_password}"
  enable_bluemix_install = "${var.enable_bluemix_install}"
  random                 = "${random_string.random-dir.result}"
  dependsOn              = "[${module.deployVM_singlenode.dependsOn}, ${module.icp_prereqs.dependsOn}]"
}

module "icp_config_yaml" {
  # source               = "${var.github_location}/modules/config_icp_boot_standalone"
  source                 = "github.com/IBM-CAMHub-Open/template_icp_modules//config_icp_boot_standalone"
  private_key            = "${length(var.icp_private_ssh_key) == 0 ? "${tls_private_key.generate.private_key_pem}" : "${var.icp_private_ssh_key}"}"
  vm_os_password         = "${var.singlenode_vm_os_password}"
  vm_os_user             = "${var.singlenode_vm_os_user}"
  vm_ipv4_address_list   = "${concat(var.singlenode_vm_ipv4_address)}"
  enable_kibana          = "${lower(var.enable_kibana)}"
  enable_metering        = "${lower(var.enable_metering)}"
  icp_version            = "${var.icp_version}"
  kub_version            = "${var.kub_version}"
  vm_domain              = "${var.vm_domain}"
  icp_cluster_name       = "${var.icp_cluster_name}"
  icp_admin_user         = "${var.icp_admin_user}"
  icp_admin_password     = "${var.icp_admin_password}"
  enable_bluemix_install = "${var.enable_bluemix_install}"
  bluemix_token          = "${var.bluemix_token}"
  random                 = "${random_string.random-dir.result}"
  dependsOn              = "[${module.icp_download_load.dependsOn}, ${module.icp_prereqs.dependsOn}]"
}
