//
//  MapViewController.m
//  MobileTourGuide
//
//  Created by Scott Andrus on 3/20/12.
//  Copyright (c) 2012 Vanderbilt University. All rights reserved.
//

#import "MapViewController.h"
#import "ScanController.h"
#import "QRCodeReader.h"
#import "Location.h"
#import "LocationDetailController.h"

@implementation MapViewController
@synthesize mapView;
@synthesize scan, allLoc;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

- (void)viewDidUnload
{
    [self setScan:nil];
    [self setMapView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    // 1
    CLLocationCoordinate2D zoomLocation;
    zoomLocation.latitude = 36.143566;
    zoomLocation.longitude= -86.805906;
    // 2
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 0.5*METERS_PER_MILE, 0.5*METERS_PER_MILE);
    // 3
    MKCoordinateRegion adjustedRegion = [mapView regionThatFits:viewRegion];                
    // 4
    [mapView setRegion:adjustedRegion animated:YES]; 
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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
}


@end
