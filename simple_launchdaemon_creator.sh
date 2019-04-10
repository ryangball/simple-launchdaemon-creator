#!/bin/bash

identifier=""   # com.company.package
packageName=""  # Package
version=""      # 1.0
target=""       # main_script_name.sh

# Prompt for the identifier, strip off .plist if it is included
[[ -z "$identifier" ]] && identifier=$(osascript -e 'set identifier to the text returned of (display dialog "Enter the identifier of the package." default answer "com.company.package")' 2> /dev/null)
[[ -z "$identifier" ]] && echo "User cancelled; exiting" && exit 0
identifier=${identifier%.plist*}

# Prompt for the name of the package, strip off .pkg if it is included
[[ -z "$packageName" ]] && packageName=$(osascript -e 'set packageName to the text returned of (display dialog "Enter the name of the package." default answer "Package Name")' 2> /dev/null)
[[ -z "$packageName" ]] && echo "User cancelled; exiting" && exit 0
packageName=${packageName%.pkg*}

# Prompt for the version
[[ -z "$version" ]] && version=$(osascript -e 'set theVersion to the text returned of (display dialog "Enter the version of the package." default answer "1.0")' 2> /dev/null)
[[ -z "$version" ]] && echo "User cancelled; exiting" && exit 0

# Prompt for the target of the LaunchDaemon
[[ -z "$target" ]] && target=$(osascript -e 'tell app (path to frontmost application as Unicode text) to set new_file to POSIX path of (choose file with prompt "Choose target sh script or app." of type {"SH","APP"})' 2> /dev/null)
[[ -z "$target" ]] && echo "User cancelled; exiting." && exit 0
targetPath=${target%/}
targetName=${targetPath##*/}

# Create/clean our build directories
find "/private/tmp/$packageName" -mindepth 1 -delete
mkdir -p "/private/tmp/$packageName/files/Library/LaunchDaemons"
mkdir -p "/private/tmp/$packageName/files/Library/Scripts/"
mkdir -p "/private/tmp/$packageName/scripts"
mkdir -p "/private/tmp/$packageName/build"

# Configure the target
if [[ "$targetName" == *.app ]]; then
    echo "Setting LaunchDaemon program arguments to open an app."
    programArguments="/usr/bin/open"
else
    echo "Setting LaunchDaemon program arguments to run a script."
    programArguments="sh"
fi
echo "Moving $targetName to temporary build directory..."
cp -R "$targetPath" "/private/tmp/$packageName/files/Library/Scripts/"

# Create the LaunchDaemon plist
cat << EOF > "/private/tmp/$packageName/files/Library/LaunchDaemons/$identifier.plist"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>Label</key>
	<string>$identifier</string>
	<key>ProgramArguments</key>
	<array>
		<string>$programArguments</string>
		<string>/Library/Scripts/$targetName</string>
	</array>
	<key>RunAtLoad</key>
	<true/>
</dict>
</plist>
EOF

# Create the preinstall script
cat << EOF > "/private/tmp/$packageName/scripts/preinstall"
#!/bin/bash

# Stop our LaunchDaemon
/bin/launchctl unload -w /Library/LaunchDaemons/$identifier.plist

exit 0
EOF

# Create the postinstall script
cat << EOF > "/private/tmp/$packageName/scripts/postinstall"
#!/bin/bash

# Set permissions on LaunchDaemon and Script
chown root:wheel /Library/LaunchDaemons/$identifier.plist
chmod 644 /Library/LaunchDaemons/$identifier.plist
chown -R root:wheel /Library/Scripts/$targetName
chmod -R 755 /Library/Scripts/$targetName

# Start our LaunchDaemon
/bin/launchctl load -w /Library/LaunchDaemons/$identifier.plist

exit 0
EOF

# Set permission on the preinstall/postinstall scripts
chmod +x "/private/tmp/$packageName/scripts/postinstall"
chmod +x "/private/tmp/$packageName/scripts/preinstall"

# Remove any unwanted .DS_Store files from the temp build directory
find "/private/tmp/$packageName/" -name '*.DS_Store' -type f -delete

# Remove any extended attributes (ACEs) from the temp build directory
/usr/bin/xattr -rc "/private/tmp/$packageName"

# Build the .pkg
echo "Building the .pkg in /private/tmp/$packageName/build/"
/usr/bin/pkgbuild --quiet --root "/private/tmp/$packageName/files/" \
    --install-location "/" \
    --scripts "/private/tmp/$packageName/scripts/" \
    --identifier "$identifier" \
    --version "$version" \
    --ownership recommended \
    "/private/tmp/$packageName/build/${packageName}_${version}.pkg"

# shellcheck disable=SC2181
if [[ "$?" == "0" ]]; then
    echo "Revealing ${packageName}_${version}.pkg in Finder"
    open -R "/private/tmp/$packageName/build/${packageName}_${version}.pkg"
else
    echo "Build failed."
fi
exit 0