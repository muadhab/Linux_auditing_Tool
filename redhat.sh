#!/bin/bash

# Get the hostname for the report filename
HOSTNAME=$(hostname)
REPORT_FILE="/tmp/security_audit_report_${HOSTNAME}.html"

# Total number of checks to perform
TOTAL_CHECKS=19
CHECK_COUNTER=0

# Array of steps for better tracking
STEPS=("System Information" "User Accounts" "Password Policies" "SSH Configuration" "Firewall Status" 
       "Running Services" "File Permissions" "Cron Jobs" "Software Updates" "Log Review" 
       "Check Installed Packages" "Kernel Parameters" "System Integrity Checks" 
       "Check for Unused Packages" "Memory and Processes" "Disk Information" 
       "Networking Information" "Opened Ports" "CIS Benchmark Checks")

# Function to update progress
update_progress() {
    local CURRENT_STEP=$1
    CHECK_COUNTER=$((CHECK_COUNTER + 1))
    PERCENTAGE=$((CHECK_COUNTER * 100 / TOTAL_CHECKS))
    
    # Create a progress bar
    BAR_LENGTH=50
    FILLED_LENGTH=$((PERCENTAGE * BAR_LENGTH / 100))
    UNFILLED_LENGTH=$((BAR_LENGTH - FILLED_LENGTH))
    BAR=$(printf "[%s%s] %d%%" "$(printf '=%*s' "$FILLED_LENGTH" '' | tr ' ' '=')" "$(printf ' %*s' "$UNFILLED_LENGTH" '' | tr ' ' ' ')" "$PERCENTAGE")

    # Print the progress bar
    echo -ne "$BAR\r"
}

# Create HTML file and add header
{
    echo "<html>"
    echo "<head>"
    echo "<title>Security Audit Report for Neurones IT</title>"
    echo "<style>"
    echo "body { font-family: Arial, sans-serif; }"
    echo "h1 { color: #2C3E50; }"
    echo "h2 { color: #34495E; }"
    echo "table { width: 100%; border-collapse: collapse; margin-bottom: 20px; }"
    echo "th, td { border: 1px solid #BDC3C7; padding: 8px; text-align: left; }"
    echo "th { background-color: #2C3E50; color: white; }"
    echo ".warning { color: red; }"
    echo "</style>"
    echo "</head>"
    echo "<body>"
    echo "<h1>Security Audit Report for Neurones IT</h1>"
    echo "<h2>Audit Date: $(date)</h2>"
    echo "<h2>Hostname: ${HOSTNAME}</h2>"
    echo "<hr>"
} > "$REPORT_FILE"

# 1. System Information
{
    echo "<h2>System Information</h2>"
    echo "<table>"
    echo "<tr><th>Property</th><th>Value</th></tr>"
    echo "<tr><td>Hostname</td><td>${HOSTNAME}</td></tr>"
    echo "<tr><td>Operating System</td><td>$(cat /etc/redhat-release)</td></tr>"
    echo "<tr><td>Kernel Version</td><td>$(uname -r)</td></tr>"
    echo "<tr><td>Uptime</td><td>$(uptime -p)</td></tr>"
    echo "<tr><td>Architecture</td><td>$(uname -m)</td></tr>"
    echo "</table>"
} >> "$REPORT_FILE"
update_progress "${STEPS[0]}"

# 2. User Accounts
{
    echo "<h2>User Accounts</h2>"
    echo "<table>"
    echo "<tr><th>Description</th><th>Count</th></tr>"
    echo "<tr><td>Total Users</td><td>$(cat /etc/passwd | wc -l)</td></tr>"
    echo "<tr><td>Administrator Accounts</td><td>$(getent group wheel | awk -F: '{print $4}' | wc -w)</td></tr>"
    echo "<tr><td>Accounts with No Password</td><td>$(awk -F: '($2 == "") {print $1}' /etc/shadow | wc -l)</td></tr>"
    echo "</table>"
} >> "$REPORT_FILE"
update_progress "${STEPS[1]}"

# 3. Password Policies
{
    echo "<h2>Password Policies</h2>"
    echo "<table>"
    echo "<tr><th>Policy</th><th>Value</th></tr>"
    echo "<tr><td>Password Expiration</td><td>$(grep "^PASS_MAX_DAYS" /etc/login.defs | awk '{print $2}') days</td></tr>"
    echo "<tr><td>Password Minimum Length</td><td>$(grep "^PASS_MIN_LEN" /etc/login.defs | awk '{print $2}') characters</td></tr>"
    echo "<tr><td>Password Complexity Requirements</td><td>$(grep "^enforcing" /etc/security/pwquality.conf | awk '{print $2}')</td></tr>"
    echo "</table>"
} >> "$REPORT_FILE"
update_progress "${STEPS[2]}"

# 4. SSH Configuration
{
    echo "<h2>SSH Configuration</h2>"
    echo "<table>"
    echo "<tr><th>Configuration</th><th>Status</th></tr>"
    echo "<tr><td>PermitRootLogin</td><td>$(grep -q "PermitRootLogin no" /etc/ssh/sshd_config && echo "Disabled" || echo "<span class='warning'>Enabled</span>")</td></tr>"
    echo "<tr><td>PasswordAuthentication</td><td>$(grep -q "PasswordAuthentication no" /etc/ssh/sshd_config && echo "Disabled" || echo "<span class='warning'>Enabled</span>")</td></tr>"
    echo "<tr><td>PermitEmptyPasswords</td><td>$(grep -q "PermitEmptyPasswords no" /etc/ssh/sshd_config && echo "Not Allowed" || echo "<span class='warning'>Allowed</span>")</td></tr>"
    echo "</table>"
} >> "$REPORT_FILE"
update_progress "${STEPS[3]}"

# 5. Firewall Status
{
    echo "<h2>Firewall Status</h2>"
    echo "<table>"
    echo "<tr><th>Status</th></tr>"
    if systemctl is-active --quiet firewalld; then
        echo "<tr><td>Firewalld is active.</td></tr>"
    else
        echo "<tr><td>Firewalld is inactive!</td></tr>"
    fi
    echo "</table>"
} >> "$REPORT_FILE"
update_progress "${STEPS[4]}"

# 6. Running Services
{
    echo "<h2>Running Services</h2>"
    echo "<table>"
    echo "<tr><th>Active Services</th></tr>"
    systemctl list-units --type=service --state=running | awk '{print "<tr><td>" $1 "</td></tr>"}' | tail -n +2 >> "$REPORT_FILE"
    echo "</table>"
} >> "$REPORT_FILE"
update_progress "${STEPS[5]}"

# 7. File Permissions
{
    echo "<h2>File Permissions</h2>"
    echo "<table>"
    echo "<tr><th>File</th><th>Permissions</th></tr>"
    echo "<tr><td>/etc/shadow</td><td>$(stat -c "%A" /etc/shadow)</td></tr>"
    echo "<tr><td>/etc/passwd</td><td>$(stat -c "%A" /etc/passwd)</td></tr>"
    echo "<tr><td>SSH keys</td><td>$(stat -c "%A" /etc/ssh/ssh_host_*_key 2>/dev/null)</td></tr>"
    echo "</table>"
} >> "$REPORT_FILE"
update_progress "${STEPS[6]}"

# 8. Cron Jobs
{
    echo "<h2>Cron Jobs</h2>"
    echo "<table>"
    echo "<tr><th>User</th><th>Cron Jobs</th></tr>"
    echo "<tr><td>Current User</td><td>$(crontab -l 2>/dev/null || echo 'No crontab')</td></tr>"
    echo "<tr><td>System Jobs</td><td>$(ls /etc/cron.* 2>/dev/null | xargs)</td></tr>"
    echo "</table>"
} >> "$REPORT_FILE"
update_progress "${STEPS[7]}"

# 9. Software Updates
{
    echo "<h2>Software Updates</h2>"
    echo "<table>"
    echo "<tr><th>Updates Status</th></tr>"
    if [ "$(yum list updates 2>/dev/null | tail -n +2 | wc -l)" -gt 0 ]; then
        echo "<tr><td>Updates available for installation.</td></tr>"
    else
        echo "<tr><td>No updates available.</td></tr>"
    fi
    echo "</table>"
} >> "$REPORT_FILE"
update_progress "${STEPS[8]}"

# 10. Log Review
{
    echo "<h2>Log Review</h2>"
    echo "<table>"
    echo "<tr><th>Recent Authentication Failures</th></tr>"
    sudo grep "authentication failure" /var/log/secure | tail -n 5 >> "$REPORT_FILE"
    echo "</table>"
} >> "$REPORT_FILE"
update_progress "${STEPS[9]}"

# 11. Check Installed Packages
{
    echo "<h2>Installed Packages</h2>"
    echo "<table>"
    echo "<tr><th>Package Name</th><th>Version</th></tr>"
    yum list installed | awk 'NR>1 {print "<tr><td>" $1 "</td><td>" $2 "</td></tr>"}' >> "$REPORT_FILE"
    echo "</table>"
} >> "$REPORT_FILE"
update_progress "${STEPS[10]}"

# 12. Kernel Parameters
{
    echo "<h2>Kernel Parameters</h2>"
    echo "<table>"
    echo "<tr><th>Parameter</th><th>Value</th></tr>"
    echo "<tr><td>vm.swappiness</td><td>$(sysctl vm.swappiness | awk '{print $3}')</td></tr>"
    echo "<tr><td>fs.file-max</td><td>$(sysctl fs.file-max | awk '{print $2}')</td></tr>"
    echo "</table>"
} >> "$REPORT_FILE"
update_progress "${STEPS[11]}"

# 13. System Integrity Checks
{
    echo "<h2>System Integrity Checks</h2>"
    echo "<table>"
    echo "<tr><th>Check</th><th>Status</th></tr>"
    echo "<tr><td>File Integrity Monitor (AIDE)</td><td>$(if command -v aide > /dev/null; then aide --check; else echo "Not installed"; fi)</td></tr>"
    echo "</table>"
} >> "$REPORT_FILE"
update_progress "${STEPS[12]}"

# 14. Check for Unused Packages
{
    echo "<h2>Unused Packages</h2>"
    echo "<table>"
    echo "<tr><th>Unused Packages</th></tr>"
    if [ "$(package-cleanup --quiet --leaves | wc -l)" -gt 0 ]; then
        package-cleanup --quiet --leaves | awk '{print "<tr><td>" $1 "</td></tr>"}' >> "$REPORT_FILE"
    else
        echo "<tr><td>No unused packages found.</td></tr>"
    fi
    echo "</table>"
} >> "$REPORT_FILE"
update_progress "${STEPS[13]}"

# 15. Memory and Processes
{
    echo "<h2>Memory and Processes</h2>"
    echo "<table>"
    echo "<tr><th>Total Memory</th><td>$(free -h | awk '/^Mem:/{print $2}')</td></tr>"
    echo "<tr><th>Used Memory</th><td>$(free -h | awk '/^Mem:/{print $3}')</td></tr>"
    echo "<tr><th>Running Processes</th><td>$(ps aux | wc -l)</td></tr>"
    echo "</table>"
} >> "$REPORT_FILE"
update_progress "${STEPS[14]}"

# 16. Disk Information
{
    echo "<h2>Disk Information</h2>"
    echo "<table>"
    echo "<tr><th>Filesystem</th><th>Size</th><th>Used</th><th>Available</th></tr>"
    df -h | awk 'NR>1 {print "<tr><td>" $1 "</td><td>" $2 "</td><td>" $3 "</td><td>" $4 "</td></tr>"}' >> "$REPORT_FILE"
    echo "</table>"
} >> "$REPORT_FILE"
update_progress "${STEPS[15]}"

# 17. Networking Information
{
    echo "<h2>Networking Information</h2>"
    echo "<table>"
    echo "<tr><th>Network Interfaces</th></tr>"
    ip addr show | awk '/^[0-9]+: /{print "<tr><td>" $2 "</td></tr>"}' >> "$REPORT_FILE"
    echo "</table>"
} >> "$REPORT_FILE"
update_progress "${STEPS[16]}"

# 18. Opened Ports
{
    echo "<h2>Opened Ports</h2>"
    echo "<table>"
    echo "<tr><th>Port</th><th>Status</th></tr>"
    ss -tuln | awk 'NR>1 {print "<tr><td>" $5 "</td><td>Listening</td></tr>"}' >> "$REPORT_FILE"
    echo "</table>"
} >> "$REPORT_FILE"
update_progress "${STEPS[17]}"

# 19. CIS Benchmark Checks
{
    echo "<h2>CIS Benchmark Checks</h2>"
    echo "<table>"
    echo "<tr><th>Check</th><th>Status</th></tr>"
    # Example check for SSH
    if grep -q "^PermitRootLogin no" /etc/ssh/sshd_config; then
        echo "<tr><td>Root Login via SSH</td><td>Pass</td></tr>"
    else
        echo "<tr><td>Root Login via SSH</td><td class='warning'>Fail</td></tr>"
    fi
    # Add more checks as needed
    echo "</table>"
} >> "$REPORT_FILE"
update_progress "${STEPS[18]}"

# Closing HTML tags
{
    echo "</body>"
    echo "</html>"
} >> "$REPORT_FILE"

# Final report completion message
echo -e "\nSecurity audit report generated at: $REPORT_FILE"
