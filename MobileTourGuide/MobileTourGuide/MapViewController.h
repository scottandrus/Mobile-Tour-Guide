//
//  MapViewController.h
//  MobileTourGuide
//
//  Created by Scott Andrus on 3/20/12.
//  Copyright (c) 2012 Vanderbilt University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "ZXingWidgetController.h"

#define METERS_PER_MILE 1609.344

@interface MapViewController : UIViewController <ZXingDelegate> 

@property (weak, nonatomic) IBOutlet UIBarButtonItem *scan;
@property (strong, nonatomic) NSDictionary *allLoc;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;


@end
