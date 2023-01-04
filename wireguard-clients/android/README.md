# Android GUI for ZTAC-Client

This product based on [WireGuard](https://www.wireguard.com/). It [opportunistically uses the kernel implementation](https://git.zx2c4.com/android_kernel_wireguard/about/), and falls back to using the non-root [userspace implementation](https://git.zx2c4.com/wireguard-go/about/).

## Requirements 

Docker

## Building

cd packaging/wireguard/os

sudo docker run --rm -v `pwd`:/project mingc/android-build-box bash -c 'cd /project/os/android/src; ./gradlew assembleRelease'

Build result located here: packaging/wireguard/os/android/src/ui/build/outputs/apk/release/

## Embedding

The tunnel library is [on JCenter](https://bintray.com/wireguard/wireguard-android/wireguard-android/_latestVersion), alongside [extensive class library documentation](https://javadoc.io/doc/com.ericom.ztac/tunnel).

```
implementation 'com.ericom.ztac:tunnel:$wireguardTunnelVersion'
```

The library makes use of Java 8 features, so be sure to support those in your gradle configuration:

```
compileOptions {
    sourceCompatibility JavaVersion.VERSION_1_8
    targetCompatibility JavaVersion.VERSION_1_8
}
```
