

#import <Foundation/Foundation.h>

@interface OCExceptionCatcher : NSObject

+ (BOOL)captureException:(void(^)())tryBlock error:(__autoreleasing NSError **)error;

@end
