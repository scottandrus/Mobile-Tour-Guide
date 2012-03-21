//
//  ScanController.m
//  MobileTourGuide
//
//  Created by Scott Andrus on 3/19/12.
//  Copyright (c) 2012 Vanderbilt University. All rights reserved.
//

#import "ScanController.h"
#import "QRCodeReader.h"

@implementation ScanController

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
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    }

@end
