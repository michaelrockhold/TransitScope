//
//  SoapFunction.h
//  BusGnosis
//
//  Created by Michael Rockhold on 6/28/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XPathQuery.h"

@interface SoapFunction : NSObject
{
	NSURL* m_url;
	NSString* m_method;
	NSString* m_namespace;
	NSString* m_soapAction;
	NSDictionary* m_reqHeaders;
	NSArray* m_paramOrder;
	NSString* m_responseQuery;
	NSString* m_responsePrefix;
	NSString* m_responseNamespace;
}

- (id)initWithUrl:(NSString*)url
		   Method:(NSString*)method
		Namespace:(NSString*)ns
	   SoapAction:(NSString*)soapAction
	   ParamOrder:(NSArray*)paramOrder
	ResponseQuery:(NSString*)responseQuery
   ResponsePrefix:(NSString*)responsePrefix
ResponseNamespace:(NSString*)responseNamespace;

	// for synchronous use, just call invoke
-(BOOL) Invoke:(NSDictionary*)params 
   nodeHandler:(NSObject<XPathNodeHandler>*)nodeHandler 
	   timeout:(NSTimeInterval)timeout 
		 error:(NSError**)error;
-(void)executeRequestSynchronously:(NSURLRequest*)request nodeHandler:(NSObject<XPathNodeHandler>*)nodeHandler error:(NSError**)error;


	// use these two in asynchronous applications, with a call to create an NSURLConnection after the first, finally passing the returned data to the second
-(NSURLRequest*)makeRequest:(NSDictionary*)params 
					timeout:(NSTimeInterval)timeout;

-(void)processResponseDocument:(NSData*)returnedData 
				   nodeHandler:(NSObject<XPathNodeHandler>*)nodeHandler;

@end
