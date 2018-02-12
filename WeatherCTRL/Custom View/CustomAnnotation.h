//
//  CustomAnnotation.h
//  Weather
//
//  Created by Vishnu Deep Samikeri on 2/10/18.
//  Copyright © 2018 Vishnu Deep Samikeri. All rights reserved.

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "Weather.h"

@interface CustomAnnotation : NSObject <MKAnnotation>

@property (nonatomic, strong) Weather *locationDetails;
@property (nonatomic, readwrite) CLLocationCoordinate2D coordinate;

+ (MKAnnotationView *)createViewAnnotationForMapView:(MKMapView *)mapView
                                          annotation:(id <MKAnnotation>)annotation
                                                icon:(NSString *)icon
                                               label:(NSString *)label;


@end
