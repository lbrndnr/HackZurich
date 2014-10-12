//
//  CalendarDetailViewController.m
//  HackZurich
//
//  Created by Laurin Brandner on 12/10/14.
//  Copyright (c) 2014 Laurin Brandner. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import "CalendarDetailViewController.h"

#define RELATIVE_MAP_HEIGHT 0.25f
#define OFFSET 10.0f

@interface CalendarDetailViewController () <UIScrollViewDelegate>

@property (nonatomic, strong) XbICVEvent* event;
@property (nonatomic) CGSize lastMapViewSize;

-(NSAttributedString*)attributedStringForDescription:(NSString *)description;
-(NSAttributedString*)attributedStringForLocation:(NSString*)location;

@end
@implementation CalendarDetailViewController

-(void)setEvent:(XbICVEvent *)event {
    if (![_event isEqual:event]) {
        _event = event;
        
        self.title = [event.description stringByReplacingOccurrencesOfString:@"\\n" withString:@" "] ?: event.summary;
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
    self.scrollView.contentInset = UIEdgeInsetsMake(-RELATIVE_MAP_HEIGHT*CGRectGetHeight(self.scrollView.frame), 0.0f, 0.0f, 0.0f);
    self.view = self.scrollView;
    
    self.mapView = [MKMapView new];
    self.mapView.userInteractionEnabled = NO;
    [self.view addSubview:self.mapView];
    
    self.titleLabel = [UILabel new];
    self.titleLabel.numberOfLines = 0;
    self.titleLabel.attributedText = [self attributedStringForDescription:self.title];
    [self.view addSubview:self.titleLabel];
    
    self.locationLabel = [UILabel new];
    self.locationLabel.numberOfLines = 0;
    self.locationLabel.attributedText = [self attributedStringForLocation:self.event.location];
    [self.view addSubview:self.locationLabel];
    
    self.summaryLabel = [UILabel new];
    self.summaryLabel.numberOfLines = 0;
    self.summaryLabel.text = self.event.summary;
    [self.view addSubview:self.summaryLabel];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.event.location) {
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        [geocoder geocodeAddressString:self.event.location completionHandler:^(NSArray* placemarks, NSError* error) {
            MKCoordinateRegion region = self.mapView.region;
            region.span.latitudeDelta = 1.0f;
            region.span.longitudeDelta = 1.0f;
            self.mapView.region = region;
            CLLocationCoordinate2D coordinate = ((CLPlacemark*)placemarks.firstObject).location.coordinate;
            coordinate.latitude += self.mapView.region.span.latitudeDelta*0.4f;
            self.mapView.centerCoordinate = coordinate;
            
            [UIView animateWithDuration:0.5f delay:0.1f usingSpringWithDamping:0.6f initialSpringVelocity:0.0f options:0 animations:^{
                self.scrollView.contentInset = UIEdgeInsetsMake(self.topLayoutGuide.length, 0.0f, 0.0f, 0.0f);
            } completion:nil];
        }];
    }
    else {
        self.mapView.hidden = YES;
    }
}

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGRect bounds = self.view.bounds;
    self.mapView.frame = (CGRect){{0.0f, -CGRectGetHeight(bounds)}, {CGRectGetWidth(bounds), CGRectGetHeight(bounds)+RELATIVE_MAP_HEIGHT*CGRectGetHeight(bounds)}};
    self.lastMapViewSize = self.mapView.frame.size;
    
    CGSize constraint = CGSizeMake(CGRectGetWidth(bounds)-2.0f*OFFSET, CGFLOAT_MAX);
    CGSize titleLabelSize = [self.titleLabel.attributedText boundingRectWithSize:constraint options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    self.titleLabel.frame = (CGRect){{OFFSET, CGRectGetMaxY(self.mapView.frame)+OFFSET}, titleLabelSize};
    CGSize summaryLabelSize = [self.summaryLabel.attributedText boundingRectWithSize:constraint options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    summaryLabelSize.width = CGRectGetWidth(bounds)-2.0f*OFFSET;
    self.summaryLabel.frame = (CGRect){{OFFSET, CGRectGetMaxY(self.titleLabel.frame)+OFFSET}, summaryLabelSize};
    CGSize locationLabelSize = [self.locationLabel.attributedText boundingRectWithSize:constraint options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    locationLabelSize.width = CGRectGetWidth(bounds)-3.0f*OFFSET;
    self.locationLabel.frame = (CGRect){{2.0f*OFFSET, CGRectGetMaxY(self.summaryLabel.frame)+OFFSET}, locationLabelSize};
}

-(NSAttributedString*)attributedStringForLocation:(NSString *)location {
    if (!location) {
        return nil;
    }
    
    location = [location stringByReplacingOccurrencesOfString:@"\\," withString:@","];
    NSString* string = [NSString stringWithFormat:@"at %@", location];
    
    NSMutableAttributedString* attributedString = [[NSMutableAttributedString alloc] initWithString:string];
    [attributedString setAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:22.0f]} range:[string rangeOfString:location]];
    
    return attributedString;
}

-(NSAttributedString*)attributedStringForDescription:(NSString *)description {
    if (!description) {
        return nil;
    }
    
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

//-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    if (self.event.location) {
//        CGFloat factor = scrollView.contentOffset.y/-scrollView.contentInset.top;
//        if (factor > 1.0f) {
//            MKCoordinateRegion region = self.mapView.region;
//            region.span.latitudeDelta = factor;
//            region.span.longitudeDelta = factor;
//            self.mapView.region = region;
//        }
//    }
//}

@end
