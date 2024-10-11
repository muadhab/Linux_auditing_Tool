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
    echo "<tr><td>Operating System</td><td>$(lsb_release -d | awk -F: '{print $2}' | xargs)</td></tr>"
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
    echo "<tr><td>Administrator Accounts</td><td>$(getent group sudo | awk -F: '{print $4}' | wc -w)</td></tr>"
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
    echo "<tr><td>Password Complexity Requirements</td><td>$(grep "^ENCRYPT_METHOD" /etc/login.defs | awk '{print $2}')</td></tr>"
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
    if systemctl is-active --quiet ufw; then
        echo "<tr><td>UFW is active.</td></tr>"
    else
        echo "<tr><td>UFW is inactive!</td></tr>"
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
    if [ "$(apt list --upgradable 2>/dev/null | grep -c upgradable)" -gt 0 ]; then
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
    sudo grep "authentication failure" /var/log/auth.log | tail -n 10 | awk '{print "<tr><td>" $0 "</td></tr>"}' >> "$REPORT_FILE"
    echo "</table>"
} >> "$REPORT_FILE"
update_progress "${STEPS[9]}"

# 11. Check Installed Packages
{
    echo "<h2>Installed Packages</h2>"
    echo "<table>"
    echo "<tr><th>Property</th><th>Value</th></tr>"
    echo "<tr><td>Total Installed Packages</td><td>$(dpkg -l | wc -l)</td></tr>"
    echo "<tr><td>Vulnerable Packages</td><td>$(apt list --upgradable 2>/dev/null | grep -E "upgradable")</td></tr>"
    echo "</table>"
} >> "$REPORT_FILE"
update_progress "${STEPS[10]}"

# 12. Kernel Parameters
{
    echo "<h2>Kernel Parameters</h2>"
    echo "<table>"
    echo "<tr><th>Parameter</th><th>Value</th></tr>"
    sysctl_keys=("fs.suid_dumpable" "kernel.core_uses_pid" "kernel.kptr_restrict" "kernel.yama.ptrace_scope")
    for key in "${sysctl_keys[@]}"; do
        echo "<tr><td>$key</td><td>$(sysctl -n $key)</td></tr>"
    done
    echo "</table>"
} >> "$REPORT_FILE"
update_progress "${STEPS[11]}"

# 13. System Integrity Checks
{
    echo "<h2>System Integrity Checks</h2>"
    echo "<table>"
    echo "<tr><th>Check</th><th>Status</th></tr>"
    if [ -x "$(command -v debsums)" ]; then
        echo "<tr><td>Debian Package Integrity Check</td><td>$(debsums -s)</td></tr>"
    else
        echo "<tr><td>Debsums</td><td>Not installed; skipping package integrity checks.</td></tr>"
    fi
    echo "</table>"
} >> "$REPORT_FILE"
update_progress "${STEPS[12]}"

# 14. Check for Unused Packages
{
    echo "<h2>Unused Packages</h2>"
    echo "<table>"
    echo "<tr><th>Package</th></tr>"
    dpkg -l | awk '/^rc/ {print "<tr><td>" $2 "</td></tr>"}' >> "$REPORT_FILE"
    echo "</table>"
} >> "$REPORT_FILE"
update_progress "${STEPS[13]}"

# 15. Memory and Processes
{
    echo "<h2>Memory and Processes</h2>"
    echo "<table>"
    echo "<tr><th>Description</th><th>Value</th></tr>"
    echo "<tr><td>Total Memory</td><td>$(free -h | awk '/^Mem:/{print $2}')</td></tr>"
    echo "<tr><td>Used Memory</td><td>$(free -h | awk '/^Mem:/{print $3}')</td></tr>"
    echo "<tr><td>Total Processes</td><td>$(ps -e | wc -l)</td></tr>"
    echo "<tr><td>Running Processes</td><td>$(ps -e --no-headers | wc -l)</td></tr>"
    echo "</table>"
} >> "$REPORT_FILE"
update_progress "${STEPS[14]}"

# 16. Disk Information
{
    echo "<h2>Disk Information</h2>"
    echo "<table>"
    echo "<tr><th>Filesystem</th><th>Size</th><th>Used</th><th>Available</th><th>Use%</th></tr>"
    df -h | awk 'NR>1 {print "<tr><td>" $1 "</td><td>" $2 "</td><td>" $3 "</td><td>" $4 "</td><td>" $5 "</td></tr>"}' >> "$REPORT_FILE"
    echo "</table>"
} >> "$REPORT_FILE"
update_progress "${STEPS[15]}"

# 17. Networking Information
{
    echo "<h2>Networking Information</h2>"
    echo "<table>"
    echo "<tr><th>Property</th><th>Value</th></tr>"
    echo "<tr><td>Hostname</td><td>${HOSTNAME}</td></tr>"
    echo "<tr><td>IP Address</td><td>$(hostname -I | xargs)</td></tr>"
    echo "<tr><td>Network Interfaces</td><td>$(ip link show | awk -F: '$0 !~ "lo|virbr" {print $2}' | xargs)</td></tr>"
    echo "</table>"
} >> "$REPORT_FILE"
update_progress "${STEPS[16]}"

# 18. Opened Ports
{
    echo "<h2>Opened Ports</h2>"
    echo "<table>"
    echo "<tr><th>Protocol</th><th>Port</th><th>Status</th></tr>"
    sudo netstat -tuln | awk 'NR>2 {print "<tr><td>" $1 "</td><td>" $4 "</td><td>" $6 "</td></tr>"}' >> "$REPORT_FILE"
    echo "</table>"
} >> "$REPORT_FILE"
update_progress "${STEPS[17]}"

# 19. CIS Benchmark Checks
{
    echo "<h2>CIS Benchmark Checks</h2>"
    echo "<table>"
    echo "<tr><th>Check</th><th>Status</th></tr>"

    # 1. Ensure the latest updates are installed
    echo "<tr><td>Ensure the latest updates are installed</td><td>$(apt-get update && apt-get upgrade -s | grep -E 'upgraded' | wc -l | awk '{print ($1 > 0) ? "Updates available" : "No updates"}')</td></tr>"

    # 2. Ensure permissions on /etc/passwd are configured
    echo "<tr><td>Ensure permissions on /etc/passwd are configured</td><td>$(stat -c "%a" /etc/passwd)</td></tr>"

    # 3. Ensure permissions on /etc/shadow are configured
    echo "<tr><td>Ensure permissions on /etc/shadow are configured</td><td>$(stat -c "%a" /etc/shadow)</td></tr>"

    # 4. Ensure SSH access is limited
    echo "<tr><td>Ensure SSH access is limited</td><td>$(grep -E 'AllowUsers|AllowGroups' /etc/ssh/sshd_config || echo 'Not configured')</td></tr>"

    # 5. Ensure firewall is enabled
    echo "<tr><td>Ensure firewall is enabled</td><td>$(sudo ufw status | grep -q "active" && echo "Enabled" || echo "Disabled")</td></tr>"

    # 6. Ensure iptables rules exist
    echo "<tr><td>Ensure iptables rules exist</td><td>$(sudo iptables -L | grep -E 'Chain|0' | wc -l | awk '{print ($1 > 1) ? "Configured" : "Not configured"}')</td></tr>"

    # 7. Ensure SELinux is not enabled
    echo "<tr><td>Ensure SELinux is not enabled</td><td>$(getenforce 2>/dev/null || echo "Not applicable")</td></tr>"

    # 8. Ensure password expiration is set
    echo "<tr><td>Ensure password expiration is set</td><td>$(grep '^PASS_MAX_DAYS' /etc/login.defs | awk '{print $2}') days</td></tr>"

    # 9. Ensure lockout for failed login attempts
    echo "<tr><td>Ensure lockout for failed login attempts</td><td>$(grep 'fail2ban' /etc/hosts.deny | wc -l | awk '{print ($1 > 0) ? "Configured" : "Not configured"}')</td></tr>"

    # 10. Ensure the system is not accepting ICMP redirects
    echo "<tr><td>Ensure the system is not accepting ICMP redirects</td><td>$(sysctl net.ipv4.conf.all.accept_redirects | awk '{print $3}')</td></tr>"

    # 11. Ensure IP forwarding is disabled
    echo "<tr><td>Ensure IP forwarding is disabled</td><td>$(sysctl net.ipv4.ip_forward | awk '{print $3}')</td></tr>"

    # 12. Ensure the system's timezone is set
    echo "<tr><td>Ensure the system's timezone is set</td><td>$(timedatectl show-timezone)</td></tr>"

    # 13. Ensure automatic updates are enabled
    echo "<tr><td>Ensure automatic updates are enabled</td><td>$(dpkg-query -f='${Status}' -W unattended-upgrades | grep "install ok installed" && echo "Enabled" || echo "Disabled")</td></tr>"

    # 14. Check for unused packages
    echo "<tr><td>Check for unused packages</td><td>$(dpkg -l | awk '/^rc/ {print $2}' | wc -l) unused packages</td></tr>"

    # 15. Ensure NTP is configured
    echo "<tr><td>Ensure NTP is configured</td><td>$(systemctl is-active ntp | awk '{print ($1 == "active") ? "Configured" : "Not configured"}')</td></tr>"

    # 16. Ensure /tmp is mounted with noexec
    echo "<tr><td>Ensure /tmp is mounted with noexec</td><td>$(mount | grep "/tmp" | grep -q "noexec" && echo "Configured" || echo "Not configured")</td></tr>"

    # 17. Ensure core dumps are restricted
    echo "<tr><td>Ensure core dumps are restricted</td><td>$(ulimit -c | awk '{print ($1 == 0) ? "Restricted" : "Not restricted"}')</td></tr>"

    # 18. Ensure auditd is installed and running
    echo "<tr><td>Ensure auditd is installed and running</td><td>$(dpkg -l | grep auditd && systemctl is-active auditd | awk '{print ($1 == "active") ? "Running" : "Not running"}')</td></tr>"

    # 19. Ensure password complexity is configured
    echo "<tr><td>Ensure password complexity is configured</td><td>$(grep -E '^password requisite pam_pwquality.so' /etc/pam.d/common-password && echo "Configured" || echo "Not configured")</td></tr>"

    # 20. Ensure root login is disabled
    echo "<tr><td>Ensure root login is disabled</td><td>$(grep -q "PermitRootLogin no" /etc/ssh/sshd_config && echo "Configured" || echo "Enabled")</td></tr>"

    echo "</table>"
} >> "$REPORT_FILE"
update_progress "${STEPS[17]}"


# Finish HTML
{
    echo "<hr>"
    echo "<footer>Generated by Security Audit Script</footer>"
    echo "</body>"
    echo "</html>"
} >> "$REPORT_FILE"

# Final progress update
update_progress "${STEPS[17]}" "Complete"
echo -e "\nAudit complete. Report saved to $REPORT_FILE."
