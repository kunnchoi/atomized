//
//  ViewController.m
//  Atomized
//
//  Created by Andrew Choi on 4/14/14.
//  Copyright (c) 2014 Andrew Choi. All rights reserved.
//

#import "ViewController.h"
#import "Reachability.h"

@interface ViewController ()


@end

@implementation ViewController
@synthesize _connectedToInternet = connectedToInternet;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onInternetConnectivityChanged:) name:kReachabilityChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterForeground:) name:@"applicationWillEnterForeground" object:nil];

    [self initApp];

}

- (void)enterForeground:(NSNotification *)notification
{
    BOOL reload = !connectedToInternet;

    if([self updateInternetConnectivityStatus] && reload)
    {
        [self initApp];
        return;
    }
    if(![self updateInternetConnectivityStatus])
        return;
}

- (void)initApp
{
    // Check for internet connection
    if(![self updateInternetConnectivityStatus])
        return;
    
    // Do any additional setup after loading the view, typically from a nib.
    NSString* url = @"http://app.atomized.com";
    NSURL* nsUrl = [NSURL URLWithString:url];
    NSURLRequest* request = [NSURLRequest requestWithURL:nsUrl cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:30];
    [self.mWebView loadRequest:request];
}

- (void)onInternetConnectivityChanged:(NSNotification *)notification
{
    [self updateInternetConnectivityStatus];
}

- (BOOL)updateInternetConnectivityStatus
{
    // Check for internet connection
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus internetStatus = [reachability currentReachabilityStatus];
    if (internetStatus != NotReachable)
    {
        connectedToInternet = YES;
    }
    else
    {
        connectedToInternet = NO;
        [self loadErrorView];
    }
    return connectedToInternet;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) loadErrorView
{
    NSString *errorHTMLPath = [[NSBundle mainBundle] pathForResource:@"offline" ofType:@"html"];
    __block NSData *htmlData = [NSData dataWithContentsOfFile:errorHTMLPath];
    [self.mWebView loadData:htmlData MIMEType:@"text/html" textEncodingName:@"UTF-8" baseURL:[NSURL URLWithString:@""]];
}

@end
