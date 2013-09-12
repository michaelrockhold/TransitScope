//
//  XPathQuery.h
//  FuelFinder
//
//  Created by Matt Gallagher on 4/08/08.
//  Copyright 2008 Matt Gallagher. All rights reserved.
//
//  Permission is given to use this source code file without charge in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.
//

#import <Foundation/Foundation.h>

@class XPathNodeAttribute;
@class XPathAttr;
@protocol XPathNodeHandler;

@interface XPathNode : NSObject
{
	NSString* m_name;
	NSMutableString* m_content;
	NSMutableArray* m_attributes;
	NSMutableArray* m_children;
}

+ (void)initialize;

+ (void)closeXmlLib;

+ (void)performXPathQueryOnDocPtr:(void*)xmlDocPtr Query:(NSString *)query Prefix:(NSString *)prefix Namespace:(NSString *)namespaceURI XPathNodeHandler:(id <XPathNodeHandler>)handler;

+ (void)performHTMLXPathQueryOnDocument:(NSData *)document Query:(NSString *)query Prefix:(NSString *)prefix Namespace:(NSString *)namespaceURI XPathNodeHandler:(id <XPathNodeHandler>)handler;

+ (void)performXMLXPathQueryOnDocument:(NSData *)document Query:(NSString *)query Prefix:(NSString *)prefix Namespace:(NSString *)namespaceURI XPathNodeHandler:(id <XPathNodeHandler>)handler;


+ (XPathNode*)CreateFromXmlNodePtr:(void*)pXmlNodePtr Parent:(XPathNode*)parent;

+ (NSDictionary*)nodeArrayToDictionary:(NSArray*)nodes;

- (id)init;

- (void)appendContent:(NSString*)stuff;

- (void)addChild:(XPathNode*)child;

- (void)addAttribute:(XPathAttr*)attr;

@property (strong, nonatomic) NSString* name;
@property (strong, nonatomic, readonly) NSString* content;
@property (strong, nonatomic, readonly) NSArray* attributes;
@property (strong, nonatomic, readonly) NSArray* children;
@property (strong, nonatomic, readonly) NSDictionary* childrenAsDictionary;


@end

@interface XPathAttr : NSObject
{
	NSString* m_name;
	XPathNode* m_content;
}

- (id)initWithName:(NSString*)name Content:(XPathNode*)node;

@property (strong, nonatomic, readonly) NSString* name;
@property (strong, nonatomic, readonly) XPathNode* content;

@end

@protocol XPathNodeHandler
-(void)handleNode:(XPathNode*)node;
@end
