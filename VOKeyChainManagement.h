//
//  VOKeyChainManagement.h
//  voPlayer
//
//  Created by voApp on 5/8/14.
//  Copyright (c) 2014 Lin Cheng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VOKeyChainManagement : NSObject

+ (BOOL)saveKeyData:(NSString *)data withKeyID:(NSString *)identifier;

+ (NSData *)retrieveKeyData:(NSString *)identifier;

+ (BOOL)updateKeyData:(NSString *)data withKeyID:(NSString *)identifier;

+ (BOOL)deleteKeyData:(NSString *)identifier;

+ (BOOL)deleteAllKeyDataUseInApp;

@end
