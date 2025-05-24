#calculation for unick id string
#!/bin/bash

# Generate a unique ID string using the current timestamp and a random number
unique_id=$(date +%s%N | sha256sum | head -c 16)
echo "Generated Unique ID: $unique_id"
