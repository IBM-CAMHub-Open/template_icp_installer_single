# Generate a random id to maintian output object uniqueness
resource "random_id" "clusterid" {
  byte_length = "2"
}

output "ibm_cloud_private_admin_url" {
  value = "https://${element(values(var.singlenode_hostname_ip),0)}:8443"
}

output "ibm_cloud_private_admin_user" {
  value = "${var.icp_admin_user}"
}

output "ibm_cloud_private_admin_password" {
  value = "${var.icp_admin_password}"
}

output "ibm_cloud_private_master_ip" {
  value = "${element(values(var.singlenode_hostname_ip),0)}"
}

output "ibm_cloud_private_proxy_hostname" {
  value = "${element(keys(var.singlenode_hostname_ip),0)}.${var.vm_domain}"
}

output "cloud_connection_name"{
	value = "${var.icp_cluster_name}${random_id.clusterid.hex}Connection" 
}