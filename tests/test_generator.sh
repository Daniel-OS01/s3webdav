#!/bin/bash

# Make the generator script executable
chmod +x interactive-generator/generate_config.sh

# Run the generator script and pipe in the answers.
# This script serves as a test to ensure the generator completes successfully.
(
  echo "1" # Quick Start
  echo "1" # Docker Compose
  echo ""  # Domain Name (optional)
  echo "2" # Secure (Add Basic Auth layer)
  echo "testuser" # Basic Auth Username
  echo "testpass" # Basic Auth Password
  echo "4" # Resource Profile: None
  echo "rclone-proxy-generated-test" # Output directory
  echo "" # S3 Access Key ID (default)
  echo "s3secret" # S3 Secret Access Key
  echo "3" # WebDAV provider: Generic
  echo "http://test.com" # WebDAV URL
  echo "webdavuser" # WebDAV Username
  echo "short" # WebDAV Password
  echo "y" # Confirm weak password
) | ./interactive-generator/generate_config.sh

# Check if the output directory was created
if [ ! -d "rclone-proxy-generated-test" ]; then
  echo "Test failed: Output directory not created."
  exit 1
fi

# Check if the expected files were created
if [ ! -f "rclone-proxy-generated-test/docker-compose.yml" ] || \
   [ ! -f "rclone-proxy-generated-test/.env" ] || \
   [ ! -f "rclone-proxy-generated-test/rclone.conf" ]; then
  echo "Test failed: Not all configuration files were created."
  # Clean up the test directory
  rm -rf rclone-proxy-generated-test
  exit 1
fi

echo "Test passed: Configuration files generated successfully."

# Clean up the test directory
rm -rf rclone-proxy-generated-test