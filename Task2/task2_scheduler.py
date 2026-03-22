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

def append_job(job):
    # Two possible approaches considered:
    # 1. Load all jobs and rewrite the full queue file
    # 2. append only the new job
    #
    # Appending was chosen because submitting a new job does not alter
    # Any existing queue entries. This makes the operation simpler,
    # faster, and less likely to accidentally overwrite previous jobs.

    with open(QUEUE_FILE, "a", encoding="utf-8") as file:
        file.write(
             f"{job['student_id']}|{job['job_name']}|"
            f"{job['execution_time']}|{job['priority']}\n"
        )

def append_completed_job(job, scheduling_type):
    completed_time = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    with open(COMPLETED_FILE, "a", encoding="utf-8") as file:
        file.write(
            f"{job['student_id']}|{job['job_name']}|{job['execution_time']}|"
            f"{job['priority']}|{scheduling_type}|{completed_time}\n"
        )

def prompt_non_empty(prompt_text, field_name):
    # Returning to the main menu after invalid input would be easier,
    # but repeated prompted is used because it gives a better user
    # experience during job submission.
    # The user can still exit by entering 'q'
    while True:
        value = input(prompt_text).strip()

        if value.lower() == "q":
            print("Job submission cancelled.")
            return None

        if not value:
            print(f"{field_name} cannot be empty. Enter 'q' to cancel.")
            continue

        return value    

def prompt_positive_integer(prompt_text, field_name):
    while True:
        value = input(prompt_text).strip()

        if value.lower() == "q":
            print("Job submission cancelled.")
            return None

        try:
            number = int(value)
            if number <= 0:
                print(f"{field_name} must be greater than 0. Enter 'q' to cancel.")
                continue
            return number
        except ValueError:
            print(f"{field_name} must be a whole number. Enter 'q' to cancel.")

def prompt_priority(prompt_text):
    while True:
        value = input(prompt_text).strip()

        if value.lower() == "q":
            print("Job submission cancelled.")
            return None

        try:
            priority = int(value)
            if 1 <= priority <= 10:
                return priority
            print("Priority must be between 1 and 10. Enter 'q' to cancel.")
        except ValueError:
            print("Priority must be a whole number. Enter 'q' to cancel.")

def submit_job():
    print("\n=== Submit Job Request ===")
    print("Enter 'q' at any prompt to cancel submission.")

    student_id = prompt_non_empty("Enter student ID: ", "Student ID")
    if student_id is None:
        return

    job_name = prompt_non_empty("Enter job name: ", "Job name")
    if job_name is None:
        return

    execution_time = prompt_positive_integer(
        "Enter estimated execution time in seconds: ",
        "Execution time"
    )
    if execution_time is None:
        return

    priority = prompt_priority("Enter priority (1-10): ")
    if priority is None:
        return

    job = {
        "student_id": student_id,
        "job_name": job_name,
        "execution_time": execution_time,
        "priority": priority
    }

    append_job(job)

    log_event(
        f"SUBMIT | StudentID={student_id} | Job={job_name} | "
        f"ExecTime={execution_time} | Priority={priority}"
    )

    print("Job submitted successfully.")

def view_pending_jobs():
    # Two ways were considered here
    # 1. Print each job line exactly as stored in the file
    # 2. Format the output 

    # Formatted output was chosen because it is significantly more
    # readable and provides a clearer overview of the queue.

    jobs = load_jobs()

    print("\n=== Pending Jobs ===")

    if not jobs:
        # Explicit message chosen instead of printing nothing
        # to clearly inform the user that the queue is empty.
        print("No pending jobs found.")
        return

    # Display table header
    print(f"{'Pos':<5}{'Student ID':<15}{'Job Name':<20}{'Exec Time':<12}{'Priority':<10}")
    print("-" * 62)

    # Position is calculated dynamically instead of being stored
    # in the file to avoid redundancy and ensure accuracy.
    for index, job in enumerate(jobs, start=1):
        print(
            f"{index:<5}"
            f"{job['student_id']:<15}"
            f"{job['job_name']:<20}"
            f"{job['execution_time']:<12}"
            f"{job['priority']:<10}"
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
            view_pending_jobs()
        elif choice == "2":
            submit_job()
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