//
//  AgendaViewController.m
//  MobileTourGuide
//
//  Created by Scott Andrus on 2/16/12.
//  Copyright (c) 2012 Vanderbilt University. All rights reserved.
//

#import "AgendaViewController.h"
#import "LocationDetailController.h"
#import "Location.h"
#import "ZXingWidgetController.h"
#import "QRCodeReader.h"
#import "ScanController.h"


@implementation AgendaViewController
@synthesize scan, scanDetail;
@synthesize locations, indexSel, myLoc, editedSelection, haveVisited, allLoc;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (id)init {
    self = [super init];
    if (self) {
        haveVisited = NO;
        scanDetail = nil;
    }
    return self;
}

- (void)viewDidLoad
{
    if (haveVisited) {
        NSIndexPath *index = [editedSelection valueForKey:@"indexPath"];
        BOOL isOnAgenda = [[editedSelection valueForKey:@"location"] onAgenda];
        Location *oldLoc = [self.locations objectAtIndex:index.row];
        oldLoc.onAgenda = isOnAgenda;
    }
    
    haveVisited = YES;

    [self.tableView reloadData];
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    
    [self setScan:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.tableView reloadData];
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (scanDetail == nil) {
        NSLog(@"It's nil");
    }
    else {
        NSLog(@"Not nil, all good!");
    }
//    
//    if (scanDetail != nil) {
//        LocationDetailController *temp = scanDetail;
//        scanDetail = nil;
//        
//    }
    [self.tableView reloadData];
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

#pragma mark -
#pragma mark Table Data Source Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.locations count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    NSString *identifier = @"LocationCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    Location *location = [self.locations objectAtIndex:indexPath.row];
    location.onAgenda = YES;
    
    cell.textLabel.text = location.name;
	cell.detailTextLabel.text = location.category;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (editingStyle == UITableViewCellEditingStyleDelete)
	{
        Location *location = [self.locations objectAtIndex:indexPath.row];
        location.onAgenda = NO;
		[self.locations removeObjectAtIndex:indexPath.row];
		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
	}   
}


- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    NSUInteger fromRow = [fromIndexPath row];
    NSUInteger toRow = [toIndexPath row];
    id object = [locations objectAtIndex:fromRow];
    [locations removeObjectAtIndex:fromRow];
    [locations insertObject:object atIndex:toRow];
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

#pragma mark -
#pragma mark Table View Delegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

}

- (IBAction)toggleMove {
    [self.tableView setEditing:!self.tableView.editing animated:YES];
    if (self.tableView.editing) {
        [self.navigationItem.leftBarButtonItem setTitle:@"Done"];
        [self.navigationItem.leftBarButtonItem setStyle:UIBarButtonItemStyleDone];
    }
    else {
        [self.navigationItem.leftBarButtonItem setTitle:@"Edit"];
        [self.navigationItem.leftBarButtonItem setStyle:UIBarButtonItemStylePlain];
    }
}

- (void)zxingControllerDidCancel:(ZXingWidgetController*)controller {
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)scanPressed:(id)sender {
	
    ZXingWidgetController *widController = [[ZXingWidgetController alloc] initWithDelegate:self showCancel:YES OneDMode:NO];
    QRCodeReader* qrcodeReader = [[QRCodeReader alloc] init];
    NSSet *readers = [[NSSet alloc ] initWithObjects:qrcodeReader,nil];
    widController.readers = readers;
    NSBundle *mainBundle = [NSBundle mainBundle];
    widController.soundToPlay =
    [NSURL fileURLWithPath:[mainBundle pathForResource:@"beep-beep" ofType:@"aiff"] isDirectory:NO];
    [self presentModalViewController:widController animated:YES];
}

- (void)zxingController:(ZXingWidgetController*)controller didScanResult:(NSString *)result {
    
    NSString *scanned = result;
    NSString *admissions = @"VANDY_LOCATION_ADMISSIONS";
    
    LocationDetailController *destination = [[LocationDetailController alloc] init];
    scanDetail = [[LocationDetailController alloc] init];
    if ([scanned isEqualToString:admissions]) {
        
        NSDictionary *selection;
        
        Location *loc = [allLoc valueForKey:@"Admissions"];
        
        selection = [NSDictionary dictionaryWithObjectsAndKeys:
                     loc, @"location",
                     nil];
        
        [destination setValue:selection forKey:@"selection"];
        
        destination.title = loc.name;
        scanDetail = destination;
        if (scanDetail == nil) {
            NSLog(@"It's nil");
        }
        else {
            NSLog(@"Not nil, all good!");
        }
        
        [self.navigationController pushViewController:scanDetail animated:NO];
        
    }

    [self dismissModalViewControllerAnimated:YES];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender { 
    LocationDetailController *destination = segue.destinationViewController;
    
    if ([destination respondsToSelector:@selector(setSelection:)]) {
        // prepare selection info
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        
        Location *loc = [self.locations objectAtIndex:indexPath.row];
        
        NSDictionary *selection;
        
        selection = [NSDictionary dictionaryWithObjectsAndKeys:
                     indexPath, @"indexPath",
                     loc, @"location",
                     nil];
       
        [destination setValue:selection forKey:@"selection"];
        
        destination.title = loc.name;
    }
}


@end
