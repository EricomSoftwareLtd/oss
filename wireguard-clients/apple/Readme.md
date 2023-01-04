# ZTEDGE Client for iOS and macOS

This project contains an application for iOS and for macOS, as well as many components shared between the two of them. You may toggle between the two platforms by selecting the target from within Xcode.

## Building

- Rename and populate developer team ID file:



```
$ cp WireGuard/WireGuard/Config/Developer.xcconfig.template WireGuard/WireGuard/Config/Developer.xcconfig
$ vim WireGuard/WireGuard/Config/Developer.xcconfig
```

- Install swiftlint and go 1.13.4:

```
$ brew install swiftlint go
```

- Open project in Xcode:

```
$ open ./WireGuard/WireGuard.xcodeproj
```
