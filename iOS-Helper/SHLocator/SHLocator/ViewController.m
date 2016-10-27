//
//  ViewController.m
//  SHLocator
//
//  Created by Shaojun Han on 7/26/16.
//  Copyright © 2016 Hadlinks. All rights reserved.
//

#import "ViewController.h"
#import "SHLocator.h"

#import <objc/runtime.h>
#import <objc/message.h>

//@interface B : NSObject
//
//@end
//
//@implementation B
//
//+ (void)aaa {
//    NSLog(@"B.class.aaa");
//}
//
//@end

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    objc_msgSend(objc_getClass("B"), @selector(aaa));
    
    NSURL *URL;
    NSString *a;
    [a writeToURL:<#(nonnull NSURL *)#> atomically:<#(BOOL)#> encoding:<#(NSStringEncoding)#> error:<#(NSError * _Nullable __autoreleasing * _Nullable)#>]
    
    // Do any additional setup after loading the view, typically from a nib.
    static SHLocator *locator = nil;
    locator = [[SHLocator alloc] initWithDelegate:nil];
    
    // 东经82°21'30"，北纬44°50'34" 对应82.3583 44.8428
//    CLLocation *location = [[CLLocation alloc] initWithLatitude:44.8428 longitude:82.3583];
//    [locator reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> *placemarks, NSError *error) {
//        NSLog(@"locator.places = %@", placemarks);
//        CLPlacemark *place = [placemarks firstObject];
//        NSLog(@"locator.places.place = %@", place);
//        
//        NSLog(@"locator.places.place.city = %@", place.locality);
//        NSLog(@"locator.places.place.subCity = %@", place.subLocality);
//        NSLog(@"locator.places.place.capital = %@", place.administrativeArea);
//        NSLog(@"locator.places.place.subCapital = %@", place.subAdministrativeArea);
//    }];
    
    // 116.719 39.524
//    static SHLocator *locator = nil;
//    locator = [[SHLocator alloc] init];
    [locator reverseGeocodeLatitude:39.524 longitude:116.719 completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        CLPlacemark *mark = [placemarks firstObject];
        NSLog(@".pro = %@, .subpro = %@, .city = %@, .subcity = %@", mark.administrativeArea, mark.subAdministrativeArea, mark.locality, mark.subLocality);
    }];
}

@end
