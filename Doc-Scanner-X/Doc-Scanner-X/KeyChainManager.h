//
//  KeyChainManager.h
//  Doc-Scanner-X
//
//  Created by dynamsoft on 2018/1/12.
//  Copyright © 2018年 com.dynamsoft. All rights reserved.
//

#ifndef KeyChainManager_h
#define KeyChainManager_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Security/Security.h>

@interface KeyChainManager : NSObject

+ (void) saveUUID:(nonnull NSString*)uuid;

+ (nullable NSString*) readUUID;

@end
#endif /* KeyChainManager_h */
