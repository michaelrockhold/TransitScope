//
//  AgencyPageController.h
//  SeattleLiveTransit
//
//  Created by Michael Rockhold on 11/25/09.
//  Copyright 2009 The Rockhold Company. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Route;

@interface AgencyPageController : UIViewController < UIWebViewDelegate >
{
	NSURL* m_mainURL;
	
	IBOutlet UIBarButtonItem* m_backbutton;
	IBOutlet UIWebView* m_webview;
	IBOutlet UIActivityIndicatorView* m_activityIndicator;
}

- (id)initWithRoute:(Route*)route;

-(NSString*)urlString:(int)routeNum;

-(NSString*)controllerNibName;

@end
