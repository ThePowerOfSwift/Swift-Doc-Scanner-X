//
//  LocalData.m
//  Doc-Scanner-X
//
//  Created by dynamsoft on 2017/11/27.
//  Copyright © 2017年 com.dynamsoft. All rights reserved.
//

#import "LocalData.h"

#define NAME      (@"dataName")
#define TYPE      (@"dataType")
#define TIMESTAMP (@"dataTimeStamp")

@implementation LocalData


- (instancetype) init:(NSString *)dataName dataType:(NSUInteger)dataType dataTimeStamp:(NSString *)dataTimeStamp {
    self = [super init];
    if (self) {
        self.dataName = dataName;
        self.dataType = dataType;
        self.dataTimeStamp = dataTimeStamp;
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_dataName forKey:NAME];
    [aCoder encodeInteger:_dataType forKey:TYPE];
    [aCoder encodeObject:_dataTimeStamp forKey:TIMESTAMP];
}

- (instancetype) initWithCoder:(NSCoder *)aDecoder {
    self.dataName = (NSString*)[aDecoder decodeObjectForKey:NAME];
    self.dataType = (NSUInteger)[aDecoder decodeIntegerForKey:TYPE];
    self.dataTimeStamp = (NSString*)[aDecoder decodeObjectForKey:TIMESTAMP];
    return self;
}

+ (NSURL*) getArchiveURL {
    NSArray* a = [NSArray array];
    a = [NSArray array];
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask].firstObject URLByAppendingPathComponent:@"/localdata"];
}

@end
