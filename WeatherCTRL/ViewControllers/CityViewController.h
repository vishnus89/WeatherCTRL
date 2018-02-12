//
//  CityViewController.h
//  Weather
//
///  Created by Vishnu Deep Samikeri on 2/10/18.
//  Copyright © 2018 Vishnu Deep Samikeri. All rights reserved.

#import <UIKit/UIKit.h>
#import "Weather.h"
#import "ForecastViewCell.h"
#import "Server.h"

@interface CityViewController : UIViewController <UICollectionViewDelegate,UICollectionViewDataSource>

@property (strong, nonatomic) IBOutlet UIImageView *weatherIcon;
@property (weak, nonatomic) IBOutlet UILabel *locationName;
@property (weak, nonatomic) IBOutlet UILabel *weatherCondition;
@property (weak, nonatomic) IBOutlet UILabel *temperatureRange;
@property (weak, nonatomic) IBOutlet UILabel *currentTemperature;
@property (weak, nonatomic) IBOutlet UILabel *lastUpdate;
@property (weak, nonatomic) IBOutlet UILabel *humidity;
@property (weak, nonatomic) IBOutlet UILabel *windspeed;
@property (weak, nonatomic) IBOutlet UILabel *pressure;

@property (strong, nonatomic) Weather *currentWeatherObject;

@property (strong, nonatomic) IBOutlet UICollectionView *forecastCollectionView;
@property (strong, nonatomic) IBOutlet UIView *headerView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerViewHeight;



@end
