#!/bin/bash

# create the service principal
create_service_principal() {
  # prompt for service principal name
  echo -e "\nWhat name do you want to use for the Service Principal?"
  read sp_name

  # create service principal based on user selection
  echo -e "\nPlease choose an option of scope you want to assign this service principal to:"
  options=("Subscription" "Existing Resource Group" "New Resource Group")
  select opt in "${options[@]}"; do
    case $opt in
    "Subscription")
      az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/$subscription_id" --name=$sp_name
      break
      ;;
    "Existing Resource Group")
      echo "Please enter the name of the resource group:"
      read resource_group
      az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/$subscription_id/resourceGroups/$resource_group" --name=$sp_name
      break
      ;;
    "New Resource Group")
      echo "Please enter the name of the resource group:"
      read resource_group

      echo "Please enter the location of the resource group:"
      read location

      az group create --name $resource_group --location $location
      az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/$subscription_id/resourceGroups/$resource_group" --name=$sp_name
      break
      ;;
    *) echo "Invalid option $REPLY" ;;
    esac
  done
}

echo -e "\n-----------------------------------------------------"

# connect to start the process
./connect-azure.sh

# Check the exit status of the connect-azure.sh script
if [ $? -ne 0 ]; then
  echo "Failed to connect to Azure. Exiting."
  ./disconnect-azure.sh
  exit 1
fi

# create
create_service_principal

# disconnect
./disconnect-azure.sh

echo -e "\n-----------------------------------------------------"

# cleanup
# Replace <id> with the ID of the service principal you want to delete
# az ad sp delete --id <id>

# Replace MyResourceGroup with the name of the resource group you want to delete
# az group delete --name MyResourceGroup --yes --no-wait
