#!/bin/bash

identifier="com.github.ryangball.simple-launchdaemon-creator"
version="1.0"

if [[ -n "$1" ]]; then
    version="$1"
    echo "Version set to $version"
else
    echo "No version passed, using version $version"
fi

# Create temp build directories
mkdir -p /private/tmp/simple-launchdaemon-creator/files/Applications
mkdir -p /private/tmp/simple-launchdaemon-creator/scripts
mkdir -p "$PWD/build"

# Build the .app
echo "Building the .app with Platypus..."
/usr/local/bin/platypus \
    --background \
    --quit-after-execution \
    --app-icon "$PWD/images/AppIcon.icns" \
    --name 'Simple LaunchDaemon Creator' \
    --interface-type 'None' \
    --interpreter '/bin/bash' \
    --author 'Ryan Ball' \
    --app-version "$version" \
    --bundle-identifier "$identifier" \
    --optimize-nib \
    --overwrite \
    'simple_launchdaemon_creator.sh' \
    "/private/tmp/simple-launchdaemon-creator/files/Applications/Simple LaunchDaemon Creator.app"

# Remove any unwanted .DS_Store files from the temp build directory
find "/private/tmp/simple-launchdaemon-creator/" -name '*.DS_Store' -type f -delete

# Remove any extended attributes (ACEs) from the temp build directory
/usr/bin/xattr -rc "/private/tmp/simple-launchdaemon-creator"

echo "Building the PKG..."
/usr/bin/pkgbuild --quiet --root "/private/tmp/simple-launchdaemon-creator/files/" \
    --install-location "/" \
    --identifier "$identifier" \
    --version "$version" \
    --ownership recommended \
    "$PWD/build/Simple_LaunchDaemon_Creator_${version}.pkg"

# shellcheck disable=SC2181
if [[ "$?" == "0" ]]; then
    echo "Revealing Simple_LaunchDaemon_Creator_${version}.pkg in Finder"
    open -R "$PWD/build/Simple_LaunchDaemon_Creator_${version}.pkg"
else
    echo "Build failed."
fi

exit 0