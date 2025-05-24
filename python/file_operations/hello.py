import hashlib
import time
import random

# Generate a unique ID using the current timestamp and a random number
def generate_unique_id():
    timestamp = str(time.time_ns())  # Get the current timestamp in nanoseconds
    random_number = str(random.randint(0, 1000000))  # Generate a random number
    unique_string = timestamp + random_number
    unique_id = hashlib.sha256(unique_string.encode()).hexdigest()[:16]  # Hash and truncate
    return unique_id

# Print the generated unique ID
if __name__ == "__main__":
    unique_id = generate_unique_id()
    print(f"Generated Unique ID: {unique_id}")