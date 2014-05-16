//
//  VOAES128Wrapper.m
//  voPlayer
//
//  Created by voApp on 5/8/14.
//  Copyright (c) 2014 Lin Cheng. All rights reserved.
//

#import "VOAES128Wrapper.h"
#import "VOKeyChainManagement.h"
#import "VOCustomNSURLProtocol.h"
#import <Security/Security.h>
#import <CommonCrypto/CommonCrypto.h>

@interface VOAES128Wrapper ()

@property (nonatomic, retain) NSString *encryptKey;
@property (nonatomic, retain) NSData *decryptKey;

- (NSString *)generate16BytesAESKey;

@end

@implementation VOAES128Wrapper

@synthesize isEncryptKeyChanged, isDncryptKeyChanged;
@synthesize encryptKey, decryptKey;


- (id)init
{
    if (self = [super init]) {
        // register the custom url protocol to hanle the request.
        [NSURLProtocol registerClass:[VOCustomNSURLProtocol class]];
        isEncryptKeyChanged = YES;
        isDncryptKeyChanged = YES;
    }
    return self;
}

- (void)dealloc
{
    // unregister the custom url protocol
    [NSURLProtocol unregisterClass:[VOCustomNSURLProtocol class]];
    
    // clean the crypt data and id in keychain
    [VOKeyChainManagement deleteAllKeyDataUseInApp];
    
    encryptKey = nil;
    decryptKey = nil;
    
    [super dealloc];
}

#pragma mark -- Private 

- (NSString *)generate16BytesAESKey
{
    NSString *randVal = @"";
    
    //[0~9],[a~z],[A~Z]
    NSArray *generateBaseList = [NSArray arrayWithObjects:@"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"a", @"b", @"c", @"d", @"e", @"f", @"g", @"h", @"i", @"j", @"k", @"l", @"m", @"n", @"o", @"p", @"q", @"r", @"s", @"t", @"u", @"v", @"w", @"x", @"y", @"z", @"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z", nil];
    
    for (int i = 0; i < kCCBlockSizeAES128; i++)
    {
        int idx = arc4random() % [generateBaseList count];
        randVal = [randVal stringByAppendingString:[generateBaseList objectAtIndex:idx]];
    }
    
    NSString *retVal = [randVal length] > 0 ? randVal : nil;
    return retVal;
}

#pragma mark -- Enerypt and Decrypt

- (NSData *)encryptData:(const void *)clrData dataSize:(unsigned int)dataSize encryptKeyId:(const void *)encryptKeyId
{
    NSData *encryptedData = nil;
    
    if (isEncryptKeyChanged)
    {
        isEncryptKeyChanged = NO;
        // generate the encrypt key and store in keychain with id
        encryptKey = [self generate16BytesAESKey];
        BOOL isSuccess = [VOKeyChainManagement saveKeyData:encryptKey withKeyID:encryptKeyId];
        if (!isSuccess) {
            return encryptedData;
        }
    }
    
    size_t bufferSize = dataSize + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding,
                                          [encryptKey UTF8String], kCCKeySizeAES128,
                                          NULL,
                                          clrData, dataSize,
                                          buffer, bufferSize,
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess)
    {
        encryptedData = [NSData dataWithBytes:buffer length:numBytesEncrypted];
    }
    free(buffer);
    return encryptedData;
}

- (NSData *)decryptData:(const void *)encData dataSize:(unsigned int)dataSize decryptKeyId:(const void *)decryptKeyId
{
    NSData *decryptData = nil;
    
    if (decryptKeyId)
    {
        // retrieve the key data with keyId in keychain
        if (isDncryptKeyChanged) {
            isDncryptKeyChanged = NO;
            decryptKey = [VOKeyChainManagement retrieveKeyData:decryptKeyId];
            if (!decryptKey) {
                return decryptData;
            }
        }
        
        size_t bufferSize = dataSize + kCCBlockSizeAES128;
        void *buffer = malloc(bufferSize);
        
        size_t numBytesDecrypted = 0;
        CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmAES128,
                                              kCCOptionPKCS7Padding,
                                              [decryptKey bytes], kCCKeySizeAES128,
                                              NULL,
                                              encData, dataSize,
                                              buffer, bufferSize,
                                              &numBytesDecrypted);
        if (cryptStatus == kCCSuccess)
        {
            decryptData = [NSData dataWithBytes:buffer length:numBytesDecrypted];
        }
        free(buffer);
    }
    return decryptData;
}

@end
