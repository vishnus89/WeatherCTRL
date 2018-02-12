//
//  HelperViewController.m
//  Weather
//
//  Created by Vishnu Deep Samikeri on 2/10/18.
//  Copyright © 2018 Vishnu Deep Samikeri. All rights reserved.

#import "HelperViewController.h"

@interface HelperViewController ()

@property (strong, nonatomic) NSString *helpURL;

@end

@implementation HelperViewController{
    WKWebView *webView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //Notification Handler for rotation of Device
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setupConstrains) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    //Set WebView
    [self setupWebView];
    
    //Set Back button
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style: UIBarButtonItemStylePlain target:self action:@selector(dismissView:)];
    self.navigationItem.leftBarButtonItem = backButton;
    
    [self setupConstrains];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}
-(void)setupWebView{
    self.helpURL = @"https://github.com/dayalprem/Weather/blob/master/README.md";
    NSURL *url = [NSURL URLWithString:self.helpURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    webView = [[WKWebView alloc]init] ;
    webView.UIDelegate = self;
    webView.navigationDelegate = self;
    [webView loadRequest:request];
    [self.view addSubview:webView];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = TRUE;
 }
-(void)setupConstrains{
    [webView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    NSLayoutConstraint *top = [NSLayoutConstraint
                               constraintWithItem:webView
                               attribute:NSLayoutAttributeTop
                               relatedBy:NSLayoutRelationEqual
                               toItem:self.view
                               attribute:NSLayoutAttributeTop
                               multiplier:1.0f
                               constant:0.0f];
    NSLayoutConstraint *bottom = [NSLayoutConstraint
                               constraintWithItem:webView
                               attribute:NSLayoutAttributeTop
                               relatedBy:NSLayoutRelationEqual
                               toItem:self.view
                               attribute:NSLayoutAttributeTop
                               multiplier:1.0f
                               constant:0.0f];
    
    NSLayoutConstraint *leading = [NSLayoutConstraint
                                   constraintWithItem:webView
                                   attribute:NSLayoutAttributeLeading
                                   relatedBy:NSLayoutRelationEqual
                                   toItem:self.view
                                   attribute:NSLayoutAttributeLeading
                                   multiplier:1.0f
                                   constant:0.0f];
    NSLayoutConstraint *trailing = [NSLayoutConstraint
                                   constraintWithItem:webView
                                   attribute:NSLayoutAttributeLeading
                                   relatedBy:NSLayoutRelationEqual
                                   toItem:self.view
                                   attribute:NSLayoutAttributeLeading
                                   multiplier:1.0f
                                   constant:0.0f];
    [self.view addConstraints:@[leading,trailing,top,bottom]];
    [self.view layoutSubviews];
}
-(void)dismissView:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
