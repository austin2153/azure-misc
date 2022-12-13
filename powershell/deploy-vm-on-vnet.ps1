# 96.27.249.234 ISP
Connect-AzAccount

# vm vars
$VMResourceGroupName = "aclab-vnet-rg"
$VMName = "aclabwinvm02"
$NICName = "aclabwinvm02-nic0"
$Location = "eastus"
$PublicIpRequired = $true

# vnet vars
$vNetName = "aclabvnet01"
$NetResourceGroupName = "aclab-vnet-rg"
$SubnetName = "subnet-b"

# create public ip if boolean is true
if ( $PublicIpRequired -eq $true ) {
    $ip = @{
        Name = "$($VMName)-PublicIP"
        ResourceGroupName = $VMResourceGroupName
        Location = $Location
        Sku = 'Standard'
        AllocationMethod = 'Static'
        IpAddressVersion = 'IPv4'
        Zone = 1,2,3   
    }
    New-AzPublicIpAddress @ip
} else {
    Write-Host "Skipping public IP Creation" -ForegroundColor Cyan
}

# get vnet from name and rg
$VirtualNetwork = Get-AzVirtualNetwork -Name $vNetName -ResourceGroupName $NetResourceGroupName

# get subnet based on name and return id
Write-Host "Found '$($VirtualNetwork.Subnets.Count)' subnets in '$($VirtualNetwork.Name)'" -ForegroundColor Cyan
foreach ($subnet in $VirtualNetwork.Subnets) {
    if ( $subnet.Name -contains $SubnetName ) {
        Write-Host "Found '$($subnet.Name)' Returning id '$($subnet.Id)'" -ForegroundColor Cyan
        $SubnetId = $subnet.Id
    }
}

# create and attach nic to existing vnet
$NIC = New-AzNetworkInterface -Name $NICName -ResourceGroupName $VMResourceGroupName `
    -Location $Location -SubnetId $SubnetId

# create credential for vm
$SecurePassword = ConvertTo-SecureString "Jackson1234#" -AsPlainText -Force
$Credential = New-Object System.Management.Automation.PSCredential ("austin", $SecurePassword);

# create vm
$VirtualMachine = New-AzVMConfig `
    -VMName $VMName `
    -VMSize Standard_B1ms
$VirtualMachine = Set-AzVMOperatingSystem `
    -VM $VirtualMachine `
    -Windows `
    -ComputerName $VMName `
    -Credential $Credential `
    -ProvisionVMAgent `
    -EnableAutoUpdate
$VirtualMachine = Add-AzVMNetworkInterface `
    -VM $VirtualMachine `
    -Id $NIC.Id
$VirtualMachine = Set-AzVMSourceImage `
    -VM $VirtualMachine `
    -PublisherName 'MicrosoftWindowsServer' `
    -Offer 'WindowsServer' `
    -Skus '2012-R2-Datacenter' `
    -Version latest
New-AzVM `
    -ResourceGroupName $VMResourceGroupName `
    -Location $Location `
    -VM $VirtualMachine `
    -Verbose



# cleanup
Remove-AzVM -ResourceGroupName $VMResourceGroupName -Name $VMName