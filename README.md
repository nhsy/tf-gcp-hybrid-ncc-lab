# tf-gcp-hybrid-ncc-lab

## Overview
This lab implements the hub & spoke architecture with a centralized network appliance as described in the diagram below.

![network diagram](images/network.svg)

A single GCE Compute VM running Debian is used to implement the network appliance role.

In addition, Network Connectivity Centre (NCC) is used for dynamic routing between the network appliance and Google Cloud Router using Border Gateway Protocol (BGP).

Further details on this architecture can be found on the Google documentation below:

https://cloud.google.com/architecture/architecture-centralized-network-appliances-on-google-cloud

## GCP Resources

- Cloud Router
- Compute Engine VM
- Firewall Rules
- Identity Aware Proxy
- Network
- Network Connectivity Centre
- Subnetworks
- VPC Peering

### Networks

|  Network  | Subnetwork CIDR |         Peered        |
|:---------:|:---------------:|:---------------------:|
|    Hub    |  10.64.1.0/24   | Shared, Nonprod, Prod |
|  Transit  |  10.65.1.0/24   |          N/A          |
| Untrusted |  10.66.1.0/24   |          N/A          |
|  Shared   |  10.72.1.0/24   |          Hub          |
|  Nonprod  |  10.73.1.0/24   |          Hub          |
|   Prod    |  10.74.1.0/24   |          Hub          |

### Compute VMs

|       Name       |   Network(s)   |     IP Address(es)     |
|:----------------:|:--------------:|:----------------------:|
| vm-hub-appliance | Hub, Untrusted | 10.64.1.20, 10.66.1.20 |
|  vm-shared-test  |     Shared     |       10.72.1.20       |
| vm-nonprod-test  |    NonProd     |       10.73.1.20       |
|   vm-prod-test   |      Prod      |       10.74.1.20       |

## Usage
1. Export `GOOGLE_APPLICATIONS_CREDENTIALS` Google Service Account key.
2. Copy [terraform.tfvars.sample](terraform.tfvars.sample) to terraform.tfvars and update `project_id`.

```shell
terraform init
terraform plan
terraform apply
```
3. Execute shell commands to complete setup of NCC (currently not supported by google terraform provider).
4. Manually delete the `Default internet gateway` routes for the Peered networks (nw-shared / nw-nonprod / nw-prod) using the GCP Console or CLI.

## Testing
Wait 3 minutes after performing the manual steps detailed above then log onto each test GCE VM using IAP and test connectivity as follows:

```bash
gcloud compute ssh vm-shared-test --zone europe-west1-b --tunnel-through-iap --command "ping 8.8.8.8"
```

```bash
gcloud compute ssh vm-nonprod-test --zone europe-west1-b --tunnel-through-iap --command "ping 8.8.8.8"
```

```bash
gcloud compute ssh vm-prod-test --zone europe-west1-b --tunnel-through-iap --command "ping 8.8.8.8"
```

## Further Info
The Debian GCE VM is configured on startup with the metadata startup script [appliance.sh](files/appliance.sh).

The script configures the following:
* Install apt packages
* IP route table
* IP rules
* IP table masquerade
* Enables ip_forward in sysctl.conf
* Configures FRR BGP Daemon

## TO DO

- [ ] Attach & configure transit interface to Appliance VM
- [ ] Create Cloud VPN connection in Transit VPC