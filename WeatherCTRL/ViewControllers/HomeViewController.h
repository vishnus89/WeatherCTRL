//
//  HomeViewController.h
//  Weather
///  Created by Vishnu Deep Samikeri on 2/10/18.
//  Copyright © 2018 Vishnu Deep Samikeri. All rights reserved.

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "Server.h"
#import "Weather.h"
#import "CityViewController.h"
#import "LocationsViewController.h"
#import "HelperViewController.h"

@interface HomeViewController : UIViewController <MKMapViewDelegate,CLLocationManagerDelegate,UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) CLLocationManager *locationManager;

@property (strong, nonatomic) IBOutlet UITextField *searchbar;
@property (strong, nonatomic) IBOutlet UIButton *bookmarkButton;
@property (weak, nonatomic) IBOutlet UIButton *assistanceButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bookmarkButtonLeading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bookmarkButtonWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bookmarkButtonBottomDistanceFromMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *searchbarBottomDistanceFromMargin;

- (IBAction)assistanceViewButton:(id)sender;
- (IBAction)viewSavedLocations:(id)sender;
@end
