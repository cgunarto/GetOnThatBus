//
//  DetailViewController.m
//  GetOnThatBus
//
//  Created by CHRISTINA GUNARTO on 11/4/14.
//  Copyright (c) 2014 Christina Gunarto. All rights reserved.
//

#import "DetailViewController.h"
#import "BusStopAnnotation.h"
#import <MapKit/MapKit.h>
#define klatitudeDelta 0.1
#define klongitudeDelta 0.1


@interface DetailViewController () <MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *routeLabel;
@property (weak, nonatomic) IBOutlet UILabel *interModalLabel;
@property (weak, nonatomic) IBOutlet UILabel *busStopName;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end

@implementation DetailViewController

#pragma mark View Controller Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTransferLabelColor];

    self.title = self.busStop.name;
    self.busStopName.text = self.busStop.name;

    self.routeLabel.text = self.busStop.route;
    self.interModalLabel.text = self.busStop.interModal;

    [self setAddressLabelwithReverseGeocode];
    [self setInitialViewToBusStop];

}

#pragma mark Custom Method

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

- (void)setInitialViewToBusStop
{
    //set the center of the map to Chicago
    double latitude = [self.busStop.latitude floatValue];
    double longitude = [self.busStop.longitude floatValue];

    CLLocationCoordinate2D busStopCoord = CLLocationCoordinate2DMake(latitude, longitude);
    MKCoordinateSpan coordinateSpan;
    coordinateSpan.latitudeDelta = klatitudeDelta;
    coordinateSpan.longitudeDelta = klongitudeDelta;

    MKCoordinateRegion region = MKCoordinateRegionMake(busStopCoord, coordinateSpan);

    BusStopAnnotation *busStopAnnotation = [[BusStopAnnotation alloc]init];
    busStopAnnotation.coordinate = busStopCoord;
    busStopAnnotation.title = self.busStop.name;
    busStopAnnotation.subtitle = self.busStop.route;

    [self.mapView addAnnotation:busStopAnnotation];
    [self.mapView setRegion:region animated:YES];


}

//set TransferLabel text color to correspond to pin color (purple for Pace route, green for Metra route)
- (void)setTransferLabelColor
{
    if ([self.busStop.interModal isEqual:@"Pace"])
    {
        self.interModalLabel.textColor = [UIColor purpleColor];
    }
    else if ([self.busStop.interModal isEqual:@"Metra"])
    {
        self.interModalLabel.textColor = [UIColor greenColor];
    }

}


#pragma mark Map View Delegate Method

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    //MKPinAnnotationView instead of MKAnnotation -- be careful
    MKPinAnnotationView *pin = [[MKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:nil];
    pin.canShowCallout = YES;

    //change the pin image based on transfer or no transfer
    if([self.busStop.interModal isEqualToString: @"Metra"])
    {
        pin.image = [UIImage imageNamed:@"greenmark"];
        return pin;
    }

    else if([self.busStop.interModal isEqualToString:@"Pace"])
    {
        pin.image = [UIImage imageNamed:@"purplemark"];
        return pin;
    }

    return pin;
}

@end
