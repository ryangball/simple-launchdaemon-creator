#!/bin/bash

identifier=""   # com.company.package
packageName=""  # Package
version=""      # 1.0
target=""       # main_script_name.sh

# Prompt for the identifier, strip off .plist if it is included
[[ -z "$identifier" ]] && identifier=$(osascript -e 'set identifier to the text returned of (display dialog "Enter the identifier of the package." default answer "com.company.package")' 2> /dev/null)
[[ -z "$identifier" ]] && echo "User cancelled; exiting" && exit 0
identifier=${identifier%.plist*}
echo "Identifier set to: $identifier"

# Prompt for the name of the package, strip off .pkg if it is included
[[ -z "$packageName" ]] && packageName=$(osascript -e 'set packageName to the text returned of (display dialog "Enter the name of the package." default answer "Package Name")' 2> /dev/null)
[[ -z "$packageName" ]] && echo "User cancelled; exiting" && exit 0
packageName=${packageName%.pkg*}
echo "Package Name set to: $packageName"

# Prompt for the version
[[ -z "$version" ]] && version=$(osascript -e 'set theVersion to the text returned of (display dialog "Enter the version of the package." default answer "1.0")' 2> /dev/null)
[[ -z "$version" ]] && echo "User cancelled; exiting" && exit 0
echo "Version set to: $version"

# Prompt for the target of the LaunchDaemon
[[ -z "$target" ]] && target=$(osascript -e 'set new_file to POSIX path of (choose file with prompt "Choose target sh script or app." of type {"SH","BASH","PY","APP"})' 2> /dev/null)
[[ -z "$target" ]] && echo "User cancelled; exiting." && exit 0
targetPath=${target%/}
targetName=${targetPath##*/}
echo "Target Name is: $targetName"

# Configure the target and warn if .app is chosen
if [[ "$targetName" == *.app ]]; then
    echo "Warning user of LaunchDaemon use to open applications."
    [[ -z "$confirmation" ]] && confirmation=$(osascript -e 'display dialog "Opening an app that requires a GUI is better suited for a LaunchAgent. Are you sure you want to continue?" buttons {"Cancel","I Understand"} default button 2 with icon 2' 2> /dev/null)
    [[ -z "$confirmation" ]] && echo "User cancelled; exiting." && exit 0
    echo "Setting LaunchDaemon program arguments to open an app..."
    programArguments="/usr/bin/open"
else
    echo "Setting LaunchDaemon program arguments to run a script..."
    # Try to determine the program arguments from the script's shebang
    case "$(head -n 1 "$targetPath")" in
        *bash)
            programArguments="/bin/bash"
            ;;
        *sh)
            programArguments="/bin/sh"
            ;;
        *python)
            programArguments="/usr/bin/python"
            ;;
    esac
fi
echo "Program Arguments set to: $programArguments"

# Create/clean our build directories
echo "Build directory will be: /private/tmp/$packageName"
find "/private/tmp/$packageName" -mindepth 1 -delete
mkdir -p "/private/tmp/$packageName/files/Library/LaunchDaemons"
mkdir -p "/private/tmp/$packageName/files/Library/Scripts/"
mkdir -p "/private/tmp/$packageName/scripts"
mkdir -p "/private/tmp/$packageName/build"

# Move target into place
echo "Moving $targetName to temporary build directory..."
cp -R "$targetPath" "/private/tmp/$packageName/files/Library/Scripts/"

# Create the LaunchDaemon plist
echo "Creating the LaunchDaemon plist..."
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
	<key>StandardErrorPath</key>
	<string>/Library/Logs/$identifier.log</string>
	<key>StandardOutPath</key>
	<string>/Library/Logs/$identifier.log</string>
</dict>
</plist>
EOF

# Create the preinstall script
echo "Creating the preinstall/postinstall scripts..."
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
chown -R root:wheel "/Library/Scripts/$targetName"
chmod -R 755 "/Library/Scripts/$targetName"

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
echo "Building the .pkg in: /private/tmp/$packageName/build/"
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