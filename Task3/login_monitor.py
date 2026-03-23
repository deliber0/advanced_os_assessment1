#!/usr/bin/env python3

# This script handles:
# - tracking login attempts per user
# - detecting repeated attempts within a time window
# - locking accounts after multiple failed attempts
#
# Python is used instead of Bash because it provides better support for:
# - structured data storage (JSON)
# - time-based calculations
# - maintaining persistent user state

import json
import os
import sys
import time

# Defines how many failed attempts are allowed before
# locking an account.
LOCK_THRESHOLD = 3 

# Defines the time in seconds used to detect repeated login attempts
SUSPICIOUS_WINDOW = 60

# Load login state from a JSON file.
# JSON is used instead of plaintext to store structured per-user data.
def load_state(state_file):
    if not os.path.exists(state_file):
        return {}

    with open(state_file, "r", encoding="utf-8") as file:
        try:
            return json.load(file)
        except json.JSONDecodeError:
            return {}

# Save updated login state back to file to ensure persistence across executions.
def save_state(state_file, state):
    with open(state_file, "w", encoding="utf-8") as file:
        json.dump(state, file, indent=4)


def main():
    if len(sys.argv) != 4:
        print("ERROR|Invalid arguments")
        sys.exit(1)

    state_file = sys.argv[1]
    student_id = sys.argv[2]
    attempt_result = sys.argv[3].lower()

    if attempt_result not in {"success", "fail"}:
        print("ERROR|Invalid login result")
        sys.exit(1)

    current_time = int(time.time())
    state = load_state(state_file)

    # Create a default record for first-time users
    if student_id not in state:
        state[student_id] = {
            "failed_attempts": 0,
            "locked": False,
            "attempt_timestamps": []
        }

    user_state = state[student_id]

    if user_state["locked"]:
        print("LOCKED|Account is already locked")
        save_state(state_file, state)
        return
    # Only keep recent attempts within defined time window
    recent_attempts = [
        ts for ts in user_state["attempt_timestamps"]
        if current_time - ts <= SUSPICIOUS_WINDOW
    ]
    user_state["attempt_timestamps"] = recent_attempts

    # Mark activity as suspicious when there has already been 
    # at least one recent attempt within the configured time window
    suspicious = len(recent_attempts) > 0

    user_state["attempt_timestamps"].append(current_time)

    if attempt_result == "success":
        user_state["failed_attempts"] = 0
        save_state(state_file, state)

        if suspicious:
            print("SUCCESS_SUSPICIOUS|Login successful but repeated attempts detected")
        else:
            print("SUCCESS|Login successful")
        return

    user_state["failed_attempts"] += 1

    # Account is locked after reaching failure threshold
    # to prevent brute-force style login attempts
    if user_state["failed_attempts"] >= LOCK_THRESHOLD:
        user_state["locked"] = True
        save_state(state_file, state)

        if suspicious:
            print("LOCKED_SUSPICIOUS|Account locked after repeated failed attempts")
        else:
            print("LOCKED|Account locked after 3 failed attempts")
        return

    save_state(state_file, state)

    if suspicious:
        print(
            f"FAIL_SUSPICIOUS|Failed login attempt recorded ({user_state['failed_attempts']}/3)"
        )
    else:
        print(f"FAIL|Failed login attempt recorded ({user_state['failed_attempts']}/3)")


if __name__ == "__main__":
    main()