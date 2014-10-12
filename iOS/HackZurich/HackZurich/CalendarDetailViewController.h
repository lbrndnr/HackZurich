//
//  CalendarDetailViewController.h
//  HackZurich
//
//  Created by Laurin Brandner on 12/10/14.
//  Copyright (c) 2014 Laurin Brandner. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "XbICalendar.h"

@interface CalendarDetailViewController : UIViewController

@property (nonatomic, readonly) XbICVEvent* event;

@property (nonatomic, strong) UIScrollView* scrollView;
@property (nonatomic, strong) MKMapView* mapView;
@property (nonatomic, strong) UILabel* titleLabel;
@property (nonatomic, strong) UILabel* locationLabel;
@property (nonatomic, strong) UILabel* summaryLabel;
@property (nonatomic, strong) UILabel* timeLabel;

-(instancetype)initWithEvent:(XbICVEvent*)event;

@end
