//
//  TourViewController.h
//  MobileTourGuide
//
//  Created by Scott Andrus on 2/16/12.
//  Copyright (c) 2012 Vanderbilt University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Location.h"
#import "ZXingWidgetController.h"

@interface TourViewController : UITableViewController<ZXingDelegate>

@property (strong, nonatomic) NSMutableArray *tourList;
@property (strong, nonatomic) NSDictionary *allLoc;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *scan;

@end
