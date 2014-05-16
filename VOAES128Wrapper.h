//
//  VOAES128Wrapper.h
//  voPlayer
//
//  Created by voApp on 5/8/14.
//  Copyright (c) 2014 Lin Cheng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VOAES128Wrapper : NSObject

@property (nonatomic, assign) BOOL isEncryptKeyChanged;
@property (nonatomic, assign) BOOL isDncryptKeyChanged;

// Initialize
- (id)init;

// Encrypt and Decrypt
- (NSData *)encryptData:(const void *)clrData dataSize:(unsigned int)dataSize encryptKeyId:(const void *)encryptKeyId;
- (NSData *)decryptData:(const void *)encData dataSize:(unsigned int)dataSize decryptKeyId:(const void *)decryptKeyId;

@end
