//
//  VOCustomNSURLProtocol.h
//  voPlayer
//
//  Created by voApp on 5/8/14.
//  Copyright (c) 2014 Lin Cheng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VOCustomNSURLProtocol : NSURLProtocol
+ (BOOL)canInitWithRequest:(NSURLRequest *)request;
+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request;
- (void)startLoading;
- (void)stopLoading;
@end
