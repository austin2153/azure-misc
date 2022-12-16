New-AzResourceGroupDeployment `
    -ResourceGroupName "aclabtest" `
    -TemplateFile C:\dev\ac-azure\az104\arm\ExportedTemplate-aclabtestrg\template.json

New-AzSubscriptionDeployment `
    -Location "eastus" `
    -TemplateFile "C:\dev\ac-azure\az104\arm\ExportedTemplate-aclabtestrg\template.json"

New-AzResourceGroup -Name "aclabtest" -Location "eastus"
New-AzResourceGroupDeployment `
    -Name ExampleDeployment `
    -ResourceGroupName "aclabtest" `
    -TemplateFile "C:\dev\ac-azure\az104\arm\ExportedTemplate-aclabtestrg\template.json" `
    -TemplateParameterFile "C:\dev\ac-azure\az104\arm\ExportedTemplate-aclabtestrg\parameters.json"