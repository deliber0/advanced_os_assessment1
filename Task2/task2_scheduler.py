#!/usr/bin/env python3

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
            print("Exiting system.")
            return True
        elif choice == "N":
            return False
        else:
            print("Invalid choice. Please enter Y or N.")


def choose_scheduling_method():
    while True:
        print("\n=== Select Scheduling Method")
        print("1. Round Robin")
        print("2. Priority Scheduling")
        print("3. Back")

        choice = input("Select an option: ").strip()

        if choice == "1":
            print("Round Robin scheduling not implemented yet.")
            return
        elif choice == "2":
            print("Priority scheduling not implemented yet.")
            return
        elif choice == "3":
            return
        else:
            print("Invalid option. Please choose a number from 1 to 3.")


def main():
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