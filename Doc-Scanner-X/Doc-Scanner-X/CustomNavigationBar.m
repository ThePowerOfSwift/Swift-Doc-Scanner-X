//
//  CustomNavigationBar.m
//  Doc-Scanner-X
//
//  Created by dynamsoft on 2017/11/27.
//  Copyright © 2017年 com.dynamsoft. All rights reserved.
//

#import "CustomNavigationBar.h"

@implementation CustomNavigationBar

- (void) layoutSubviews {
    [super layoutSubviews];
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"11.0")) {
        for (UIView* view in self.subviews) {
            NSString* str = NSStringFromClass(view.class);
            if ([str containsString:@"Background"]) {
                view.frame = self.bounds;
            } else if ([str containsString:@"ContentView"]) {
                view.frame = CGRectMake(0, 20, self.frame.size.width, self.frame.size.height-20);
            }
        }
    }
}

@end
