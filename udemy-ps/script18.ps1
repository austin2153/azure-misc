Connect-AzAccount
New-AzResourceGroup -Name $resourceGroup -Location $location

$resourceGroup = "aclab-scaleset-rg"
$location = "eastus"
$scaleSetName="aclab-scaleset-01"
$virtualNetworkName="aclab-network-scaleset"
$subnetName="subnet01"
$vmImage = "Win2019Datacenter"
$vmSize="Standard_DS2_v2"



New-AzVmss -ResourceGroupName $resourceGroup -Location $location -VMScaleSetName $scaleSetName `
  -VirtualNetworkName $virtualNetworkName -SubnetName $subnetName -PublicIpAddressName "myPublicIPAddress" `
  -ImageName $vmImage -UpgradePolicyMode "Automatic" -VmSize $vmSize -Credential (Get-Credential)