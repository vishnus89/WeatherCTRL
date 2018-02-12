//
//  CustomAnnotation.m
//  Weather
//
//  Created by Vishnu Deep Samikeri on 2/10/18.
//  Copyright © 2018 Vishnu Deep Samikeri. All rights reserved.
//

#import "CustomAnnotation.h"
#import "CustomAnnotationView.h"

@implementation CustomAnnotation

/**
 Initializer for Custom Annotation
 */
+ (MKAnnotationView *)createViewAnnotationForMapView:(MKMapView *)mapView
                                          annotation:(id <MKAnnotation>)annotation
                                                icon:(NSString *)icon
                                               label:(NSString *)label{
    MKAnnotationView *returnedAnnotationView =
    (CustomAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:NSStringFromClass([CustomAnnotation class])];
    if (returnedAnnotationView == nil)
    {
        returnedAnnotationView =
        [[CustomAnnotationView alloc] initWithAnnotation:annotation
                                         reuseIdentifier:NSStringFromClass([CustomAnnotation class])
                                                    icon:icon
                                                   label:label ];
    }
    
    return returnedAnnotationView;
}

@end
