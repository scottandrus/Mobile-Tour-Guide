//
//  LocationDetailController.h
//  MobileTourGuide
//
//  Created by Scott Andrus on 2/20/12.
//  Copyright (c) 2012 Vanderbilt University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Location.h"
#import "ZXingWidgetController.h"

@interface LocationDetailController : UIViewController<ZXingDelegate>

@property (strong, nonatomic) NSIndexPath *indexSel;
@property (strong, nonatomic) Location *currentLoc;
@property (copy, nonatomic) NSDictionary *selection;
@property (weak, nonatomic) id delegate;
@property (strong, nonatomic) NSDictionary *allLoc;
@property (strong, nonatomic) NSMutableArray *agenda;


@property (weak, nonatomic) IBOutlet UIButton *photo;
@property (strong, nonatomic) IBOutlet UITextView *description;
@property (strong, nonatomic) IBOutlet UILabel *hours;
@property (strong, nonatomic) IBOutlet UIButton *addAgenda;
@property (strong, nonatomic) IBOutlet UIButton *alreadyOnAgenda;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *scan;

@end
