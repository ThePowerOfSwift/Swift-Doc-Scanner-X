//
//  KeyChainManager.m
//  Doc-Scanner-X
//
//  Created by dynamsoft on 2018/1/12.
//  Copyright © 2018年 com.dynamsoft. All rights reserved.
//

#import "KeyChainManager.h"

@implementation KeyChainManager

+ (void) saveUUID:(NSString*)uuid {
    NSDictionary* keyChainItem = [[NSDictionary alloc] initWithObjectsAndKeys:(NSString*)kSecClass,kSecAttrAccount,(NSString*)kSecValueData,uuid, nil];
    SecItemAdd((CFDictionaryRef)keyChainItem, nil);
}

+ (NSString*) readUUID {
    id result;
    NSDictionary* query = [[NSDictionary alloc] initWithObjectsAndKeys:(NSString*)kSecClass,kSecAttrAccount,(NSString*)kSecReturnData,kCFBooleanTrue,(NSString*)kSecMatchLimit, kSecMatchLimitOne, nil];
    
    SecItemCopyMatching((CFDictionaryRef)query, (CFTypeRef)&result);
    NSString* uuid = (NSString*)result;
    if (uuid == nil) {
        uuid = [UIDevice currentDevice].identifierForVendor.UUIDString;
        [self saveUUID:uuid];
        return uuid;
    } else {
        return uuid;
    }
}
@end
