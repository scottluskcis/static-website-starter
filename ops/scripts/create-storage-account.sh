#!/bin/bash

get_or_create_resource_group() {
  echo -e "\nCreate a New Azure Resource Group or Use Existing?"
  options=("New" "Existing")
  select opt in "${options[@]}"; do
    case $opt in
    "New")
      echo -e "\nPlease enter the name of the resource group:"
      read resource_group

      echo -e "\nPlease enter the location of the resource group:"
      read location

      az group create --name $resource_group --location $location
      break
      ;;
    "Existing")
      echo -e "\nPlease enter the name of the resource group:"
      read resource_group
      break
      ;;
    *) echo "Invalid option $REPLY" ;;
    esac
  done 
}

# create the service principal
create_storage_account() {  
  # variable $1 is the resource group name

  echo -e "\nPlease enter the name of the storage account:"
  read storage_account_name

  echo -e "\nPlease enter the location to use for the storage account:"
  read location

  # create Azure storage account
  az storage account create \
    --name $storage_account_name \
    --location $location \
    --resource-group $1

  # get the account key
  account_key=$(az storage account keys list --resource-group $1 --account-name $storage_account_name --query '[0].value' --output tsv)

  # create Container in Azure storage account
  az storage container create \
    --account-name $storage_account_name \
    --name tfstate \
    --public-access off \
    --account-key $account_key
}

echo -e "\n-----------------------------------------------------"

# connect to start the process
./connect-azure.sh

# Check the exit status of the connect-azure.sh script
if [ $? -ne 0 ]; then
  echo -e "\nFailed to connect to Azure. Exiting."
  ./disconnect-azure.sh
  exit 1
fi

# get or create resource group
get_or_create_resource_group 

# create the storage account
create_storage_account $resource_group

# disconnect
./disconnect-azure.sh

echo -e "\n-----------------------------------------------------"
