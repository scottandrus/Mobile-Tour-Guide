//
//  ImageViewController.m
//  MobileTourGuide
//
//  Created by Scott Andrus on 2/25/12.
//  Copyright (c) 2012 Vanderbilt University. All rights reserved.
//

#import "ImageViewController.h"

@implementation ImageViewController

@synthesize image;
@synthesize display;

- (void)viewDidLoad {
    NSData *imgUrl = [NSData dataWithContentsOfURL:[NSURL URLWithString:image]];
    display.image = [UIImage imageWithData:imgUrl];
}

- (void)viewDidUnload {
    [self setDisplay:nil];
    [super viewDidUnload];
}
@end
