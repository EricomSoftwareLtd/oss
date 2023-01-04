// SPDX-License-Identifier: MIT
// Copyright @ 2021 Ericom Software. All Rights Reserved.

#import <Cocoa/Cocoa.h>

int main(int argc, char *argv[])
{
    NSString *appIdInfoDictionaryKey = @"com.ericom.ztac.macos.app_id";
    NSString *appId = [NSBundle.mainBundle objectForInfoDictionaryKey:appIdInfoDictionaryKey];

    NSString *launchCode = @"LaunchedByZTELoginItemHelper";
    NSAppleEventDescriptor *paramDescriptor = [NSAppleEventDescriptor descriptorWithString:launchCode];

    [NSWorkspace.sharedWorkspace launchAppWithBundleIdentifier:appId options:NSWorkspaceLaunchWithoutActivation
                                additionalEventParamDescriptor:paramDescriptor launchIdentifier:NULL];
    return 0;
}
