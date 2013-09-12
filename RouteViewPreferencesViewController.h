
@protocol RouteViewPreferencesViewControllerDelegate;


@interface RouteViewPreferencesViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
	id <RouteViewPreferencesViewControllerDelegate> __weak delegate;
	NSMutableArray* m_sortByChoices;
}

@property (nonatomic, weak) id <RouteViewPreferencesViewControllerDelegate> delegate;
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
