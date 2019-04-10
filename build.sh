#!/bin/bash

identifier="com.company.package"
packageName="Package"
mainScript="main_script_name.sh"
plist="com.company.package.plist"
version="1.0"

if [[ -n "$1" ]]; then
    version="$1"
    echo "Version set to $version"
else
    echo "No version passed, using version $version"
fi

find "/private/tmp/$packageName" -mindepth 1 -delete
mkdir -p "/private/tmp/$packageName/files/Library/LaunchDaemons"
mkdir -p "/private/tmp/$packageName/files/Library/Scripts/"
mkdir -p "/private/tmp/$packageName/scripts"
mkdir -p "$PWD/build"

# Migrate postinstall script to temp build directory
cp "$PWD/postinstall.sh" /private/tmp/$packageName/scripts/postinstall
chmod +x /private/tmp/$packageName/scripts/postinstall

# Create the target script
cp "$PWD/$mainScript" "/private/tmp/$packageName/files/Library/Scripts/$mainScript"

# Copy the LaunchDaemon plist to the temp build directory
cp "$PWD/$plist" "/private/tmp/$packageName/files/Library/LaunchDaemons/"

# Remove any unwanted .DS_Store files from the temp build directory
find "/private/tmp/$packageName/" -name '*.DS_Store' -type f -delete

# Remove any extended attributes (ACEs) from the temp build directory
/usr/bin/xattr -rc "/private/tmp/$packageName"

echo "Building the .pkg in $PWD/build/"
/usr/bin/pkgbuild --quiet --root "/private/tmp/$packageName/files/" \
    --install-location "/" \
    --scripts "/private/tmp/$packageName/scripts/" \
    --identifier "$identifier" \
    --version "$version" \
    --ownership recommended \
    "$PWD/build/${packageName}_${version}.pkg"

# shellcheck disable=SC2181
if [[ "$?" == "0" ]]; then
    echo "Revealing ${packageName}_${version}.pkg in Finder"
    open -R "$PWD/build/${packageName}_${version}.pkg"
else
    echo "Build failed."
fi
exit 0