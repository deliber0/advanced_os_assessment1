#!/bin/bash

# Task 1 - System Admin Tool
LOG_FILE="system_monitor_log.txt"
ARCHIVE_DIR="ArchiveLogs"

log_action() {
	# Using a single logging function keeps format consistent 
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
	# and easier to control in a script
	# --sort=-%mem sorts by memory usage (highest first)
	# Using 'comm' instead of 'args' so the output stays readable.
	ps -eo pid,user,%cpu,%mem,comm --sort=-%mem | head -n 11

	echo

	log_action "Viewed top 10 processes by memory usage"
}

terminate_process() {
	echo
	echo "===== Terminate Process ====="

	# Asking for PID is safer than offering options
	# Avoids the user accidentally terminating the wrong process

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
			echo "Termination cancelled."
			log_action "Cancelled termination for PID $pid ($process_name)"
			;;
		*)
			echo "Invalid input. Termination cancelled."
			log_action "Invalid confirmation input during termination for PID $pid ($process_name)"
			;;
	esac

	echo
}

inspect_directory_usage() {
	echo
	echo "===== Directory Disk Usage ====="

	# Ask the user for a path allows the same function to inspect different locations.
	read -p "Enter directory path to inspect: " dir_path

	# Checking the path is real 
	if [[ ! -d "$dir_path" ]]; then
		echo "Invalid directory path."
		echo
		log_action "Invalid directory path entered for disk inspection: $dir_path"
		return
	fi

	# Using du -sh gives a readable total size for the directory 
	usage=$(du -sh "$dir_path" 2>/dev/null | awk '{print $1}')

	echo "Directory: $dir_path"
	echo "Total size: $usage"
	echo

	log_action "Inspected disk usage for directory: $dir_path ($usage)"
}

find_large_logs() {
	echo
	echo "===== Large Log File Detection ====="

	# Asking for a directory rather than hardcoding a single log location
	read -p "Enter directory path to scan for large log files: " dir_path

	if [[ ! -d "$dir_path" ]]; then
		echo "Invalid directory path."
		echo 
		log_action "Invalid directory path entered for large log scan: $dir_path"
		return
	fi

	# Using 'find' because it is available by default on Linux systems,
	# making the script portable and avoids needing to install packages.
	# Tools like 'fd' can offer faster searching, but needs to be installed.
	large_logs=$(find "$dir_path" -type f -name "*.log" -size +50M -exec ls -lh {} \; 2>/dev/null)

	if [[ -z "$large_logs" ]]; then
		echo "No .log files larger than 50MB were found."
		echo
		log_action "No large log files found in directory: $dir_path"
		return
	fi

	echo "Large log files found:"
	echo "$large_logs"
	echo

	log_action "Detected large log files in directory: $dir_path" 
}

archive_large_logs() {
	echo
	echo "===== Archive Large Log Files ====="

	# Asking for a directory rather than it being fixed to one location.
	read -p "Enter directory path to archive large log files from: " dir_path

	if [[ ! -d "$dir_path" ]]; then
		echo "Invalid directory path."
		echo
		log_action "Invalid directory path entered for log archiving: $dir_path"
		return
	fi

	# Creating ArchiveLogs if it doesn't exist yet
	if [[ ! -d "$ARCHIVE_DIR" ]]; then
		mkdir -p "$ARCHIVE_DIR"
		log_action "Created archive directory: $ARCHIVE_DIR"
	fi

	# Using find to identify only large .log files
	mapfile -t log_files < <(find "$dir_path" -type f -name "*.log" -size +50M 2>/dev/null)

	if [[ ${#log_files[@]} -eq 0 ]]; then
		echo "No .log files larger than 50MB were found to archive."
		echo
		log_action "No large log files found for archiving in directory: $dir_path"
		return
	fi

	archived_count=0

	for file in "${log_files[@]}"; do
		base_name=$(basename "$file")
		timestamp=$(date '+%Y%m%d_%H%M%S')
		archive_name="${base_name}_${timestamp}.gz"
		archive_path="$ARCHIVE_DIR/$archive_name"

		# Using gzip compression to reduce storage space needed 
		if gzip -c "$file" > "$archive_path"; then
			echo "Archived: $file -> $archive_path"
			log_action "Archived large log file: $file -> $archive_path"
			((archived_count++))
		else
			echo "Failed to archive: $file"
			log_action "Failed to archive large log file: $file"
		fi
	done

	echo
	echo "Archived $archived_count file(s)."
	echo

	check_archive_size
}

check_archive_size() {
	# Checking the size of the archive to check if the 1GB limit is reached.
	if [[ ! -d "$ARCHIVE_DIR" ]]; then
		return
	fi

	archive_size_bytes=$(du -sb "$ARCHIVE_DIR" 2>/dev/null | awk '{print $1}')

	if [[ -n "$archive_size_bytes" && "$archive_size_bytes" -gt 1073741824 ]]; then
		archive_size_human=$(du -sh "$ARCHIVE_DIR" 2>/dev/null | awk '{print $1}')
		echo "Warning: ArchiveLogs exceeds 1GB (current size: $archive_size_human)."
		echo
		log_action "ArchiveLogs exceeded 1GB warning triggered (size: $archive_size_human)"
	fi
}

confirm_exit() {
	echo
	echo "===== Exit Confirmation ====="

	while true; do
		# Loop ensures a valid input is received
		read -p "Are you sure you want to exit? (Y/N): " confirm_exit_choice

		case "$confirm_exit_choice" in
			Y|y)
				echo "Exiting system admin tool..."
				log_action "Exited system admin tool"
				return 0
				;;
			N|n)
				echo "Exit cancelled."
				log_action "Cancelled exit request"
				return 1
				;;
			*)
				echo "Invalid input. Please enter Y or N."
				log_action "Invalid exit confirmation input"
				;;
		esac
	done
}

while true; do
    echo "===== System Admin Tool ====="
    echo "1. Show system usage"
	echo "2. Show top processes"
	echo "3. Terminate a process"
	echo "4. Inspect directory disk usage"
	echo "5. Find large log files"
	echo "6. Archive large log files"
    echo "7. Exit"

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
			inspect_directory_usage
			;;
		5)
			find_large_logs
			;;
		6)
			archive_large_logs
			;;
        7)
            if confirm_exit; then
				break
			fi
			;;
        *)
            echo "Invalid option"
			log_action "Invalid menu option entered: $choice"
            ;;
    esac

    echo
done