#!/bin/bash

# login
login_to_azure() {
  if ! az account show >/dev/null 2>&1; then
    echo -e "\nLogging in to Azure"
    az login
  else
    echo -e "\nAlready logged in to Azure"
  fi
}

# set the subscription
set_subscription() {
  answer="n"
  if az account show >/dev/null 2>&1; then
    subscriptionNameOrId=$(az account show --query "{Name:name, ID:id}" --output table)
    
    echo -e "\nCurrent subscription set to: \n"
    echo -e "${subscriptionNameOrId}"
    echo -e "\nDo you want to use this subscription? (Y/n)"
    read answer
  fi

  first_char=$(echo "${answer:0:1}" | tr '[:upper:]' '[:lower:]')
  if [ "$first_char" == "y" ]; then
    return
  fi

  echo -e "\nSpecify the Id or Name of an Azure Subscription to use:"
  read subscriptionNameOrId
  if [ -z "$subscriptionNameOrId" ]; then
    echo "No input provided. Please specify a subscription Id or Name."
    exit 1
  fi

  az account set --subscription "$subscriptionNameOrId"
  if ! az account show >/dev/null 2>&1; then
    echo "No valid account is set. Please check the subscription Id or Name and try again."
    exit 1
  fi
}

# confirm continue using this account
confirm_continue() {
  subscription_name=$(az account show --query name --output tsv)
  subscription_id=$(az account show --query id --output tsv)
  echo -e "\nCurrent subscription: '$subscription_name'. \nDo you want to perform this operation using this subscription? (Y/n)"
  read answer
  first_char=$(echo "${answer:0:1}" | tr '[:upper:]' '[:lower:]')
  if [ "$first_char" != "y" ]; then
    echo -e "\nAborting...\n"
    exit 1
  fi
}

# run the functions
login_to_azure
set_subscription
confirm_continue