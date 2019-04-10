# Simple LaunchDaemon Creator
Easily create a LaunchDaemon for use on a Mac. You choose the identifier, the name, the version, and the target script/app - and you can create a .pkg containing all necessary files with correct permissions. Upon installation of the resulting .pkg, the target script/app will load automatically at time of install, as well as when the system starts.

## Building the LaunchDaemon .PKG
To build a new LaunchDaemon .pkg you can simply run the simple_launchdaemon_creator.sh script. Dialogs will ask you the necessary information, build the .pkg, and reveal it in Finder. The resulting .pkg will include the LaunchDaemon and target script/app as well as a pre/postinstall scripts to launch the daemon after installation and at system startup.
```
git clone https://github.com/ryangball/simple-launchdaemon-creator.git
cd simple-launchdaemon-creator
./simple_launchdaemon_creator.sh
```

## Variables
Of course there are a lot of variables that go into LaunchDaemons. This is creates a very simple LaunchDaemon with the RunAtLoad key set to true. If you need to customize this, feel free to clone the repository and edit the code.