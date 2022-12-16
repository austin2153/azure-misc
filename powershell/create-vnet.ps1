Connect-AzAccount
Get-InstalledModule -Name Az -AllVersions | Select-Object -Property Name,Version 
Disconnect-AzAccount
Get-AzSubscription

# Set context to a subscription
Get-AzSubscription
$context = Get-AzSubscription -SubscriptionId 965ab6d3-fa18-45bd-b2c2-c813de59b590
Set-AzContext $context

# Kick off Azure Policy Compliance Scan
Start-AzPolicyComplianceScan

# Create a resource group
New-AzResourceGroup -Name "rg_testgroup" -Location "East US 2"

# Get policy definition and assign it to a resource group
$definition = Get-AzPolicyDefinition | Where-Object { $_.Properties.DisplayName -eq "Audit resource location matches resource group location" }
$rg = Get-AzResourceGroup -Name rg_"testgroup" -Location "East US 2"
$rg.ResourceGroupName
New-AzPolicyAssignment -Name "Resource group location match" -DisplayName "Checking the rules" -Scope $rg.ResourceId -PolicyDefinition $definition


 







# $rg = @{
#   Name = 'CreateVNetQS-rg'
#   Location = 'EastUS'
# }
# New-AzResourceGroup @rg

# $rg = "SL-Network"
# $location = "North Central US"

# #VNET Name and Address Space
# $VNETName = "SL-70533-VNET-Pshell"
# $VNETAddressSpace = "10.0.0.0/22"

# #Subnet Names and Address Space

# $subnetAName = "SL-Web"
# $subnetAAddressPrefix = "10.0.0.0/24"

# $subnetBName = "SL-App"
# $subnetBAddressPrefix = "10.0.1.0/24"

# $subnetCName = "SL-Data"
# $subnetCAddressPrefix = "10.0.2.0/24"

# #Create Subnet
# $subnets = New-AzureRmVirtualNetworkSubnetConfig