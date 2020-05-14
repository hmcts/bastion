# RDO Bastion Deployment

To use this repo, you need to do the following

1. Create Infra Keyvault and Storage Account for the terraform Remote State, this is a run once steps

    cd run_once
    terraform init
    terraform apply

    Note: Place a .tfvars file in the run_once folder with these variables filled out

    ```bash
    bastion_name = ""
    location = ""
    environment = ""
    admin_username = ""
    admin_password = ""
    ssh-public-key = ""
    ssh-private-key = "Manual-Add"  #Note: You will need to add private Key to Keyvault manually
    ```

2. Depending upon which Bastion Service (Paas or Iaas) you require copy the files into the root folder

    In the root folder should have the basic's terraform to build a Resource Group and Virtual Network, when you copy either Paas or Iaas files into the root folder,
    this will provision which ever bastion you require.

   Note: Place a .tfvars file in the root folder with these variables filled out

    '''bash
    bastion_name = ""
    location = ""
    address_space = [""]
    subnet = ""
    environment = ""
    bastion_infra_rg = ""
    bastion_infra_key_vault = ""
    virtual_machine_name = ""
    virtual_machine_count = 1
    '''

    Once filled out, you need to run

    '''terraform
    terraform init -input=false \
    -backend=true \
    -backend-config="storage_account_name=#####TOO_FILL_OUT###" \
    -backend-config="key=bastion/terraform.tfstate" \
    -backend-config="container_name=terraform-state" \
    -backend-config="resource_group_name=####TOO_FILL_OUT###"
    '''

To-Do's
    Fix Ansible provisioning with tf 12 - error: inappropriate value for attribute "host": string required.
    Wait for Solution for|:
        To sign in, use a web browser to open the page <https://microsoft.com/devicelogin> and enter the code xxxxxxx to authenticate. Press ENTER when ready.
        Access denied: to sign in you must be assigned a role with action 'Microsoft.Compute/virtualMachines/login/action', for example 'Virtual Machine User Login'
