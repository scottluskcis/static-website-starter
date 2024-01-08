#!/bin/bash

# logout
logout_from_azure() {
  echo -e "\nDo you want to logout of Azure? (Y/n)"
  read answer
  first_char=$(echo "${answer:0:1}" | tr '[:upper:]' '[:lower:]')
  if [ "$first_char" == "y" ]; then
    az logout
    echo -e "\nLogged out of Azure"
  fi
}

logout_from_azure