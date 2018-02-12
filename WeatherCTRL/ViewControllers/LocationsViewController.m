//
//  LocationsViewController.m
//  Weather
//
//  Created by Vishnu Deep Samikeri on 2/10/18.
//  Copyright © 2018 Vishnu Deep Samikeri. All rights reserved.
#import "LocationsViewController.h"

@interface LocationsViewController ()

@end

@implementation LocationsViewController{
    NSString *temperatureSuffix;
    NSMutableArray *searchResults;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Multiple editing not allowed
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    
    //Search Bar Delegate
    [self.searchbar setDelegate:self];
    
    //Check Unit type
    [self checkUnitType];
    
    //Setup back Button for navication controller
    [self setupDismissButton];
}

-(void)viewDidAppear:(BOOL)animated{
    //Dismiss an empty view
    [self dismissEmptyView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.searchbar.text.length != 0)
        return searchResults.count;
    if (self.listObject.count != 0)
        return self.listObject.count;
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LocationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"bookmark" forIndexPath:indexPath];
    
    Weather *localWeatherObject;
    if (searchResults.count != 0) {
     localWeatherObject = (Weather *)[searchResults objectAtIndex:indexPath.row];
    }else{
     localWeatherObject = (Weather *)[self.listObject objectAtIndex:indexPath.row];
    }
    
    cell.locationName.text = localWeatherObject.city;
    cell.locationWeather.text = [localWeatherObject.weather capitalizedString];
    cell.locationWeatherImage.image = [UIImage imageNamed:localWeatherObject.icon];
    cell.locationCurrentTemperature.text = [NSString stringWithFormat:@"%0.2f %@",localWeatherObject.currentTemp,temperatureSuffix];
    cell.locationTemperatureRange.text =  [NSString stringWithFormat:@"Min/Max: %0.2f %@/%0.2f %@",localWeatherObject.minTemp,temperatureSuffix,localWeatherObject.maxTemp,temperatureSuffix];
    return cell;
}

#pragma mark - Table view Delegate
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if ([self.searchbar isFirstResponder]) {
        [self.searchbar resignFirstResponder];
    }
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Weather *removeObject;
        if (searchResults != 0) {
            removeObject = [searchResults objectAtIndex:indexPath.row];
        }else{
            removeObject = [self.listObject objectAtIndex:indexPath.row];
        }
        UIAlertController* alert = [UIAlertController
                                    alertControllerWithTitle:@"Delete Bookmark"
                                    message:[NSString stringWithFormat:@"Do you want to delete %@ from Saved Locations",removeObject.city]
                                    preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* button0 = [UIAlertAction
                                  actionWithTitle:@"Cancel"
                                  style:UIAlertActionStyleCancel
                                  handler:^(UIAlertAction * action)
                                  {
                                      tableView.editing = NO;
                                  }];
        
        UIAlertAction* addAction = [UIAlertAction
                                    actionWithTitle:@"DELETE"
                                    style:UIAlertActionStyleDestructive
                                    handler:^(UIAlertAction * action)
                                    {
                                        
                                        [self removeBookmarkedLocation:removeObject.city];
                                        [self.listObject removeObject:removeObject];
                                        if (searchResults != 0) {
                                            [searchResults removeObject:removeObject];
                                        }
                                        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                                        [self dismissEmptyView];
                                    }];
        
        [alert addAction:button0];
        [alert addAction:addAction];
        [alert setModalPresentationStyle:UIModalPresentationPopover];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    CityViewController *cityVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"CityViewController"];
    cityVC.currentWeatherObject = (Weather *)[self.listObject objectAtIndex:indexPath.row];
    [self presentViewController:cityVC animated:YES completion:nil];
    
}



#pragma mark - Searchbar Delegate

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"city contains[cd] %@", searchText];
    searchResults = [[self.listObject filteredArrayUsingPredicate:resultPredicate] mutableCopy];
    [self.tableView reloadData];
}

-(BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    [searchBar setShowsCancelButton:YES];
    return YES;
}

-(BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar{
    if (searchBar.text.length == 0) {
        [searchBar setShowsCancelButton:NO];
    }
    return YES;
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    searchBar.text = @"";
    searchResults = nil;
    [searchBar resignFirstResponder];
    [self.tableView reloadData];
}


#pragma mark - Custom Methods
/**
 Remove a saved bookmark
 
 @param location - Details of the bookmark to be removed
 */
-(void)removeBookmarkedLocation:(NSString *)location{
    NSMutableDictionary *savedLocations = [[NSMutableDictionary alloc] init];
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kBookmarkedLocatons] != nil) {
        savedLocations = [[NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:kBookmarkedLocatons]] mutableCopy];
        if ([[savedLocations allKeys] containsObject:location]) {
            [savedLocations removeObjectForKey:location];
        }
        if ([savedLocations count] > 0) {
            [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:savedLocations] forKey:kBookmarkedLocatons];
        }else{
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:kBookmarkedLocatons];
        }
    }
    return;
}


/**
 Check units to be displayed
 */
-(void)checkUnitType{
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:kUnitType] isEqualToString:@"metric"]) {
        temperatureSuffix = @"°C";
    }else{
        temperatureSuffix = @"°F";
    }
}


/**
 Load Custom Back button in Navigation Bar
 */
-(void)setupDismissButton{
    UIImage *dismissButtonImage = [UIImage imageNamed:@"dismiss"];
    CGRect dismissButtonFrame = CGRectMake(0, 0, 30, 30);
    UIButton *dismissButton = [[UIButton alloc] initWithFrame:dismissButtonFrame];
    [dismissButton setImage:dismissButtonImage forState:UIControlStateNormal];
    [dismissButton addTarget:self action:@selector(dismissView:) forControlEvents:UIControlEventTouchUpInside];
    [dismissButton setShowsTouchWhenHighlighted:YES];
    if (@available(iOS 9.0, *)) {
        [[dismissButton.widthAnchor constraintEqualToConstant:30] setActive:YES];
        [[dismissButton.heightAnchor constraintEqualToConstant:30] setActive:YES];
    }
    UIBarButtonItem *navBarDismiss = [[UIBarButtonItem alloc] initWithCustomView:dismissButton];
    self.navigationItem.rightBarButtonItem = navBarDismiss;
}



/**
 Dismiss View if List is empty
 */
-(void)dismissEmptyView{
    if (self.listObject.count == 0) {
        [self dismissView:nil];
    }
}

/**
 Dismiss View
 
 @param sender - Sender
 */
-(void)dismissView:(id)sender{
    [self.listObject removeAllObjects];
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
