# Simple LaunchDaemon Creator
Easily create a LaunchDaemon for use on a Mac. You choose the identifier, the name, the version, and the target script/app to create a .pkg containing all necessary files with correct permissions. Upon installation of the resulting .pkg, the target script/app will load automatically at time of install, as well as when the system starts.

## Install a Release
You can download a .pkg from the [release](https://github.com/ryangball/simple-launchdaemon-creator/releases) section containing a pre-built .app which installs under the /Applications directory. Just install the .pkg, and run "/Applications/Simple LaunchDaemon Creator.app" to start.

## Build a LaunchDaemon .PKG from Command Line
Alternatively, you can clone this repository and simply run the simple_launchdaemon_creator.sh from Terminal.
```
git clone https://github.com/ryangball/simple-launchdaemon-creator.git
cd simple-launchdaemon-creator
./simple_launchdaemon_creator.sh
```

## Build This Project into an Application
### Requirements for Building "Simple LaunchDaemon Creator.app" Yourself
- [Platypus](https://sveinbjorn.org/platypus): A developer tool that creates native Mac applications from command line scripts such as shell scripts or Python, Perl, Ruby, Tcl, JavaScript and PHP programs.
    - You must install the command line tool associated with Platypus. Open Platypus, in the Menu Bar choose "Platypus" > "Preferences" and click the "Install" button to install the Platypus command line tool.

To build the application yourself you can simply run the build.sh script and specify a version number for both the .app and .pkg. The resulting .pkg will include the .app with a target of /Applications just like any of the [releases](https://github.com/ryangball/simple-launchdaemon-creator/releases). If you do not include a version number as a parameter then version 1.0 will be assigned as the default. You can modify the simple_launchdaemon_creator.sh script first and build the .app afterward if you'd like.
```
git clone https://github.com/ryangball/simple-launchdaemon-creator.git
cd simple-launchdaemon-creator
./build.sh 1.0
```

## This Won't Work For Everybody
Of course there are a lot of variables that go into LaunchDaemons. This is creates a very simple LaunchDaemon with the RunAtLoad key set to true. If you need to customize this, feel free to clone the repository and make any modifications you feel necessary.