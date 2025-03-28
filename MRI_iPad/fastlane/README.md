fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

Install _fastlane_ using
```
[sudo] gem install fastlane -NV
```
or alternatively using `brew install fastlane`

# Available Actions
## iOS
### ios test
```
fastlane ios test
```
[CI] Run Unit and UI Tests
### ios build
```
fastlane ios build
```
[CI] Default build configuration
### ios release
```
fastlane ios release
```
[CI] Upload a previous build app to TestFlight
### ios api_key
```
fastlane ios api_key
```
[CI] Generate a fresh token to authenticate on the app store connect api

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
