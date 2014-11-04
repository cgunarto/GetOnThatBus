//
//  BusStop.h
//  GetOnThatBus
//
//  Created by CHRISTINA GUNARTO on 11/4/14.
//  Copyright (c) 2014 Christina Gunarto. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface BusStop : NSObject
@property (nonatomic,strong) NSString *stopID; //it could be NSNumber
@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSString *route;

@property NSNumber *longitude;
@property NSNumber *latitude;
//@property CLLocationCoordinate2D coord;  why can't this be here?

- (instancetype)initWithBusStopDictionary: (NSDictionary *)busStopDictionary;

@end
