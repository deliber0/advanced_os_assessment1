#!/bin/bash

LOG_FILE="submission_log.txt"

log_action() {
    local message="$1"
    echo "$(date '+%Y-%m-%d %H:%M:%S') | $message" >> "$LOG_FILE"
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
            echo
            echo "Submit assignment selected."
            log_action "MENU | Submit assignment selected"
            ;;
        2)
            echo
            echo "Check submitted file selected."
            log_action "MENU | Check submitted file selected"
            ;;
        3)
            echo
            echo "List submitted assignments selected."
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