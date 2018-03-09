//
//  CustomTableViewCell.m
//  Doc-Scanner-X
//
//  Created by dynamsoft on 2018/1/12.
//  Copyright © 2018年 com.dynamsoft. All rights reserved.
//

#import "CustomTableViewCell.h"

@implementation CustomTableViewCell

- (void)layoutSubviews {
    [super layoutSubviews];
    self.imageView.frame = CGRectMake(17, 17, 60, 60);
    if (self.imageView.image.size.width > 0) {
        self.textLabel.frame = CGRectMake(87, self.textLabel.frame.origin.y, self.textLabel.frame.size.width, self.textLabel.frame.size.height);
        self.detailTextLabel.frame = CGRectMake(87, self.detailTextLabel.frame.origin.y, self.detailTextLabel.frame.size.width, self.detailTextLabel.frame.size.height);
    }
}

@end
