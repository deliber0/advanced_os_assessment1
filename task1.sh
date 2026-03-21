#!/bin/bash

# Task 1 - System Admin Tool
LOG_FILE="system_monitor_log.txt"

log_action() {
	# Using a single logging function keeps format consistnent 
	# and avoids repeating myself throughout the script
	local message="$1"
	echo "$(date '+%Y-%m-%d %H:%M:%S') | $message" >> "$LOG_FILE"
}

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

	log_action "Viewed system usage"
}

show_top_processes() {
	echo
	echo "===== Top 10 Memory-Consuming Processes ====="

	# Using ps instead of top because it is non-interactive
	# and easier control in a script
	# --sort=-%mem sorts by memory usage (highest first)
	# Using 'comm' instead of 'args' so the output stays readable.
	ps -eo pid,user,%cpu,%mem,comm --sort=-%mem | head -n 11

	echo

	log_action "Viewed top 10 proceses by memory usage"
}

terminate_process() {
	echo
	echo "===== Terminate Process ====="

	# Asking for PID is safer than offering options
	# Avoids the user accidently terminating the wrong process

	read -p "Enter PID to terminate: " pid

	# Validation
	if ! [[ "$pid" =~ ^[0-9]+$ ]]; then
		echo "Invalid PID. Please enter a numeric process ID."
		echo
		log_action "Invalid PID entered for termination: $pid"
		return
	fi

	# Checking the process exists first
	if ! ps -p "$pid" > /dev/null 2>&1; then
		echo "Process with PID $pid was not found."
		echo
		log_action "Termination attempted on non-existent PID: $pid"
		return
	fi

	process_name=$(ps -p "$pid" -o comm= | xargs)

	# Critical process protection is added to avoid terminating
	# unsafe system processes.
	case "$process_name" in
		systemd|init|systemd-journal|systemd-resolved|bash|sudo)
			echo "Termination blocked: $process_name is treated as a critical system process."
			echo
			log_action "Blocked termination of critical process: PID $pid ($process_name)"
			return
			;;
	esac

	echo "Selected process:"
	ps -p "$pid" -o pid,user,%cpu,%mem,comm

	# Confirmation is required so termination is never performed immediately.
	read -p "Are you sure you want to terminate PID $pid? (Y/N): " confirm

	case "$confirm" in 
		Y|y)
			if kill "$pid" 2>/dev/null; then
				echo "Process $pid terminated successfully."
				log_action "Terminated process: PID $pid ($process_name)"
			else
				echo "Failed to terminate process $pid."
				log_action "Failed to terminate process: PID $pid ($process_name)"
			fi
			;;
		N|n)
			echo "Termincation cancelled."
			log_action "Cancelled termination for PID $pid ($process_name)"
			;;
		*)
			echo "Invalid input. Termination cancelled."
			log_action "Invalid confirmation input during termination for PID $pid ($process_name)"
			;;
	esac

	echo
}

while true; do
    echo "===== System Admin Tool ====="
    echo "1. Show system usage"
	echo "2. Show top processes"
	echo "3. Termniate a process"
    echo "4. Exit"

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
			show_top_processes
			;;
		3)
			terminate_process
			;;
        4)
            echo "Exiting..."
			log_action "Exited system admin tool"
            break
            ;;
        *)
            echo "Invalid option"
			log_action "Invalid menu option entered: $choice"
            ;;
    esac

    echo
done