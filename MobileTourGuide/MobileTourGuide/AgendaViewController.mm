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
@synthesize scan;
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
    }
    return self;
}

- (void)viewDidLoad
{
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
    if (haveVisited) {
        Location *oldLoc = [editedSelection valueForKey:@"location"];
    }
    
    haveVisited = YES;
    [self.tableView reloadData];
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    NSLog(@"%d", locations.count);
    [super viewDidAppear:animated];
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
        NSDictionary *selection;
        
        selection = [NSDictionary dictionaryWithObjectsAndKeys:
                     loc, @"location",
                     locations, @"agenda",
                     nil];
        
        [destination setValue:selection forKey:@"selection"];
        [destination setValue:allLoc forKey:@"allLoc"];
        
        destination.title = loc.name;
    }
    else {
        LocationDetailController *destination = segue.destinationViewController;
        if ([destination respondsToSelector:@selector(setSelection:)]) {
            // prepare selection info
            NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
            
            Location *loc = [self.locations objectAtIndex:indexPath.row];
            
            NSDictionary *selection;
            
            selection = [NSDictionary dictionaryWithObjectsAndKeys:
                         indexPath, @"indexPath",
                         loc, @"location",
                         locations, @"agenda",
                         nil];
           
            [destination setValue:selection forKey:@"selection"];
            [destination setValue:locations forKey:@"agenda"];
            
            [destination setValue:allLoc forKey:@"allLoc"];
            
            destination.title = loc.name;
    }
    }
}


@end
