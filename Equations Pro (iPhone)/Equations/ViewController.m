//
//  ViewController.m
//  Equations
//
//  Created by Neel Somani on 5/19/12.
//  Copyright (c) 2012 Gale Ranch Middle School. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ((interfaceOrientation == UIInterfaceOrientationLandscapeLeft) || (interfaceOrientation == UIInterfaceOrientationLandscapeRight)) {
        return NO;
    }
    else{
        return YES;
    }
}

- (IBAction)about:(id)sender {
    UIAlertView *author = [[UIAlertView alloc] initWithTitle: @"Feedback?" message: @"Equations was made by Neel Somani from Gale Ranch Middle School. Any suggestions, questions, or complaints can be emailed to admin@neelsomani.com." delegate: self cancelButtonTitle: @"Got it!" otherButtonTitles: nil];
	
	[author show];
}

@end
