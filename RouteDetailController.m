//
//  RouteDetailController.m
//  LiveTransit-Seattle
//
//  Created by Michael Rockhold on 8/14/09.
//  Copyright 2009 The Rockhold Company. All rights reserved.
//

#import "RouteDetailController.h"
#import "Route.h"
#import "Model.h"
#import "MapViewController.h"
#import "TimetablesPageController.h"
#import "AdvisoriesPageController.h"

#define kLiveTransitSection 0
#define kAgencySection 1

#define kShowOnMapRow 0

#define kSchedulesRow 0
#define kReroutesRow 1

@interface RouteDetailController (PrivateMethods)

-(void)resetScheduleArrays;

@end


@implementation RouteDetailController

#pragma mark -
#pragma mark View lifecycle

-(id)initWithRoute:(Route*)route
{
	if ( self = [self initWithStyle:UITableViewStyleGrouped] )
	{		
		m_route = route;
		m_showThisRouteSwitch = [[UISwitch alloc] init];
		m_showThisRouteSwitch.on = route.visible;
		[m_showThisRouteSwitch addTarget:self action:@selector(showRouteSwitchToggled:) forControlEvents:UIControlEventValueChanged];
	}
	return self;
}



-(void)viewWillAppear:(BOOL)animated
{
	m_showThisRouteSwitch.on = YES;
    // Update the view with current data before it is displayed.
    [super viewWillAppear:animated];
    
    // Scroll the table view to the top before it appears
    [self.tableView reloadData];
    [self.tableView setContentOffset:CGPointZero animated:NO];
    self.title = [NSString stringWithFormat:NSLocalizedString(@"RouteNum", @"Route ID Number format"), m_route.ID];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES; //interfaceOrientation == UIInterfaceOrientationPortrait;
}

#pragma mark -
#pragma mark Table view data source

-(void)showRouteSwitchToggled:(id)sender
{
	m_route.visible = m_showThisRouteSwitch.on;
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	/*
	 The number of rows varies by section.
	 */
    NSInteger rows = 0;
    switch (section)
	{
        case kLiveTransitSection:
			rows = 1;
			break;
			
        case kAgencySection:
            rows = 2;
            break;
			
        default:
            break;
    }
    return rows;
}

-(UITableViewCell*)tableView:(UITableView*)tableView 
	   cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
	static NSString* CellIdentifier = @"RouteDetailCellIdentifier";
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if ( cell == nil )
	{
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
	
    NSString* cellText = nil;
    switch (indexPath.section) {
			
        case kLiveTransitSection: // show this route switch section
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			
			switch (indexPath.row) {
				case kShowOnMapRow:
					m_showThisRouteSwitch.on = m_route.visible;
					cell.accessoryView = m_showThisRouteSwitch;
					cellText = NSLocalizedString(@"STR", @"Show this route");
					break;
					
				default:
					break;
			}
            break;
			
        case kAgencySection: // notifications & reroutes section
			cell.selectionStyle = UITableViewCellSelectionStyleBlue;
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

			switch (indexPath.row) {
				case kSchedulesRow: // notifications
					cellText = NSLocalizedString(@"Schedules", @"KCM/ST bus schedules");
					break;
					
				case kReroutesRow: // reroutes	
					cellText = NSLocalizedString(@"RiderAdvisories", @"KC Metro route advisories");
					break;
					
				default:
					break;
			}
            break;
			
        default:
            break;
    }	
    
    cell.textLabel.text = cellText;
    return cell;
}

#pragma mark -
#pragma mark Table view selection

- (NSIndexPath *)tableView:(UITableView *)tableView 
  willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSIndexPath* selection = nil;
	switch (indexPath.section) {
        case kLiveTransitSection: // show this route switch section
			switch (indexPath.row)
		{
			case kShowOnMapRow:
				break;
				
			default:
				break;
		}
            break;
			
        case kAgencySection: // schedule & reroutes section
			switch (indexPath.row)
		{
			case kSchedulesRow:	
				selection = indexPath;	
				break;
				
			case kReroutesRow:	
				selection = indexPath;	
				break;
				
			default:
				break;
		}
            break;
			
        default:
            break;
    }	
	return selection;
}

-(void)tableView:(UITableView *)tableView 
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case kLiveTransitSection: // show this route switch section
			switch (indexPath.row)
			{
				case kShowOnMapRow:
					break;
					
				default:
					break;
			}
            break;
			
        case kAgencySection: {
			UIViewController* viewController = nil;

			switch (indexPath.row)
			{
				case kSchedulesRow:
					viewController = [[TimetablesPageController alloc] initWithRoute:m_route];	
					break;
					
				case kReroutesRow:	
					viewController = [[AdvisoriesPageController alloc] initWithRoute:m_route];	
					break;
					
				default:
					break;
			}
			if ( viewController )
			{
				[[self navigationController] pushViewController:viewController animated:YES];
			}
			}
            break;
			
        default:
            break;
    }	
}

@end
