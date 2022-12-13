$resourceGroup = "aclab-keyvault-arm"
$location = "eastus"
$vaultName = "aclab-vault-01"

New-AzResourceGroup -Name $resourceGroup -Location $location
New-AzKeyVault `
  -VaultName $vaultName `
  -resourceGroupName $resourceGroup `
  -Location $location `
  -EnabledForTemplateDeployment
$secretvalue = ConvertTo-SecureString 'Jackson1234#' -AsPlainText -Force
$secret = Set-AzKeyVaultSecret -VaultName $vaultName -Name 'ExamplePassword' -SecretValue $secretvalue
Write-Host $secret


New-AzResourceGroupDeployment `
  -ResourceGroupName $resourceGroup `
  -TemplateUri "C:\dev\ac-azure\az305\arm\keyvault-arm\template.json" `
  -TemplateParameterFile "C:\dev\ac-azure\az305\arm\keyvault-arm\parameters.json"