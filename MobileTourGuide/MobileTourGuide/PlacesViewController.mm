//
//  PlacesViewController.m
//  MobileTourGuide
//
//  Created by Scott Andrus on 2/16/12.
//  Copyright (c) 2012 Vanderbilt University. All rights reserved.
//

#import "PlacesViewController.h"
#import "Location.h"
#import "LocationDetailController.h"
#import <QuartzCore/QuartzCore.h>
#import "ScanController.h"
#import "QRCodeReader.h"
#import "ImageViewController.h"

@implementation PlacesViewController
@synthesize bulkAdd;
@synthesize image;
@synthesize description;

@synthesize locations, editedSelection, indexSel, agenda, name, selection, isSectioned, allLoc, scan, imgURL, info;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    
    if ([selection valueForKey:@"location"] != nil) {
        locations = [selection valueForKey:@"location"];
        agenda = [selection valueForKey:@"agenda"];
        if ([selection valueForKey:@"isSectioned"]) {
            isSectioned = YES;
        }
        else {
            isSectioned = NO;
        }
    }
    
    if (!isSectioned) {
        //The rounded corner part, where you specify your view's corner radius:
        description.layer.cornerRadius = 11;
        description.clipsToBounds = YES;
        description.layer.borderColor = [[UIColor grayColor] CGColor];
        description.layer.borderWidth = .5;
        description.text = info;
        
    }
    
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [self setDescription:nil];
    [self setBulkAdd:nil];
    [self setImage:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"view reloaded");
    [self.tableView reloadData];
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    image.adjustsImageWhenHighlighted = NO;
    image.layer.cornerRadius = 9;
    image.clipsToBounds = YES;
    
    image.layer.borderColor = [[UIColor grayColor] CGColor];
    image.layer.borderWidth = .5;
    
    [image setImage:[UIImage imageNamed:@"02-redo.png"] forState:UIControlStateNormal];
    
    NSData *imgUrl = [NSData dataWithContentsOfURL:[NSURL URLWithString:imgURL]];
    [image setImage:[UIImage imageWithData:imgUrl]
           forState:UIControlStateNormal];
    [image setImage:[UIImage imageWithData:imgUrl]
           forState:UIControlStateHighlighted];
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

#pragma mark - Table Data Source Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    if (isSectioned) {
        return [locations count];
    }
    else {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (isSectioned) {
        return [[locations objectAtIndex:section] count];
    }
    else {
        size_t count = 0;
        for (size_t i = 0; i < (size_t)[locations count]; i++) {
            for (size_t j = 0; j < (size_t)[[locations objectAtIndex:i] count]; j++) {
                count++;
            }
        }
        return count;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (isSectioned) {
        if (section == 0)
            return @"Administrative";
        if (section == 1)
            return @"Residence Hall";
        if (section == 2)
            return @"Dining Hall";
        if (section == 3)
            return @"Class Building";
        if (section == 4)
            return @"Athletics / Recreation";
        else
            return @"Wait, wtf did you do?";
    }
    else {
        return nil;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = @"LocationCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];

    Location *location;
    if (isSectioned) {
        NSMutableArray *category = [locations objectAtIndex:[indexPath section]];
        location = [category objectAtIndex:[indexPath row]];
    }
    else {
        size_t selLoc = 0;
        for (size_t i = 0; i < (size_t)[locations count]; i++) {
            for (size_t j = 0; j < (size_t)[[locations objectAtIndex:i] count]; j++) {
                if (selLoc == indexPath.row) {
                    location = [[locations objectAtIndex:i] objectAtIndex:j];
                }
                selLoc++;
            }
        }
    }
    
    cell.textLabel.text = [location name];
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica Light" size:12];
	//cell.detailTextLabel.text = location.category;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
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

- (IBAction)redAlert:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uh oh!"
                                                    message:[NSString stringWithFormat:@"Bulk agenda editing is not currently supported at this time. Please try again later."]
                                                   delegate:nil
                                          cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
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
    
    else if ([segue.identifier isEqual:@"imagePressed"]) {
        ImageViewController *destination = segue.destinationViewController;
        [destination setValue:imgURL forKey:@"image"];
    }
    
    else {
        
        LocationDetailController *destination = segue.destinationViewController;
        
        if ([destination respondsToSelector:@selector(setSelection:)]) {
            // prepare selection info
            NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
            
            
            Location *location;
            if (isSectioned) {
                NSMutableArray *category = [locations objectAtIndex:[indexPath section]];
                location = [category objectAtIndex:[indexPath row]];
            }
            else {
                size_t currentLoc = 0;
                for (size_t i = 0; i < (size_t)[locations count]; i++) {
                    for (size_t j = 0; j < (size_t)[[locations objectAtIndex:i] count]; j++) {
                        if (currentLoc == indexPath.row) {
                            location = [[locations objectAtIndex:i] objectAtIndex:j];
                        }
                        currentLoc++;
                    }
                }
            }
            
            NSDictionary *newSelection;
            
            newSelection = [NSDictionary dictionaryWithObjectsAndKeys:
                         indexPath, @"indexPath",
                         location, @"location",
                         agenda, @"agenda",
                         nil];
            
            [destination setValue:newSelection forKey:@"selection"];
            
            [destination setValue:allLoc forKey:@"allLoc"];
            
            destination.title = location.name;
    
        }
    }
}

@end
