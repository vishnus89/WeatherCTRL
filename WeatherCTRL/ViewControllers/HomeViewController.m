//
//  HomeViewController.m
//  Weather
//
///  Created by Vishnu Deep Samikeri on 2/10/18.
//  Copyright © 2018 Vishnu Deep Samikeri. All rights reserved.

#import "HomeViewController.h"
#import "CustomAnnotation.h"
#import "CustomAnnotationView.h"

@interface HomeViewController ()

@end

@implementation HomeViewController
{
    NSMutableDictionary *annotationDictionary;
}
@synthesize mapView;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Searchbar Delegate
    self.searchbar.delegate = self;
    
    annotationDictionary = [[NSMutableDictionary alloc] init];
    //Check for Unit type of Application
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kUnitType] == nil) {
        [[NSUserDefaults standardUserDefaults] setObject:@"metric" forKey:kUnitType];
    }
    
    //Notification Handler for Keyboard display/hide
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChange:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChange:) name:UIKeyboardWillHideNotification object:nil];
    
    //Add tap gessture to hide keyboard if search bar is active
    UITapGestureRecognizer *mapViewTapped = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(checkFirstResponder)];
    [self.mapView addGestureRecognizer:mapViewTapped];
    
    UILongPressGestureRecognizer *mapViewLongPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    mapViewLongPress.minimumPressDuration = 0.5;
    [self.mapView addGestureRecognizer:mapViewLongPress];
    
    
    //Initialising Map delegate & Location manager
    [[self mapView] setShowsUserLocation:YES];
    [self.mapView setDelegate:self];
    
    self.locationManager = [[CLLocationManager alloc] init];
    [[self mapView] setShowsUserLocation:YES];
    
    
    //Request Location access for user
    [[self locationManager] setDelegate:self];
    if ([[self locationManager] respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [[self locationManager] requestWhenInUseAuthorization];
    }
    
    [[self locationManager] setDesiredAccuracy:kCLLocationAccuracyHundredMeters];
    
}

-(void)viewDidAppear:(BOOL)animated{
    [self refreshBookmarkedAnnotation];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 Deallocated Notification handler
 */
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - TextField Delegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField.text.length == 0) {
        [self checkFirstResponder];
    }else{
        [self gecodeSearchString:textField.text];
    }
    return YES;
}


#pragma mark - MapView Delegate

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [mapView setCenterCoordinate:mapView.userLocation.location.coordinate animated:YES];
        [[self mapView] setShowsUserLocation:NO];
    }
}

-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view{
    if ([view isKindOfClass:[CustomAnnotationView class]]) {
        CityViewController *cityVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"CityViewController"];
        cityVC.currentWeatherObject = (Weather *)[annotationDictionary objectForKey:[NSValue valueWithMKCoordinate:view.annotation.coordinate]];
        [self presentViewController:cityVC animated:YES completion:nil];
    }
}


-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    MKAnnotationView *returnedAnnotationView = nil;
        if ([annotation isKindOfClass:[CustomAnnotation class]])
        {
            Weather *annotationViewObject = (Weather *)[annotationDictionary objectForKey:[NSValue valueWithMKCoordinate:annotation.coordinate]];
            returnedAnnotationView = [CustomAnnotation createViewAnnotationForMapView:self.mapView
                                                                           annotation:annotation
                                                                               icon:annotationViewObject.icon
                                                                                label:annotationViewObject.weather];
        }
    
    return returnedAnnotationView;
}


#pragma mark - UIButton Handler
- (IBAction)assistanceViewButton:(id)sender {
    HelperViewController *helpVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"HelperView"];
    [self presentViewController:helpVC animated:YES completion:nil];
}

- (IBAction)viewSavedLocations:(id)sender {
    [self checkFirstResponder];
    [self performSegueWithIdentifier:@"bookmarkedLocations" sender:self];
}


#pragma mark - Custom Methods
/**
 Retrieve Current Weather Details for a given Location
 
 @param location - Location Details
 */
-(void)fetchWeatherForLocation:(CLLocation *)location{
    [Server fetchCurrentDataForLocation:location.coordinate
                             completion:^(BOOL success, NSDictionary *dict, NSArray *array, NSString *str) {
                                 
                                 if (success) {
                                     Weather *weatherModel = [[Weather alloc] init];
                                     weatherModel.location = location.coordinate;
                                     weatherModel.city = [self checkIfValidString:[dict valueForKey:@"name"]];
                                     weatherModel.currentTemp = [self checkIfValidNumber:[[dict valueForKey:@"main"] valueForKey:@"temp"]];
                                     weatherModel.minTemp = [self checkIfValidNumber:[[dict valueForKey:@"main"] valueForKey:@"temp_min"]];
                                     weatherModel.maxTemp = [self checkIfValidNumber:[[dict valueForKey:@"main"] valueForKey:@"temp_max"]];
                                     weatherModel.weather = [self checkIfValidString:[[[dict valueForKey:@"weather"] objectAtIndex:0] valueForKey:@"description"]];
                                     weatherModel.time = [self checkIfValidNumber:[dict valueForKey:@"dt"]];
                                     weatherModel.icon = [self checkIfValidString:[[[dict valueForKey:@"weather"] objectAtIndex:0] valueForKey:@"icon"]];
                                     weatherModel.humidity = [self checkIfValidNumber:[[dict valueForKey:@"main"] valueForKey:@"humidity"]];
                                     weatherModel.pressure = [self checkIfValidNumber:[[dict valueForKey:@"main"] valueForKey:@"pressure"]];
                                     weatherModel.windSpeed = [self checkIfValidNumber:[[dict valueForKey:@"wind"] valueForKey:@"speed"]];
                                     [annotationDictionary setObject:weatherModel forKey:[NSValue valueWithMKCoordinate:location.coordinate]];
                                     [self addMarkerForWeather:weatherModel];
                                     [self addBookmarkToLocation:weatherModel.city coordinates:location];
                                 }else{
                                     //Error Handling
                                     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Error with request, Please try again" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                     [alert show];
                                 }
                             }];
    
}

/**
 Check validity of Server response

 @param checkString - Server Response
 @return - Valid string
 */
-(NSString *)checkIfValidString:(id)checkString{
    if ([checkString isKindOfClass:[NSString class]])
        return checkString;
    if ([checkString isKindOfClass:[NSNumber class]])
        return [NSString stringWithFormat:@"%@",checkString];
    return @"na";
}

-(float)checkIfValidNumber:(id)numCheck{
    if ([numCheck isKindOfClass:[NSNumber class]])
        return [numCheck floatValue];
    return 0.0;
}





/**
 Add custom marker to mapview with weather details
 
 @param locationWeather custom details for weather object
 */
-(void)addMarkerForWeather:(Weather *) locationWeather{
    CustomAnnotation *annotationItem = [[CustomAnnotation alloc] init];
    annotationItem.locationDetails = locationWeather;
    annotationItem.coordinate = locationWeather.location;
    [self.mapView addAnnotation:annotationItem];
}

/**
 Check if Searchbar is the first responder
 */
-(void)checkFirstResponder{
    if ([self.searchbar isFirstResponder]){
        [self.searchbar resignFirstResponder];
    }
}

/**
 Handle Longpress on Map
 
 @param gestureRecognizer - Long press Gesture on the Map
 */
- (void)handleLongPress:(UIGestureRecognizer *)gestureRecognizer
{
    __weak typeof(self) weakSelf = self;
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan)
        return;
    
    CGPoint touchPoint = [gestureRecognizer locationInView:weakSelf.mapView];
    CLLocationCoordinate2D touchMapCoordinate = [weakSelf.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
    CLLocation *location = [[CLLocation alloc] initWithLatitude:touchMapCoordinate.latitude longitude:touchMapCoordinate.longitude];
    [weakSelf reverseGeocode:location];
}


/**
 Reverse Geocode Location
 
 @param location - Details of location to be searched
 */
- (void)reverseGeocode:(CLLocation *)location {
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:location
                   completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
                       if (error == nil) {
                           CLPlacemark *placemark = [placemarks objectAtIndex:0];
                           if (placemark.addressDictionary[@"City"]) {
                               [self addAnnotationToLocation:placemark.addressDictionary[@"City"] coordinates:location];
                           }else{
                               [self addAnnotationToLocation:placemark.addressDictionary[@"Name"] coordinates:location];
                           }
                       }else{
                           NSLog(@"Encountered error with reverse geocoding");
                       }
                   }];
}

/**
 Search location with string
 
 @param string - Location Name
 */
-(void)gecodeSearchString:(NSString *)string{
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    //Activity indicator
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    indicator.frame = CGRectMake(0.0, 0.0, 40.0, 40.0);
    indicator.center = self.view.center;
    indicator.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2];
    indicator.layer.cornerRadius = 5;
    [self.view addSubview:indicator];
    [indicator bringSubviewToFront:self.view];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = TRUE;
    [indicator startAnimating];
    
    
    [geocoder geocodeAddressString:string
                 completionHandler:^(NSArray* placemarks, NSError* error){
                     [indicator stopAnimating];
                     if (placemarks && placemarks.count > 0) {
                         [self checkFirstResponder];
                         CLPlacemark *topResult = [placemarks objectAtIndex:0];
                         MKPlacemark *placemark = [[MKPlacemark alloc] initWithPlacemark:topResult];
                         
                         MKCoordinateRegion region = self.mapView.region;
                         region.center = [(CLCircularRegion *)placemark.region center];
                         region.span.longitudeDelta = 8.0;
                         region.span.latitudeDelta = 8.0;
                         [self.searchbar setText:@""];
                         [self.mapView setRegion:region animated:YES];
                         
                         //Check if location Already exists
                         for (MKPointAnnotation *annotation in self.mapView.annotations) {
                             if ((annotation.coordinate.latitude == placemark.location.coordinate.latitude) && (annotation.coordinate.longitude == placemark.location.coordinate.longitude)) {
                                 return;
                             }
                         }
                         [self addAnnotationToLocation:placemark.addressDictionary[@"Name"] coordinates:placemark.location];
                     }else{
                         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"Cannot locate %@ on the map",string] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                         [alert show];
                     }
                 }
     
     ];
}


/**
 Promt User to add location to bookmark
 
 @param location - Location Name
 @param locationCoordinate - Location Coordinate
 */
-(void)addAnnotationToLocation:(NSString *) location coordinates:(CLLocation *)locationCoordinate{
    __weak typeof(self) weakSelf = self;
    UIAlertController* alert = [UIAlertController
                                alertControllerWithTitle:@"Add To Bookmark"
                                message:[NSString stringWithFormat:@"Do you want to add %@ to the saved Locations",location]
                                preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* button0 = [UIAlertAction
                              actionWithTitle:@"Cancel"
                              style:UIAlertActionStyleCancel
                              handler:nil];
    
    UIAlertAction* addAction = [UIAlertAction
                                actionWithTitle:@"ADD"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action)
                                {
                                    [weakSelf fetchWeatherForLocation:locationCoordinate];
                                }];
    
    [alert addAction:button0];
    [alert addAction:addAction];
    [alert setModalPresentationStyle:UIModalPresentationPopover];
    [self presentViewController:alert animated:YES completion:nil];
    
}

/**
 Handle Display and removal of keyboard from the screen
 
 @param notification Notification Object
 */
- (void)keyboardWillChange:(NSNotification *)notification{
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    int height = MIN(keyboardSize.height,keyboardSize.width);
    if (notification.name == UIKeyboardWillHideNotification) {
        self.searchbarBottomDistanceFromMargin.constant = 25;
        self.bookmarkButtonBottomDistanceFromMargin.constant = 20;
    }else{
        self.searchbarBottomDistanceFromMargin.constant = height + 15;
        self.bookmarkButtonBottomDistanceFromMargin.constant = height + 10;
    }
}


-(void)refreshBookmarkedAnnotation{
    //Check Presaved Bookmarks
    __weak typeof(self) weakSelf = self;
    NSDictionary *savedLocations = [[NSDictionary alloc] init];
    [weakSelf.mapView removeAnnotations:weakSelf.mapView.annotations];
    [annotationDictionary removeAllObjects];
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kBookmarkedLocatons] != nil) {
        savedLocations = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:kBookmarkedLocatons]];
        for (CLLocation *location in [savedLocations allValues]) {
            [weakSelf fetchWeatherForLocation:location];
        }
    }else{
        self.bookmarkButtonWidth.constant = 0;
        self.bookmarkButtonLeading.constant = 0;
        [self.bookmarkButton setHidden:YES];
    }
}


-(CLLocation *)locationFromCoordinatesLatitude:(float)lat longatitude:(float)lon{
    CLLocation *location = [[CLLocation alloc] initWithLatitude:lat longitude:lon];
    return location;
}

/**
 Add location to be saved in the bookmark
 
 @param location - Details of the location to be bookmarked
 */
-(void)addBookmarkToLocation:(NSString *)location coordinates:(CLLocation *)coordinates{
    NSMutableDictionary *savedLocations = [[NSMutableDictionary alloc] init];
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kBookmarkedLocatons] != nil) {
        savedLocations = [[NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:kBookmarkedLocatons]] mutableCopy];
        if (![[savedLocations allKeys] containsObject:location]) {
            [savedLocations setObject:coordinates forKey:location];
        }
        [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:savedLocations] forKey:kBookmarkedLocatons];
    }else{
        self.bookmarkButtonWidth.constant = 40;
        self.bookmarkButtonLeading.constant = 8;
        [self.bookmarkButton setHidden:NO];
        [savedLocations setObject:coordinates forKey:location];
        [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:savedLocations] forKey:kBookmarkedLocatons];
    }
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"bookmarkedLocations"])
    {
        LocationsViewController *vc = [[[segue destinationViewController] childViewControllers] firstObject];
        [vc setListObject:[[annotationDictionary allValues] mutableCopy]];
    }
}

@end
