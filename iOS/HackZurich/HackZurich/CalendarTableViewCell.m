//
//  CalendarTableViewCell.m
//  HackZurich
//
//  Created by Laurin Brandner on 11/10/14.
//  Copyright (c) 2014 Laurin Brandner. All rights reserved.
//

#import "CalendarTableViewCell.h"

#define OFFSET 10.0F

@interface CalendarTableViewCell ()

//@property (nonatomic, strong) UILabel* timePeriodLabel;
//@property (nonatomic, strong) UILabel* personLabel;

-(NSString*)stringForTimePeriodFromDate:(NSDate*)fromDate untilDate:(NSDate*)untilDate;
-(NSAttributedString*)attributedStringForDescription:(NSString*)description;

+(NSDateFormatter*)dateFormatter;

@end
@implementation CalendarTableViewCell

-(void)setEvent:(XbICVEvent *)event {
    if (![_event isEqual:event]) {
        _event = event;
        
        self.textLabel.attributedText = [self attributedStringForDescription:[_event.description stringByReplacingOccurrencesOfString:@"\\n" withString:@" "] ?: event.summary];
        self.detailTextLabel.text = [self stringForTimePeriodFromDate:_event.dateStart untilDate:_event.dateEnd];
    }
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self) {
        self.textLabel.numberOfLines = 0;
        self.detailTextLabel.textColor =[UIColor colorWithWhite:0.5f alpha:1.0f];
    }
    
    return self;
}

-(NSAttributedString*)attributedStringForDescription:(NSString *)description {
    if (!description) {
        return nil;
    }
    
    NSMutableAttributedString* attributedString = [[NSMutableAttributedString alloc] initWithString:description];
    NSDictionary* attributes = @{NSForegroundColorAttributeName: [self.tintColor colorWithAlphaComponent:0.7f]};
    NSArray* words = [description componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    for (NSString* word in words) {
        if ([word hasPrefix:@"#"]) {
            [attributedString addAttributes:attributes range:[description rangeOfString:word]];
        }
    }
    
    return attributedString;
}

-(NSString*)stringForTimePeriodFromDate:(NSDate *)fromDate untilDate:(NSDate *)untilDate {
    NSString* fromString = [[self.class dateFormatter] stringFromDate:fromDate];
    NSString* untilString = [[self.class dateFormatter] stringFromDate:untilDate];
    
    if (fromString && untilString) {
        return [NSString stringWithFormat:@"%@ - %@", fromString, untilString];
    }
    else if (fromString) {
        return fromString;
    }
    
    return untilString;
}

+(NSDateFormatter*)dateFormatter {
    static NSDateFormatter* formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [NSDateFormatter new];
        formatter.dateStyle = NSDateFormatterShortStyle;
        formatter.timeStyle = NSDateFormatterShortStyle;
    });

    return formatter;
}

//+(CGFloat)heightForEvent:(XbICVEvent *)event constraint:(CGSize)constraint {
//    
//    return 200.0f;
//    NSString* personLabelString = nil;
//    if (event.organizer) {
//        personLabelString = [NSString stringWithFormat:@"by %@", event.organizer.name];
//    }
//    
//    CGSize personLabelSize = [personLabelString boundingRectWithSize:constraint options:0 attributes:nil context:nil].size;
//    
//    
//    constraint.width -= personLabelSize.width+3.0f*OFFSET;
//    CGSize textLabelSize = [[_event.description stringByReplacingOccurrencesOfString:@"\\n" withString:@" "] boundingRectWithSize:constraint options:NSStringDrawingUsesFontLeading  context:nil].size;
//    self.textLabel.frame = (CGRect){{OFFSET, OFFSET}, textLabelSize};
//    self.personLabel.frame = (CGRect){{CGRectGetMaxX(self.textLabel.frame)+OFFSET, OFFSET}, personLabelSize};
//    
//    CGSize timePeriodLabelSize = self.timePeriodLabel.intrinsicContentSize;
//    self.timePeriodLabel.frame = (CGRect){{OFFSET, CGRectGetMaxY(self.textLabel.frame)+OFFSET}, timePeriodLabelSize};
//}

//-(void)layoutSubviews {
//    [super layoutSubviews];
//    
//    CGSize personLabelSize = self.personLabel.intrinsicContentSize;
//    
//    CGSize constraint = CGSizeMake(CGRectGetWidth(self.bounds)-personLabelSize.width-3.0f*OFFSET, CGFLOAT_MAX);
//    CGSize textLabelSize = [self.textLabel.attributedText boundingRectWithSize:constraint options:NSStringDrawingUsesFontLeading context:nil].size;
//    self.textLabel.frame = (CGRect){{OFFSET, OFFSET}, textLabelSize};
//    self.personLabel.frame = (CGRect){{CGRectGetMaxX(self.textLabel.frame)+OFFSET, OFFSET}, personLabelSize};
//    
//    CGSize timePeriodLabelSize = self.timePeriodLabel.intrinsicContentSize;
//    self.timePeriodLabel.frame = (CGRect){{OFFSET, CGRectGetMaxY(self.textLabel.frame)+OFFSET}, timePeriodLabelSize};
//}

@end
