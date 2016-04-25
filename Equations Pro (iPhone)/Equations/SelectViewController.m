//
//  SelectViewController.m
//  Equations
//
//  Created by Neel Somani on 5/28/12.
//  Copyright (c) 2012 Gale Ranch Middle School. All rights reserved.
//

#import "SelectViewController.h"
#import "AppDelegate.h"

@interface SelectViewController ()

@end

@implementation SelectViewController
@synthesize indicatorEasy;
@synthesize indicatorHard;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [self setIndicatorEasy:nil];
    [self setIndicatorHard:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)loadEasy:(id)sender {
    UIButton *start_but = (UIButton *) sender;
    start_but.hidden = YES;
    indicatorEasy.hidden = NO;
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.levelnumber = (int *) 0;
}

- (IBAction)loadHard:(id)sender {
    UIButton *start_but = (UIButton *) sender;
    start_but.hidden = YES;
    indicatorHard.hidden = NO;
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.levelnumber = (int *) 1;
}
@end
