#!/bin/bash

# Set permissions on LaunchDaemon and Script
chown root:wheel /Library/LaunchDaemons/com.company.package.plist
chmod 644 /Library/LaunchDaemons/com.company.package.plist
chown root:wheel /Library/Scripts/main_script_name.sh
chmod 755 Library/Scripts/main_script_name.sh

# Start our LaunchDaemon
/bin/launchctl load -w /Library/LaunchDaemons/com.company.package.plist

exit 0