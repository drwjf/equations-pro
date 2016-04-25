//
//  AppDelegate.h
//  Equations
//
//  Created by Neel Somani on 5/19/12.
//  Copyright (c) 2012 Gale Ranch Middle School. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    int *levelnumber;
}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic) int *levelnumber;

@end