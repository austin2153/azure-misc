# Connect-AzAccount

# # var setup
# $group = 'aclab-demo-rg'
# $loc = 'eastus'
# $vnet01 = 'aclab-vnet-01'
# $nsg01 = 'aclab-vnet-01-nsg'
# $vnet02 = 'aclab-vnet-02'
# $subnet01 = 'subnet-01'
# $subnet02 = 'subnet-02'
# $vm01 = 'aclab-linvm-01'
# $vm02 = 'aclab-linvm-02'
# $user = 'austin'
# $pass = ConvertTo-SecureString 'FiservGetout5#' -AsPlainText -Force
# $cred = New-Object System.Management.Automation.PSCredential ('austin', $pass);

# # create rg
# New-AzResourceGroup -Name $group -Location $loc

# # create an inbound nsg rule for port 22
# $nsgRule = New-AzNetworkSecurityRuleConfig `
#   -Name 'ssh-inbound' `
#   -Protocol Tcp `
#   -Direction Inbound `
#   -Priority 100 `
#   -SourceAddressPrefix * `
#   -SourcePortRange * `
#   -DestinationAddressPrefix * `
#   -DestinationPortRange 22 `
#   -Access Allow;

# # create a nsg / add the rule
# $nsg = New-AzNetworkSecurityGroup `
#   -ResourceGroupName $group `
#   -Location $loc `
#   -Name $nsg01 `
#   -SecurityRules $nsgRule

# # create subnet / add the nsg 
# $subnet = New-AzVirtualNetworkSubnetConfig `
#   -Name $subnet01 `
#   -AddressPrefix 10.0.1.0/24 `
#   -NetworkSecurityGroup $nsg

# # create vnet / add the subnet
# $vnet = New-AzVirtualNetwork `
#   -ResourceGroupName $group `
#   -Location $loc `
#   -Name $vnet01 `
#   -AddressPrefix '10.0.0.0/16' `
#   -Subnet $subnet

# # create a public IP address and specify a DNS name
# $publicIp = New-AzPublicIpAddress `
#   -ResourceGroupName $group `
#   -Location $loc `
#   -Name ($vm01 + 'publicip') `
#   -AllocationMethod Static `
#   -IdleTimeoutInMinutes 4

# # create a nic / add vnet and public ip
# $nic = New-AzNetworkInterface `
#   -Name ($vm01 + 'nic') `
#   -ResourceGroupName $group `
#   -Location $loc `
#   -SubnetId $vnet.Subnets[0].Id `
#   -PublicIpAddressId $publicIp.Id

# # configure ssh keys
# ssh-keygen.exe              ## generate ssh key if not already exist
# $sshPublicKey = Get-Content "$env:USERPROFILE\.ssh\id_rsa.pub"
# Add-AzVMSshPublicKey -VM $vmconfig -KeyData $sshPublicKey -Path '/home/azureuser/.ssh/authorized_keys'

# # create a virtual machine configuration 
# $vmConfig = New-AzVMConfig `
#   -VMName $vm01 `
#   -VMSize Standard_B1s | Set-AzVMOperatingSystem `
#     -Linux -ComputerName $vm01 `
#     -Credential $cred `
#     -DisablePasswordAuthentication | Set-AzVMSourceImage `
#     -PublisherName 'OpenLogic' `
#     -Offer 'CentOS' `
#     -Skus '7.5' `
#     -Version '7.5.201808150' | ## (CentOS 7)
#     ## Set-AzVMSourceImage -PublisherName "RedHat" -Offer "RHEL" -Skus "7-LVM" -Version "7.9.2020100116" | ## (RHEL 7)
#     ## Set-AzVMSourceImage -PublisherName "Canonical" -Offer "UbuntuServer" -Skus "18.04-LTS" -Version "18.04.202010140" | ## (Ubuntu 18)
#     ## Set-AzVMSourceImage -PublisherName "Debian" -Offer "debian-10" -Skus "10" -Version "0.20201023.432" | ## (Debian 10)
#     ## Set-AzVMSourceImage -PublisherName "MicrosoftWindowsServer" -Offer "WindowsServer" -Skus "2019-Datacenter" -Version "2019.0.20190410" | (WindowsServer 2019)
#     Add-AzVMNetworkInterface -Id $nic.Id;

    

# $SingleSubnet = New-AzVirtualNetworkSubnetConfig -Name $SubnetName -AddressPrefix $SubnetAddressPrefix
# $Vnet = New-AzVirtualNetwork -Name $NetworkName -ResourceGroupName $ResourceGroupName -Location $LocationName -AddressPrefix $VnetAddressPrefix -Subnet $SingleSubnet
# $PIP = New-AzPublicIpAddress -Name $PublicIPAddressName -DomainNameLabel $DNSNameLabel -ResourceGroupName $ResourceGroupName -Location $LocationName -AllocationMethod Dynamic
# $NIC = New-AzNetworkInterface -Name $NICName -ResourceGroupName $ResourceGroupName -Location $LocationName -SubnetId $Vnet.Subnets[0].Id -PublicIpAddressId $PIP.Id

# $Credential = New-Object System.Management.Automation.PSCredential ($VMLocalAdminUser, $VMLocalAdminSecurePassword);

# $VirtualMachine = New-AzVMConfig -VMName $VMName -VMSize $VMSize
# $VirtualMachine = Set-AzVMOperatingSystem -VM $VirtualMachine -Windows -ComputerName $ComputerName -Credential $Credential -ProvisionVMAgent -EnableAutoUpdate
# $VirtualMachine = Add-AzVMNetworkInterface -VM $VirtualMachine -Id $NIC.Id
# $VirtualMachine = Set-AzVMOSDisk -VM $VirtualMachine -Name $OSDiskName -VhdUri $OSDiskUri -SourceImageUri $SourceImageUri -Caching $OSDiskCaching -CreateOption $OSCreateOption -Windows

# New-AzVM -ResourceGroupName $ResourceGroupName -Location $LocationName -VM $VirtualMachine -Verbose



# ## Create a virtual machine
# New-AzVM `
# -ResourceGroupName $group `
# -Location $loc `
# -VM $vmConfig

# # create vm
# New-AzVM `
#   -ResourceGroupName $group `
#   -Name $vm01 `
#   -Location $loc `
#   -Image UbuntuLTS `
#   -Size Standard_B2s `
#   -PublicIpAddressName myPubIP `
#   -OpenPorts 80 `
#   -Credential $cred
# # -GenerateSshKey `
# # -SshKeyName mySSHKey