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
  source = "git::https://github.com/IBM-CAMHub-Open/template_icp_modules.git?ref=2.3//vmware_provision"

  #######
  vsphere_datacenter    = "${var.vsphere_datacenter}"
  vsphere_resource_pool = "${var.vsphere_resource_pool}"

  #######
  count = "${length(element(keys(var.singlenode_hostname_ip))) }"

  #######
  // vm_folder = "${module.createFolder.folderPath}"

  vm_vcpu                    = "${var.singlenode_vcpu}"
  vm_name                    = "${keys(var.singlenode_hostname_ip)}"
  vm_memory                  = "${var.singlenode_memory}"
  vm_template                = "${var.singlenode_vm_template}"
  vm_os_password             = "${var.singlenode_vm_os_password}"
  vm_os_user                 = "${var.singlenode_vm_os_user}"
  vm_domain                  = "${var.vm_domain}"
  vm_folder                  = "${var.vm_folder}"
  vm_private_ssh_key         = "${length(var.icp_private_ssh_key) == 0 ? "${tls_private_key.generate.private_key_pem}"     : "${base64decode(var.icp_private_ssh_key)}"}"
  vm_public_ssh_key          = "${length(var.icp_public_ssh_key)  == 0 ? "${tls_private_key.generate.public_key_openssh}"  : "${var.icp_public_ssh_key}"}"
  vm_network_interface_label = "${var.vm_network_interface_label}"
  vm_ipv4_gateway            = "${var.singlenode_vm_ipv4_gateway}"
  vm_ipv4_address            = "${values(var.singlenode_hostname_ip)}"
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
  vm_clone_timeout        = "${var.vm_clone_timeout}"
  random                     = "${random_string.random-dir.result}"
  enable_vm                  = "${var.enable_single_node}"
  
  #######
  bastion_host        = "${var.bastion_host}"
  bastion_user        = "${var.bastion_user}"
  bastion_private_key = "${var.bastion_private_key}"
  bastion_port        = "${var.bastion_port}"
  bastion_host_key    = "${var.bastion_host_key}"
  bastion_password    = "${var.bastion_password}"  
}

module "add_ilmt_file" {
  source               = "git::https://github.com/IBM-CAMHub-Open/terraform-modules.git?ref=1.0//config_add_ilmt_file"

  private_key          = "${length(var.icp_private_ssh_key) == 0 ? "${tls_private_key.generate.private_key_pem}" : "${base64decode(var.icp_private_ssh_key)}"}"
  vm_os_password       = "${var.singlenode_vm_os_password}"
  vm_os_user           = "${var.singlenode_vm_os_user}"
  vm_ipv4_address_list = "${concat(values(var.singlenode_hostname_ip))}"
  #######
  bastion_host        = "${var.bastion_host}"
  bastion_user        = "${var.bastion_user}"
  bastion_private_key = "${var.bastion_private_key}"
  bastion_port        = "${var.bastion_port}"
  bastion_host_key    = "${var.bastion_host_key}"
  bastion_password    = "${var.bastion_password}"
  #######    
  dependsOn            = "${module.deployVM_singlenode.dependsOn}"
}

module "push_hostfile" {
  source               = "git::https://github.com/IBM-CAMHub-Open/template_icp_modules.git?ref=2.3//config_hostfile"

  private_key          = "${length(var.icp_private_ssh_key) == 0 ? "${tls_private_key.generate.private_key_pem}" : "${base64decode(var.icp_private_ssh_key)}"}"
  vm_os_password       = "${var.singlenode_vm_os_password}"
  vm_os_user           = "${var.singlenode_vm_os_user}"
  vm_ipv4_address_list = "${concat(values(var.singlenode_hostname_ip))}"
  #######
  bastion_host        = "${var.bastion_host}"
  bastion_user        = "${var.bastion_user}"
  bastion_private_key = "${var.bastion_private_key}"
  bastion_port        = "${var.bastion_port}"
  bastion_host_key    = "${var.bastion_host_key}"
  bastion_password    = "${var.bastion_password}"
  #######    
  random               = "${random_string.random-dir.result}"
  dependsOn            = "${module.deployVM_singlenode.dependsOn}"
}

module "icphosts" {
  source                = "git::https://github.com/IBM-CAMHub-Open/template_icp_modules.git?ref=2.3//config_icphosts"

  master_public_ips     = "${join(",", values(var.singlenode_hostname_ip))}"
  proxy_public_ips      = "${join(",", values(var.singlenode_hostname_ip))}"
  management_public_ips = "${join(",", values(var.singlenode_hostname_ip))}"
  worker_public_ips     = "${join(",", values(var.singlenode_hostname_ip))}"
  va_public_ips         = "${join(",", values(var.singlenode_hostname_ip))}"
  enable_vm_management  = "${var.enable_vm_management}"
  enable_vm_va          = "${var.enable_vm_va}"
  enable_glusterFS      = "false"
  random                = "${random_string.random-dir.result}"
  icp_version           = "${var.icp_version}"
}

module "icp_prereqs" {
  source               = "git::https://github.com/IBM-CAMHub-Open/template_icp_modules.git?ref=2.3//config_icp_prereqs"

  private_key          = "${length(var.icp_private_ssh_key) == 0 ? "${tls_private_key.generate.private_key_pem}" : "${base64decode(var.icp_private_ssh_key)}"}"
  vm_os_password       = "${var.singlenode_vm_os_password}"
  vm_os_user           = "${var.singlenode_vm_os_user}"
  vm_ipv4_address_list = "${concat(values(var.singlenode_hostname_ip))}"
  #######
  bastion_host        = "${var.bastion_host}"
  bastion_user        = "${var.bastion_user}"
  bastion_private_key = "${var.bastion_private_key}"
  bastion_port        = "${var.bastion_port}"
  bastion_host_key    = "${var.bastion_host_key}"
  bastion_password    = "${var.bastion_password}"  
  #######  
  random               = "${random_string.random-dir.result}"
  dependsOn            = "${module.deployVM_singlenode.dependsOn}"
}

module "icp_download_load" {
  source                 = "git::https://github.com/IBM-CAMHub-Open/template_icp_modules.git?ref=2.3//config_icp_download"

  private_key            = "${length(var.icp_private_ssh_key) == 0 ? "${tls_private_key.generate.private_key_pem}" : "${base64decode(var.icp_private_ssh_key)}"}"
  vm_os_password         = "${var.singlenode_vm_os_password}"
  vm_os_user             = "${var.singlenode_vm_os_user}"
  vm_ipv4_address_list   = "${concat(values(var.singlenode_hostname_ip))}"
  docker_url             = "${var.docker_binary_url}"
  icp_url                = "${var.icp_binary_url}"
  icp_version            = "${var.icp_version}"
  download_user          = "${var.download_user}"
  download_user_password = "${var.download_user_password}"
  enable_bluemix_install = "${var.enable_bluemix_install}"
  #######
  bastion_host        = "${var.bastion_host}"
  bastion_user        = "${var.bastion_user}"
  bastion_private_key = "${var.bastion_private_key}"
  bastion_port        = "${var.bastion_port}"
  bastion_host_key    = "${var.bastion_host_key}"
  bastion_password    = "${var.bastion_password}"  
  #######    
  random                 = "${random_string.random-dir.result}"
  dependsOn              = "[${module.deployVM_singlenode.dependsOn}, ${module.icp_prereqs.dependsOn}]"
}

module "icp_config_yaml" {
  source                 = "git::https://github.com/IBM-CAMHub-Open/template_icp_modules.git?ref=2.3//config_icp_boot_standalone"

  private_key            = "${length(var.icp_private_ssh_key) == 0 ? "${tls_private_key.generate.private_key_pem}" : "${base64decode(var.icp_private_ssh_key)}"}"
  vm_os_password         = "${var.singlenode_vm_os_password}"
  vm_os_user             = "${var.singlenode_vm_os_user}"
  vm_ipv4_address_list   = "${concat(values(var.singlenode_hostname_ip))}"
  enable_kibana          = "${lower(var.enable_kibana)}"
  enable_metering        = "${lower(var.enable_metering)}"
  enable_monitoring      = "${lower(var.enable_monitoring)}"
  icp_version            = "${var.icp_version}"
  kub_version            = "${var.kub_version}"
  vm_domain              = "${var.vm_domain}"
  icp_cluster_name       = "${var.icp_cluster_name}"
  icp_admin_user         = "${var.icp_admin_user}"
  icp_admin_password     = "${var.icp_admin_password}"
  enable_bluemix_install = "${var.enable_bluemix_install}"
  bluemix_token          = "${var.bluemix_token}"
  #######
  bastion_host        = "${var.bastion_host}"
  bastion_user        = "${var.bastion_user}"
  bastion_private_key = "${var.bastion_private_key}"
  bastion_port        = "${var.bastion_port}"
  bastion_host_key    = "${var.bastion_host_key}"
  bastion_password    = "${var.bastion_password}"  
  #######    
  random                 = "${random_string.random-dir.result}"
  dependsOn              = "[${module.icp_download_load.dependsOn}, ${module.icp_prereqs.dependsOn}]"
}
