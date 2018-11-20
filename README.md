<!---
Copyright IBM Corp. 2018, 2018
--->

# IBM Cloud Private Installer

The IBM Cloud Private Single Node Deployment Terraform template and inline modules will provision several virtual machine, install prerequisites and install the IBM Cloud Private product within you vmWare Hypervisor enviroment.

This template will install and configure the IBM Cloud Private in an Single Node topology.

The components of a IBM Cloud Private deployment include:

- NFS Server (All in 1 Node)
- Single  Node (All in 1 Node)
- Master Nodes (All in 1 Node)
- Proxy Nodes (All in 1 Node)
- Worker Nodes (All in 1 Node)
- Vulnerabilty Node (All in 1 Node)

![IBM Cloud Private Single Node Topology](./ICP-Single.jpg)

<p align="center">Image 1: IBM Cloud Private Single Node Topology></p>

For more infomation on IBM Cloud Private Nodes, please reference the Knowledge Center: <https://www.ibm.com/support/knowledgecenter/en/SSBS6K_3.1.0/getting_started/architecture.html>

## IBM Cloud Private Versions

| ICP Version | GitTag Reference|
|------|:-------------:|
| 2.1.0.2| 2.0|
| 2.1.0.3| 2.1|
| 3.1.0  | 2.2|
| 3.1.1  | 2.3|

<https://github.com/IBM-CAMHub-Open/template_icp_installer_single>

## System Requirements

### Hardware requirements

IBM Cloud Private nodes must meet the following requirements:
<https://www.ibm.com/support/knowledgecenter/en/SSBS6K_2.1.0/supported_system_config/hardware_reqs.html>

This template will setup the following hardware minimum requirements:

| Node Type | CPU Cores | Memory (mb) | Disk 1 | Disk 2 | Number of hosts |
|------|:-------------:|:----:|:-----:|:-----:|:-----:|
| Single node | 12 | 32768 | 400 | n/a | 1 |

### Supported operating systems and platforms

The following operating systems and platforms are supported.

***Ubuntu 16.04 LTS***

- VMware Tools must be enabled in the image for VMWare template.
- Ubuntu Repos with correct configuration must be enabled in the images.
- Sudo User and password must exist and be allowed for use.
- Firewall (via iptables) must be disabled.
- SELinux must be disabled.
- The system umask value must be set to 0022.

### Network Requirements

The following network information is required:
Based on the Standard setup:

- IP Address
  - 1 IP Address's
- Netmask Bit Number eg 24
- Network Gateway
- Interface Name

## Template Variables

The following tables list the template variables.

### Cloud Input Variables

| Name | Description | Type | Default |
|------|-------------|:----:|:-----:|
| vsphere_datacenter |vSphere DataCenter Name| string |  |
| vsphere_resource_pool | vSphere Resource Pool | string |  |
| vm_network_interface_label | vSphere Port Group Name | string | `VM Network` |
| vm_folder | vSphere Folder Name | string |  |

### IBM Cloud Private Template Settings

| Name | Description | Type | Default |
|------|-------------|:----:|:-----:|
| vm_dns_servers | IBM Cloud Private DNS Servers | list | `<list>` |
| vm_dns_suffixes | IBM Cloud Private DNS Suffixes | list | `<list>` |
| vm_domain | IBM Cloud Private Domain Name | string | `ibm.com` |
| vm_os_user | Virtual Machine  Template User Name | string | `root` |
| vm_os_password | Virtual Machine Template User Password | string | `s3cretpassw0rd` |
| vm_template | Virtual Machine Template Name | string |  |
| vm_disk1_datastore | Virtual Machine Datastore Name - Disk 1 | string |  |

### IBM Cloud Private Multi-Node Settings

| Name | Description | Type | Default |
|------|-------------|:----:|:-----:|
| enable_kibana | Enable IBM Cloud Private Kibana | string | `true` |
| enable_metering | Enable IBM Cloud Private Metering | string | `true` |
| worker_enable_glusterFS |  Enable IBM Cloud Private GlusterFS on worker Nodes| string | `true` |
| icp_cluster_name | IBM Cloud Private Cluster Name | string | `icpclustervip` |
| icp_admin_user |  IBM Cloud Private Admin Username| string | `admin` |
| icp_admin_password | IBM Cloud Private Admin Password | string | `admin` |

### IBM Cloud Private Download Settings

| Name | Description | Type | Default |
|------|-------------|:----:|:-----:|
| download_user | Repository User Name (Optional) | string |  |
| download_user_password | Repository User Password (Optional) | string |  |
| docker_binary_url | IBM Cloud Private Docker Download Location (http/https/ftp/file) | string |  |
| icp_binary_url |  IBM Cloud Private Download Location (http/https/ftp/file)| string | |
| icp_private_ssh_key | IBM Cloud Private - Private SSH Key | string | `` |
| icp_public_ssh_key | IBM Cloud Private - Public SSH Key | string | `` |
| icp_version | IBM Cloud Private Version | string | `3.1.0` |
| kub_version | Kubernetes Version| string | `1.11.0` |

### Single Node Input Settings

| Name | Description | Type | Default |
|------|-------------|:----:|:-----:|
| boot_prefix_name | Single  Node Hostname Prefix | string | `ICPSingle` |
| boot_memory |  Single  Node Memory Allocation (mb) | string | `32768` |
| boot_vcpu | Single  Node vCPU Allocation | string | `12` |
| boot_vm_disk1_size | Single  Node Disk Size (GB) | string | `400` |
| boot_vm_ipv4_address | Single  Nodes IP Address | list | `<list>` |
| boot_vm_ipv4_gateway | Single  Node IP Gateway | string |  |
| boot_vm_ipv4_prefix_length | Single  Node IP Netmask (CIDR) | string | `24` |

## Template Output Variables

| Name | Description |
|------|-------------|
| ibm_cloud_private_admin_url | IBM Cloud Private Cluster URL |
| ibm_cloud_private_admin_user | IBM Cloud Private Admin Username |
| ibm_cloud_private_admin_password | IBM Cloud Private Admin Password |
