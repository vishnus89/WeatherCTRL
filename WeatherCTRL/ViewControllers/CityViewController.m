//
//  CityViewController.m
//  Weather
//
//  Created by Vishnu Deep Samikeri on 2/10/18.
//  Copyright © 2018 Vishnu Deep Samikeri. All rights reserved.

#import "CityViewController.h"

@interface CityViewController ()

@end

@implementation CityViewController{
    NSString *windSuffix;
    NSString *temperatureSuffix;
    NSMutableArray *forecastData;
}

- (void)viewDidLoad {
    forecastData = [[NSMutableArray alloc] init];
    [super viewDidLoad];
    //Adjust Header View for Old iPhones
    if (self.view.frame.size.width < 375) {
        
        NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self.headerView
                                                                      attribute:NSLayoutAttributeHeight
                                                                      relatedBy:0
                                                                         toItem:self.view
                                                                      attribute:NSLayoutAttributeHeight
                                                                     multiplier:.45
                                                                       constant:0];
        [self.view addConstraint:constraint];
        [self.view removeConstraint:self.headerViewHeight];
    }
    
    //Adjust Font for iPad
    if ([[[UIDevice currentDevice] model] containsString:@"iPad"]) {
        if (@available(iOS 8.2, *)) {
            [self.currentTemperature setFont:[UIFont systemFontOfSize:30 weight:UIFontWeightHeavy]];
        } else {
            [self.currentTemperature setFont:[UIFont systemFontOfSize:30]];
        }
    }
    
    //Notification handler to check if defaults changed
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(defaultsChanged:) name:NSUserDefaultsDidChangeNotification object:nil];
    
    //Add swipe gesture to header view to dismiss view
    UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeHandler:)];
    [swipeGesture setDirection:UISwipeGestureRecognizerDirectionDown];
    [self.headerView addGestureRecognizer:swipeGesture];
    
    //Load defaults
    [self checkUnitType];
    [self setHeaderViewConstants];
    [self fetchForecastDataForLocation:self.currentWeatherObject.location];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(BOOL)shouldAutorotate{
    if ([[[UIDevice currentDevice] model] containsString:@"iPad"]) {
        return YES;
    }
    return NO;
}


#pragma mark - Collection View Delegate and Data source
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if ([forecastData isKindOfClass:[NSNull class]]) {
        return 0;
    }
    return [forecastData count];
}



-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                 cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    ForecastViewCell *cell = (ForecastViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"forecastCell" forIndexPath:indexPath];
    __weak Weather *dayData = [forecastData objectAtIndex:indexPath.row];
    
    NSDateFormatter* hourFormatter = [[NSDateFormatter alloc] init];
    NSDateFormatter* dayFormatter = [[NSDateFormatter alloc] init];
    hourFormatter.dateFormat = @"HH:mm:ss";
    dayFormatter.dateFormat = @"EEEE";
    cell.forecastCondition.text = [dayData.weather capitalizedString];
    cell.forecastCurrent.text = [NSString stringWithFormat:@"%0.2f %@",dayData.currentTemp,temperatureSuffix];
    cell.forecastWindSpeed.text = [NSString stringWithFormat:@"Windspeed: %0.2f %@",dayData.windSpeed,windSuffix];
    cell.forecastHumidity.text = [NSString stringWithFormat:@"Humidity: %0.2f %%",dayData.humidity];
    cell.forecastPressure.text = [NSString stringWithFormat:@"Pressure: %0.2f mb",dayData.pressure];
    cell.forecastDay.text = [dayFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:dayData.time]];
    cell.forecastTime.text = [hourFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:dayData.time]];
    cell.forecastimage.image = [UIImage imageNamed:dayData.icon];
    cell.forecastTemperatureRange.text = [NSString stringWithFormat:@"Min/Max: %0.2f/%0.2f %@",dayData.minTemp,dayData.maxTemp,temperatureSuffix];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    if ([[[UIDevice currentDevice] model] containsString:@"iPad"]) {
    return CGSizeMake(195, collectionView.frame.size.height*0.66);
    }
    return CGSizeMake( 195, 260);
}

/**
 Fetch forecast details of given Location
 
 @param location - Location Coordinates
 */
-(void)fetchForecastDataForLocation:(CLLocationCoordinate2D )location{
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
    
    [Server fetchWeeklyDataForLocation:location
                            completion:^(BOOL success, NSDictionary *dict, NSArray *array, NSString *str) {
                                [indicator stopAnimating];
                                if (success) {
                                    for (NSDictionary *weatherData in dict[@"list"]) {
                                        Weather *forecastModel = [[Weather alloc] init];
                                        forecastModel.location = location;
                                        forecastModel.currentTemp = [self checkIfValidNumber:[[weatherData valueForKey:@"main"] valueForKey:@"temp"]];
                                        forecastModel.minTemp = [self checkIfValidNumber:[[weatherData valueForKey:@"main"] valueForKey:@"temp_min"]];
                                        forecastModel.maxTemp = [self checkIfValidNumber:[[weatherData valueForKey:@"main"] valueForKey:@"temp_max"]];
                                        forecastModel.weather = [self checkIfValidString:[[[weatherData valueForKey:@"weather"] objectAtIndex:0] valueForKey:@"description"]];
                                        forecastModel.time = [self checkIfValidNumber:[weatherData valueForKey:@"dt"]];
                                        forecastModel.icon = [self checkIfValidString:[[[weatherData valueForKey:@"weather"] objectAtIndex:0] valueForKey:@"icon"]];
                                        forecastModel.humidity = [self checkIfValidNumber:[[weatherData valueForKey:@"main"] valueForKey:@"humidity"]];
                                        forecastModel.pressure = [self checkIfValidNumber:[[weatherData valueForKey:@"main"] valueForKey:@"pressure"]];
                                        forecastModel.windSpeed = [self checkIfValidNumber:[[weatherData valueForKey:@"wind"] valueForKey:@"speed"]];
                                        [forecastData addObject:forecastModel];
                                    }
                                    [self.forecastCollectionView reloadData];
                                }else{
                                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Error with request, Please try again" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                    [alert show];
                                }
                            }];
}

/**
 Check validity of String
 
 @param checkString - Server Response string
 @return - Valid string
 */
-(NSString *)checkIfValidString:(id)checkString{
    if ([checkString isKindOfClass:[NSString class]])
        return checkString;
    if ([checkString isKindOfClass:[NSNumber class]])
        return [NSString stringWithFormat:@"%@",checkString];
    return @"na";
}

/**
 Check validity of number
 
 @param numCheck - Server Response float
 @return - Float Value
 */
-(float)checkIfValidNumber:(id)numCheck{
    if ([numCheck isKindOfClass:[NSNumber class]])
        return [numCheck floatValue];
    return 0.0;
}


/**
 Check default Unit system being used in the app
 */
-(void)checkUnitType{
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:kUnitType] isEqualToString:@"metric"]) {
        windSuffix = @"km/h";
        temperatureSuffix = @"°C";
    }else{
        windSuffix = @"mph";
        temperatureSuffix = @"°F";
    }
}

/**
 Setup Header View
 */
-(void)setHeaderViewConstants{
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    __weak typeof(self) weakSelf = self;
    self.locationName.text = weakSelf.currentWeatherObject.city;
    self.weatherCondition.text = [weakSelf.currentWeatherObject.weather capitalizedString];
    self.currentTemperature.text = [NSString stringWithFormat:@"%0.2f %@",weakSelf.currentWeatherObject.currentTemp,temperatureSuffix];
    self.windspeed.text = [NSString stringWithFormat:@"Windspeed: %0.2f %@",weakSelf.currentWeatherObject.windSpeed,windSuffix];
    self.humidity.text = [NSString stringWithFormat:@"Humidity: %0.2f %%",weakSelf.currentWeatherObject.humidity];
    self.pressure.text = [NSString stringWithFormat:@"Pressure: %0.2f mb",weakSelf.currentWeatherObject.pressure];
    self.lastUpdate.text = [NSString stringWithFormat:@"Last Updated: %@",[dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:weakSelf.currentWeatherObject.time]]];
    self.weatherIcon.image = [UIImage imageNamed:self.currentWeatherObject.icon];
    self.temperatureRange.text = [NSString stringWithFormat:@"Min/Max: %0.2f %@/%0.2f %@",weakSelf.currentWeatherObject.minTemp,temperatureSuffix,weakSelf.currentWeatherObject.maxTemp,temperatureSuffix];
}

/**
 Swipe Handler for Header View

 @param gesture - Gesture being sent
 */
-(void)swipeHandler:(UIGestureRecognizer *)gesture{
    [self dismissViewControllerAnimated:YES completion:nil];
}

/**
 Handle change in UserDefaults

 @param notification - Notification Sender
 */
-(void)defaultsChanged:(NSNotification *)notification{
    [self checkUnitType];
    [forecastData removeAllObjects];
    [self fetchForecastDataForLocation:self.currentWeatherObject.location];
    [self setHeaderViewConstants];
}

@end
