//
//  SettingsBundleHelper.m
//  Weather
//
//  Created by Prem Dayal on 9/26/17.
//  Copyright © 2017 Prem Dayal. All rights reserved.
//

#import "SettingsBundleHelper.h"
#import "Server.h"

#define kVersionIdentifier @"version_preference"
#define kBuildIdentifier @"build_preference"
#define kDeleteAllBookmarks @"RESET_APP_KEY"


@implementation SettingsBundleHelper

+(void)resetApplication{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kDeleteAllBookmarks]) {
        [[NSUserDefaults standardUserDefaults] setBool:false forKey:kDeleteAllBookmarks];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kBookmarkedLocatons];
    }
}

+(void)setVersionAndBuild{
    NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    [[NSUserDefaults standardUserDefaults] setObject:version forKey:kVersionIdentifier];
    NSString *build = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    [[NSUserDefaults standardUserDefaults] setObject:build forKey:kBuildIdentifier];
}

@end
