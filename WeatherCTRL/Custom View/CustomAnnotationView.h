//
//  CustomAnnotationView.h
//  Weather
//
//  Created by Prem Dayal on 9/25/17.
//  Copyright © 2017 Prem Dayal. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface CustomAnnotationView : MKAnnotationView


- (id)initWithAnnotation:(id <MKAnnotation>)annotation
         reuseIdentifier:(NSString *)reuseIdentifier
                    icon:(NSString *)icon
                   label:(NSString *)label;

@end
