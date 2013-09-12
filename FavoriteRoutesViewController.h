//
//  LiveTransit:Seattle
//
//  Created by Michael Rockhold on 7/24/09.
//  Copyright 2009 The Rockhold Company. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Model.h"
#import "RouteViewPreferencesViewController.h"

typedef NSInteger (*sortFn_t)(id, id, void *);

@interface FavoriteRoutesViewController : UIViewController <UISearchBarDelegate, UISearchDisplayDelegate, RouteViewPreferencesViewControllerDelegate>
{
	IBOutlet UITableView*		m_tableView;
	IBOutlet UIBarButtonItem*	m_searchButtonItem;
	IBOutlet UIBarButtonItem*	m_settingsButtonItem;
	IBOutlet UILabel*			m_statusLine;
	
	CLLocation*			m_referenceLocation;
	NSArray*			m_routeProxyArray;
	NSArray*			m_foundRoutesArray;	
}

-(IBAction)showAllRoutes:(id)sender;
-(IBAction)hideAllRoutes:(id)sender;
-(IBAction)startSearch:(id)sender;

-(IBAction)showInfo;

@property (nonatomic, strong) UITableView* tableView;
@property (nonatomic, strong) NSArray* routeProxyArray;
@property (nonatomic, strong) NSArray* foundRoutesArray;
@property (nonatomic, strong) CLLocation* referenceLocation;

@end
