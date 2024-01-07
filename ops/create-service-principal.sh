#!/bin/bash

echo -e "\n-----------------------------------------------------" 

# Check if user is already logged in
if ! az account show > /dev/null 2>&1; then
    echo -e "\nLogging in to Azure"
    az login
else
    echo -e "\nAlready logged in to Azure"
fi

# prompt for subscription
echo -e "\nSpecify the Id or Name of an Azure Subscription to use:"
read subscriptionNameOrId
if [ -z "$subscriptionNameOrId" ]; then
    echo "No input provided. Please specify a subscription Id or Name."
    exit 1
fi

# set the subscription
az account set --subscription "$subscriptionNameOrId"
if ! az account show > /dev/null 2>&1; then
    echo "No valid account is set. Please check the subscription Id or Name and try again."
    exit 1 
fi

# confirm creation of service principal
subscription_name=$(az account show --query name --output tsv)
subscription_id=$(az account show --query id --output tsv)
echo -e "\nCurrent subscription: '$subscription_name'. \nDo you want to create a service prinicpal for this subscription? (Y/n)"
read answer 
first_char=$(echo "${answer:0:1}" | tr '[:upper:]' '[:lower:]')
if [ "$first_char" != "y" ]; then
  echo "Aborting."
  exit 1
fi

# prompt for service principal name
echo -e "\nWhat name do you want to use for the Service Principal?"
read sp_name

# create service principal based on user selection
echo -e "\nPlease choose an option of scope you want to assign this service principal to:"
options=("Subscription" "Existing Resource Group" "New Resource Group")
select opt in "${options[@]}"
do
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
        *) echo "Invalid option $REPLY";;
    esac
done

# logout
echo -e "\nScript execution completed. \nDo you want to logout of Azure? (Y/n)"
read answer
first_char=$(echo "${answer:0:1}" | tr '[:upper:]' '[:lower:]')
if [ "$first_char" == "y" ]; then
    az logout
    echo -e "\nLogged out of Azure" 
fi

echo -e "\n-----------------------------------------------------" 

# cleanup
# Replace <id> with the ID of the service principal you want to delete
# az ad sp delete --id <id>

# Replace MyResourceGroup with the name of the resource group you want to delete
# az group delete --name MyResourceGroup --yes --no-wait