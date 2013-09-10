//
//  Utils.m
//  SeattleLiveTransit
//
//  Created by Michael Rockhold on 12/4/09.
//  Copyright 2009 The Rockhold Company. All rights reserved.
//

#import "Utils.h"

BOOL CoordinateWithinRegion(CLLocationCoordinate2D coords, MKCoordinateRegion rgn)
{
    CLLocationDegrees leftDegrees = rgn.center.longitude - (rgn.span.longitudeDelta / 2.0);
    CLLocationDegrees rightDegrees = rgn.center.longitude + (rgn.span.longitudeDelta / 2.0);
    CLLocationDegrees bottomDegrees = rgn.center.latitude - (rgn.span.latitudeDelta / 2.0);
    CLLocationDegrees topDegrees = rgn.center.latitude + (rgn.span.latitudeDelta / 2.0);
    
    return leftDegrees <= coords.longitude && coords.longitude <= rightDegrees && bottomDegrees <= coords.latitude && coords.latitude <= topDegrees;
}
