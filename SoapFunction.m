//
//  SoapFunction.m
//  SOAP_AuthExample
//
//  Created by Michael Rockhold on 6/28/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SoapFunction.h"

@implementation SoapFunction

- (id)initWithUrl:(NSString*)url
		   Method:(NSString*)method
		Namespace:(NSString*)ns
	   SoapAction:(NSString*)soapAction
	   ParamOrder:(NSArray*)paramOrder
	ResponseQuery:(NSString*)responseQuery
   ResponsePrefix:(NSString*)responsePrefix
ResponseNamespace:(NSString*)responseNamespace
{
	if ( self = [self init] )
	{
		m_url = [[NSURL URLWithString:url] retain];
		m_method = [method retain];
		m_namespace = [ns retain];
		m_soapAction = [soapAction retain];
		m_reqHeaders = [[NSDictionary dictionaryWithObject:soapAction forKey:@"SOAPAction"] retain];
		m_paramOrder = [paramOrder retain];
		m_responseQuery = [responseQuery retain];
		m_responsePrefix = [responsePrefix retain];
		m_responseNamespace = [responseNamespace retain];
	}
	return self;
}

- (void)dealloc
{
	[m_url release];
	[m_method release];
	[m_namespace release];
	[m_soapAction release];
	[m_paramOrder release];
	[m_reqHeaders release];
	[m_responseQuery release];
	[m_responsePrefix release];
	[m_responseNamespace release];
	[super dealloc];
}

-(NSURLRequest*)makeRequest:(NSDictionary*)params timeout:(NSTimeInterval)timeout
{
	NSMutableString* soapMessage = [NSMutableString stringWithFormat:
									@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\
									<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\
									<soap:Body>\
									<%@ xmlns=\"%@\">",
									m_method,
									m_namespace];
	
	for (NSString* param in m_paramOrder)
	{
		[soapMessage appendString:[NSString stringWithFormat:
								   @"<%@>%@</%@>",
								   param,
								   [params valueForKey:param],
								   param
								   ]];
	}
	
	[soapMessage appendString:[NSString stringWithFormat:
							   @"</%@>\
							   </soap:Body>\
							   </soap:Envelope>",
							   m_method
							   ]];
	
	NSData* msgData = [soapMessage dataUsingEncoding:NSUTF8StringEncoding];
	
	NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:m_url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:timeout];
	[request addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
	[request addValue:m_soapAction forHTTPHeaderField:@"SOAPAction"];
	[request addValue:[NSString stringWithFormat:@"%lu", (unsigned long)[msgData length]] forHTTPHeaderField:@"Content-Length"];
	[request setHTTPMethod:@"POST"];
	[request setHTTPBody:msgData];
	
	return request;
}

- (void)executeRequestSynchronously:(NSURLRequest*)request nodeHandler:(NSObject<XPathNodeHandler>*)nodeHandler error:(NSError**)error
{
	NSHTTPURLResponse* theHttpUrlResponse = nil;
	NSData* returnedData = nil;
	
	@try
	{		
		returnedData = [NSURLConnection sendSynchronousRequest:request returningResponse:&theHttpUrlResponse error:error];
	}
	@catch (NSException* e)
	{
		*error = [NSError errorWithDomain:@"com.rockholdco.SoapFunction" code:1 userInfo:[NSDictionary dictionaryWithObject:e forKey:@"exception"]];
		returnedData = nil;
	}
	
	if ( theHttpUrlResponse && [theHttpUrlResponse statusCode] != 200 )
	{
		*error = [NSError errorWithDomain:@"com.rockholdco.SoapFunction" code:2 userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:[theHttpUrlResponse statusCode]] forKey:@"httpstatuscode"]];
		returnedData = nil;
	}
	
	if ( returnedData == nil || [returnedData length] == 0 )
		return;
	
	[XPathNode performXMLXPathQueryOnDocument:returnedData Query:m_responseQuery Prefix:m_responsePrefix Namespace:m_responseNamespace XPathNodeHandler:nodeHandler];
}

- (BOOL)Invoke:(NSDictionary*)params nodeHandler:(NSObject<XPathNodeHandler>*)nodeHandler timeout:(NSTimeInterval)timeout error:(NSError**)error
{
	[self executeRequestSynchronously:[self makeRequest:params timeout:timeout] nodeHandler:nodeHandler error:error];
	if ( !error )
		return YES;
	else 
		return !*error;
}

- (void)processResponseDocument:(NSData*)returnedData nodeHandler:(NSObject<XPathNodeHandler>*)nodeHandler
{
	[XPathNode performXMLXPathQueryOnDocument:returnedData Query:m_responseQuery Prefix:m_responsePrefix Namespace:m_responseNamespace XPathNodeHandler:nodeHandler];
}

/* Example response from a bad invocation:
 <?xml version="1.0" encoding="utf-8"?>
 <soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
 <soap:Body>
 <soap:Fault>
 <faultcode>soap:Server.userException</faultcode>
 <faultstring>java.lang.IllegalArgumentException: bad request: its.app.mybus.store2.ser.LocationRequest@22e4bc</faultstring> 
 <detail />
 </soap:Fault>
 </soap:Body>
 </soap:Envelope>
 */

/*
 <?xml version="1.0" encoding="utf-8"?>
 <soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
 <soap:Body>
 <getEventEstimatesIResponse xmlns="http://dotnet.ws.its.washington.edu"><getEventEstimatesIResult /></getEventEstimatesIResponse>
 </soap:Body>
 </soap:Envelope>
 */

@end
