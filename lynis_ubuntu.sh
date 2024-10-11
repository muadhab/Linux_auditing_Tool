#!/bin/bash

# Script to install and run Lynis on Ubuntu 22.04 LTS

# Update the package list
echo "Updating package list..."
sudo apt update -y

# Install Lynis
echo "Installing Lynis..."
sudo apt install -y lynis

# Run Lynis
echo "Executing Lynis..."
sudo lynis audit system

echo "Lynis has been executed. You can run it again using 'sudo lynis audit system'."
