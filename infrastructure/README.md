# Infrastructure Setup and Management

This document provides an overview of the infrastructure setup and instructions on how to apply playbooks with SSH keys to the servers.

## Overview

The current infrastructure consists of a single server named `BikeHero1`. This server is set up with specific configurations and security groups to ensure proper functionality and security.

## Server Details

| **Name**         | **BikeHero1** |
|------------------|---------------|
| **ID**           | e818313f-d7c2-4fe9-aed5-3d0e508e860c |
| **Description**  | - |
| **Project ID**   | 1c45ec899ffd4a6889d7619bbf9e5b91 |
| **Availability Zone** | AAU |
| **Flavor Name**  | AAU.CPU.e.8-16 |
| **RAM**          | 16GB |
| **VCPUs**        | 8 VCPU |
| **Disk**         | 50GB |
| **IP Addresses** | 130.225.37.223 |
| **Security Groups** | BikeHero1 |
| **Key Name**     | BikeHero1 |
| **Image Name**   | Cuda Ubuntu 24.04 with docker |
| **Volumes Attached** | BikeHero1-DataDisk1 - 5000GiB |

## Security Groups (INSECURE! Very permissive)

The security groups for `BikeHero1` are configured as follows:

- **ALLOW IPv4 udp from 0.0.0.0/0**
- **ALLOW IPv6 tcp from ::/0**
- **ALLOW IPv6 to ::/0**
- **ALLOW IPv4 tcp from 0.0.0.0/0**
- **ALLOW IPv6 udp from ::/0**
- **ALLOW IPv6 ipv6-icmp from ::/0**
- **ALLOW IPv4 icmp from 0.0.0.0/0**
- **ALLOW IPv4 to 0.0.0.0/0**

## Applying Playbooks with SSH Keys

To apply playbooks, you can use Ansible. Ensure you have Ansible installed on your local machine. Create an inventory file (inventory.ini) with the server details:

