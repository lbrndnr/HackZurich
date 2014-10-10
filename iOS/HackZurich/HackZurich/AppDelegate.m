//
//  AppDelegate.m
//  HackZurich
//
//  Created by Laurin Brandner on 10/10/14.
//  Copyright (c) 2014 Laurin Brandner. All rights reserved.
//

#import "AppDelegate.h"
#import "FirstViewController.h"
#import "SecondViewController.h"
#import "OutputFeedCreaterViewController.h"

@interface AppDelegate ()

@end
@implementation AppDelegate

-(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    UITabBarController* controller = [UITabBarController new];
    
    UINavigationController* firstViewController = [[UINavigationController alloc] initWithRootViewController:[FirstViewController new]];
    firstViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"First" image:nil selectedImage:nil];
    UINavigationController* secondViewController = [[UINavigationController alloc] initWithRootViewController:[OutputFeedCreaterViewController new]];
    secondViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Second" image:nil selectedImage:nil];
    
    controller.viewControllers = @[firstViewController, secondViewController];
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = controller;
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end
