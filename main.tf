terraform {
required_providers {
ibm = {
source = "IBM-Cloud/ibm"
version = "1.77.0"
}
}
}

provider "ibm" {
region = "us-south"
}

data "ibm_resource_group" "vsi_rg" {
name = "Default"
}

#Generate SSH key

resource "tls_private_key" "ssh_key" {
algorithm = "RSA"
rsa_bits = 4096
}

resource "ibm_is_ssh_key" "my_ssh_key" {
name = "poc-ssh-key-can-be-deleted"
public_key = tls_private_key.ssh_key.public_key_openssh
resource_group = data.ibm_resource_group.vsi_rg.id
}

#create VPC

resource "ibm_is_vpc" "my_vpc" {
name = "poc-vpc-can-be-deleted"
resource_group = data.ibm_resource_group.vsi_rg.id
}

#create Subnet

resource "ibm_is_subnet" "my_subnet" {
name = "poc-subnet-can-be-deleted"
vpc = ibm_is_vpc.my_vpc.id
zone = "us-south-1"
total_ipv4_address_count = 256
resource_group = data.ibm_resource_group.vsi_rg.id
}

resource "ibm_is_instance" "my_vsi" {
name = "poc-vsi-can-be-deleted"
image = "r006-4360612b-e860-491f-9418-c8e665c6b0ed"
profile = "cx2-2x4"
vpc = ibm_is_vpc.my_vpc.id
zone = "us-south-1"
resource_group = data.ibm_resource_group.vsi_rg.id

primary_network_interface {
subnet = ibm_is_subnet.my_subnet.id
}
keys = [ibm_is_ssh_key.my_ssh_key.id]
}
