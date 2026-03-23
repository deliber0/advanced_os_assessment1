#!/bin/bash

# Task 3 Submission and Access Control System
# This script provides a menu-driven interface for handling assignment submissions
# and integrates with a python backend for duplicate detection and validation.

# Bash is used for:
# - User interaction and menu handling
# - File system validation (existence, size, type)
# - Logging system events

# Python is used for:
# - Content hashing
# - Duplicate detection logic
#
# This seperation keeps system-level tasks in bash and computation-heavy logic in Python.


# Resolve script directory to ensure all file paths work regardless of where the
# script is executed from.
# This avoids issues with relative paths when launching the script from outside the Task3 folder.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="$SCRIPT_DIR/submission_log.txt"
SUBMISSIONS_FILE="$SCRIPT_DIR/submissions_db.txt"
DUPLICATE_CHECKER="$SCRIPT_DIR/duplicate_checker.py"


# Centralised logging function
# Using a single function ensures consistent log formatting
# and avoids repeating timestamp logic throughout the script.

log_action() {
    local message="$1"
    echo "$(date '+%Y-%m-%d %H:%M:%S') | $message" >> "$LOG_FILE"
}

record_submission() {
    local student_id="$1"
    local filename="$2"
    local file_hash="$3"
    local timestamp

    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "$student_id|$filename|$file_hash|$timestamp" >> "$SUBMISSIONS_FILE"
}

confirm_exit() {
    echo
    echo "===== Exit Confirmation ====="

    while true; do
        read -r -p "Are you sure you want to exit? (Y/N): " confirm_exit_choice

        case "$confirm_exit_choice" in
            Y|y)
                echo "Exiting system..."
                log_action "SYSTEM | User exited program"
                return 0
                ;;
            N|n)
                echo "Exit cancelled."
                log_action "SYSTEM | User cancelled exit request"
                return 1
                ;;
            *)
                echo "Invalid input. Please enter Y or N."
                log_action "SYSTEM | Invalid exit confirmation input"
                ;;
        esac
    done
}

submit_assignment() {
    echo
    echo "===== Submit Assignment ====="

    read -r -p "Enter student ID: " student_id
    read -r -p "Enter file path: " file_path

    if [[ -z "$student_id" ]]; then
        echo "Student ID cannot be empty."
        log_action "SUBMISSION | Failed | Empty student ID"
        return
    fi

    # Student ID is validated using a numeric regex pattern to ensure consistency 
    if ! [[ "$student_id" =~ ^[0-9]+$ ]]; then
        echo "Student ID must contain digits only."
        log_action "SUBMISSION | Failed | Invalid student ID format: $student_id"
        return
    fi

    if [[ -z "$file_path" ]]; then
        echo "File path cannot be empty."
        log_action "SUBMISSION | Failed | $student_id | Empty file path"
        return
    fi

    if [[ ! -f "$file_path" ]]; then
        echo "File does not exist."
        log_action "SUBMISSION | Failed | $student_id | File not found: $file_path"
        return
    fi

    filename=$(basename "$file_path")
    extension="${filename##*.}"

    case "${extension,,}" in
        pdf|docx)
            ;;
        *)
            echo "Invalid file type. Only .pdf and .docx files are allowed."
            log_action "SUBMISSION | Failed | $student_id | Invalid file type: $filename"
            return
            ;;
    esac

    file_size_bytes=$(stat -c%s "$file_path" 2>/dev/null)

    if [[ -z "$file_size_bytes" ]]; then
        echo "Could not determine file size."
        log_action "SUBMISSION | Failed | $student_id | Could not read file size: $filename"
        return
    fi

    if (( file_size_bytes > 5242880 )); then
        echo "File is too large. Maximum allowed size is 5MB."
        log_action "SUBMISSION | Failed | $student_id | File too large: $filename"
        return
    fi

    if [[ ! -f "$DUPLICATE_CHECKER" ]]; then
        echo "Duplicate checker script not found."
        log_action "SUBMISSION | Failed | $student_id | Missing duplicate checker"
        return
    fi

    # Python is used here for duplicate detection because it is well suited
    # for file hasing.
    checker_output=$(python3 "$DUPLICATE_CHECKER" "$SUBMISSIONS_FILE" "$file_path")
    checker_status=$?

    if [[ $checker_status -ne 0 ]]; then
        echo "Duplicate check failed."
        log_action "SUBMISSION | Failed | $student_id | Duplicate checker error | $filename"
        return
    fi

    duplicate_status="${checker_output%%|*}"
    file_hash="${checker_output#*|}"

    case "$duplicate_status" in
        DUPLICATE)
            echo "Duplicate submission rejected."
            log_action "SUBMISSION | Rejected duplicate | $student_id | $filename"
            return
            ;;
        UNIQUE)
            record_submission "$student_id" "$filename" "$file_hash"
            echo "Submission recorded successfully."
            log_action "SUBMISSION | Recorded | $student_id | $filename"
            ;;
        *)
            echo "Unexpected duplicate checker response."
            log_action "SUBMISSION | Failed | $student_id | Unexpected duplicate checker response | $filename"
            return
            ;;
    esac
}

check_submission() {
    echo
    echo "===== Check Submission ====="

    read -r -p "Enter file path: " file_path

    if [[ -z "$file_path" ]]; then
        echo "File path cannot be empty."
        log_action "CHECK | Failed | Empty file path"
        return
    fi

    if [[ ! -f "$file_path" ]]; then
        echo "File does not exist."
        log_action "CHECK | Failed | File not found: $file_path"
        return
    fi

    filename=$(basename "$file_path")

    # Python is reused here to ensure consistency between submission
    # and lookup logic by generating the same content hash.
    checker_output=$(python3 "$DUPLICATE_CHECKER" "$SUBMISSIONS_FILE" "$file_path")
    checker_status=$?

    if [[ $checker_status -ne 0 ]]; then
        echo "Check failed."
        log_action "CHECK | Failed | Python checker error | $filename"
        return
    fi

    duplicate_status="${checker_output%%|*}"

    if [[ "$duplicate_status" == "DUPLICATE" ]]; then
        echo "This file has already been submitted."
        log_action "CHECK | Found existing submission | $filename"
    else
        echo "This file has not been submitted."
        log_action "CHECK | No submission found | $filename"
    fi
}

list_submissions() {
    echo
    echo "===== Submitted Assignments ====="

    if [[ ! -f "$SUBMISSIONS_FILE" || ! -s "$SUBMISSIONS_FILE" ]]; then
        echo "No submissions have been recorded yet."
        log_action "LIST | No submissions found"
        return
    fi

    printf "%-12s %-25s %-64s %-20s\n" "Student ID" "Filename" "File Hash" "Timestamp"
    echo "----------------------------------------------------------------------------------------------------------------------------"

    while IFS='|' read -r student_id filename file_hash timestamp; do
        printf "%-12s %-25s %-64s %-20s\n" "$student_id" "$filename" "$file_hash" "$timestamp"
    done < "$SUBMISSIONS_FILE"

    log_action "LIST | Displayed all recorded submissions"
}

while true
do
    echo
    echo "========================================"
    echo " Task 3 Submission and Access System"
    echo "========================================"
    echo "1. Submit assignment"
    echo "2. Check if file already submitted"
    echo "3. List all submitted assignments"
    echo "4. Simulate login attempt"
    echo "5. Bye"
    echo "========================================"

    read -r -p "Choose an option (1-5): " choice

    case "$choice" in
        1)
            submit_assignment
            ;;
        2)
            echo
            check_submission
            log_action "MENU | Check submitted file selected"
            ;;
        3)
            echo
            list_submissions
            log_action "MENU | List submitted assignments selected"
            ;;
        4)
            echo
            echo "Simulate login attempt selected."
            log_action "MENU | Simulate login attempt selected"
            ;;
        5)
            if confirm_exit; then
                break
            fi
            ;;
        *)
            echo
            echo "Invalid option. Please enter a number between 1 and 5."
            log_action "MENU | Invalid option entered: $choice"
            ;;
    esac

done