Connect-AzAccount

# Create variables
$webappname = "aclabwebapp$(Get-Random)"
$rgname = 'aclab-webapp-rg'
$location = 'eastus'

# Create a resource group
New-AzResourceGroup -Name $rgname -Location $location

# Create an App Service plan in S1 tier
New-AzAppServicePlan -Name $webappname -Location $location -ResourceGroupName $rgname -Tier S1

# Create a web app
New-AzWebApp -Name $webappname -Location $location -AppServicePlan $webappname -ResourceGroupName $rgname

New-AzWebAppSlot -ResourceGroupName $rgname -Name "aclabwebapp527327562" `
    -AppServicePlan "aclabwebapp527327562" -Slot "staging"

# Cleanup
Get-AzResourceGroup -Name $rgname | Remove-AzResourceGroup -Force