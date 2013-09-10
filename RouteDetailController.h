//
//  RouteDetailController.h
//  LiveTransit-Seattle
//
//  Created by Michael Rockhold on 8/14/09.
//  Copyright 2009 The Rockhold Company. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Route;

@interface RouteDetailController : UITableViewController
{
	Route* m_route;
	UISwitch* m_showThisRouteSwitch;
}

-(id)initWithRoute:(Route*)route;
-(void)showRouteSwitchToggled:(id)sender;

@end
