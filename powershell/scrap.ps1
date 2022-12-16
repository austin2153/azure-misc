Connect-AzAccount

# ---------------

Register-AzResourceProvider -ProviderNamespace Microsoft.Kubernetes
Register-AzResourceProvider -ProviderNamespace Microsoft.KubernetesConfiguration

# ---------------

Get-AzResourceGroup -Name 'az104-09b*'
Get-AzResourceGroup -Name 'az104-09b*' | Remove-AzResourceGroup -Force -AsJob

# ---------------
# Add a tag to a resource

$r = Get-AzResource -ResourceName 'acstorage2153' -ResourceGroupName 'ac-monitor-design-rg'
$r.Tags.Add('env', 'dev')
Set-AzResource -Tag $r.Tags -ResourceId $r.ResourceId -Force


Add-WindowsFeature Web-Server
Set-Content -Path 'C:\inetpub\wwwroot\Default.html' -Value "This is the server $($env:computername) !"

$config = @{
    'fileUris'         = (, 'https://webstorelog1000.blob.core.windows.net/script/install.ps1');
    'commandToExecute' = 'powershell -ExecutionPolicy Unrestricted -File install.ps1'
}

$set = Get-AzVmss -ResourceGroupName 'test-grp' -VMScaleSetName 'demoscaleset'
$set = Add-AzVmssExtension -VirtualMachineScaleSet $set -Name 'customScript' -Publisher 'Microsoft.Compute' -Type 'CustomScriptExtension' -TypeHandlerVersion 1.9 -Setting $config
Update-AzVmss -ResourceGroupName 'test-grp' -Name 'demoscaleset' -VirtualMachineScaleSet $set

ssh -i .\aclablinux01_key.pem austin@20.231.217.114 -p 221


# 13.68.190.190/images/Default.html
# 52.149.158.13/videos/Default.html
# 20.25.111.183/images/Default.html
# 20.25.111.183/videos/Default.html


$connectTestResult = Test-NetConnection -ComputerName aclabstgacct.file.core.windows.net -Port 445
if ($connectTestResult.TcpTestSucceeded) {
    # Save the password so the drive will persist on reboot
    cmd.exe /C "cmdkey /add:`"aclabstgacct.file.core.windows.net`" /user:`"localhost\aclabstgacct`" /pass:`"MGndTKgYHBMvAbB42iMbtzwxSLlQtSjfK6jkN7QR9pz2NlKgFHgtDKhubrIfQp937cHXkgdHekI4+AStll4stg==`""
    # Mount the drive
    New-PSDrive -Name Z -PSProvider FileSystem -Root '\\aclabstgacct.file.core.windows.net\temp' -Persist
}
else {
    Write-Error -Message 'Unable to reach the Azure storage account via port 445. Check to make sure your organization or ISP is not blocking port 445, or use Azure P2S VPN, Azure S2S VPN, or Express Route to tunnel SMB traffic over a different port.'
}


Connect-AzAccount
New-AzManagementGroupSubscription -GroupName "Development" -SubscriptionId "be637f67-2af9-4b7b-be2f-18da9b2968cb"