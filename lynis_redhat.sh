#!/bin/bash

# Script to install and run Lynis on Red Hat Enterprise Linux 8.5

# Update the package list
#echo "Updating package list..."
#sudo dnf check-update

# Install required packages
echo "Installing required packages..."
sudo dnf install -y epel-release
sudo dnf install -y lynis

# Run Lynis
echo "Executing Lynis..."
sudo lynis audit system

echo "Lynis has been executed. You can run it again using 'sudo lynis audit system'."
