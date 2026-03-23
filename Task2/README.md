# University HPC Job Scheduler

## Overview
This project implements a command-line High Performance Computing (HPC) job scheduler in Python.  
The system allows users to submit jobs, store them persistently, and process them using two scheduling algorithms: Priority Scheduling and Round Robin Scheduling.

---

## Features
- Submit job requests with validation
- Persistent job storage using text files
- View pending jobs in a structured table
- Process jobs using:
  - Priority Scheduling
  - Round Robin Scheduling (5-second time quantum)
- Track completed jobs with metadata
- Centralised logging of all system activity

---

## File Structure
- `task2_scheduler.py` - Main scheduler program
- `job_queue.txt` - Stores pending jobs
- `completed_jobs.txt` - Stores completed jobs
- `scheduler_log.txt` - Stores system logs

---

## Job Format
Jobs are stored in the following format:


student_id|job_name|execution_time|priority


Example:


1001|RenderJob|12|8


---

## How to Run

### Step 1 - Navigate to directory
```bash
cd Task2
```

### Step 2 - Run the scheduler
```bash
python3 task2_scheduler.py
```

---

## Usage Guide

### Submit a Job
1. Select option `2`
2. Enter:
   - Student ID
   - Job name
   - Execution time (seconds)
   - Priority (1-10)
3. Enter `q` at any prompt to cancel

### View Pending Jobs
Select option `1` to display all jobs in the queue.

### Process Job Queue
Select option `3`, then choose:

#### Priority Scheduling
- Jobs executed in descending priority order

#### Round Robin Scheduling
- Uses a 5-second time quantum
- Jobs are processed in cycles until completion

### View Completed Jobs
Select option `4` to display all completed jobs including:
- Scheduling method
- Completion timestamp

---

## Logging
All system activity is recorded in:


scheduler_log.txt


Log format:


YYYY-MM-DD HH:MM:SS | EVENT


Examples:


2026-03-23 01:52:01 | SYSTEM | User exited program



---

## Design Decisions

- Jobs are appended to the queue file rather than rewriting it, reducing unnecessary file operations.
- A snapshot of the queue is used during scheduling to ensure consistent execution order.
- Round Robin maintains a separate remaining-time value to preserve original execution times.
- A simple list structure was used for the queue to keep the implementation clear and readable.


