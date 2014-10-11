//
//  InputTableViewCell.m
//  HackZurich
//
//  Created by Laurin Brandner on 11/10/14.
//  Copyright (c) 2014 Laurin Brandner. All rights reserved.
//

#import "InputTableViewCell.h"

#define OFFSET 10.0f

@implementation InputTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
    if (self) {
        self.textField = [UITextField new];
        [self.contentView addSubview:self.textField];
    }
    
    return self;
}

-(void)prepareForReuse {
    [super prepareForReuse];
    
    self.textField.text = nil;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect textFieldFrame = self.textLabel.frame;
    textFieldFrame.size.width = CGRectGetWidth(self.bounds)-CGRectGetMaxX(self.textLabel.frame)-CGRectGetMinX(self.textLabel.frame)-OFFSET;
    textFieldFrame.origin.x = CGRectGetMaxX(self.textLabel.frame)+OFFSET;
    self.textField.frame = textFieldFrame;
}

@end
