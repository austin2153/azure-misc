# Setup
Connect-AzAccount

# ADQ22
# Add a tag to a resource 
$r = Get-AzResource -ResourceName 'acstorage2153' -ResourceGroupName 'ac-monitor-design-rg'
$r.Tags.Add('env', 'dev')
Set-AzResource -Tag $r.Tags -ResourceId $r.ResourceId -Force

# ADQ25
# Remove a resource lock 
Get-AzResourceLock | Where-Object ResourceGroupName -EQ 'ac-monitor-design-rg' |
  Remove-AzResourceLock -Force

# ADQ26
# Add a tag to a resource (slightly diff then Q22)
$tags = (Get-AzResourceGroup -Name 'ac-monitor-design-rg').Tags
$tags.Add('Status', 'Approved')
Set-AzResourceGroup -Tag $tags -Name 'ac-monitor-design-rg'

# ADQ29
# Moving subscriptions between management groups 
$TargetManagementGroup = 'IT'
$subscriptionID = '00000000-0000-1234-11223344556677889'
New-AzManagementGroupSubscription -GroupName "$TargetManagementGroup" -SubscriptionId "$subscriptionID"

# Listing management groups 
Get-AzManagementGroup -Recurse -GroupId '849e8524-4433-4b03-aea4-b2dd81e72401' -Expand -WarningAction SilentlyContinue |
  Select-Object -ExpandProperty Children

# Create a management group
New-AzManagementGroup -GroupName 'a1' -ParentId '/providers/Microsoft.Management/managementGroups/Root'

# Remove a management group
Remove-AzManagementGroup -GroupName IT

# ADQ31
# Add new tags to a resource 
$tags = @{'Dept' = 'Marketing'; 'Status' = 'Standard' }
$resource = Get-AzResource -Name 'name' -ResourceGroupName ''
New-AzTag -ResourceId $resource.Id -Tag $tags

# STGEQ1
# Create storage account and provide access 
Login-AzAccount -TenantId '94fdbb59-19d2-4d81-93ab-a988bb54c302'
Set-AzContext -Subscription 'Austin Azure Lab'
New-AzResourceGroup -Name 'storage-test' -Location 'eastus' # New-AzResourceGroupDeployment
New-AzStorageAccount -Name 'az104q1' -ResourceGroupName 'storage-test' -SkuName Standard_GRS -Location 'eastus' #-Kind
Get-AzStorageAccountKey -ResourceGroupName 'storage-test' -Name 'az104q1'

# Cleanup
Get-AzResourceGroup -Name 'storage-test' | Remove-AzResourceGroup -Force

# STGEQ2
Get-AzVirtualNetwork -ResourceGroupName 'RG01' -Name 'VNET01' |
  Set-AzVirtualNetworkSubnetConfig -Name 'VSUBNET01' -AddressPrefix '10.0.0.0/24' -ServiceEndpoint Microsoft.Storage |
    Set-AzVirtualNetwork

# Get the VSUBNET01 object in VNET01
$subnet = Get-AzVirtualNetwork -ResourceGroupName 'RG01' -Name 'VNET01' |
  Get-AzVirtualNetworkSubnetConfig -Name 'VSUBNET01'

# Allow connectivity from storage2153 storage account to VSUBNET01
Add-AzStorageAccountNetworkRule -ResourceGroupName 'RG01' -Name 'storage2153' -VirtualNetworkResourceId $subnet.Id

# Enable the "Allow Azure services on the trusted services list to access this storage account" in the storage account
# This setting is in the 'Networking' section of the storage account
Update-AzStorageAccountNetworkRuleSet -ResourceGroupName 'RG01' -Name 'storage2153' -Bypass AzureServices

# Cleanup
Get-AzResourceGroup -Name 'RG01' | Remove-AzResourceGroup -Force

# STGE24

# setup
$resourceGroupName = 'ac-fileshare-rg'
$storageAccountName = 'acstgfileshare'
$fileShareName = 'acfileshare'
$region = 'eastus'

# create a resource group
New-AzResourceGroup -Name $resourceGroupName -Location $region 

# create storage account
$storAcct = New-AzStorageAccount `
  -ResourceGroupName $resourceGroupName `
  -Name $storageAccountName `
  -SkuName Standard_LRS `
  -Location $region `
  -Kind StorageV2 `
  -EnableLargeFileShare

# log
$storAcct.Sku.Name
$storAcct.PrimaryEndpoints.Blob

# get storage account key1
$key = (Get-AzStorageAccountKey -ResourceGroupName $resourceGroupName -Name $storageAccountName) | Where-Object { $_.KeyName -eq 'key1' }
$key.Value #log

# get storage account context
$context = New-AzStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $key.Value
$context #log 

# create file share on storage account
New-AzStorageShare -Context $context -Name $fileShareName

# mount drive in windows os - run from within os
Invoke-Expression -Command 'cmdkey /add:acstgacct01.file.core.windows.net /user:acstgacct01 ' + `
  '/pass:PMnDMqwfx89v7BCtREDpDIPr9wUv8nAGetk6tSTcBgOSEvm3I/Lkn+9TdqyfaYAuPMqJqI/23iQ2+ASt57921g=='
New-PSDrive -Name Z -PSProvider FileSystem -Root '\\acstgacct01.file.core.windows.net\filesharename' -Persist

# Cleanup
Get-AzResourceGroup -Name $resourceGroupName | Remove-AzResourceGroup -Force

# STGE31
$rgName = 'ac-storage-test'
$accountName = 'actest2153'
$ruleName = 'aclabq31-rule'

$action = Add-AzStorageAccountManagementPolicyAction -BaseBlobAction TierToCool -DaysAfterModificationGreaterThan 30
$action = Add-AzStorageAccountManagementPolicyAction -BaseBlobAction TierToArchive -DaysAfterModificationGreaterThan 30 -InputObject $action
$action
$filter = New-AzStorageAccountManagementPolicyFilter -PrefixMatch ef, gh -BlobType blockBlob
$rule = New-AzStorageAccountManagementPolicyRule -Name $ruleName -Action $action -Filter $filter
$policy = Set-AzStorageAccountManagementPolicy -ResourceGroupName $rgName -AccountName $accountName -Rule $rule
$policy

$action = Add-AzStorageAccountManagementPolicyAction -BaseBlobAction Delete -DaysAfterCreationGreaterThan 100
$action = Add-AzStorageAccountManagementPolicyAction -BaseBlobAction TierToArchive -DaysAfterModificationGreaterThan 50 `
  -DaysAfterLastTierChangeGreaterThan 40 -InputObject $action
$action = Add-AzStorageAccountManagementPolicyAction -BaseBlobAction TierToCool -DaysAfterLastAccessTimeGreaterThan 30 `
  -EnableAutoTierToHotFromCool -InputObject $action
$action = Add-AzStorageAccountManagementPolicyAction -SnapshotAction Delete -DaysAfterCreationGreaterThan 100 -InputObject $action
$action 
$filter = New-AzStorageAccountManagementPolicyFilter
$rule = New-AzStorageAccountManagementPolicyRule -Name Test -Action $action -Filter $filter
$policy = Set-AzStorageAccountManagementPolicy -ResourceGroupName 'myresourcegroup' -AccountName 'mystorageaccount' -Rule $rule

# STGE33
$rgName = 'ac-storage-test'
$storageAccount = 'actest2153'
$containerName = 'stge33'

$ctx = New-AzStorageContext -StorageAccountName $storageAccount -UseConnectedAccount
New-AzStorageContainer -Name $containerName -Context $ctx 
Set-AzStorageBlobContent -Container $containerName -File '/home/austin/Downloads/acvmtest-vm.rdp' -Blob 'acvmtest-vm.rdp' -Context $ctx -StandardBlobTier Cool
Get-ChildItem -Path /home/austin/dev/azure/az104 -File -Recurse | Set-AzStorageBlobContent -Container $containerName -Context $ctx -StandardBlobTier Cool

# Set-AzStorageBlobContent This request is not authorized to perform this operation using this permission.
# I found it's not enough for the app and account to be added as owners. I would go into your storage account > IAM > Add role assignment,
# and add the special permissions for this type of request:
# Storage Blob Data Contributor
# Storage Queue Data Contributor

#CMP14

# New-AzResourceGroupDeployment and "az group deployment create" are used with an ARM template
$paramsPath = '/Users/austin.campbell/Library/CloudStorage/OneDrive-FiservCorp/dev/ac-azure-main/vm/parameters.json'
$templatePath = '/Users/austin.campbell/Library/CloudStorage/OneDrive-FiservCorp/dev/ac-azure-main/vm/template.json'
New-AzResourceGroupDeployment -ResourceGroupName 'aclab-vm-rg' -TemplateFile $templatePath `
  -TemplateParameterFile $paramsPath -Tag @{'env' = 'dev'; 'app' = 'web'; }

# CMP32
# Automatic - In this mode, the scale set makes no guarantees about the order of VMs being brought down. The scale set may take down all VMs at the same time.
# Rolling - In this mode, the scale set rolls out the update in batches with an optional pause time between batches.
# Manual - In this mode, when you update the scale set model, nothing happens to existing VMs.

# setup
New-AzResourceGroup -Name $resourceGroup -Location $location
$resourceGroup = 'aclab-scaleset-rg'
$location = 'eastus'
$scaleSetName = 'aclab-scaleset-01'
$virtualNetworkName = 'aclab-network-scaleset'
$subnetName = 'subnet01'
$vmImage = 'Win2019Datacenter'
$vmSize = 'Standard_DS2_v2'

# create a scaleset
New-AzVmss -ResourceGroupName $resourceGroup -Location $location -VMScaleSetName $scaleSetName `
  -VirtualNetworkName $virtualNetworkName -SubnetName $subnetName -PublicIpAddressName 'myPublicIPAddress' `
  -ImageName $vmImage -UpgradePolicyMode 'Automatic' -VmSize $vmSize -Credential (Get-Credential)

# get the scalset model
Get-AzVmss -ResourceGroupName $resourceGroup -VMScaleSetName $scaleSetName

# The Update-AzVmssInstance cmdlet starts a manual upgrade of the specified Virtual Machine Scale Set (VMSS) instance. 
# This is used when the upgrade policy on the VMSS Scale Set is set to manual.
Update-AzVmss -ResourceGroupName 'myResourceGroup' -VMScaleSetName 'myScaleSet' `
  -VirtualMachineScaleSet { scaleSetConfigPowershellObject }

# The Update-AzVmssInstance cmdlet starts a manual upgrade of the specified Virtual Machine Scale Set (VMSS) instance.
# This is used when the upgrade policy on the VMSS Scale Set is set to manual.
Update-AzVmssInstance -ResourceGroupName 'Group011' -VMScaleSetName 'VMScaleSet001' -InstanceId '0'

# The Set-AzVmssVM cmdlet modifies the state of a Virtual Machine Scale Set (VMSS) instance.
Set-AzVmssVM -InstanceId '' -Reimage -ResourceGroupName $resourceGroup -VMScaleSetName 'VMSS001'

# Starts a rolling upgrade to move all virtual machine scale set instances to the latest available Platform Image OS version.
# Instances which are already running the latest available OS version are not affected.
Start-AzVmssRollingOSUpgrade -ResourceGroupName 'Group001' -VMScaleSetName 'VMSS001'

#CMP35
# Create a virtual machine with a static private IP address using Azure PowerShell
$rgname = 'aclab-staticiptest-rg'
$region = 'eastus'
$vmname = 'aclabstatic01'
$ipname = 'aclab-staticip-ip'

# create rg
$rg = @{
  Name     = $rgname
  Location = $region
}
New-AzResourceGroup @rg


## Create virtual machine. ##
$vm = @{
  ResourceGroupName   = $rgname
  Location            = $region
  Name                = $vmname
  PublicIpAddressName = $ipname
}
New-AzVM @vm


## Place virtual network configuration into a variable. ##
$net = @{
  Name              = $vmname
  ResourceGroupName = $rgname
}
$vnet = Get-AzVirtualNetwork @net

## Place subnet configuration into a variable. ##
$sub = @{
  Name           = $vmname
  VirtualNetwork = $vnet
}
$subnet = Get-AzVirtualNetworkSubnetConfig @sub

## Get name of network interface and place into a variable ##
$int1 = @{
  Name              = $vmname
  ResourceGroupName = $rgname
}
$vm = Get-AzVM @int1

## Place network interface configuration into a variable. ##
$nic = Get-AzNetworkInterface -ResourceId $vm.NetworkProfile.NetworkInterfaces.Id

## Set interface configuration. ##
$config = @{
  Name             = $vmname
  PrivateIpAddress = '192.168.1.4'
  Subnet           = $subnet
}
$nic | Set-AzNetworkInterfaceIpConfig @config -Primary

## Save interface configuration. ##
$nic | Set-AzNetworkInterface

# CMP40
$rgName = 'myResourceGroup'
$vmName = 'myVM'
$dataDiskName = 'myDisk'
$disk = Get-AzDisk -ResourceGroupName $rgName -DiskName $dataDiskName

$vm = Get-AzVM -Name $vmName -ResourceGroupName $rgName

$vm = Add-AzVMDataDisk -CreateOption Attach -Lun 0 -VM $vm -ManagedDiskId $disk.Id

# Updates the state of an Azure virtual machine.
Update-AzVM -VM $vm -ResourceGroupName $rgName

# CMPQ43
# This example shows how to add an empty data disk to an existing virtual machine.

$rgName = 'aclab-vm-rg'
$vmName = 'aclabwinvm01'
$location = 'East US'
$storageType = 'Premium_LRS'
$dataDiskName = $vmName + '_datadisk1'

$diskConfig = New-AzDiskConfig -SkuName $storageType -Location $location -CreateOption Empty -DiskSizeGB 128
$dataDisk1 = New-AzDisk -DiskName $dataDiskName -Disk $diskConfig -ResourceGroupName $rgName

$vm = Get-AzVM -Name $vmName -ResourceGroupName $rgName
$vm = Add-AzVMDataDisk -VM $vm -Name $dataDiskName -CreateOption Attach -ManagedDiskId $dataDisk1.Id -Lun 1

Update-AzVM -VM $vm -ResourceGroupName $rgName

# NETQ9

# When configuring the root of a new zone, you have to configure a root element. @ is used
# TTL is in seconds. Requirement is one hour so 3600 seconds

New-AzDnsRecordSet -Name '@' -RecordType A -ZoneName 'campbellsite.info' `
  -ResourceGroupName 'aclabtestrg' -Ttl 3600 -DnsRecords `
(New-AzDnsRecordConfig -Ipv4Address '1.2.3.4')

# You need to set 2 aliases for www
$aRecords = @()
$aRecords += New-AzDnsRecordConfig -Ipv4Address '2.3.4.5'
$aRecords += New-AzDnsRecordConfig -Ipv4Address '3.4.5.6'

New-AzDnsRecordSet -Name 'www' -ZoneName 'campbellsite.info' `
  -ResourceGroupName 'aclabtestrg' -Ttl 3600 -RecordType A -DnsRecords $aRecords

# Private DNS Related
$RecordSet = Get-AzPrivateDnsRecordSet `
  -Name www -RecordType A `
  -ResourceGroupName MyResourceGroup `
  -ZoneName myzone.com
Add-AzPrivateDnsRecordConfig `
  -RecordSet $RecordSet `
  -Ipv4Address 1.2.3.4
Set-AzPrivateDnsRecordSet `
  -RecordSet $RecordSet

Get-AzPrivateDnsRecordSet -Name www `
  -RecordType A `
  -ResourceGroupName 'MyResourceGroup' `
  -ZoneName myzone.com | Add-AzPrivateDnsRecordConfig `
  -Ipv4Address 1.2.3.4 | Set-AzPrivateDnsRecordSet

# NETQ17

# To secure your storage account, you should first configure a rule to deny access to traffic
# from all networks (including internet traffic) on the public endpoint, by default. 

# Set default deny rule
Update-AzStorageAccountNetworkRuleSet -ResourceGroupName 'aclabtestrg' `
  -Name 'aclabstgacct01' `
  -DefaultAction Deny


# Then, you should configure rules that grant access to traffic from specific VNets. 
# You can also configure rules to grant access to traffic from selected public internet
# IP address ranges, enabling connections from specific internet or on-premises clients. 

# allow access to azure storage on the subnet
Get-AzVirtualNetwork -ResourceGroupName 'aclabtestrg' -Name 'aclabvnet01' | 
  Set-AzVirtualNetworkSubnetConfig `
    -Name 'subneta' `
    -AddressPrefix '10.0.0.0/24' `
    -ServiceEndpoint Microsoft.Storage | Set-AzVirtualNetwork

# get a subnet
$subnet = Get-AzVirtualNetwork -ResourceGroupName 'aclabtestrg' -Name 'aclabvnet01' |
  Get-AzVirtualNetworkSubnetConfig -Name 'subneta'

# add subnet access to the storage account
Add-AzStorageAccountNetworkRule -ResourceGroupName 'aclabtestrg' `
  -Name 'aclabstgacct01' -VirtualNetworkResourceId $subnet.Id


# NETQ23
$rule1 = New-AzNetworkSecurityRuleConfig -Name 'rdp' -Description 'Allow RDP' -Access Allow `
  -Protocol Tcp -Direction Inbound -Priority 100 -SourceAddressPrefix Internet -SourcePortRange * `
  -DestinationAddressPrefix * -DestinationPortRange 3389

$rule2 = New-AzNetworkSecurityRuleConfig -Name 'web' -Description 'Allow HTTP' -Access Allow `
  -Protocol Tcp -Direction Inbound -Priority 101 -SourceAddressPrefix Internet -SourcePortRange * `
  -DestinationAddressPrefix * -DestinationPortRange 80

$nsg = New-AzNetworkSecurityGroup -ResourceGroupName 'aclabtestrg' -Location 'eastus' -Name 'Frontend-NSG' -SecurityRules $rule1, $rule2
$nsg

# NETQ41

$res = Get-AzResource | 
  Where-Object { $_.ResourceType -eq 'Microsoft.Network/networkWatchers' -and $_.Location -eq 'eastus' }

$networkWatcher = Get-AzNetworkWatcher `
  -Name $res.Name `
  -ResourceGroupName $res.ResourceGroupName

$diagnosticSA = Get-AzStorageAccount `
  -ResourceGroupName Diagnostics-RG `
  -Name 'Diagnostics-Storage'

$filter1 = New-AzPacketCaptureFilterConfig `
  -Protocol TCP `
  -RemoteIPAddress '0.0.0.0-255.255.255.255' `
  -LocalIPAddress '10.0.0.3' `
  -LocalPort '1-65535' `
  -RemotePort '22'

New-AzNetworkWatcherPacketCapture -NetworkWatcher $networkWatcher `
  -TargetVirtualMachineId $vm.Id `
  -PacketCaptureName 'Capture SFTP Traffic' `
  -StorageAccountId $diagnosticSA.Id `
  -TimeLimitInSeconds 60
-Filter $filter1

# NETQ43

$vM = Get-AzVM -ResourceGroupName 'aclabtestrg' -Name 'aclablinvm01'

$networkWatcher = Get-AzNetworkWatcher `
  -Name NetworkWatcher_eastus `
  -ResourceGroupName NetworkWatcherRG

Test-AzNetworkWatcherIPFlow `
  -NetworkWatcher $networkWatcher `
  -TargetVirtualMachineId $vM.Id `
  -Direction Outbound `
  -Protocol TCP `
  -LocalIPAddress 10.0.0.4 `
  -LocalPort 60000 `
  -RemoteIPAddress 13.107.21.200 `
  -RemotePort 80

Test-AzNetworkWatcherIPFlow `
  -NetworkWatcher $networkWatcher `
  -TargetVirtualMachineId $vM.Id `
  -Direction Outbound `
  -Protocol TCP `
  -LocalIPAddress 10.0.0.4 `
  -LocalPort 60000 `
  -RemoteIPAddress 172.31.0.100 `
  -RemotePort 80

# To determine why the rules in Test network communication are allowing or 
# preventing communication, review the effective security rules for the network
# interface with Get-AzEffectiveNetworkSecurityGroup
$result = Get-AzEffectiveNetworkSecurityGroup `
  -NetworkInterfaceName 'aclablinvm01VMNic' `
  -ResourceGroupName 'aclabtestrg'

$result | ConvertTo-Json -Depth 100 | Out-File 'C:\dev\ac-azure\az104\ps\netq43-output.json'

# MONQ1
Set-AzVMDiagnosticsExtension `
  -ResourceGroupName 'aclabrg' `
  -VMName 'aclabwinvm01' `
  -DiagnosticsConfigurationPath 'C:\dev\ac-azure\az104\ps\monq1-diag.xml'

# Once the diagnostics extension is enabled on a VM, you can get the current 
# settings by using the Get-AzVmDiagnosticsExtension cmdlet.
Get-AzVMDiagnosticsExtension -ResourceGroupName 'aclabrg' -VMName 'aclabwinvm01'

# MON23
Register-AzResourceProvider -ProviderNamespace 'Microsoft.RecoveryServices'

$rg = "aclabtestrg"

New-AzRecoveryServicesVault `
  -ResourceGroupName $rg `
  -Name 'myRecoveryServicesVault' `
  -Location 'eastus'

Get-AzRecoveryServicesVault `
  -Name "myRecoveryServicesVault" | Set-AzRecoveryServicesVaultContext

Get-AzRecoveryServicesVault `
  -Name "myRecoveryServicesVault" | 
  Set-AzRecoveryServicesBackupProperty -BackupStorageRedundancy LocallyRedundant

$policy = Get-AzRecoveryServicesBackupProtectionPolicy -Name "DefaultPolicy"

Enable-AzRecoveryServicesBackupProtection `
  -ResourceGroupName $rg `
  -Name "aclablinvm01" `
  -Policy $policy