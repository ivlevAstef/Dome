//
//  CheckHaveCamera.m
//  Dome
//
//  Created by Ивлев Александр on 07/07/2019.
//  Copyright © 2019 SIA. All rights reserved.
//

#import "CheckHaveCamera.h"
#import "MCRestrictionManager.h"

@implementation CheckHaveCamera

+(BOOL)checkHaveCamera
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSBundle *b = [NSBundle bundleWithPath:@"/System/Library/PrivateFrameworks/ManagedConfiguration.framework"];
        /*BOOL success =*/ [b load];
        // всегда загружается
    });

    Class managerClass = NSClassFromString(@"MCRestrictionManager");
    MCRestrictionManager *manager = [managerClass valueForKey:@"sharedManager"];

    NSSet *appIds = [manager restrictedAppBundleIDs];

    if ([appIds containsObject:@"com.apple.camera"]) {
        return YES;
    }
    return NO;
}

@end
