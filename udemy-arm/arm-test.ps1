New-AzResourceGroup -Name "aclab-armtest-rg" -Location "eastus"
New-AzResourceGroupDeployment -ResourceGroupName "aclab-armtest-rg" -TemplateFile ./template13.json

Export-AzResourceGroup -ResourceGroupName "ac-storage-test"