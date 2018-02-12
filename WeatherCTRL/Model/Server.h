//
//  Server.h
//  Weather
//
///  Created by Vishnu Deep Samikeri on 2/10/18.
//  Copyright © 2018 Vishnu Deep Samikeri. All rights reserved.

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

#define kUnitType @"kUnitType"
#define kBookmarkedLocatons @"kBookmarkedLocatons"

typedef void(^JSONcompletion)(BOOL success,
                              NSDictionary *dict,
                              NSArray *array,
                              NSString *str);

static NSString * const kAPIKey = @"bd5e378503939ddaee76f12ad7a97608";
static NSString * const kCurrentEndpoint = @"weather";
static NSString * const kforecastEndpoint = @"forecast";
static NSString * const kServerURL = @"http://api.openweathermap.org/data/2.5/";

@interface Server : NSObject

+(void)fetchCurrentDataForLocation:(CLLocationCoordinate2D) location
                        completion: (JSONcompletion) completion;
+(void)fetchWeeklyDataForLocation:(CLLocationCoordinate2D) location
                       completion: (JSONcompletion) completion;
+(NSString *)serializeParams:(NSDictionary *)params;

@end
