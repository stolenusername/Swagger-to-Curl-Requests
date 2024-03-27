#!/bin/bash

# Function to generate curl requests for each API call
generate_curl_requests() {
    local swagger_file="$1"
    local base_url="$2"
    local x_api_key="$3"
    local proxy="$4"
    local output_file="$5"

    # Parse Swagger file to extract API paths and methods
    local paths=$(jq -r '.paths | keys[]' "$swagger_file")

    # Loop through each path
    for path in $paths; do
        local methods=$(jq -r ".paths.\"$path\" | keys[]" "$swagger_file")

        # Loop through each HTTP method for the path
        for method in $methods; do
            # Exclude 'options' method
            if [ "$method" != "options" ]; then
                # Extract relevant information
                local summary=$(jq -r ".paths.\"$path\".\"$method\".summary" "$swagger_file")
                local operation_id=$(jq -r ".paths.\"$path\".\"$method\".operationId" "$swagger_file")

                # Convert method to uppercase
                method=$(echo "$method" | tr '[:lower:]' '[:upper:]')

                # Build the curl command
                local curl_command="curl -X $method"

                # Add proxy if provided
                if [ ! -z "$proxy" ]; then
                    curl_command+=" -x $proxy"
                fi

                # Add base URL and path
                if [ ! -z "$base_url" ]; then
                    curl_command+=" $base_url$path"
                else
                    curl_command+=" $path"
                fi

                # Add headers
                curl_command+=" -H 'accept: application/json'"
                curl_command+=" -H 'Unused: KEY'"

                # Add x-api-key header if provided
                if [ ! -z "$x_api_key" ]; then
                    curl_command+=" -H 'x-api-key: $x_api_key'"
                fi

                # Write curl command to output file
                echo "$curl_command" >> "$output_file"
            fi
        done
        # Add empty lines between requests
        echo >> "$output_file"
        echo >> "$output_file"
    done
}

# Initialize variables with default values
swagger_file=""
base_url=""
x_api_key=""
proxy=""
output_file="curl_requests.txt"

# Parse command line arguments
while getopts ":f:u:k:p:o:" opt; do
    case $opt in
        f) swagger_file="$OPTARG";;
        u) base_url="$OPTARG";;
        k) x_api_key="$OPTARG";;
        p) proxy="$OPTARG";;
        o) output_file="$OPTARG";;
        \?) echo "Invalid option: -$OPTARG" >&2
            exit 1;;
        :) echo "Option -$OPTARG requires an argument." >&2
            exit 1;;
    esac
done

# Check if no arguments provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 [-f swagger_file] [-u base_url] [-k x_api_key] [-p proxy] [-o output_file]"
    echo
    echo "Arguments:"
    echo "  -f  Swagger file (required)"
    echo "  -u  Base URL of the API (optional)"
    echo "  -k  X-API-Key for authentication (optional)"
    echo "  -p  Proxy address (optional)"
    echo "  -o  Output file for curl commands (default: curl_requests.txt)"
    exit 1
fi

# Check if Swagger file argument is provided
if [ -z "$swagger_file" ]; then
    echo "Error: Swagger file not provided!"
    exit 1
fi

# Check if Swagger file exists
if [ ! -f "$swagger_file" ]; then
    echo "Error: Swagger file '$swagger_file' not found!"
    exit 1
fi

# Generate curl requests and write to output file
generate_curl_requests "$swagger_file" "$base_url" "$x_api_key" "$proxy" "$output_file"
