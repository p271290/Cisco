#!/bin/bash

# Ensure script is run as root
if [ "$EUID" -ne 0 ]; then
    echo "[-] Error: This script must be run with root privileges (sudo)."
    exit 1
fi

# Define output report file with a timestamp locally
REPORT_FILE="/var/log/user_activity_report_\((hostname)_\)(date +%Y%m%d_%H%M%S).txt"

echo "[+] Collecting user login and privilege audit data..."

{
    echo "=================================================================="
    echo "        UBUNTU WORKSTATION USER ACTIVITY & SUDO AUDIT REPORT        "
    echo "        Generated on: $(date)                                     "
    echo "=================================================================="

    # 1. Login Activity
    echo -e "\n\n[ SECTION 1: RECENT USER LOGIN SESSIONS (last) ]"
    echo "------------------------------------------------------------------"
    last -n 50

    echo -e "\n\n[ SECTION 2: LAST LOGIN STATUS FOR ALL ACCOUNTS (lastlog) ]"
    echo "------------------------------------------------------------------"
    lastlog

    # 2. Sudo / Privileged Command Execution Logs
    echo -e "\n\n[ SECTION 3: SUDO COMMANDS EXECUTED BY USERS ]"
    echo "------------------------------------------------------------------"
    # Pulls structured sudo execution entries from system journal, showing username & command
    journalctl _COMM=sudo --no-pager -o short-iso | grep -E "COMMAND="

    # 3. Direct Root Shell / 'su' Transitions
    echo -e "\n\n[ SECTION 4: DIRECT ROOT SHELL / 'SU' SWITCHES ]"
    echo "------------------------------------------------------------------"
    journalctl -t su --no-pager -o short-iso

    echo -e "\n=================================================================="
    echo "                           END OF REPORT                          "
    echo "=================================================================="
} > "$REPORT_FILE"

echo "[+] Audit complete!"
echo "[+] The report has been safely saved locally to: $REPORT_FILE"
