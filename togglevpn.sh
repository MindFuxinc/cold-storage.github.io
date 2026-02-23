#!/bin/zsh

# Variables (will need to adapt these)
loggedInUser=$(who | grep "console" | grep -v "_mbsetupuser" | awk '{print $1}')
VPN_STATUS_COMMAND="sudo -u $loggedInUser launchctl list | grep -i com.paloaltonetworks.gp"
LOAD_COMMAND_1="sudo -u $loggedInUser launchctl load /Library/LaunchAgents/com.paloaltonetworks.gp.pangps.plist"
LOAD_COMMAND_2="sudo -u $loggedInUser launchctl load /Library/LaunchAgents/com.paloaltonetworks.gp.pangpa.plist"
UNLOAD_COMMAND_1="sudo -u $loggedInUser launchctl unload /Library/LaunchAgents/com.paloaltonetworks.gp.pangps.plist"
UNLOAD_COMMAND_2="sudo -u $loggedInUser launchctl unload /Library/LaunchAgents/com.paloaltonetworks.gp.pangpa.plist"

# Function to check VPN status
is_vpn_running() {
    $VPN_STATUS_COMMAND &> /dev/null
    return $? # Returns 0 if running, non-zero if not
}

# Main logic
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 [on|off]"
    exit 1
fi

case "$1" in
    "on")
        if is_vpn_running; then
            echo "GlobalProtect is already active."
            exit 0
        else
            echo "Starting GlobalProtect..."
            $LOAD_COMMAND_1
            $LOAD_COMMAND_2
            if is_vpn_running; then
                echo "GlobalProtect started successfully."
                exit 0
            else
                echo "ERROR: Failed to start GlobalProtect."
                exit 1
            fi
        fi
        ;;
    "off")
        if is_vpn_running; then
            echo "Stopping GlobalProtect..."
            $UNLOAD_COMMAND_1
            $UNLOAD_COMMAND_2
            if ! is_vpn_running; then
                echo "GlobalProtect stopped successfully."
                exit 0
            else
                echo "ERROR: Failed to stop GlobalProtect."
                exit 1
            fi
        else
            echo "GlobalProtect is already inactive."
            exit 0
        fi
        ;;
    *)
        echo "Invalid argument: $1"
        echo "Usage: $0 [on|off]"
        exit 1
        ;;
esac
