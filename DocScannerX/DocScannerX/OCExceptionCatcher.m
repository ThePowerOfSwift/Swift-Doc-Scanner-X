#import "OCExceptionCatcher.h"

@implementation OCExceptionCatcher

+ (BOOL)captureException:(void (^)())tryBlock error:(NSError *__autoreleasing *)error {
    @try {
        tryBlock();
        return YES;
    } @catch (NSException *exception) {
        *error = [[NSError alloc] initWithDomain:exception.reason code:0 userInfo:exception.userInfo];
        return NO;
    }
}

@end
