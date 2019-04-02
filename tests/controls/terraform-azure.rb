# encoding: utf-8
# copyright: 2018, The Authors

title 'Azure Testing'

control 'azurerm_resource_group' do
   describe azurerm_resource_groups do
      it                              { should exist }
      its('names')                    { should include '__bastion_rg__' }
    end
end

control 'azurerm_virtual_network' do
    describe azurerm_virtual_network(resource_group: '__bastion_rg__', name: '__bastion_rg__-vn') do
      it                              { should exist }
      its('location')                 { should eq '__bastion_location__' }
      its('subnets')                  { should eq ["bastion_subnet"] }
      its('enable_ddos_protection')   { should eq false }
      its('enable_vm_protection')     { should eq false }
      its('type')                     { should eq 'Microsoft.Network/virtualNetworks' }
    end
end

control 'azurerm_network_security_group' do
  describe azurerm_network_security_group(resource_group: '__bastion_rg__', name: '__bastion_rg__-nsg') do
    it                                { should exist }
    it                                { should allow_ssh_from_internet }
    it                                { should_not allow_rdp_from_internet }
    its('security_rules')             { should_not be_empty }
    its('default_security_rules')     { should_not be_empty }
  end
end

control 'azurerm_virtual_machine' do
  describe azurerm_virtual_machine(resource_group: '__bastion_rg__', name: '__bastion_name__-vm-00') do
    it                                { should exist }
    it                                { should_not have_endpoint_protection_installed([]) }
    its('name')                       { should eq('__bastion_name__-vm-00') }
    its('type')                       { should eq 'Microsoft.Compute/virtualMachines' }
    its('installed_extensions_types') { should include('AADLoginForLinux') }
    its('location')                   { should eq '__bastion_location__' }
    its('os_disk_name')               { should eq('__bastion_name__-vm-00-os') }
  end

describe azure_virtual_machine_data_disk(group_name: '__bastion_rg__', name: '__bastion_name__-vm-00') do
    it                                { should_not exist }
  end
end

describe azurerm_storage_account_blob_container(resource_group: '__bastion_rg__', storage_account_name: 'rdobastionsa', blob_container_name: 'rdo-bastion') do
    it                                { should exist }
      its('properties') { should have_attributes(publicAccess: 'None') }
end