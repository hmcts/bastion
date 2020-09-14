## Overview 

This repository contains Terraform IAC for deploying an IaaS bastion host into Azure via an Azure Devops Pipeline.  The Terraform code consists of the following 5 modules.

1) Boostrap module - This module provisions a resource group, virtual network, and a key vault for storing SSH keys
   
2) Bastion module - This module provisions a virtual machine to the resource group and virtual network that was provisioned in the bootstrap module.  VM extentions are installed for AAD authentication, ansible playbooks are run, and SSH keys are copied to the key vault

3) Vnet peering module - This module creates a vnet peering between the bastion virtual network and the hub network; this provides the bastion with access to network resources via the hub firewalls

4) VPN module - This is a temporary module that creates a vnet peering between the bastion virtual network and the VPN appliance virtual network.  This is required to allow VPN connected users to access the bastion.  This will be depreciated once the VPN virtual network is peered to the hub.

5) RBAC module - This module performs AAD role assignment on the virtual machine.

## Deployment Instructions

There are 2 possible ways to deply a bastion host; you can deploy a bastion into a new resource group and vnet, or you can deploy a bastion into an existing resource group and vnet.

### Deploy into a new resource group and vnet

1) Create a new directory for your bastion by duplicating the template directory.  The new directory name could be the name of the environment you are deploying to, or the name of the product that the bastion will be providing access too.

cp terraform/environment/template terraform/environment/mybastion

2) Create a SSH key pair and copy the public key to the new bastion directory.  The private key MUST be copied to the key vault once it has been created.

Create SSH key pair:
ssh-keygen -b 4096 -f id_rsa_mybastion -N "secure-passphrase" -C "mybastion"

3) Update 00-init.tf with the subscription_id that you are deploying to
  
4) Update 10-locals.tf with the values that will be used for your bastion.  The 'environment' variable will be used to define the name of the resource group, vnet and keyvault.  The follow is an example if the environment local variable is set to 'mybastion':

resource_group_name: bastion-mybastion-rg
vnet_name: bastion-mybastion-vnet
keyvault_name: bastion-mybastion-kv

5) Update 21-bastion.tf with the name of the new bastion host, and the name of the public key that was copied into the new directory

6) Update azure-pipeline.yaml and add the new environment into the parameters map.  Using the examples taken from the above steps, your object should be as follows:

```
- bastionHost: bastion_mybastion
  environment: mybastion (this should the exact name of your bastion directory)
  serviceConnection: specify the service connection that has access to your subscription
  serviceConnection_privileged: ops-approval-gate-mgmt-envs
  rg: %subscription_name%-tfstate (update the %subscription_name% as neccesary)
  location: uksouth
  storage_account: tfstate%unique_string% (%unique_string% should be replaced with the first and last 8 digits from the subscription_id, resulting in a 16 digit string)
```

7) The pipeline will run when a PR is created, and the changes applied when merged to master.  Once the resources have been deplyed, the pipeline should be manually run from Azure Devops, and the RBAC option should be selected; This will perform roles assignment on the virtual machine;  this step will require an ADO admin to approve the use of the service connection.

8) Don't forget to upload the SSH private key ot the key vault (located in the bastion resource group)

### Deploy into an existing environment (existing resource group and vnet)

1) Navigate to the directory you would like to deploy the new bastion; the options are:

terraform/environment/prod/
terraform/environment/nonprod/
terraform/environment/sbox/

2) Create a SSH key pair and copy the public key to the bastion directory.  The private key MUST be copied to the key vault (located in the bastion resource group)

Create SSH key pair:
ssh-keygen -b 4096 -f id_rsa_mybastion -N "secure-passphrase" -C "mybastion"

3) Update 21-bastion.tf and add a new bastion by calling the bastion module, making sure to give it a difference name.  Update the bastion name and public_key (the public key must be copied to the bastion directory)

```
module "mybastion" {
  source              = "../../modules/bastion/"
  location            = module.bootstrap.resource_group.location
  environment         = local.environment
  resource_group_name = module.bootstrap.resource_group.name
  subnet_id           = module.bootstrap.subnet.id
  keyvault_id         = module.bootstrap.keyvault.id
  bastion_name        = "bastion-name"
  public_key          = "bastion-name.pub"
}
```

4) Merge the change and a new bastion will be deployed.  Don't forget to copy the SSH private key to the key vault.