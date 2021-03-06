//
//  ViewController.m
//  GetOnThatBus
//
//  Created by CHRISTINA GUNARTO on 11/4/14.
//  Copyright (c) 2014 Christina Gunarto. All rights reserved.
//


//TODO: UIVIEW TRANSITION FROM VIEW
//TODO: IF MORE THAN 2 VIEWS, MAKE IT A SEPARATE VC like the container challenge
#import "RootViewController.h"
#import <MapKit/MapKit.h>
#import "BusStop.h"
#import "BusStopAnnotation.h"
#import "DetailViewController.h"

#define kURL @"https://s3.amazonaws.com/mobile-makers-lib/bus.json"
#define klatitudeDelta 0.4
#define klongitudeDelta 0.4
#define klatitudeCenter 41.8819542
#define klongitudeCenter -87.6409225

@interface RootViewController () <MKMapViewDelegate, UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftMapConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightMapConstraint;

@property (strong, nonatomic) NSDictionary *busStopResultDictionary;
@property (strong, nonatomic) NSMutableArray *allBusStopArray;
@property (strong, nonatomic) NSMutableArray *allBusStopAnnotationArray;

@end

@implementation RootViewController

#pragma mark View Controller Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self hideTableView];
    self.allBusStopArray = [@[]mutableCopy];
    [self setInitialViewToChicago];
    [self requestQueryForBusLocation];
    // loading all the pin
}

- (void)viewDidAppear:(BOOL)animated
{
    [self requestQueryForBusLocation];
//    [self hideTableView];
    [self.tableView reloadData];
}


- (void)hideTableView
{
    self.tableView.hidden = YES;
}


- (void)setInitialViewToChicago
{
    //set the center of the map to Madison & Clinton
    CLLocationCoordinate2D chicago = CLLocationCoordinate2DMake(klatitudeCenter, klongitudeCenter);
    MKCoordinateSpan coordinateSpan;
    coordinateSpan.latitudeDelta = klatitudeDelta;
    coordinateSpan.longitudeDelta = klongitudeDelta;

    MKCoordinateRegion region = MKCoordinateRegionMake(chicago, coordinateSpan);
    [self.mapView setRegion:region animated:YES];
}

#pragma mark Request Query

- (void)requestQueryForBusLocation
{
    NSURL *url = [NSURL URLWithString:kURL];
    NSURLRequest *request= [NSURLRequest requestWithURL:url];

    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
     {
         if (connectionError)
         {
             UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"CONNECTION ERROR"
                                                                            message:connectionError.localizedDescription
                                                                     preferredStyle:UIAlertControllerStyleAlert];

             UIAlertAction *okButton = [UIAlertAction actionWithTitle:@"OK"
                                                                style:UIAlertActionStyleDefault
                                                              handler:nil];

             [alert addAction:okButton];

             [self presentViewController:alert
                                animated:YES
                              completion:nil];
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
         [self.tableView reloadData];
     }];

}

#pragma mark Map View Delegate Methods

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    //MKPinAnnotationView instead of MKAnnotation -- be careful
    MKPinAnnotationView *pin = [[MKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:nil];
    pin.canShowCallout = YES;
    pin.rightCalloutAccessoryView =[UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    pin.pinColor = MKPinAnnotationColorPurple;

    BusStopAnnotation *busStopAnnotation = annotation;
    int index;

    index = busStopAnnotation.tag;
    BusStop *busStop = self.allBusStopArray[index];

    if ([busStop.interModal isEqualToString:@"Metra"])//TODO:make it #define
    {
        pin.image = [UIImage imageNamed:@"greenmark"];
        return pin;
    }
    else if ([busStop.interModal isEqualToString:@"Pace"])//TODO:make it #define
    {
        pin.image = [UIImage imageNamed:@"purplemark"];
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

#pragma mark Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(BusStop *)chosenBusStop
{
    if ([segue.identifier isEqualToString:@"segueToDetail"])
    {
        DetailViewController *detailVC = segue.destinationViewController;
        detailVC.busStop = chosenBusStop;
    }

    else if ([segue.identifier isEqualToString:@"segueFromCell"])
    {
        DetailViewController *detailVC = segue.destinationViewController;
        NSInteger rowNumber = [self.tableView indexPathForSelectedRow].row;
        BusStop *chosenBusStop = self.allBusStopArray[rowNumber];
        detailVC.busStop = chosenBusStop;
    }

}


#pragma mark Table View Cell Delegate Method

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    BusStop *busStop = self.allBusStopArray[indexPath.row];
    cell.textLabel.text = busStop.name;
    cell.detailTextLabel.text = busStop.route;

    if ([busStop.interModal isEqualToString:@"Pace"])
    {
        cell.imageView.image = [UIImage imageNamed:@"purplemark"];
    }

    else
        if([busStop.interModal isEqualToString:@"Metra"])
        {
            cell.imageView.image = [UIImage imageNamed:@"greenmark"];
        }
    else
        {
            cell.imageView.image = nil;
        }

    return cell;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.allBusStopArray.count;
}


#pragma mark Segment Controller

- (IBAction)segmentChanged:(UISegmentedControl *)sender
{
    switch ([sender selectedSegmentIndex])
    {
        case 0:
        {
            self.tableView.hidden = YES;
            self.mapView.hidden = NO;
            break;
        }

        case 1:
        {
            self.tableView.hidden = NO;
            self.mapView.hidden = YES;
            break;
        }

        default:
            break;
    }

    //[UIView transitionFromView:self.mapView toView:self.tableView duration:0.5 options(UIViewAnimationOptionShowHidTransitionViews | UIViewAnimationOptionTransitionFlipFromRight) completion:

}

#pragma mark


@end
