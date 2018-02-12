//
//  Server.m
//  Weather
//
//  Created by Vishnu Deep Samikeri on 2/10/18.
//  Copyright © 2018 Vishnu Deep Samikeri. All rights reserved.

#import "Server.h"

@implementation Server

/**
 Server Request for fetching current weather for a given location
 
 @param location - Location details
 @param completion - Return for completion of Request
 */
+(void)fetchWeeklyDataForLocation:(CLLocationCoordinate2D)location
                       completion: (JSONcompletion) completion{
    __weak typeof(self) weakSelf = self;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = TRUE;
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@",kServerURL,kforecastEndpoint,[weakSelf makeParamDictionaryWithLocation:location]];
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    [[session dataTaskWithRequest:request
                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                    
                    BOOL success = YES;
                    //Connectivity related error handling
                    if (error) {
                        NSLog(@"Error with data task: %@", error);
                        success = NO;
                        
                    }
                    
                    //HTTP error status handling
                    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                        
                        NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
                        
                        if (statusCode > 250) {
                            NSLog(@"HTTP request error status code: %ld", (long)statusCode);
                            success = NO;
                        }
                    }
                    
                    //Parsing data
                    NSDictionary *dict;
                    id json = [NSJSONSerialization JSONObjectWithData:data
                                                              options:NSJSONReadingAllowFragments
                                                                error:NULL];
                    if ([json isKindOfClass:[NSDictionary class]])
                        dict = (NSDictionary *)json;
                    
                    
                    
                    
                    //PROCESS DATA RETRIEVED
                    [self processServerData:data
                                    success:success
                                 statusCode:((NSHTTPURLResponse *)response).statusCode
                                 completion:completion];
                }] resume];
}

/**
 Server Request for fetching current weather for a given location
 
 @param location - Location details
 @param completion - Return for completion of Request
 */
+(void)fetchCurrentDataForLocation:(CLLocationCoordinate2D)location
                        completion: (JSONcompletion) completion{
    __weak typeof(self) weakSelf = self;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = TRUE;
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@",kServerURL,kCurrentEndpoint,[weakSelf makeParamDictionaryWithLocation:location]];
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    [[session dataTaskWithRequest:request
                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                    
                    BOOL success = YES;
                    //Connectivity related error handling
                    if (error) {
                        NSLog(@"Error with data task: %@", error);
                        success = NO;
                        
                    }
                    
                    //HTTP error status handling
                    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                        
                        NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
                        
                        if (statusCode > 250) {
                            NSLog(@"HTTP request error status code: %ld", (long)statusCode);
                            success = NO;
                        }
                    }
                    
                    //Parsing data
                    NSDictionary *dict;
                    id json = [NSJSONSerialization JSONObjectWithData:data
                                                              options:NSJSONReadingAllowFragments
                                                                error:NULL];
                    if ([json isKindOfClass:[NSDictionary class]])
                        dict = (NSDictionary *)json;
                    
                    
                    
                    
                    //PROCESS DATA RETRIEVED
                    [self processServerData:data
                                    success:success
                                 statusCode:((NSHTTPURLResponse *)response).statusCode
                                 completion:completion];
                }] resume];
}


/**
 Make Request Parameters
 
 @param location - Location of the requested Parameters
 @return - Parameters as a string format
 */
+(NSString *)makeParamDictionaryWithLocation:(CLLocationCoordinate2D )location{
    __weak typeof(self) weakSelf = self;
    NSDictionary *params = @{
                             @"lat":[NSString stringWithFormat:@"%f",location.latitude],
                             @"lon":[NSString stringWithFormat:@"%f",location.longitude],
                             @"appid":kAPIKey,
                             @"units":[[NSUserDefaults standardUserDefaults] objectForKey:kUnitType]
                             };
    return [weakSelf serializeParams:params];
}



/**
 Serialise Request Parameters Dictionay
 
 @param params - Parameter Dictionay
 @return - Parameters in String format
 */
+(NSString *)serializeParams:(NSDictionary *)params{
    if (!params) return @"";
    
    //Add % encoding for each param:
    NSMutableCharacterSet *encodingSet = [[NSCharacterSet URLQueryAllowedCharacterSet] mutableCopy];
    NSCharacterSet *set = [NSCharacterSet URLHostAllowedCharacterSet];
    [encodingSet removeCharactersInRange: NSMakeRange('+', 1)];
    
    
    NSMutableArray *pairs = NSMutableArray.array;
    for (NSString *key in params.keyEnumerator) {
        id value = params[key];
        if ([value isKindOfClass:[NSDictionary class]])
            for (NSString *subKey in value)
                [pairs addObject:[NSString stringWithFormat:@"%@[%@]=%@", key, subKey,[value objectForKey:subKey]]];
        
        else if ([value isKindOfClass:[NSArray class]]) {
            //PYTHON STYLE:
            NSString *arrayStr = @"";
            int i = 0;
            for (id subValue in value) {
                id encodedSubValue = subValue;
                if ([subValue respondsToSelector:
                     @selector(stringByAddingPercentEscapesUsingEncoding:)]) {
                    encodedSubValue =
                    [subValue stringByAddingPercentEncodingWithAllowedCharacters:set];
                }
                if (i==0)
                    arrayStr = [NSString stringWithFormat:@"%@",encodedSubValue];
                else
                    arrayStr = [NSString stringWithFormat:@"%@|%@",arrayStr,encodedSubValue];
                
                [pairs addObject:[NSString stringWithFormat:@"%@=%@", key, arrayStr]];
            }
            
            
        }else {
            if ([value respondsToSelector:@selector(stringByAddingPercentEscapesUsingEncoding:)]) {
                value = [value stringByAddingPercentEncodingWithAllowedCharacters:set];
            }
            
            
            [pairs addObject:[NSString stringWithFormat:@"%@=%@", key, value]];
        }
    }
    return [NSString stringWithFormat:@"?%@",[pairs componentsJoinedByString:@"&"]];
}

/**
 Parse response data or error
 
 @param data - Response data
 @param success - Check if request was succesful
 @param statusCode - Response code of Request
 @param completion - Return Completion Object
 */
+ (void) processServerData: (NSData *) data
                   success: (BOOL) success
                statusCode: (NSInteger) statusCode
                completion: (JSONcompletion)completion {
    NSDictionary *dict;
    NSArray *array;
    NSString *str;
    if (success && completion) {
    }
    else {
        str = [NSString stringWithFormat:@"%ld", (long)statusCode];
    }
    
    if (data.length > 0) {
        id json = [NSJSONSerialization JSONObjectWithData:data
                                                  options:NSJSONReadingAllowFragments
                                                    error:NULL];
        if ([json isKindOfClass:[NSDictionary class]])
            dict = (NSDictionary *)json;
        else if ([json isKindOfClass:[NSArray class]])
            array = (NSArray *)json;
        else if ([json isKindOfClass:[NSString class]])
            str = (NSString *)json;
    }
    
    if (completion){
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(success,dict,array,str);
            [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
        });
    }
}

@end
