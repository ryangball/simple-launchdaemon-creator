# Simple LaunchDaemon Creator
Easily create a LaunchDaemon for use on a Mac. You choose the identifier, the name, the version, and the target script/app (.sh, .bash, .py, .app) to create a .pkg containing all necessary files with correct permissions. Upon installation of the resulting .pkg, the target script/app will load automatically at time of install, as well as when the system starts.

## Install a Release
You can download a .pkg from the [release](https://github.com/ryangball/simple-launchdaemon-creator/releases) section containing a pre-built .app which installs under the /Applications directory. Just install the .pkg, and run "/Applications/Simple LaunchDaemon Creator.app" to start.

## Build a LaunchDaemon .PKG from Command Line
Alternatively, you can clone this repository and simply run the simple_launchdaemon_creator.sh from Terminal.
```bash
git clone https://github.com/ryangball/simple-launchdaemon-creator.git
cd simple-launchdaemon-creator
./simple_launchdaemon_creator.sh
```

## Build This Project into an Application
### Requirements for Building "Simple LaunchDaemon Creator.app" Yourself
- [Platypus](https://sveinbjorn.org/platypus): A developer tool that creates native Mac applications from command line scripts such as shell scripts or Python, Perl, Ruby, Tcl, JavaScript and PHP programs.
    - You must install the command line tool associated with Platypus. Open Platypus, in the Menu Bar choose "Platypus" > "Preferences" and click the "Install" button to install the Platypus command line tool.

To build the application yourself you can simply run the build.sh script and specify a version number for both the .app and .pkg. The resulting .pkg will include the .app with a target of /Applications just like any of the [releases](https://github.com/ryangball/simple-launchdaemon-creator/releases). If you do not include a version number as a parameter then version 1.0 will be assigned as the default. You can modify the simple_launchdaemon_creator.sh script first and build the .app afterward if you'd like.
```bash
git clone https://github.com/ryangball/simple-launchdaemon-creator.git
cd simple-launchdaemon-creator
./build.sh 1.0
```

## LaunchDaemon Plist Keys Automatically Set
Example LaunchDaemon plist that gets created:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>Label</key>
	<string>com.github.ryangball.sample</string>
	<key>ProgramArguments</key>
	<array>
		<string>/bin/sh</string>
		<string>/Library/Scripts/Sample.sh</string>
	</array>
	<key>RunAtLoad</key>
	<true/>
	<key>StandardErrorPath</key>
	<string>/Library/Logs/com.github.ryangball.sample.log</string>
	<key>StandardOutPath</key>
	<string>/Library/Logs/com.github.ryangball.sample.log</string>
</dict>
</plist>
```
### ProgramArguments Key
Simple LaunchDaemon Creator tries to determine the ProgramArguments from the [shebang](https://github.com/MadhavBahlMD/shebang-everything#shebang) line if your target is a script. So you should include a valid shebang as the first line of your script. If your target is an app, `/usr/bin/open` is used.

Supported shebangs ([request something](https://github.com/ryangball/simple-launchdaemon-creator/issues/new?title=[Feature%20Request])):
- `#!/bin/bash`
- `#!/bin/sh`
- `#!/usr/bin/python`

### RunAtLoad Key
The RunAtLoad key is set to true. This will start the LaunchDaemon at system startup.

### StandardErrorPath and StandardOutPath Keys
The main LaunchDaemon plist is automatically set to have stdout and stderr combined and written to `/Library/Logs/YOUR_CHOSEN_IDENTIFIER.log` for ease of troubleshooting.

## Using a LaunchDaemon to Launch GUI Applications
Applications that require the GUI typically need to run in the user's context which means after a user is logged in. This is problematic (not impossible) for a LaunchDaemon. For example if you use a LaunchDaemon to open Google Chrome.app, the LaunchDaemon will attempt to launch Chrome before a user is even logged in which will fail.

Not all applications will have this issue (non GUI apps). When creating a LaunchDaemon with an app as a target, you will be warned that a LaunchAgent might be better.

## YMMV
Of course there are a lot of variables that go into LaunchDaemons. This is creates a very simple LaunchDaemon with the RunAtLoad key set to true. If you need to customize this, feel free to clone the repository and make any modifications you feel necessary.

## Issues or Additional Features
### Issues
For issues that you think are worth looking into, you can [submit an issue](https://github.com/ryangball/simple-launchdaemon-creator/issues/new).

### Feature Requests
If you think additional functionality would be beneficial, you can [create a feature request](https://github.com/ryangball/simple-launchdaemon-creator/issues/new?title=[Feature%20Request]) by creating an issue and noting that it is a feature request.