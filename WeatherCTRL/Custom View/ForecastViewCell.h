//
//  ForecastViewCell.h
//  Weather
//
//  Created by Vishnu Deep Samikeri on 2/10/18.
//  Copyright © 2018 Vishnu Deep Samikeri. All rights reserved.

#import <UIKit/UIKit.h>

@interface ForecastViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *forecastDay;
@property (weak, nonatomic) IBOutlet UILabel *forecastTime;
@property (weak, nonatomic) IBOutlet UILabel *forecastCondition;
@property (weak, nonatomic) IBOutlet UIImageView *forecastimage;
@property (weak, nonatomic) IBOutlet UILabel *forecastCurrent;
@property (weak, nonatomic) IBOutlet UILabel *forecastTemperatureRange;
@property (weak, nonatomic) IBOutlet UILabel *forecastHumidity;
@property (weak, nonatomic) IBOutlet UILabel *forecastWindSpeed;
@property (weak, nonatomic) IBOutlet UILabel *forecastPressure;

@end
