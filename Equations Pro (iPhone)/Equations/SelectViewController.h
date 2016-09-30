//
//  SelectViewController.h
//  Equations
//
//  Created by Neel Somani on 5/28/12.
//  Copyright (c) 2012 Gale Ranch Middle School. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SelectViewController : UIViewController

- (IBAction)loadEasy:(id)sender;
- (IBAction)loadHard:(id)sender;

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *indicatorEasy;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *indicatorHard;

@end
