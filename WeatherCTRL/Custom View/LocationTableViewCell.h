//
//  LocationTableViewCell.h
//  Weather
//
//  Created by Vishnu Deep Samikeri on 2/10/18.
//  Copyright © 2018 Vishnu Deep Samikeri. All rights reserved.

#import <UIKit/UIKit.h>

@interface LocationTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *locationName;
@property (weak, nonatomic) IBOutlet UILabel *locationWeather;
@property (weak, nonatomic) IBOutlet UILabel *locationTemperatureRange;
@property (weak, nonatomic) IBOutlet UILabel *locationCurrentTemperature;
@property (weak, nonatomic) IBOutlet UIImageView *locationWeatherImage;

@end
