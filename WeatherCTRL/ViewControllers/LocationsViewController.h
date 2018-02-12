//
//  LocationsViewController.h
//  Weather
//
//  Created by Vishnu Deep Samikeri on 2/10/18.
//  Copyright © 2018 Vishnu Deep Samikeri. All rights reserved.

#import <UIKit/UIKit.h>
#import "LocationTableViewCell.h"
#import "CityViewController.h"
#import "Weather.h"

@interface LocationsViewController : UITableViewController <UISearchBarDelegate>

@property (strong,nonatomic) NSMutableArray *listObject;
@property (strong, nonatomic) IBOutlet UISearchBar *searchbar;

@end
