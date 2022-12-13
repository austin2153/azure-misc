#Download AzCopy
wget https://aka.ms/downloadazcopy-v10-linux
 
#Expand Archive
tar -xvf downloadazcopy-v10-linux
 
#(Optional) Remove existing AzCopy version
sudo rm /usr/bin/azcopy
 
#Move AzCopy to the destination you want to store it
sudo cp ./azcopy_linux_amd64_*/azcopy /usr/bin/