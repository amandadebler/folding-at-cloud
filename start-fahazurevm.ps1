

Param(
$RESOURCE_GROUP="foldingathome",
$LOCATION="southcentralus",
$USER=$env:USERNAME,
$NAME="folding",
$MAX_PRICE=0.15, # $0.15 USD/hour, or $109.50/mo.; current spot price was $0.1228 on 6 April 2020
$VM_SIZE="Standard_NV6" # single M60 GPU with 6 CPU cores and 56 GB RAM that gets around 500k points per days; NC6 has 1 K80 GPU and gets around 330k points per day
)

$NAME = $NAME.toLower()

# Does this resource group exist in this location?
az group create --name $RESOURCE_GROUP --location $LOCATION

# Does this VNet exist with these addresses?
az network vnet create `
    --resource-group $RESOURCE_GROUP `
    --name $NAME-Vnet `
    --address-prefix 192.168.0.0/16 `
    --subnet-name $NAME-Subnet `
    --subnet-prefix 192.168.1.0/24

# Does this public IP exist?
az network public-ip create `
    --resource-group $RESOURCE_GROUP `
    --name $NAME-PublicIP `
    --dns-name $NAME-publicdns

az network nsg create `
    --resource-group $RESOURCE_GROUP `
    --name $NAME-NetworkSecurityGroup

az network nsg rule create `
    --resource-group $RESOURCE_GROUP `
    --nsg-name $NAME-NetworkSecurityGroup `
    --name $NAME-NetworkSecurityGroupRuleSSH `
    --protocol tcp `
    --priority 1000 `
    --destination-port-range 22 `
    --access allow

az network nic create `
    --resource-group $RESOURCE_GROUP `
    --name $NAME-Nic `
    --vnet-name $NAME-Vnet `
    --subnet $NAME-Subnet `
    --public-ip-address $NAME-PublicIP `
    --network-security-group $NAME-NetworkSecurityGroup

#--size Standard_NC6 \
$VM = $(az vm create `
  --resource-group $RESOURCE_GROUP `
  --name $NAME-vm `
  --size $VM_SIZE `
  --image Canonical:UbuntuServer:18.04-LTS:latest `
  --custom-data cloud-init.yaml `
  --admin-username $USER `
  --generate-ssh-keys `
  --nics $NAME-Nic `
  --priority Spot `
  --max-price $MAX_PRICE)

$VM
  
$fqdns = ($VM | ConvertFrom-JSON).fqdns 

Write-Host "To access new VM, use ssh $USER@$fqdns - but give it 5-10 minutes to install all the updates + CUDA drivers :)"

  # Give it some time to install all the updates + CUDA drivers :)


