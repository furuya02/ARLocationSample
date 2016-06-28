//
//  ViewController.m
//  ARLocationSample
//
//  Created by hirauchi.shinichi on 2016/06/27.
//  Copyright © 2016年 SAPPOROWORKS. All rights reserved.
//

#import "ViewController.h"
#import <WikitudeSDK/WikitudeSDK.h>
#import "SecretKey.h" // ライセンスーにキー情報が含まれているためGithubでは公開されておりません。
@import GoogleMaps;

@interface ViewController ()<WTArchitectViewDelegate>


@property (weak, nonatomic) IBOutlet WTArchitectView *architectView;
@property (nonatomic, weak) WTNavigation *architectWorldNavigation;
@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) GMSPlacesClient *placesClient; // Google Place API

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];




    if (nil == self.locationManager) {
        self.locationManager = [[CLLocationManager alloc] init];
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
            [ self.locationManager requestWhenInUseAuthorization];
        }
    }

    NSError *deviceSupportError = nil;
    if ( [WTArchitectView isDeviceSupportedForRequiredFeatures:WTFeature_2DTracking error:&deviceSupportError] ) {
        self.architectView.delegate = self;
        [self.architectView setLicenseKey:WT_LICENSE_KEY];
        self.architectWorldNavigation = [self.architectView loadArchitectWorldFromURL:[[NSBundle mainBundle] URLForResource:@"index" withExtension:@"html" subdirectory:@"ArchitectWorld"] withRequiredFeatures:WTFeature_Geo | WTFeature_2DTracking];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveApplicationWillResignActiveNotification:) name:UIApplicationWillResignActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveApplicationDidBecomeActiveNotification:) name:UIApplicationDidBecomeActiveNotification object:nil];

        self.architectView.translatesAutoresizingMaskIntoConstraints = NO;

        NSDictionary *views = NSDictionaryOfVariableBindings(_architectView);
        [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"|[_architectView]|" options:0 metrics:nil views:views] ];
        [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_architectView]|" options:0 metrics:nil views:views] ];
    }
    else {
        NSLog(@"This device is not supported. Show either an alert or use this class method even before presenting the view controller that manages the WTArchitectView. Error: %@", [deviceSupportError localizedDescription]);
    }


    // Google Place API
//    self.placesClient = [[GMSPlacesClient alloc] init];
//    [_placesClient currentPlaceWithCallback:^(GMSPlaceLikelihoodList *placeLikelihoodList, NSError *error){
//        if (error != nil) {
//            NSLog(@"Pick Place error %@", [error localizedDescription]);
//            return;
//        }
//
//        for ( GMSPlaceLikelihood *placeLikelihood in [placeLikelihoodList likelihoods])
//        {
//            float latitude = placeLikelihood.place.coordinate.latitude;
//            float longitude = placeLikelihood.place.coordinate.longitude;
//            NSLog(@"{ \"latitude\": %f, \"longitude\": %f, \"name\": \"%@\" },",latitude,longitude,placeLikelihood.place.name);
//        }
//    }];


}

#pragma mark - View Lifecycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self startWikitudeSDKRendering];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

    [self stopWikitudeSDKRendering];
}

#pragma mark - Private Methods

- (void)startWikitudeSDKRendering{
    if ( ![self.architectView isRunning] ) {
        [self.architectView start:^(WTStartupConfiguration *configuration) {
        } completion:^(BOOL isRunning, NSError *error) {
            if ( !isRunning ) {
                NSLog(@"WTArchitectView could not be started. Reason: %@", [error localizedDescription]);
            }
        }];
    }
}

- (void)stopWikitudeSDKRendering {
    if ( [self.architectView isRunning] ) {
        [self.architectView stop];
    }
}

#pragma mark - View Rotation
- (BOOL)shouldAutorotate {

    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {

    return UIInterfaceOrientationMaskAll;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {

    [self.architectView setShouldRotate:YES toInterfaceOrientation:toInterfaceOrientation];
}




#pragma mark - Notifications

- (void)didReceiveApplicationWillResignActiveNotification:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self stopWikitudeSDKRendering];
    });
}

- (void)didReceiveApplicationDidBecomeActiveNotification:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{

        if ( self.architectWorldNavigation.wasInterrupted )
        {
            [self.architectView reloadArchitectWorld];
        }
        [self startWikitudeSDKRendering];
    });
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
