//
//  TimetablesPageController.m
//  SeattleLiveTransit
//
//  Created by Michael Rockhold on 11/15/09.
//  Copyright 2009 The Rockhold Company. All rights reserved.
//

#import "TimetablesPageController.h"

@implementation TimetablesPageController

-(NSString*)controllerNibName
{
	return @"TimetablesPageController";
}

-(NSString*)urlString:(int)routeNum
{
	NSString* fmt = (routeNum >= 500 && routeNum < 600) 
	? @"http://soundtransit.org/Riding-Sound-Transit/Schedules-and-Facilities/ST-Express-Bus/%03d-Weekday.xml"
	: @"http://metro.kingcounty.gov/tops/bus/schedules/s%03d_0_.html";
	
	return [NSString stringWithFormat:fmt, routeNum];
}
					 
@end
