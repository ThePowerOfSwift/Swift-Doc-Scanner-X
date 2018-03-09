//
//  LocalData.h
//  Doc-Scanner-X
//
//  Created by dynamsoft on 2017/11/28.
//  Copyright © 2017年 com.dynamsoft. All rights reserved.
//

#ifndef LocalData_h
#define LocalData_h

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface LocalData : NSObject <NSCoding>

#pragma mark - Properties

@property NSString* dataName;

@property NSUInteger dataType;

@property NSString* dataTimeStamp;


#pragma mark - Initialization

- (instancetype) init:(NSString*)dataName dataType:(NSUInteger)dataType dataTimeStamp:(NSString*)dataTimeStamp;


#pragma mark - NSCoding

- (instancetype) initWithCoder:(NSCoder *)aDecoder;

- (void) encodeWithCoder:(NSCoder*)aCoder;

#pragma mark - ArchiveURL getter

+ (NSURL*) getArchiveURL;

@end

#endif /* LocalData_h */
