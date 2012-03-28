//
//  LocationDetailController.m
//  MobileTourGuide
//
//  Created by Scott Andrus on 2/20/12.
//  Copyright (c) 2012 Vanderbilt University. All rights reserved.
//

#import "LocationDetailController.h"
#import <QuartzCore/QuartzCore.h>
#import "ImageViewController.h"
#import "ScanController.h"
#import "QRCodeReader.h"

@implementation LocationDetailController
@synthesize scan;
@synthesize photo;

@synthesize indexSel, currentLoc, delegate, selection, allLoc, agenda;
@synthesize description, hours, addAgenda, alreadyOnAgenda;

- (void)viewDidLoad {

    [super viewDidLoad];
    
    //The rounded corner part, where you specify your view's corner radius:
    description.layer.cornerRadius = 11;
    description.clipsToBounds = YES;
    description.layer.borderColor = [[UIColor grayColor] CGColor];
    description.layer.borderWidth = .5;
    
    self.currentLoc = [selection valueForKey:@"location"];

    // Set description text
    self.description.text = [currentLoc description];
    
    // Set the hours of operation
    NSString *newHours = @"Hours: ";
    self.hours.text = [newHours stringByAppendingString:currentLoc.hours];
}

- (void)viewDidUnload {
    self.title = nil;
    self.indexSel = nil;
    self.currentLoc = nil;
    self.delegate = nil;
    self.selection = nil;
    self.description = nil;
    self.hours = nil;
    self.addAgenda = nil;
    self.alreadyOnAgenda = nil;
    //self.myImage = nil;
    [self setPhoto:nil];
    [self setScan:nil];
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle
- (IBAction)redAlert:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uh oh!"
                                                    message:[NSString stringWithFormat:@"\"Check In!\" is not supported in the current version of the prototype. Please check back later."]
                                                   delegate:nil
                                          cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

- (IBAction)audioAlert:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uh oh!"
                                                    message:[NSString stringWithFormat:@"Audio tours are not supported in the current version of the prototype. Please check back later."]
                                                   delegate:nil
                                          cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

- (IBAction)videoPressed:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:currentLoc.video]];  
}

- (IBAction)addAgenda:(id)sender {
    agenda = [selection valueForKey:@"agenda"];
    alreadyOnAgenda.hidden = NO;
    addAgenda.hidden = YES;
    currentLoc.onAgenda = YES;
    NSLog(@"added");
    [agenda addObject:currentLoc];
}

- (void)viewWillAppear:(BOOL)animated {
    
    // Check if onAgenda.
    if (currentLoc.onAgenda) {
        alreadyOnAgenda.hidden = NO;
        addAgenda.hidden = YES;
    }
    else {
        alreadyOnAgenda.hidden = YES;
        addAgenda.hidden = NO;
    }

    
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    self.photo.adjustsImageWhenHighlighted = NO;
    self.photo.layer.cornerRadius = 9;
    self.photo.clipsToBounds = YES;
    
    self.photo.layer.borderColor = [[UIColor grayColor] CGColor];
    self.photo.layer.borderWidth = .5;
    
    [photo setImage:[UIImage imageNamed:@"02-redo.png"] forState:UIControlStateNormal];
    
    NSData *imgUrl = [NSData dataWithContentsOfURL:[NSURL URLWithString:currentLoc.image]];
    [photo setImage:[UIImage imageWithData:imgUrl]
           forState:UIControlStateNormal];
    [photo setImage:[UIImage imageWithData:imgUrl]
           forState:UIControlStateHighlighted];
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
    // prepare selection info
    if ([selection objectForKey:@"indexPath"] != nil) {
        NSIndexPath *indexPath = [selection objectForKey:@"indexPath"];
        NSDictionary *editedSelection = [NSDictionary dictionaryWithObjectsAndKeys:
                                         indexPath, @"indexPath",
                                         currentLoc, @"location",
                                         nil];
        [delegate setValue:editedSelection forKey:@"editedSelection"];
        [delegate setValue:currentLoc forKey:@"myLoc"];
    }
    else {
        NSDictionary *editedSelection = [NSDictionary dictionaryWithObjectsAndKeys:currentLoc, @"location", nil];
        [delegate setValue:editedSelection forKey:@"editedSelection"];
        [delegate setValue:currentLoc forKey:@"myLoc"];
    }
    
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


- (void)zxingControllerDidCancel:(ZXingWidgetController*)controller {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)zxingController:(ZXingWidgetController*)controller didScanResult:(NSString *)result {
    
    NSString *scanned = result;
    Location *loc;
    if ([allLoc valueForKey:scanned] != nil) {
        loc = [allLoc valueForKey:scanned];
        
        [self dismissModalViewControllerAnimated:YES];
        [self performSegueWithIdentifier:@"scanLoc" sender:loc];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uh oh!"
                                                        message:[NSString stringWithFormat:@"This is not a valid Vanderbilt QR code. Please try again."]
                                                       delegate:nil
                                              cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [self dismissModalViewControllerAnimated:YES];
    }
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender { 
    if (sender == scan) {
        ZXingWidgetController *destination = segue.destinationViewController;
        destination = [destination initWithDelegate:self showCancel:YES OneDMode:NO];
        QRCodeReader* qrcodeReader = [[QRCodeReader alloc] init];
        NSSet *readers = [[NSSet alloc ] initWithObjects:qrcodeReader,nil];
        destination.readers = readers;
        NSBundle *mainBundle = [NSBundle mainBundle];
        destination.soundToPlay =
        [NSURL fileURLWithPath:[mainBundle pathForResource:@"beep-beep" ofType:@"aiff"] isDirectory:NO];
    }
    else if ([segue.identifier isEqual:@"scanLoc"]) {
        LocationDetailController *destination = segue.destinationViewController;
        Location *loc = sender;
        NSDictionary *mySelection;
        
        mySelection = [NSDictionary dictionaryWithObjectsAndKeys:
                     loc, @"location",
                     nil];
        
        [destination setValue:mySelection forKey:@"selection"];
        
        [destination setValue:allLoc forKey:@"allLoc"];
        
        destination.title = loc.name;
    }
    else {
        ImageViewController *destination = segue.destinationViewController;
        destination.title = currentLoc.name;
        [destination setValue:currentLoc.image forKey:@"image"];
    }
    
}


@end
