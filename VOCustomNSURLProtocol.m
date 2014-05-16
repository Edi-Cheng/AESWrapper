//
//  VOCustomNSURLProtocol.m
//  voPlayer
//
//  Created by voApp on 5/8/14.
//  Copyright (c) 2014 Lin Cheng. All rights reserved.
//

#import "VOCustomNSURLProtocol.h"
#import "VOKeyChainManagement.h"

// Custom URL scheme name
NSString * const VO_CUSTOM_SCHEME_NAME = @"CLKEY";

@implementation VOCustomNSURLProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
	return ([[[request URL] scheme] isEqualToString:VO_CUSTOM_SCHEME_NAME]);
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request
{
    return request;
}

- (void)startLoading
{
    NSURLRequest *request = [self request];
    NSString *requestString = request.URL.relativeString;
    
    // Get the keyId in request and retrieve the keyData in keychain.
    NSArray *stringArray = [requestString componentsSeparatedByString:@"//"];
    NSData *keyData = [VOKeyChainManagement retrieveKeyData:stringArray.lastObject];

	// Now return the data as a url response.
	NSURLResponse *response = [[NSURLResponse alloc] initWithURL:[request URL] MIMEType:@"text/plain" expectedContentLength:[keyData length] textEncodingName:nil];
    
	id client = [self client];
	[client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
	NSData *data = [[NSData alloc] initWithBytes:[keyData bytes] length:[keyData length]];
	[client URLProtocol:self didLoadData:data];
	[client URLProtocolDidFinishLoading:self];
	[data release];
	[response release];
}

- (void)stopLoading
{
    //NSLog(@"something went wrong!");
}

@end
