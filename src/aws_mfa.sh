#!/bin/bash

set -eu

# Show help if --help is present
if [[ "$*" == *--help* ]]; then
    cat <<EOF
Usage: aws_mfa <device_arn> [mfa_profile]

Arguments:
  device_arn    MFA device ARN (required)
  mfa_profile   AWS profile name to update (default: mfa)

This script gets temporary AWS credentials using MFA and sets them to the specified profile.
EOF
    exit 0
fi

# Check required commands
for cmd in aws jq; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        printf "[ERROR] Required command '%s' not found. Please install it.\n" "$cmd" >&2
        exit 1
    fi
done

# Validate arguments
if [ $# -lt 1 ] || [ $# -gt 2 ]; then
    printf "[ERROR] aws_mfa: Invalid arguments.\nUsage: aws_mfa <device_arn> [mfa_profile]\n" >&2
    exit 1
fi

# Set device ARN and MFA profile
device_arn=$1

if [ $# -eq 2 ]; then
    mfa_profile="$2"
else
    mfa_profile="mfa"
fi

echo "Using profile: $mfa_profile"

# Prompt for MFA code
echo 'Enter MFA code:'
read -r code

# Get session token using MFA
if ! mfa_result=$(aws sts get-session-token --serial-number "$device_arn" --token-code "$code"); then
    printf "[ERROR] aws sts get-session-token failed\n" >&2
    exit 1
fi

# Parse and set AWS credentials
access_key_id=$(echo "$mfa_result" | jq -r '.Credentials.AccessKeyId')
secret_access_key=$(echo "$mfa_result" | jq -r '.Credentials.SecretAccessKey')
session_token=$(echo "$mfa_result" | jq -r '.Credentials.SessionToken')

echo "Updating AWS credentials using aws configure set..."
aws configure set aws_access_key_id "$access_key_id" --profile "$mfa_profile"
aws configure set aws_secret_access_key "$secret_access_key" --profile "$mfa_profile"
aws configure set aws_session_token "$session_token" --profile "$mfa_profile"

echo "Done!"
echo "[Tips] To verify: aws sts get-caller-identity --profile $mfa_profile"
