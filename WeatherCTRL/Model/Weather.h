//
//  Weather.h
//  Weather
//
//  Created by Vishnu Deep Samikeri on 2/10/18.
//  Copyright © 2018 Vishnu Deep Samikeri. All rights reserved.

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "Server.h"

@interface Weather : NSObject

@property (assign, nonatomic) CLLocationCoordinate2D location;
@property (strong, nonatomic) NSString * city;
@property (strong, nonatomic) NSString * weather;
@property (strong, nonatomic) NSString * icon;
@property (assign, nonatomic)  float time;
@property (assign, nonatomic)  float windSpeed;
@property (assign, nonatomic)  float currentTemp;
@property (assign, nonatomic)  float minTemp;
@property (assign, nonatomic)  float maxTemp;
@property (assign, nonatomic)  float pressure;
@property (assign, nonatomic)  float humidity;

@end
