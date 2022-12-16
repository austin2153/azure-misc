
# generate a SAS token for you
Connect-AzAccount
Get-AzSubscription
 
$subscriptionId = "be637f67-2af9-4b7b-be2f-18da9b2968cb"
$storageAccountRG = "ac-storage-test"
$storageAccountName = "actest2153"
$storageContainerName = "private"
$localPath = "/home/austin/dev/azure/scripts"
 
Select-AzSubscription -SubscriptionId $SubscriptionId
$storageAccountKey = (Get-AzStorageAccountKey -ResourceGroupName $storageAccountRG -AccountName $storageAccountName).Value[0]
$destinationContext = New-AzStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $storageAccountKey
$containerSASURI = New-AzStorageContainerSASToken -Context $destinationContext -ExpiryTime(get-date).AddSeconds(3600) -FullUri -Name $storageContainerName -Permission rw
azcopy copy $localPath $containerSASURI --recursive