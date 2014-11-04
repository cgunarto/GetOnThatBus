//
//  BusStop.m
//  GetOnThatBus
//
//  Created by CHRISTINA GUNARTO on 11/4/14.
//  Copyright (c) 2014 Christina Gunarto. All rights reserved.
//

#import "BusStop.h"

@implementation BusStop

- (instancetype)initWithBusStopDictionary: (NSDictionary *)busStopDictionary
{
    self = [super init];
    self.stopID = busStopDictionary[@"_id"];
    self.name = busStopDictionary[@"cta_stop_name"];
    self.route = busStopDictionary[@"routes"];

    self.longitude = busStopDictionary[@"longitude"];

    self.latitude = busStopDictionary[@"latitude"];

    return self;
}


@end
