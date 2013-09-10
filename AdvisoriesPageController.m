//
//  AdvisoriesPageController.m
//  SeattleLiveTransit
//
//  Created by Michael Rockhold on 11/23/09.
//  Copyright 2009 The Rockhold Company. All rights reserved.
//

#import "AdvisoriesPageController.h"

@implementation AdvisoriesPageController

-(NSString*)controllerNibName
{
	return @"AdvisoriesPageController";
}

-(NSString*)urlString:(int)routeNum
{
	return (routeNum >= 500 && routeNum < 600) 
	? @"http://soundtransit.org/Riding-Sound-Transit/Rider-Alerts.xml?ss=print&sort=date"
	: @"http://metro.kingcounty.gov/up/rr/reroutes.html";
}

@end
