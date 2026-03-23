#!/usr/bin/env python3

# Duplicate Checker for Task 3 Submission System
#
# This script handles:
# - generating a SHA-256 hash of file contents
# - checking for duplicate submissions
#
# Python is used because it provides cleaner file handling and hashing capabilities
# compared to Bash.

import hashlib
import os
import sys

# Generate a SHA-256 ash of the file contents.
# Reading in chunks prevents high memory usage for large files.
def calculate_file_hash(file_path):
    sha256 = hashlib.sha256()

    with open(file_path, "rb") as file:
        for chunk in iter(lambda: file.read(4096), b""):
            sha256.update(chunk)

    return sha256.hexdigest()

# Each stored submission is checked to determine if both filename and content match.
# Only exact matches are considered duplicates.
def is_duplicate(submissions_file, filename, file_hash):
    if not os.path.exists(submissions_file):
        return False

    with open(submissions_file, "r", encoding="utf-8") as file:
        for line in file:
            line = line.strip()
            if not line:
                continue

            parts = line.split("|")
            if len(parts) != 4:
                continue

            _, stored_filename, stored_hash, _ = parts

            if stored_filename == filename and stored_hash == file_hash:
                return True

    return False


def main():
    if len(sys.argv) != 3:
        print("ERROR")
        sys.exit(1)

    submissions_file = sys.argv[1]
    file_path = sys.argv[2]

    if not os.path.isfile(file_path):
        print("ERROR")
        sys.exit(1)

    filename = os.path.basename(file_path)
    file_hash = calculate_file_hash(file_path)

    if is_duplicate(submissions_file, filename, file_hash):
        print(f"DUPLICATE|{file_hash}")
    else:
        print(f"UNIQUE|{file_hash}")


if __name__ == "__main__":
    main()