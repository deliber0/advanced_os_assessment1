#!/bin/bash

# Task 1 - System Admin Tool

show_system_usage() {
    # Using uptime for load average because it gives a quick summary
    # of system demand without needing more complex parsing.
    load_info=$(uptime | awk -F'load average: ' '{print $2}')

   	# Using top in batch mode (-bn1) to avoid interactive output
	# and allow CPU data to be captured within the script.
    cpu_idle=$(top -bn1 | grep "Cpu(s)" | awk '{print $8}' | tr -d ',')
    cpu_used=$(awk "BEGIN {printf \"%.1f\", 100 - $cpu_idle}")

    # Using free -h because the output is already human-readable,
    # which makes the admin menu easier to understand.
    mem_line=$(free -h | awk '/^Mem:/')
    swap_line=$(free -h | awk '/^Swap:/')

    mem_total=$(echo "$mem_line" | awk '{print $2}')
    mem_used=$(echo "$mem_line" | awk '{print $3}')
    mem_free=$(echo "$mem_line" | awk '{print $4}')

    swap_total=$(echo "$swap_line" | awk '{print $2}')
    swap_used=$(echo "$swap_line" | awk '{print $3}')
    swap_free=$(echo "$swap_line" | awk '{print $4}')

    echo
    echo "===== Current System Usage ====="
    echo "Load Average (1, 5, 15 min): $load_info"
    echo "CPU Usage: ${cpu_used}%"
    echo "Memory Used: $mem_used / $mem_total"
    echo "Memory Free: $mem_free"
    echo "Swap Used: $swap_used / $swap_total"
    echo "Swap Free: $swap_free"
    echo
}

while true; do
    echo "===== System Admin Tool ====="
    echo "1. Show system usage"
    echo "2. Exit"

    # Using read here so the menu waits for explicit user input
    # rather than running actions automatically.
    read -p "Choose an option: " choice

    # A case statement is used because it scales better than
    # repeated if/elif checks as more menu options are added.
    case $choice in
        1)
            show_system_usage
            ;;
        2)
            echo "Exiting..."
            break
            ;;
        *)
            echo "Invalid option"
            ;;
    esac

    echo
done