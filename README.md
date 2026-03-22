# U19972 – Advanced Operating Systems  
## Task 1 – University Data Centre Process and Resource Management System

This Bash script simulates process and resource management within a university data centre.  
It provides an interactive menu for monitoring system performance, managing processes, and handling log files.

---

## Requirements

- Linux environment (WSL, Ubuntu)
- Bash shell

---

## How to Run

```bash
chmod +x task1.sh
./task1.sh

 ## Menu Options

 1. **Show system usage**
    Displays:
    - Load average (1, 5, 15 minutes)
    - CPU usage
    - Memory usage
    - Swap usage

 2. **Show top processes**
    Displays the top 10 processes sorted by memory usage, including:
    - PID
    - User
    - CPU %
    - Memory %

 3. **Terminate a process**
    - Enter a PID
    - Input is validated
    - Critical processes (e.g. `systemd`) are protected
    - Confirmation is required before termination

 4. **Inspect directory disk usage**
    - Enter a directory path
    - Displays total size using `du -sh`

 5. **Find large log files**
    - Enter a directory path
    - Finds `.log` files larger than 50MB

 6. **Archive large log files**
    - Compresses large `.log` files
    - Stores them in `ArchiveLogs`
    - Uses timestamped `.gz` filenames

 7. **Exit**
    - Requires Y/N confirmation before exiting