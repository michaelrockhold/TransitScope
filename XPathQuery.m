//
//  XPathQuery.m
//  FuelFinder
//
//  Created by Matt Gallagher on 4/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//
//  Permission is given to use this source code file without charge in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.
//

#import "XPathQuery.h"

#import <libxml/tree.h>
#import <libxml/parser.h>
#import <libxml/HTMLparser.h>
#import <libxml/xpath.h>
#import <libxml/xpathInternals.h>
#include <dlfcn.h>

typedef int XMLCALL (*fn_xmlXPathRegisterNs)(xmlXPathContextPtr ,const xmlChar *,const xmlChar *);
static fn_xmlXPathRegisterNs gpxmlXPathRegisterNs;

typedef xmlXPathObjectPtr XMLCALL (*fn_xmlXPathEvalExpression)(const xmlChar *, xmlXPathContextPtr);
static fn_xmlXPathEvalExpression gpxmlXPathEvalExpression;

typedef xmlXPathContextPtr XMLCALL (*fn_xmlXPathNewContext)(xmlDocPtr);
static fn_xmlXPathNewContext gpxmlXPathNewContext;

typedef htmlDocPtr XMLCALL (*fn_htmlReadMemory)(const char *, int, const char *, const char *, int);
static fn_htmlReadMemory gphtmlReadMemory;

typedef void XMLCALL (*fn_xmlXPathFreeObject)(xmlXPathObjectPtr);
static fn_xmlXPathFreeObject gpxmlXPathFreeObject;

typedef void XMLCALL (*fn_xmlXPathFreeContext)(xmlXPathContextPtr);
static fn_xmlXPathFreeContext gpxmlXPathFreeContext;

typedef xmlDocPtr XMLCALL (*fn_xmlReadMemory)(const char *, int, const char *, const char *, int);
static fn_xmlReadMemory gpxmlReadMemory;

typedef void XMLCALL (*fn_xmlFreeDoc)(xmlDocPtr);
static fn_xmlFreeDoc gpxmlFreeDoc;

static void* gxmllib = NULL;

/* ---------------------------------------------------------------------*/
int XMLCALL		   
privXmlXPathRegisterNs(xmlXPathContextPtr ctxt,
						 const xmlChar *prefix,
						 const xmlChar *ns_uri)
{
	return (*gpxmlXPathRegisterNs)(ctxt,prefix,ns_uri);
}

xmlXPathObjectPtr XMLCALL  
privXmlXPathEvalExpression(const xmlChar *str,
						 xmlXPathContextPtr ctxt)
{
	return (*gpxmlXPathEvalExpression)(str, ctxt);
}

xmlXPathContextPtr XMLCALL 
privXmlXPathNewContext(xmlDocPtr doc)
{
	return (*gpxmlXPathNewContext)(doc);
}

htmlDocPtr XMLCALL
privHtmlReadMemory(const char *buffer,
					 int size,
					 const char *URL,
					 const char *encoding,
					 int options)
{
	return (*gphtmlReadMemory)(buffer, size, URL, encoding, options);
}

void XMLCALL		   
privXmlXPathFreeObject(xmlXPathObjectPtr obj)
{
	return (*gpxmlXPathFreeObject)(obj);
}

void XMLCALL
privXmlXPathFreeContext(xmlXPathContextPtr ctxt)
{
	return (*gpxmlXPathFreeContext)(ctxt);
}

xmlDocPtr XMLCALL
privXmlReadMemory(const char *buffer,
					 int size,
					 const char *URL,
					 const char *encoding,
					 int options)
{
	return (*gpxmlReadMemory)(buffer, size, URL, encoding, options);
}

void XMLCALL		
privXmlFreeDoc(xmlDocPtr cur)
{
	return (*gpxmlFreeDoc)(cur);
}

/* ---------------------------------------------------------------------*/

#define xmlXPathRegisterNs(c,p,u) privXmlXPathRegisterNs(c,p,u)

#define xmlXPathEvalExpression(s,c) privXmlXPathEvalExpression(s,c)

#define xmlXPathNewContext(d) privXmlXPathNewContext(d)

#define htmlReadMemory(b,s,u,e,o) privHtmlReadMemory(b,s,u,e,o)

#define xmlXPathFreeObject(o) privXmlXPathFreeObject(o)

#define xmlXPathFreeContext(c) privXmlXPathFreeContext(c)

#define xmlReadMemory(b,s,u,e,o) privXmlReadMemory(b,s,u,e,o)

#define xmlFreeDoc(c) privXmlFreeDoc(c)
/* ---------------------------------------------------------------------*/

XPathNode* XPathNodeFromXmlNodePtr(xmlNodePtr currentNode, XPathNode* parent);

@implementation XPathNode

@synthesize name = m_name, content = m_content, attributes = m_attributes, children = m_children;

+ (void)initialize
{
	gxmllib = dlopen("/usr/lib/libxml2.dylib", RTLD_NOW);
	
	gpxmlXPathRegisterNs = dlsym(gxmllib, "xmlXPathRegisterNs");
	gpxmlXPathEvalExpression = dlsym(gxmllib, "xmlXPathEvalExpression");
	gpxmlXPathNewContext = dlsym(gxmllib, "xmlXPathNewContext");
	gphtmlReadMemory = dlsym(gxmllib, "htmlReadMemory");
	gpxmlXPathFreeObject = dlsym(gxmllib, "xmlXPathFreeObject");
	gpxmlXPathFreeContext = dlsym(gxmllib, "xmlXPathFreeContext");
	gpxmlReadMemory = dlsym(gxmllib, "xmlReadMemory");
	gpxmlFreeDoc = dlsym(gxmllib, "xmlFreeDoc");	
}

+ (void) closeXmlLib
{
	dlclose(gxmllib);
}

-(NSString*)description
{
	return [NSString stringWithFormat:@"XPathNode name = %@,\n     content = %@,\n     children = (%@),\n     attributes= (%@)\n",
							 self.name, self.content, self.children, self.attributes];
}

+ (void)performHTMLXPathQueryOnDocument:(NSData *)document Query:(NSString *)query Prefix:(NSString *)prefix Namespace:(NSString *)namespaceURI XPathNodeHandler:(id <XPathNodeHandler>)handler
{
    xmlDocPtr doc;
	
    /* Load XML document */
	doc = htmlReadMemory([document bytes], [document length], "", NULL, HTML_PARSE_NOWARNING | HTML_PARSE_NOERROR);
	
    if (doc == NULL)
	{
		NSLog(@"Unable to parse.");
    }
	
	[XPathNode performXPathQueryOnDocPtr:doc Query:query Prefix:prefix Namespace:namespaceURI XPathNodeHandler:handler];
    xmlFreeDoc(doc); 
}

+ (void)performXMLXPathQueryOnDocument:(NSData *)document Query:(NSString *)query Prefix:(NSString *)prefix Namespace:(NSString *)namespaceURI XPathNodeHandler:(id <XPathNodeHandler>)handler
{
    xmlDocPtr doc;
	
    /* Load XML document */
	doc = xmlReadMemory([document bytes], [document length], "", NULL, XML_PARSE_RECOVER);
	
    if (doc == NULL)
	{
		NSLog(@"Unable to parse.");
    }
	
	[XPathNode performXPathQueryOnDocPtr:doc Query:query Prefix:prefix Namespace:namespaceURI XPathNodeHandler:handler];
    xmlFreeDoc(doc); 
}

+ (void)performXPathQueryOnDocPtr:(void*)doc Query:(NSString *)query Prefix:(NSString *)prefix Namespace:(NSString *)namespaceURI XPathNodeHandler:(id <XPathNodeHandler>)handler
{
    xmlXPathContextPtr xpathCtx = NULL; 
    xmlXPathObjectPtr xpathObj= NULL; 
	
    /* Create xpath evaluation context */
    xpathCtx = xmlXPathNewContext((xmlDocPtr)doc);
    if ( xpathCtx == NULL )
	{
		NSLog(@"Unable to create XPath context.");
		goto cleanup;
    }
    
	if ( prefix != nil && namespaceURI != nil )
	{
		if ( xmlXPathRegisterNs(xpathCtx, (xmlChar *)[prefix cStringUsingEncoding:NSUTF8StringEncoding], (xmlChar *)[namespaceURI cStringUsingEncoding:NSUTF8StringEncoding]) != 0 )
		{
			NSLog(@"Unable to register namespace.");
			goto cleanup;
		}
	}
	
    /* Evaluate xpath expression */
    xpathObj = xmlXPathEvalExpression((xmlChar *)[query cStringUsingEncoding:NSUTF8StringEncoding], xpathCtx);
    if ( xpathObj == NULL )
	{
		NSLog(@"Unable to evaluate XPath.");
		goto cleanup;
    }
	
	xmlNodeSetPtr nodes = xpathObj->nodesetval;
	if ( !nodes )
	{
		NSLog(@"Nodes was nil.");
		goto cleanup;
	}
	
	NSInteger i;
	for (i = 0; i < nodes->nodeNr; i++)
	{
		XPathNode* xpathnode = [XPathNode CreateFromXmlNodePtr:nodes->nodeTab[i] Parent:nil];
		if ( xpathnode )
		{
			[handler handleNode:xpathnode];
		}
	}
	
cleanup:
    /* Cleanup */
    if (xpathObj != NULL) xmlXPathFreeObject(xpathObj);
    if (xpathCtx != NULL) xmlXPathFreeContext(xpathCtx); 
}

- (void)appendContent:(NSString*)stuff
{
	[m_content appendString:stuff];
}

- (void)addChild:(XPathNode*)child
{
	if ( child != nil )
		[m_children addObject:child];
}

- (void)addAttribute:(XPathAttr*)attr
{
	if ( attr != nil )
		[m_attributes addObject:attr];
}

- (NSDictionary*)childrenAsDictionary
{	
	NSMutableDictionary* mdi = [NSMutableDictionary dictionaryWithCapacity:self.children.count];
	
		//NSLog(@"Node Children: %@\n", self.children);
	for (XPathNode* n in self.children)
	{
		[mdi setValue:n.content forKey:n.name];			
	}
	return mdi;
}

+ (XPathNode*) CreateFromXmlNodePtr:(void*)pXmlNodePtr Parent:(XPathNode*)parent
{
	XPathNode* resultNode = [[XPathNode alloc] init];
	
	xmlNodePtr pNode = (xmlNodePtr)pXmlNodePtr;
	
	if ( pNode->name )
	{
		resultNode.name = [NSString stringWithCString:(const char *)pNode->name encoding:NSUTF8StringEncoding];
	}
	
	if ( pNode->content && pNode->content != (xmlChar *)-1 )
	{
		NSString *currentNodeContent = [NSString stringWithCString:(const char *)pNode->content encoding:NSUTF8StringEncoding];
		
		if ( [resultNode.name isEqual:@"text"] && parent != nil )
		{
			[parent appendContent:[currentNodeContent stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
			return nil;
		}
		//else
		[resultNode appendContent:currentNodeContent];
	}
	
	xmlAttr *attribute = pNode->properties;
	if ( attribute )
	{
		do
		{
			XPathAttr* attr = [[XPathAttr alloc] initWithName:[NSString stringWithCString:(const char *)attribute->name encoding:NSUTF8StringEncoding]
									Content:[XPathNode CreateFromXmlNodePtr:attribute->children Parent:nil]];
			[resultNode addAttribute:attr];
			attribute = attribute->next;
		} while ( attribute );
	}
	
	xmlNodePtr childNode = pNode->children;
	if ( childNode )
	{
		do
		{
			[resultNode addChild:[XPathNode CreateFromXmlNodePtr:childNode Parent:resultNode]];
            childNode = childNode->next;
		} while ( childNode );		
	}
	
	return resultNode;
}

+ (NSDictionary*)nodeArrayToDictionary:(NSArray*)nodes
{	
	NSMutableDictionary* mdi = [NSMutableDictionary dictionaryWithCapacity:nodes.count];

	if ( nodes != nil )
	{
		for (XPathNode* n in nodes)
		{
			[mdi setValue:n.content forKey:n.name];			
		}
	}
	return mdi;
}

- (id)init
{
	if ( self = [super init] )
	{
		self.name = nil;
		m_content = [NSMutableString string];
		m_attributes = [NSMutableArray array];
		m_children = [NSMutableArray array];
	}
	return self;
}


@end

@implementation XPathAttr 

@synthesize name = m_name, content = m_content;

- (id)initWithName:(NSString*)name Content:(XPathNode*)node
{
	if ( self = [self init] )
	{
		m_name = name;
		m_content = node;
	}
	return self;
}


@end




