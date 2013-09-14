	//
	//  BusDetailViewController.m
	//  LiveTransit-Seattle
	//
	//  Created by Michael Rockhold on 8/14/09.
	//  Copyright 2009 The Rockhold Company. All rights reserved.
	//

#import "BusDetailViewController.h"
#import "Bus.h"
#import "Route.h"
#import "Model.h"
#import "RouteDetailController.h"
#import "BusAnnotationView.h"
#import <MapKit/MKMapView.h>

extern NSObject<Model>* g_Model;

#define kMapSection 0
#define kTopShimRow 0
#define kMapViewRow 1
#define kBusInfoRow 2

#define kControlsSection 1
#define kRouteInfoRow 0
#define kBusTrackButtonRow 1

const double cMapViewTopShimHeight = 12;
const double cMapViewBusInfoRowHeight = 24;
const double cMapRowHeight = 148;
const double cMapRowWidth = 300;

@interface BusDetailViewController() <MKMapViewDelegate>

@end

@implementation BusDetailViewController

#pragma mark -
#pragma mark View lifecycle

- (id)initWithBus:(Bus*)bus
{
	if ( self = [self initWithStyle:UITableViewStyleGrouped] )
	{
		m_bus = bus;
	}
	return self;
}


-(void)viewDidLoad
{
	[super viewDidLoad];
	m_followThisBusSwitch = [[UISwitch alloc] init];
	[m_followThisBusSwitch addTarget:self action:@selector(followingBusSwitchToggled:) forControlEvents:UIControlEventValueChanged];
	
	m_mapview = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, cMapRowWidth, cMapRowHeight)];
    m_mapview.delegate = self;
	m_mapview.showsUserLocation = YES;
	m_mapview.scrollEnabled = NO;
	m_mapview.zoomEnabled = NO;
	[m_mapview addAnnotation:m_bus];
	[self recenterMap];
	[m_bus addObserver:self forKeyPath:@"position" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:NULL];
	[g_Model addObserver:self forKeyPath:@"followedBus" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:NULL];
}

-(void)viewDidUnload
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[g_Model removeObserver:self forKeyPath:@"followedBus"];
	[m_bus removeObserver:self forKeyPath:@"position"];
	[super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
	m_followThisBusSwitch.on = [m_bus isEqual:g_Model.followedBus];
	
		// Update the view with current data before it is displayed.
    [super viewWillAppear:animated];
    
		// Scroll the table view to the top before it appears
    [self.tableView reloadData];
    [self.tableView setContentOffset:CGPointZero animated:NO];
	self.title = [NSString stringWithFormat:NSLocalizedString(@"VehicleInfo", @"Vehicle ID Number format"), m_bus.ID];
	
	m_updatePositionUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updatePositionUpdateTime:) userInfo:nil repeats:YES];
}

-(void)viewWillDisappear:(BOOL)animated
{
	[m_updatePositionUpdateTimer invalidate];
	[super viewWillDisappear:animated];
}

- (void)observeValueForKeyPath:(NSString*)keyPath
					  ofObject:(id)object
                        change:(NSDictionary*)change
                       context:(void *)context
{
	if ( [keyPath isEqual:@"followedBus"] )
	{
		if ( [change[NSKeyValueChangeKindKey] intValue] == NSKeyValueChangeSetting )
		{
			id newAnn = change[NSKeyValueChangeNewKey];
			id previousAnn = change[NSKeyValueChangeOldKey];
			
			if ( [m_bus isEqual:newAnn] || [m_bus isEqual:previousAnn] )
			{
				[self.mapView removeAnnotation:m_bus];
				[self.mapView addAnnotation:m_bus];
			}
		}
	}
	else if ( [object isEqual:m_bus] && [keyPath isEqual:@"position"] )
	{
		[self.mapView removeAnnotation:(Bus*)object];
		[self.mapView addAnnotation:(Bus*)object];
		[self recenterMap];
    }
	
	[self.tableView reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return interfaceOrientation == UIInterfaceOrientationPortrait;
}

- (void)updatePositionUpdateTime:(NSDictionary*)userInfo
{
	[self.tableView reloadData];
}

-(void)recenterMap
{
	m_mapview.region = MKCoordinateRegionMakeWithDistance(m_bus.coordinate, 175.0, 200.0);	
}

-(void)followingBusSwitchToggled:(id)sender
{
	g_Model.followedBus = (m_followThisBusSwitch.on) ? m_bus : nil;
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
	/*
	 The number of rows varies by section.
	 */
    NSInteger rows = 0;
    switch (section) {
        case kMapSection: 
			rows = 3; // map
			break;
			
        case kControlsSection: // Route info and Track this bus switch
            rows = 2;
            break;
			
        default:
            break;
    }
    return rows;
}

- (CGFloat)   tableView:(UITableView *)tableView 
heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	CGFloat height = 48;
	
	switch (indexPath.section)
	{
        case kMapSection:
			switch (indexPath.row) {
				case kTopShimRow:
					height = cMapViewTopShimHeight;
					break;
					
				case kMapViewRow:
					height = cMapRowHeight;
					break;
					
				case kBusInfoRow:
					height = cMapViewBusInfoRowHeight;
					break;
					
				default:
					break;
			}
            break;
			
        case kControlsSection:
			switch (indexPath.row) {
				case kRouteInfoRow:
					break;
					
				case kBusTrackButtonRow:
					break;
					
				default:
					break;
			}
            break;
        default:
            break;
    }
	
	return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView 
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString* CellIdentifier = ( indexPath.section == 0 && indexPath.row == 1 )
	? @"BusDetailCellIdentifier-mapview"	
	: @"BusDetailCellIdentifier-simple";
	
	UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if ( cell == nil )
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
	}
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
		// Set the text in the cell for the section/row.
	
	switch (indexPath.section)
	{
        case kMapSection:
			switch (indexPath.row) {
				case kTopShimRow: // do nothing; just for show
					break;
					
				case kMapViewRow:
					[cell.contentView insertSubview:m_mapview atIndex:0];
					break;
					
				case kBusInfoRow:
					cell.textLabel.font = [UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
					int secondsSinceLastUpdate = -rint([m_bus.timestamp timeIntervalSinceNow]);
					int minutes = secondsSinceLastUpdate / 60;
					int seconds = secondsSinceLastUpdate % 60;
					
					if ( minutes == 0 )
					{
						cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"SecondsSinceLastUpdateFormat", @"X seconds since last update"), secondsSinceLastUpdate];
					}
					else if ( minutes == 1 )
					{
						if ( seconds == 0 )
							cell.textLabel.text = NSLocalizedString(@"OneMinuteSinceLastUpdateFormat", @"1 minute since last update");
						else if ( seconds == 1 )
							cell.textLabel.text = NSLocalizedString(@"OneMinuteAndOneSecondSinceLastUpdateFormat", @"1 minute, 1 second since last update");
						else
							cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"OneMinuteAndSecondsSinceLastUpdateFormat", @"1 minute, Y seconds since last update"), seconds];
					}
					else 
					{
						if ( seconds == 0 )
							cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"MinutesSinceLastUpdateFormat", @"X minutes since last update"), minutes];
						else if ( seconds == 1 )
							cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"MinutesAndOneSecondSinceLastUpdateFormat", @"X minutes, 1 second since last update"), minutes];
						else
							cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"MinutesAndSecondsSinceLastUpdateFormat", @"X minute, Y seconds since last update"), minutes, seconds];						
					}		
					break;
					
				default:
					break;
			}
            break;
			
        case kControlsSection:
			switch (indexPath.row) {
				case kRouteInfoRow:
					cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"RouteInfo", @"Route ID Number format"), m_bus.route.ID];
					cell.selectionStyle = UITableViewCellSelectionStyleBlue;
					cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
					break;
										
				case kBusTrackButtonRow:
					cell.accessoryView = m_followThisBusSwitch;
					cell.textLabel.text = NSLocalizedString(@"TTB", @"Track this bus");
					break;
					
				default:
					break;
			}
            break;
			
        default:
            break;
    }
	
    return cell;
}

#if 0
- (NSString *)tableView:(UITableView *)tableView 
titleForHeaderInSection:(NSInteger)section
{
    NSString *title = nil;
    switch (section) {
        case kMapSection:
            break;
			
        case kControlsSection:
            break;
			
        default:
            break;
    }
    return title;
}
#endif

#pragma mark -
#pragma mark Table view selection

- (NSIndexPath *)tableView:(UITableView *)tableView 
  willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSIndexPath* selection = nil;
	switch (indexPath.section) {
        case kMapSection:
            break;
			
        case kControlsSection: // route & notification section
			switch (indexPath.row) {
				case kRouteInfoRow:
					selection = indexPath;	
					break;
					
				case kBusTrackButtonRow:
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

- (void)      tableView:(UITableView *)tableView 
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	UIViewController* viewController = nil;
    switch (indexPath.section) {
        case kMapSection: // track this bus section
						  // do nothing
            break;
			
        case kControlsSection: // route & notification section
			switch (indexPath.row) {
				case kRouteInfoRow:
					viewController = [[RouteDetailController alloc] initWithRoute:m_bus.route];	
					break;
										
				case kBusTrackButtonRow:
					break;
					
				default:
					break;
			}
			if ( viewController )
			{
				[[self navigationController] pushViewController:viewController animated:YES];
			}
            break;
			
        default:
            break;
    }
	
}

@end
