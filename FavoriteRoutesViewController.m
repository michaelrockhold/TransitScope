//
//  LiveTransit:Seattle
//
//  Created by Michael Rockhold on 7/24/09.
//  Copyright 2009 The Rockhold Company. All rights reserved.
//

#import "FavoriteRoutesViewController.h"
#import "Bus.h"
#import "Route.h"
#import "Model.h"
#import "RouteDetailController.h"
#import "RouteViewPreferencesViewController.h"

extern NSObject<Model>* g_Model;

@interface RouteProxy : NSObject
{
	Route* m_route;
	NSUInteger m_routeNumber;
	CLLocationDistance m_distanceToReferenceLocation;
}

-(id)initWithRoute:(Route*)route referenceLocation:(CLLocation*)refLoc;
-(NSComparisonResult)compareByDistanceToReferenceLocation:(RouteProxy*)other;
-(NSComparisonResult)compareByRouteID:(RouteProxy*)other;

@property (nonatomic, readonly) NSUInteger routeNumber;
@property (nonatomic, retain, readonly) Route* route;
@property (nonatomic, readonly) CLLocationDistance distanceToReferenceLocation;
@end

@implementation RouteProxy
@synthesize routeNumber = m_routeNumber, route = m_route, distanceToReferenceLocation = m_distanceToReferenceLocation;

-(id)initWithRoute:(Route*)route referenceLocation:(CLLocation*)refLoc
{
	if ( self = [self init] )
	{
		m_route = [route retain];
		
		m_routeNumber = [m_route.ID intValue];
		
		m_distanceToReferenceLocation = 999999;
		if ( refLoc != nil )
		{
			for (Bus* b in m_route.buses)
			{
				CLLocationDistance d = [b.position getDistanceFrom:refLoc];
			
				if ( d < m_distanceToReferenceLocation ) m_distanceToReferenceLocation = d;
			}
		}
	}
	return self;
}

-(void)dealloc
{
	[m_route release];
	[super dealloc];
}

-(NSComparisonResult)compareByDistanceToReferenceLocation:(RouteProxy*)other
{
	if (self.distanceToReferenceLocation < other.distanceToReferenceLocation)
        return NSOrderedAscending;
    else if (self.distanceToReferenceLocation > other.distanceToReferenceLocation)
        return NSOrderedDescending;
    else
        return NSOrderedSame;
}

-(NSComparisonResult)compareByRouteID:(RouteProxy*)other
{
	if (self.routeNumber < other.routeNumber)
        return NSOrderedAscending;
    else if (self.routeNumber > other.routeNumber)
        return NSOrderedDescending;
    else
        return NSOrderedSame;
}

@end



@interface FavoriteRoutesViewController (PrivateMethods)

-(void)resort;
-(void)reinitForSortingRule;

-(void)routeSortingRuleChanged:(NSNotification *)notification;

-(void)redrawStatusLine;
-(void)reload;
-(void)redisplay;

@end


@implementation FavoriteRoutesViewController
@synthesize tableView = m_tableView, routeProxyArray = m_routeProxyArray, foundRoutesArray = m_foundRoutesArray, referenceLocation = m_referenceLocation;

#pragma mark -
#pragma mark View lifecycle

-(void)dealloc
{
	[m_routeProxyArray release];
	[m_foundRoutesArray release];
	[super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	m_referenceLocation = nil;
	self.routeProxyArray = nil;
	self.foundRoutesArray = nil;
    self.title = NSLocalizedString(@"RoutesTitle", @"Routes");    
	self.tableView.rowHeight = 55;
		
	self.navigationItem.leftBarButtonItem = m_searchButtonItem;
	self.navigationItem.rightBarButtonItem = m_settingsButtonItem;
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(routeSortingRuleChanged:)
												 name:SortRoutesKey object:nil];
	
	[g_Model addObserver:self forKeyPath:@"currentLocation" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:NULL];
	[g_Model addObserver:self forKeyPath:@"centerOfMap" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:NULL];	
	[g_Model addObserver:self forKeyPath:@"routes" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:NULL];	
}

-(void)viewDidUnload
{
	self.referenceLocation = nil;
	[g_Model removeObserver:self forKeyPath:@"currentLocation"];
	[g_Model removeObserver:self forKeyPath:@"centerOfMap"];
	[g_Model removeObserver:self forKeyPath:@"routes"];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self reinitForSortingRule];
	[self redisplay];
	if ( self.searchDisplayController.active )
	{
		[self.searchDisplayController.searchResultsTableView reloadData];
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

-(void)routeSortingRuleChanged:(NSNotification*)notification
{
	[self reinitForSortingRule];
	[self redisplay];
}

-(void)reinitForSortingRule
{
	switch ([[NSUserDefaults standardUserDefaults] integerForKey:SortRoutesKey])
	{
		case eSortRoutesByRouteNumber:
			self.referenceLocation = nil;
			break;
		case eSortRoutesByProximityToCurrentLocation:
			self.referenceLocation = g_Model.currentLocation;
			break;
		case eSortRoutesByProximityToCenterOfMap:
			self.referenceLocation = g_Model.centerOfMap;
			break;
		default:
			break;
	}
}

-(void)reload
{
	[self.tableView reloadData];
}

-(void)redisplay
{
	[self resort];
	[self reload];
	[self redrawStatusLine];
}

-(void)resort
{
	self.routeProxyArray = [NSMutableArray arrayWithCapacity:g_Model.routes.count];
	for (Route* r in g_Model.routes)
	{
		RouteProxy* rp = [[RouteProxy alloc] initWithRoute:r referenceLocation:self.referenceLocation];
		[(NSMutableArray*)(self.routeProxyArray) addObject:rp];
		[rp release];
	}
	
	[(NSMutableArray*)(self.routeProxyArray) sortUsingSelector:(self.referenceLocation == nil ? @selector(compareByRouteID:) : @selector(compareByDistanceToReferenceLocation:))];	
}

-(void)redrawStatusLine
{
	NSUInteger busCount;
	NSUInteger routeCount;
	[g_Model getCountsOfBuses:&busCount routes:&routeCount];
	m_statusLine.text = [NSString stringWithFormat:@"%d buses on %d routes", busCount, routeCount];
}

#pragma mark -
#pragma mark Actions

-(IBAction)showAllRoutes:(id)sender
{
	[g_Model revealAllRoutes];
	[self reload];
}

-(IBAction)hideAllRoutes:(id)sender
{
	[g_Model hideAllRoutes];
	[self reload];
}

-(IBAction)startSearch:(id)sender
{
	[self.searchDisplayController setActive:YES animated:YES];
}

- (void)observeValueForKeyPath:(NSString*)keyPath
					  ofObject:(id)object
                        change:(NSDictionary*)change
                       context:(void *)context
{
	NSUInteger choiceIndex = (NSUInteger)[[NSUserDefaults standardUserDefaults] integerForKey:SortRoutesKey];

	if ( [object isEqual:g_Model] )
	{
		if ( [keyPath isEqualToString:@"currentLocation"] )
		{
			if ( g_Model.currentLocation != nil && choiceIndex == eSortRoutesByProximityToCurrentLocation )
			{
				self.referenceLocation = g_Model.currentLocation;
				[self redisplay];
			}
		}
		else if ( [keyPath isEqualToString:@"centerOfMap"] )
		{
			if ( g_Model.centerOfMap != nil && choiceIndex == eSortRoutesByProximityToCenterOfMap )
			{
				self.referenceLocation = g_Model.centerOfMap;
				[self redisplay];
			}
		}
		else if ( [keyPath isEqualToString:@"routes"] )
		{
			[self redisplay];
		}
	}
	else if ( [keyPath isEqualToString:@"visible"] )// object is a Route
	{
		[self reload];
	}
}

#pragma mark -
#pragma mark Table view data source methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	// regular table and search results table both have just one section
    return 1;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
	NSInteger rows = 0;
	if ( section == 0 )
	{
		rows = ( tableView == self.tableView ) ? [self.routeProxyArray count] : [self.foundRoutesArray count];
	}
	return rows;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
	static NSString* s_RouteTableViewCellIdentifier = @"RouteTableViewCell";
	UITableViewCell* cell = nil;
	BOOL fSearching = !( tableView == self.tableView );
	
	if ( indexPath.section == 0 )
	{
		RouteProxy* routeProxy = nil;
		if ( !fSearching )
			routeProxy = [self.routeProxyArray objectAtIndex:indexPath.row];
		
		Route* route = (Route*) ( fSearching
								 ? [self.foundRoutesArray objectAtIndex:indexPath.row]
								 : routeProxy.route);

		cell = [tableView dequeueReusableCellWithIdentifier:s_RouteTableViewCellIdentifier];
		if ( cell == nil )
		{
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:s_RouteTableViewCellIdentifier] autorelease];
		}
		
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
		cell.accessoryView = nil;
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.textLabel.text = route.ID;
		cell.textLabel.enabled = route.visible;
		
		if ( !fSearching )
		{
			NSMutableString* detailText;
			CLLocationDistance drl = routeProxy.distanceToReferenceLocation;
			switch ([route.buses count])
			{
				case 0:
					detailText = [NSMutableString stringWithString:NSLocalizedString(@"NoBuses", @"No buses")];
					break;
				case 1:
					detailText = [NSMutableString stringWithString:NSLocalizedString(@"OneBus", @"One bus")];
					if ( drl > 0 && drl < 5000 )
						[detailText appendString:[NSString stringWithFormat:NSLocalizedString(@"OneBusNAwayFmt", @", N meters away"), drl]];
					break;
				default:
					detailText = [NSMutableString stringWithFormat:NSLocalizedString(@"SomeBusesFormat", @"<count> buses format"), [route.buses count]];
					if ( drl > 0 && drl < 5000 )
						[detailText appendString:[NSString stringWithFormat:NSLocalizedString(@"NBusesNAwayFmt", @" (closest: N meters away)"), drl]];
					break;
			}
			
			cell.detailTextLabel.text = detailText;
		}
	}
	return cell;
}

#pragma mark -
#pragma mark Table view selection

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	BOOL fSearching = !( tableView == self.tableView );
	
	if ( indexPath.section == 0 )
	{
		RouteProxy* routeProxy = nil;
		if ( !fSearching )
			routeProxy = [self.routeProxyArray objectAtIndex:indexPath.row];
		
		Route* route = (Route*) ( fSearching
								 ? [self.foundRoutesArray objectAtIndex:indexPath.row]
								 : routeProxy.route);
		
		UIViewController* viewController = [[RouteDetailController alloc] initWithRoute:route];	
		[[self navigationController] pushViewController:viewController animated:YES];
		[viewController release];	
	}			
}

#pragma mark -
#pragma mark Search Bar Delegate methods

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar                      // return NO to not become first responder
{
	return YES;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar                     // called when text starts editing
{

}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar                        // return NO to not resign first responder
{
	return YES;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar                       // called when text ends editing
{
	// we do nothing
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText   // called when text changes (including clear)
{                                                                                  	
	self.foundRoutesArray = [[g_Model.routes filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"ID BEGINSWITH %@", searchText]] allObjects];
}

- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text // called before text changes
{
	return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar                     // called when keyboard search button pressed
{
	//[searchBar resignFirstResponder];
}
- (void)searchBarBookmarkButtonClicked:(UISearchBar *)searchBar                   // called when bookmark button pressed
{
	// we do nothing
}
- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar                    // called when cancel button pressed
{
	//[searchBar resignFirstResponder];
}

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope
{
	// we do nothing
}

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller
{
	self.tableView.tableHeaderView = self.searchDisplayController.searchBar;
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller
{
	self.tableView.tableHeaderView = nil;
}

#pragma mark -
#pragma mark info view support

- (IBAction)showInfo
{        
    RouteViewPreferencesViewController* controller = [[RouteViewPreferencesViewController alloc] initWithNibName:@"RouteViewPreferencesView" bundle:nil];
    controller.delegate = self;
    
    controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentModalViewController:controller animated:YES];
    
    [controller release];
}


- (void)routeViewPreferencesViewControllerDidFinish:(RouteViewPreferencesViewController*)controller
{
    [self dismissModalViewControllerAnimated:YES];
}

@end
