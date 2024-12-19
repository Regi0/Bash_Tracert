#!/bin/bash

# Configuration
HOSTS_FILE="/home/regi/Bash_Tracert/hosts.txt"  # File containing the list of hosts (one per line)
OUTPUT_DIR="/home/regi/Bash_Tracert/Results"    # Directory to store output files
TRACEROUTE_COUNT=30                            # Number of hops for traceroute (optional)

# Ensure the output directory exists
mkdir -p "$OUTPUT_DIR"

# Get the current timestamp for the output file
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
OUTPUT_FILE="$OUTPUT_DIR/traceroute_results_$TIMESTAMP.txt"

# Check if the hosts file exists
if [[ ! -f "$HOSTS_FILE" ]]; then
    echo "Error: Hosts file '$HOSTS_FILE' not found."
    exit 1
fi

# Function to perform traceroute
function traceroute_host {
    local host=$1
    local output_file=$2
    local max_hops=$3

    echo "Tracerouting $host..." >> "$output_file"
    
    # Perform the traceroute command
    traceroute -m "$max_hops" "$host" >> "$output_file" 2>&1
    
    # Add a separator after each traceroute result
    echo -e "\n----- Separator -----\n" >> "$output_file"
}

# Perform traceroutes concurrently
export -f traceroute_host  # Export the function for parallel execution

# Read each host and start the traceroute in the background
cat "$HOSTS_FILE" | while read -r host || [[ -n "$host" ]]; do
    if [[ -n "$host" ]]; then
        # Start the traceroute in the background
        traceroute_host "$host" "$OUTPUT_FILE" "$TRACEROUTE_COUNT" &
    fi
done

# Wait for all background processes to finish
wait

echo "Traceroute results saved to $OUTPUT_FILE"
