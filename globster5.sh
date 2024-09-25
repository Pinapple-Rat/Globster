#!/bin/zsh

URL="${1:-}"
FILEPTH="${2:-}"
SHOW_DETAILS="${3:-no}"

# Print the arguments received by the script
echo "Arguments received:"
echo "URL: $URL"
echo "FILEPTH: $FILEPTH"
echo "SHOW_DETAILS: $SHOW_DETAILS"

# Display help message if -h or --help is provided
if [[ "$URL" = "-h" || "$URL" = "--help" ]]; then
    cat << HELP_DOC

[URL] Full URL or IP of target(with http://). :PORT is also allowed
[FILE] Filepath for dictionary file
[OPTIONAL] 'details' to include page byte size in output and print every tried directory

COMMAND STRUCTURE:
./Globster.sh [URL] [File] [OPTIONAL]

EXAMPLES:
./Globster.sh http://example.com /usr/share/wordlists/dirb/big.txt
./Globster.sh http://example.com /usr/share/wordlists/dirb/big.txt details
HELP_DOC
    exit 0
fi

# Check if the URL and file path are provided
if [[ -z "$URL" ]]; then
    echo "Error: URL not provided."
    exit 1
fi

if [[ -z "$FILEPTH" ]]; then
    echo "Error: File path not provided."
    exit 1
fi

if [[ ! -f "$FILEPTH" ]]; then
    echo "Error: File '$FILEPTH' does not exist."
    exit 1
fi

# Ensure URL ends with a '/'
if [[ "$URL" != */ ]]; then
    URL="${URL}/"
fi

# Display header based on SHOW_DETAILS
if [[ "$SHOW_DETAILS" = "details" ]]; then
    echo "[Status Code] [Page Byte Size] || [URL][DIR]"
else
    echo "[Status Code] || [URL][DIR]"
fi

# Process each line in the file
while IFS= read -r line; do
    # Assign the line to a variable
    VAR="$line"
    
    # Skip empty lines
    if [[ -z "$VAR" ]]; then
        continue
    fi

    # Build the full URL
    FULL_URL="${URL}${VAR}"

    # Debug: Print the URL being processed
    echo "Processing: $FULL_URL"

    # Use curl to get the HTTP status code and page byte size based on SHOW_DETAILS
    if [[ "$SHOW_DETAILS" = "details" ]]; then
        curld_result=$(curl -o /dev/null -s -w "%{http_code} %{size_download}\n" "$FULL_URL")
    else
        curld_result=$(curl -o /dev/null -s -w "%{http_code}\n" "$FULL_URL")
    fi

    # Check if curl command was successful
    if [[ $? -ne 0 ]]; then
        echo "Error: curl failed for $FULL_URL"
        continue
    fi

    # Extract the status code from the result
    status_code=$(echo "$curld_result" | awk '{print $1}')

    # Print results based on SHOW_DETAILS and status code
    if [[ "$SHOW_DETAILS" = "details" ]]; then
        echo "$curld_result || $FULL_URL"
    else
        # Print only if the status code is not 404
        if [[ "$status_code" != "404" ]]; then
            echo "$curld_result || $FULL_URL"
        fi
    fi

done < "$FILEPTH"

echo "GOOD BYE"
