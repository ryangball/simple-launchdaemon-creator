# Simple LaunchDaemon Creator

### Build Project
To build new versions you can simply run the build.sh script and specify a version number for the .pkg. The resulting .pkg will include the LaunchDaemon and target script as well as a postinstall script to launch the daemon after installation and at system startup. If you do not include a version number as a parameter then version 1.0 will be assigned as the default.
```
$ git clone https://github.com/ryangball/simple-launchdaemon-creator.git
$ cd simple-launchdaemon-creator
$ sh build.sh 1.5
Version set to 1.5
Building the .pkg in /Users/ryangball/simple-launchdaemon-creator/build/
Revealing Package_1.5.pkg in Finder
```