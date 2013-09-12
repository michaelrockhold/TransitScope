
#import "RouteViewPreferencesViewController.h"

NSString* SortRoutesKey = @"SLT_SortRoutesByDefaultKey";

@implementation RouteViewPreferencesViewController


@synthesize delegate;


#pragma mark -
#pragma mark === Action method ===
#pragma mark -

- (IBAction)done
{
	[self.delegate routeViewPreferencesViewControllerDidFinish:self];	
}


#pragma mark -
#pragma mark === View configuration ===
#pragma mark -

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle
{	
	if ( self = [super initWithNibName:nibName bundle:nibBundle] )
	{
		m_sortByChoices = [NSMutableArray arrayWithCapacity:4];
			// add these in order determined by eSortRoutes
		[m_sortByChoices addObject:NSLocalizedString(@"SortByRteNum", "by route number")];
		[m_sortByChoices addObject:NSLocalizedString(@"SortByProximityCurLoc", "by closest bus to present location")];
		[m_sortByChoices addObject:NSLocalizedString(@"SortByProximityCenterOfMap", "by closest bus to center of main map")];
	}
	return self;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

#pragma mark -
#pragma mark === TableView datasource and delegate methods ===
#pragma mark -

/*
 Provide cells for the table, with each showing one of the available time signatures.
 */

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section
{
    return m_sortByChoices.count;
}


- (UITableViewCell *)tableView:(UITableView *)table cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	
	static NSString *reuseIdentifier = @"RouteViewPreferencesCellIdentifier";
	
    UITableViewCell *cell = [table dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    }
	
	NSUInteger choiceIndex = (NSUInteger)[[NSUserDefaults standardUserDefaults] integerForKey:SortRoutesKey];

    cell.textLabel.text = m_sortByChoices[indexPath.row];
	cell.accessoryType = ( choiceIndex == indexPath.row ) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    return cell;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return NSLocalizedString(@"RouteViewPrefHeader", @"Sort Route view by what?");
}


- (void)tableView:(UITableView *)table didSelectRowAtIndexPath:(NSIndexPath *)newIndexPath
{
	NSUInteger choiceIndex = (NSUInteger)[[NSUserDefaults standardUserDefaults] integerForKey:SortRoutesKey];
	
	NSIndexPath *oldIndexPath = [NSIndexPath indexPathForRow:choiceIndex inSection:0];
	
    [[table cellForRowAtIndexPath:oldIndexPath] setAccessoryType:UITableViewCellAccessoryNone];
    [[table cellForRowAtIndexPath:newIndexPath] setAccessoryType:UITableViewCellAccessoryCheckmark];
    
    [table deselectRowAtIndexPath:newIndexPath animated:YES];
	
	[[NSUserDefaults standardUserDefaults] setInteger:newIndexPath.row forKey:SortRoutesKey];
	[[NSNotificationQueue defaultQueue]
	 enqueueNotification:[NSNotification notificationWithName:SortRoutesKey object:nil]
	 postingStyle:NSPostWhenIdle
	 coalesceMask:NSNotificationNoCoalescing
	 forModes:nil];
}

@end
