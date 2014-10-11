//
//  CalendarDetailViewController.m
//  HackZurich
//
//  Created by Laurin Brandner on 12/10/14.
//  Copyright (c) 2014 Laurin Brandner. All rights reserved.
//

#import "CalendarDetailViewController.h"

#define MAP_HEIGHT 150.0f
#define OFFSET 10.0f

@interface CalendarDetailViewController () <UIScrollViewDelegate>

@property (nonatomic, strong) XbICVEvent* event;
@property (nonatomic) CGSize lastMapViewSize;

-(NSAttributedString*)attributedStringForDescription:(NSString *)description;

@end
@implementation CalendarDetailViewController

-(void)setEvent:(XbICVEvent *)event {
    if (![_event isEqual:event]) {
        _event = event;
        
        self.title = [event.description stringByReplacingOccurrencesOfString:@"\\n" withString:@" "];
    }
}

-(instancetype)initWithEvent:(XbICVEvent *)event {
    self = [super init];
    if (self) {
        self.event = event;
    }
    
    return self;
}

-(void)loadView {
    self.scrollView = [[UIScrollView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.scrollView.backgroundColor = [UIColor whiteColor];
    self.scrollView.tintColor = [UIColor colorWithRed:49.0f/255.0f green:157.0f/255.0f blue:71.0f/255.0f alpha:1.0f];
    self.scrollView.delegate = self;
    self.scrollView.alwaysBounceVertical = YES;
    self.scrollView.contentInset = UIEdgeInsetsMake(-MAP_HEIGHT, 0.0f, 0.0f, 0.0f);
    self.view = self.scrollView;
    
    self.mapView = [MKMapView new];
    self.mapView.userInteractionEnabled = NO;
    [self.view addSubview:self.mapView];
    
    self.titleLabel = [UILabel new];
    self.titleLabel.numberOfLines = 0;
    self.titleLabel.attributedText = [self attributedStringForDescription:self.title];
    [self.view addSubview:self.titleLabel];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [UIView animateWithDuration:0.5f delay:0.1f usingSpringWithDamping:0.6f initialSpringVelocity:0.0f options:0 animations:^{
        self.scrollView.contentInset = UIEdgeInsetsMake(self.topLayoutGuide.length, 0.0f, 0.0f, 0.0f);
    } completion:nil];
}

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGRect bounds = self.view.bounds;
    
    self.mapView.frame = (CGRect){{0.0f, -CGRectGetHeight(bounds)}, {CGRectGetWidth(bounds), CGRectGetHeight(bounds)+MAP_HEIGHT}};
    self.lastMapViewSize = self.mapView.frame.size;
    
    CGSize constraint = CGSizeMake(CGRectGetWidth(bounds)-2.0f*OFFSET, CGFLOAT_MAX);
    CGSize titleLabelSize = [self.titleLabel.attributedText boundingRectWithSize:constraint options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    self.titleLabel.frame = (CGRect){{OFFSET, CGRectGetMaxY(self.mapView.frame)+OFFSET}, titleLabelSize};
}

-(NSAttributedString*)attributedStringForDescription:(NSString *)description {
    NSMutableString* string = description.mutableCopy;
    NSRange firstHashTagRange = [description rangeOfString:@"#"];
    if (firstHashTagRange.location != NSNotFound && firstHashTagRange.location != 0) {
        [string insertString:@"\n" atIndex:firstHashTagRange.location];
    }
    
    NSMutableAttributedString* attributedString = [[NSMutableAttributedString alloc] initWithString:string attributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:28.0f]}];
    NSDictionary* attributes = @{NSForegroundColorAttributeName: [self.view.tintColor colorWithAlphaComponent:0.7f], NSFontAttributeName: [UIFont systemFontOfSize:17.0f]};
    NSArray* words = [string componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    for (NSString* word in words) {
        if ([word hasPrefix:@"#"]) {
            [attributedString setAttributes:attributes range:[string rangeOfString:word]];
        }
    }
    
    return attributedString;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat factor = scrollView.contentOffset.y/-scrollView.contentInset.top;
    if (factor > 1.0f) {
        MKCoordinateRegion region = self.mapView.region;
        region.span.latitudeDelta = factor;
        region.span.longitudeDelta = factor;
        self.mapView.region = region;
    }
}

@end
