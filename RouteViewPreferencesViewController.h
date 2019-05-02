
@protocol RouteViewPreferencesViewControllerDelegate;


@interface RouteViewPreferencesViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
	id <RouteViewPreferencesViewControllerDelegate> delegate;
	NSMutableArray* m_sortByChoices;
}

@property (nonatomic, assign) id <RouteViewPreferencesViewControllerDelegate> delegate;
- (IBAction)done;

@end


@protocol RouteViewPreferencesViewControllerDelegate
- (void)routeViewPreferencesViewControllerDidFinish:(RouteViewPreferencesViewController*)controller;
@end

extern NSString* SortRoutesKey;

enum eSortRoutes
{
	eSortRoutesByRouteNumber = 0,
	eSortRoutesByProximityToCurrentLocation,
	eSortRoutesByProximityToCenterOfMap
};
