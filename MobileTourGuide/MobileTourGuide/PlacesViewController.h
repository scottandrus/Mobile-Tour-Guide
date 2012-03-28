//
//  PlacesViewController.h
//  MobileTourGuide
//
//  Created by Scott Andrus on 2/16/12.
//  Copyright (c) 2012 Vanderbilt University. All rights reserved.
//
//

#import <UIKit/UIKit.h>
#import "Location.h"
#import "ZXingWidgetController.h"

@interface PlacesViewController : UITableViewController<ZXingDelegate>

@property (strong, nonatomic) NSMutableArray *locations;
@property (strong, nonatomic) NSMutableArray *selection;
@property (strong, nonatomic) NSDictionary *editedSelection;
@property (strong, nonatomic) NSIndexPath *indexSel;
@property (strong, nonatomic) NSMutableArray *agenda;
@property (strong, nonatomic) NSString *name;
@property BOOL isSectioned;
@property (strong, nonatomic) NSDictionary *allLoc;

@property (strong, nonatomic) NSString *imgURL;
@property (strong, nonatomic) NSString *info;

@property (weak, nonatomic) IBOutlet UIButton *image;
@property (weak, nonatomic) IBOutlet UITextView *description;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *scan;
@property (weak, nonatomic) IBOutlet UIButton *bulkAdd;

@end
