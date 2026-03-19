#!/bin/bash

# Task 1 - System Admin Tool

while true; do
	echo "===== System Admin Tool ====="
	echo "1. Show System usage"
	echo "2. Exit"

	read -p "Choose an option: " choice

	case $choice in 
		1)
			echo "not implemented yet"
			;;
		2)
			echo "exiting..."
			break
			;;
		*)
			echo "Invalid option"
			;;
	esac
done
