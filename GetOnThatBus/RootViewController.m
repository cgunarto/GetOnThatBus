//
//  ViewController.m
//  GetOnThatBus
//
//  Created by CHRISTINA GUNARTO on 11/4/14.
//  Copyright (c) 2014 Christina Gunarto. All rights reserved.
//

#import "RootViewController.h"
#import <MapKit/MapKit.h>
#import "BusStop.h"
#define kURL @"https://s3.amazonaws.com/mobile-makers-lib/bus.json"

@interface RootViewController () <MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (strong, nonatomic) NSDictionary *busStopResultDictionary;
@property (strong, nonatomic) NSMutableArray *allBusStopArray;

@end

@implementation RootViewController

//CHICAGO 41.8337329,-87.7321555

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.allBusStopArray = [@[]mutableCopy];

    //set the center of the map to Chicago
    CLLocationCoordinate2D chicago = CLLocationCoordinate2DMake(41.8337329, -87.7321555);
    MKCoordinateSpan coordinateSpan;
    coordinateSpan.latitudeDelta = 0.4;
    coordinateSpan.longitudeDelta = 0.4;

    MKCoordinateRegion region = MKCoordinateRegionMake(chicago, coordinateSpan);
    [self.mapView setRegion:region animated:YES];


    // loading all the pin
    NSURL *url = [NSURL URLWithString:kURL];
    NSURLRequest *request= [NSURLRequest requestWithURL:url];

    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
    {
        if (connectionError)
        {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"CONNECTION ERROR" message:connectionError.localizedDescription preferredStyle:UIAlertControllerStyleAlert];

            UIAlertAction *okButton = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];

            [alert addAction:okButton];
            [self presentViewController:alert animated:YES completion:nil];
        }

        else
        {
            NSDictionary *allJSONDataDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            NSArray *allBusStopDictionaryArray = allJSONDataDictionary[@"row"]; // now allBusStopDictionaryArray becomes an array of dictionary

            for (NSDictionary *d in allBusStopDictionaryArray)
            {
                BusStop *busStop = [[BusStop alloc] initWithBusStopDictionary:d];
                [self.allBusStopArray addObject:busStop];

                CLLocationCoordinate2D coor = CLLocationCoordinate2DMake([busStop.latitude doubleValue], [busStop.longitude doubleValue]);

                MKPointAnnotation *busStopAnnotation = [[MKPointAnnotation alloc]init];
                busStopAnnotation.coordinate = coor;
                busStopAnnotation.title = busStop.name;
                busStopAnnotation.subtitle = busStop.route;
                [self.mapView addAnnotation:busStopAnnotation];

            }
            
        }
    }];

}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    //MKPinAnnotationView instead of MKAnnotation -- be careful
    MKPinAnnotationView *pin = [[MKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:nil];
    pin.canShowCallout = YES;
    pin.rightCalloutAccessoryView =[UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    return pin;
}








@end
