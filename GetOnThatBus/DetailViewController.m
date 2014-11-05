//
//  DetailViewController.m
//  GetOnThatBus
//
//  Created by CHRISTINA GUNARTO on 11/4/14.
//  Copyright (c) 2014 Christina Gunarto. All rights reserved.
//

#import "DetailViewController.h"
#import <MapKit/MapKit.h>

@interface DetailViewController ()
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *routeLabel;
@property (weak, nonatomic) IBOutlet UILabel *interModalLabel;

@end

@implementation DetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = self.busStop.name;
    self.routeLabel.text = self.busStop.route;
    self.interModalLabel.text = self.busStop.interModal;

    [self setAddressLabelwithReverseGeocode];
}


- (void)setAddressLabelwithReverseGeocode
{
    CLGeocoder *geocoder = [[CLGeocoder alloc]init];
    double latitude = [self.busStop.latitude doubleValue];
    double longitude = [self.busStop.longitude doubleValue];

    CLLocation *location = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];

    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error)
    {
        CLPlacemark *placemark = placemarks[0];
        NSLog(@"Found %@", placemark.name);
        self.addressLabel.text = placemark.name;
    }];

}



@end
