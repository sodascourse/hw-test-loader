# Homework Test Loader

## Usage

1. It's recommended to have a local installed Ruby instead of using OS X's ruby. Check [`homebrew`](http://brew.sh)
2. Clone this repository
3. Run make command

### Make Commands

Homework # | Command
-----------|-------------------------------------------------------------
Homework 1 | `make homework1 path=[PATH_TO_YOUR_PROJECT] scheme=[SCHEME]

For example:
```shell
make homework1 path=/Users/sodas/Desktop/hw1 scheme=Calculator
```

The path is where you save your xcode project. And the scheme is the name next to the _run button_ of Xcode.


## NOTE

We use [**Xcodeproj**](https://github.com/CocoaPods/Xcodeproj) to inject test code and
[**scan**](https://github.com/fastlane/fastlane/tree/master/scan) to run test.
