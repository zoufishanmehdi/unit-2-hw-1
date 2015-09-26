//
//  DetailViewController.h
//  TalkinToTheNet
//
//  Created by Zoufishan Mehdi on 9/25/15.
//  Copyright © 2015 Mike Kavouras. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocationSearchResult.h"

@interface DetailViewController : UIViewController

@property (nonatomic) NSDictionary *foursquareData;
@property (nonatomic) LocationSearchResult *dataPassed;


@end
