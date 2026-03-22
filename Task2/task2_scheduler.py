#!/usr/bin/env python3

from datetime import datetime

# FILE PATHS
# These define where job data and logs are stored.
# Using plain text files keeps the system simple and portable.

QUEUE_FILE = "job_queue.txt"
COMPLETED_FILE = "completed_jobs.txt"
LOG_FILE = "scheduler_log.txt"

# Logs system events with timestamps for traceability
def log_event(message):
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    with open(LOG_FILE, "a", encoding="utf-8") as file:
        file.write(f"{timestamp} | {message}\n")

# Jobs are stored in the format:
# student_id|job_name|execution_time|priority

def load_jobs():
    jobs = []

    try:
        with open(QUEUE_FILE, "r", encoding="utf-8") as file:
            for line in file:
                line = line.strip()
                if not line:
                    continue
                
                parts = line.split("|")

                # Incorrectly formatted records are skipped instead of crashing the program
                if len(parts) != 4:
                    continue

                student_id, job_name, execution_time, priority = parts

                try:
                    jobs.append({
                        "student_id": student_id,
                        "job_name": job_name,
                        "execution_time": int(execution_time),
                        "priority": int(priority)
                    })
                except ValueError:
                    continue

    except FileNotFoundError:
        with open(QUEUE_FILE, "w", encoding="utf-8"):
            pass

    return jobs

def append_completed_job(job, scheduling_type):
    completed_time = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    with open(COMPLETED_FILE, "a", encoding="utf-8") as file:
        file.write(
            f"{job['student_id']}|{job['job_name']}|{job['execution_time']}|"
            f"{job['priority']}|{scheduling_type}|{completed_time}\n"
        )

# Menu
def print_menu():
    print("\n=== University HPC Job Scheduler ===")
    print("1. View pending jobs")
    print("2. Submit a job request")
    print("3. Process job queue")
    print("4. View completed jobs")
    print("5. Bye")


def confirm_exit():
    while True:
        choice = input("Are you sure you want to exit? (Y/N): ").strip().upper()
        if choice == "Y":
            log_event("SYSTEM | User exited program")
            print("Exiting system.")
            return True
        elif choice == "N":
            return False
        else:
            print("Invalid choice. Please enter Y or N.")


def choose_scheduling_method():
    while True:
        print("\n=== Select Scheduling Method ===")
        print("1. Round Robin")
        print("2. Priority Scheduling")
        print("3. Back")

        choice = input("Select an option: ").strip()

        if choice == "1":
            log_event("SCHEDULER | Round Robin selected")
            print("Round Robin scheduling not implemented yet.")
            return
        elif choice == "2":
            log_event("SCHEDULER | Priority Scheduling selected")
            print("Priority scheduling not implemented yet.")
            return
        elif choice == "3":
            return
        else:
            print("Invalid option. Please choose a number from 1 to 3.")


def main():
    log_event("SYSTEM | Scheduler started")

    while True:
        print_menu()
        choice = input("Select an option: ").strip()

        if choice == "1":
            print("Pending jobs view not implemented yet.")
        elif choice == "2":
            print("Job submission not implemented yet.")
        elif choice == "3":
            choose_scheduling_method()
        elif choice == "4":
            print("Completed jobs view not implemented yet.")
        elif choice == "5":
            if confirm_exit():
                break
        else:
            print("Invalid option. Please choose a number from 1 to 5.")


if __name__ == "__main__":
    main()