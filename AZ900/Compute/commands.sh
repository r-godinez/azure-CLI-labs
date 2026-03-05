
# Create resource group
 az group create --name IntroAzureRG --location mexicocentral

# Create Linux VM
az vm create \
  --resource-group "IntroAzureRG" \
  --name my-vm \
  --size Standard_B1s \
  --public-ip-sku Standard \
  --image Ubuntu2204 \
  --admin-username azureuser \
  --generate-ssh-keys    

# Install Nginx using a script
 az vm extension set \
   --resource-group "IntroAzureRG" \
   --vm-name my-vm \
   --name customScript \
   --publisher Microsoft.Azure.Extensions \
   --version 2.1 \
   --settings '{"fileUris":["https://raw.githubusercontent.com/MicrosoftDocs/mslearn-welcome-to-azure/master/configure-nginx.sh"]}' \
   --protected-settings '{"commandToExecute": "./configure-nginx.sh"}'    

# Access web server
IPADDRESS="$(az vm list-ip-addresses \
  --resource-group "IntroAzureRG" \
  --name my-vm \
  --query "[].virtualMachine.network.publicIpAddresses[*].ipAddress" \
  --output tsv)"    

curl --connect-timeout 5 http://$IPADDRESS

echo $IPADDRESS       

# List Network Security Group Rules
az network nsg list \
  --resource-group "IntroAzureRG" \
  --query '[].name' \
  --output tsv    

az network nsg rule list \
  --resource-group "IntroAzureRG" \
  --nsg-name my-vmNSG \
  --query '[].{Name:name, Priority:priority, Port:destinationPortRange, Access:access}' \
  --output table    

# Create Network Security Rule to allow access in port 80 (HTTP)
az network nsg rule create \
  --resource-group "IntroAzureRG" \
  --nsg-name my-vmNSG \
  --name allow-http \
  --protocol tcp \
  --priority 100 \
  --destination-port-range 80 \
  --access Allow     

# Verify
az network nsg rule list \
  --resource-group "IntroAzureRG" \
  --nsg-name my-vmNSG \
  --query '[].{Name:name, Priority:priority, Port:destinationPortRange, Access:access}' \
  --output table    

# Access web app
curl --connect-timeout 5 http://$IPADDRESS

echo $IPADDRESS   
