//
//  AgencyPageController.m
//  SeattleLiveTransit
//
//  Created by Michael Rockhold on 11/25/09.
//  Copyright 2009 The Rockhold Company. All rights reserved.
//

#import "AgencyPageController.h"
#import "Route.h"

@implementation AgencyPageController

- (id)initWithRoute:(Route*)route
{
    if ( self = [super initWithNibName:[self nibName] bundle:nil] )
	{				
		m_mainURL = [NSURL URLWithString:[self urlString:[route.ID intValue]]];
    }
    return self;
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	
	m_backbutton.image = [UIImage imageNamed:@"GoBack.png"];
	self.navigationItem.rightBarButtonItem = m_backbutton;
	m_webview.delegate = self;
	[m_webview loadRequest:[NSURLRequest requestWithURL:m_mainURL]];	
}

- (void)viewWillDisappear:(BOOL)animated
{
	if ( m_webview.loading ) [m_webview stopLoading];
	m_webview.delegate = nil;
	[super viewWillDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)didReceiveMemoryWarning {
		// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
		// Release any cached data, images, etc that aren't in use.
}

#pragma mark -
#pragma mark Override these

-(NSString*)urlString:(int)routeNum
{
	return nil;
}

-(NSString*)controllerNibName
{
	return nil;
}

#pragma mark -
#pragma mark Webview delegate methods

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
	m_activityIndicator.hidden = NO;
	[m_activityIndicator startAnimating];
	return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	[m_activityIndicator stopAnimating];
	m_backbutton.enabled = m_webview.canGoBack;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
	[m_activityIndicator stopAnimating];
	m_backbutton.enabled = m_webview.canGoBack;
}

@end
