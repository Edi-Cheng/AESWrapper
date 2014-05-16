//
//  VOKeyChainManagement.m
//  voPlayer
//
//  Created by voApp on 5/8/14.
//  Copyright (c) 2014 Lin Cheng. All rights reserved.
//

#import "VOKeyChainManagement.h"
#import <Security/Security.h>

static NSString *keychainAttributeServiceName = @"com.aes128crypt.keychainAttributeServiceName";

@implementation VOKeyChainManagement

+ (NSMutableDictionary *)newSearchDictionary
{
    NSMutableDictionary *searchDictionary = [[NSMutableDictionary alloc] init];
    
    [searchDictionary setObject:(id)kSecClassGenericPassword forKey:(id)kSecClass];
    [searchDictionary setObject:keychainAttributeServiceName forKey:(id)kSecAttrService];
    
    return searchDictionary;
}

+ (BOOL)saveKeyData:(NSString *)data withKeyID:(NSString *)identifier
{
    NSMutableDictionary *searchDictionary = [self newSearchDictionary];
    
    NSData *encodedIdentifier = [identifier dataUsingEncoding:NSUTF8StringEncoding];
    [searchDictionary setObject:encodedIdentifier forKey:(id)kSecAttrGeneric];
    [searchDictionary setObject:encodedIdentifier forKey:(id)kSecAttrAccount];
    
    NSData *passwordData = [data dataUsingEncoding:NSUTF8StringEncoding];
    [searchDictionary setObject:passwordData forKey:(id)kSecValueData];
    
    NSData *result = nil;
    OSStatus status = SecItemAdd((CFDictionaryRef)searchDictionary, (CFTypeRef *)&result);
    [searchDictionary release];
    
    if (status == errSecSuccess) {
        return YES;
    } else if (status == errSecDuplicateItem) {
        return [self updateKeychainValue:data forIdentifier:identifier];
    }
    return NO;
}

+ (NSData *)retrieveKeyData:(NSString *)identifier
{
    NSMutableDictionary *searchDictionary = [self newSearchDictionary];
    
    NSData *encodedIdentifier = [identifier dataUsingEncoding:NSUTF8StringEncoding];
    [searchDictionary setObject:encodedIdentifier forKey:(id)kSecAttrGeneric];
    [searchDictionary setObject:encodedIdentifier forKey:(id)kSecAttrAccount];
    
    // Add search attributes
    [searchDictionary setObject:(id)kSecMatchLimitOne forKey:(id)kSecMatchLimit];
    
    // Add search return types
    [searchDictionary setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnData];
    
    NSData *result = nil;
    OSStatus status = SecItemCopyMatching((CFDictionaryRef)searchDictionary,
                                          (CFTypeRef *)&result);
    
    if (status != errSecSuccess) {
        //NSLog(@"status = %d", (int)status);
    }
    
    [searchDictionary release];
    return result;
}

+ (BOOL)updateKeyData:(NSString *)data withKeyID:(NSString *)identifier
{
    NSMutableDictionary *searchDictionary = [self newSearchDictionary];
    NSData *encodedIdentifier = [identifier dataUsingEncoding:NSUTF8StringEncoding];
    [searchDictionary setObject:encodedIdentifier forKey:(id)kSecAttrGeneric];
    [searchDictionary setObject:encodedIdentifier forKey:(id)kSecAttrAccount];
    
    NSMutableDictionary *updateDictionary = [[NSMutableDictionary alloc] init];
    NSData *passwordData = [data dataUsingEncoding:NSUTF8StringEncoding];
    [updateDictionary setObject:passwordData forKey:(id)kSecValueData];
    
    OSStatus status = SecItemUpdate((CFDictionaryRef)searchDictionary,
                                    (CFDictionaryRef)updateDictionary);
    
    [searchDictionary release];
    [updateDictionary release];
    
    if (status == errSecSuccess) {
        return YES;
    }
    return NO;

}

+ (BOOL)updateKeychainValue:(NSString *)data forIdentifier:(NSString *)identifier
{
    NSMutableDictionary *searchDictionary = [self newSearchDictionary];
    NSData *encodedIdentifier = [identifier dataUsingEncoding:NSUTF8StringEncoding];
    [searchDictionary setObject:encodedIdentifier forKey:(id)kSecAttrGeneric];
    [searchDictionary setObject:encodedIdentifier forKey:(id)kSecAttrAccount];
    
    NSMutableDictionary *updateDictionary = [[NSMutableDictionary alloc] init];
    NSData *passwordData = [data dataUsingEncoding:NSUTF8StringEncoding];
    [updateDictionary setObject:passwordData forKey:(id)kSecValueData];
    
    OSStatus status = SecItemUpdate((CFDictionaryRef)searchDictionary,
                                    (CFDictionaryRef)updateDictionary);
    
    [searchDictionary release];
    [updateDictionary release];
    
    if (status == errSecSuccess) {
        return YES;
    }
    return NO;
}


+ (BOOL)deleteKeyData:(NSString *)identifier
{
    NSMutableDictionary *searchDictionary = [self newSearchDictionary];
    NSData *encodedIdentifier = [identifier dataUsingEncoding:NSUTF8StringEncoding];
    [searchDictionary setObject:encodedIdentifier forKey:(id)kSecAttrGeneric];
    [searchDictionary setObject:encodedIdentifier forKey:(id)kSecAttrAccount];
    
    OSStatus status = SecItemDelete((CFDictionaryRef)searchDictionary);
    [searchDictionary release];
    if (status == errSecSuccess) {
        return YES;
    }
    return NO;

}

+ (BOOL)deleteAllKeyDataUseInApp
{
    NSMutableDictionary *searchDictionary = [self newSearchDictionary];
    OSStatus status = SecItemDelete((CFDictionaryRef)searchDictionary);
    [searchDictionary release];
    if (status == errSecSuccess) {
        return YES;
    }
    return NO;
}

@end
