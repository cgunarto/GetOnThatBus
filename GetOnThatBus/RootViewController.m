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
#import "BusStopAnnotation.h"
#import "DetailViewController.h"
#define kURL @"https://s3.amazonaws.com/mobile-makers-lib/bus.json"

@interface RootViewController () <MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (strong, nonatomic) NSDictionary *busStopResultDictionary;
@property (strong, nonatomic) NSMutableArray *allBusStopArray;
@property (strong, nonatomic) NSMutableArray *allBusStopAnnotationArray;

@end

@implementation RootViewController

//CHICAGO 41.8337329,-87.7321555

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.allBusStopArray = [@[]mutableCopy];
    [self setInitialViewToChicago];
    [self requestQuery];
    // loading all the pin
}


- (void)setInitialViewToChicago
{
    //set the center of the map to Chicago
    CLLocationCoordinate2D chicago = CLLocationCoordinate2DMake(41.8337329, -87.7321555);
    MKCoordinateSpan coordinateSpan;
    coordinateSpan.latitudeDelta = 0.4;
    coordinateSpan.longitudeDelta = 0.4;

    MKCoordinateRegion region = MKCoordinateRegionMake(chicago, coordinateSpan);
    [self.mapView setRegion:region animated:YES];
}

- (void)requestQuery
{
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

             int i = 0;

             for (NSDictionary *d in allBusStopDictionaryArray)
             {
                 BusStop *busStop = [[BusStop alloc] initWithBusStopDictionary:d];
                 [self.allBusStopArray addObject:busStop];

                 CLLocationCoordinate2D coor = CLLocationCoordinate2DMake([busStop.latitude doubleValue], [busStop.longitude doubleValue]);

                 BusStopAnnotation *busStopAnnotation = [[BusStopAnnotation alloc]init];
                 busStopAnnotation.coordinate = coor;
                 busStopAnnotation.title = busStop.name;
                 busStopAnnotation.subtitle = busStop.route;
                 busStopAnnotation.tag = i;
                 [self.allBusStopAnnotationArray addObject:busStopAnnotation];
                 i = i + 1;
                 
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

    BusStopAnnotation *busStopAnnotation = annotation;
    int index;

    index = busStopAnnotation.tag;
    BusStop *busStop = self.allBusStopArray[index];

    if ([busStop.interModal isEqualToString:@"Metra"])
    {
        pin.image = [UIImage imageNamed:@"greenmark"];
        return pin;
    }
    else if ([busStop.interModal isEqualToString:@"Pace"])
    {
        pin.image = [UIImage imageNamed:@"yellowmark"];
        return pin;
    }

    return pin;
}


//If accessory detail is tapped
- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    BusStopAnnotation *busStopAnnotation = view.annotation;
 //   int index = [self.allBusStopAnnotationArray indexOfObject:view.annotation];
    int seletedIndex = busStopAnnotation.tag;

    BusStop *chosenBusStop = self.allBusStopArray[seletedIndex];

    [self performSegueWithIdentifier:@"segueToDetail" sender:(BusStop *)chosenBusStop];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(BusStop *)chosenBusStop
{
    DetailViewController *detailVC = segue.destinationViewController;
    detailVC.busStop = chosenBusStop;
}








@end
