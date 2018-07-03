#!/bin/bash 
 
  echo "computer name is now :" $1
    
  sudo scutil --set ComputerName $1
  sudo scutil --set LocalHostName $1

## Enable local firewall  

	sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on
	sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setloggingmode on
	sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setstealthmode on
	sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setallowsigned off
	sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setallowsignedapp off
	sudo pkill -HUP socketfilterfw
