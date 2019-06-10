provider "openstack" {
  version  = "~> 1.8"
  insecure = true
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
  source = "git::https://github.com/IBM-CAMHub-Open/template_icp_modules.git?ref=2.3//openstack_provision"

  #######
  vm_public_ssh_key                 = "${length(var.icp_public_ssh_key)  == 0 ? "${tls_private_key.generate.public_key_openssh}"  : "${var.icp_public_ssh_key}"}"
  vm_private_ssh_key                = "${length(var.icp_private_ssh_key) == 0 ? "${tls_private_key.generate.private_key_pem}"     : "${base64decode(var.icp_private_ssh_key)}"}"
  vm_os_password                    = "${var.singlenode_vm_os_password}"
  vm_os_user                        = "${var.singlenode_vm_os_user}"
  vm_ipv4_address                   = "${values(var.singlenode_hostname_ip)}"

  vm_name                           = "${keys(var.singlenode_hostname_ip)}"
  vm_domain                         = "${var.vm_domain}"
  vm_image_id                       = "${var.singlenode_vm_image_id}"
  vm_flavor_id                      = "${var.singlenode_vm_flavor_id}"
  vm_security_groups                = "${var.singlenode_vm_security_groups}"
  vm_public_ip_pool                = "${var.singlenode_vm_public_ip_pool}"
  vm_disk1_size                     = "${var.singlenode_vm_disk1_size}"
  vm_disk1_delete_on_termination    = "${var.singlenode_vm_disk1_delete_on_termination}"
  vm_disk2_enable                   = "${var.singlenode_vm_disk2_enable}"
  vm_disk2_size                     = "${var.singlenode_vm_disk2_size}"
  vm_disk2_delete_on_termination    = "${var.singlenode_vm_disk2_delete_on_termination}"
  enable_vm                         = "${var.enable_single_node}"
  random                            = "${random_string.random-dir.result}"
  
  #######
  bastion_host        = "${var.bastion_host}"
  bastion_user        = "${var.bastion_user}"
  bastion_private_key = "${var.bastion_private_key}"
  bastion_port        = "${var.bastion_port}"
  bastion_host_key    = "${var.bastion_host_key}"
  bastion_password    = "${var.bastion_password}"
}

module "add_ilmt_file" {
  source               = "git::https://github.com/IBM-CAMHub-Open/terraform_module_ilmt.git?ref=3.1.2"

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
  private_key          = "${length(var.icp_private_ssh_key) == 0 ? "${tls_private_key.generate.private_key_pem}"     : "${base64decode(var.icp_private_ssh_key)}"}"
  vm_os_password       = "${var.singlenode_vm_os_password}"
  vm_os_user           = "${var.singlenode_vm_os_user}"
  vm_ipv4_address_list = "${concat(values(var.singlenode_hostname_ip))}"
  random               = "${random_string.random-dir.result}"
  dependsOn            = "${module.deployVM_singlenode.dependsOn}"

  #######
  bastion_host        = "${var.bastion_host}"
  bastion_user        = "${var.bastion_user}"
  bastion_private_key = "${var.bastion_private_key}"
  bastion_port        = "${var.bastion_port}"
  bastion_host_key    = "${var.bastion_host_key}"
  bastion_password    = "${var.bastion_password}"
  #######
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
  private_key          = "${length(var.icp_private_ssh_key) == 0 ? "${tls_private_key.generate.private_key_pem}"     : "${base64decode(var.icp_private_ssh_key)}"}"
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
  private_key            = "${length(var.icp_private_ssh_key) == 0 ? "${tls_private_key.generate.private_key_pem}"     : "${base64decode(var.icp_private_ssh_key)}"}"
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
  private_key            = "${length(var.icp_private_ssh_key) == 0 ? "${tls_private_key.generate.private_key_pem}"     : "${base64decode(var.icp_private_ssh_key)}"}"
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