//
//  LocationViewController.m
//  TalkinToTheNet
//
//  Created by Zoufishan Mehdi on 9/24/15.
//  Copyright © 2015 Mike Kavouras. All rights reserved.
//

#import "LocationViewController.h"
#import "APIManager.h"
#import "LocationSearchResult.h"
#import "DetailViewController.h"

@interface LocationViewController () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) NSMutableArray *searchResults;
@property (nonatomic) NSString *locationSearchEntry;


@end

@implementation LocationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.textField.delegate = self;

}



#pragma mark - FS API Request
- (void)makeNewFourSquareAPIRequestWithSearchTerm: (NSString *)searchTerm // pass four square search term
                                    callbackBlock:(void(^)())block { // call block
    
    // search terms via url
    NSString *urlString = [NSString stringWithFormat:@"https://api.foursquare.com/v2/venues/search?client_id=M1KDUWRS5OBWUNQCXHHF23TAUEG2YOB0RXGBSP0LBVRCX2XL&client_secret=FWTAPZOJ4UBPUXX2R5Q1D5F3X0HXMCSMERWL4DJFW3UA33YX&v=20150919&ll=40.7,-74&query=%@", searchTerm];
    
    self.locationSearchEntry = searchTerm;

    
    NSString *encodedString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSLog(@"%@", encodedString);
    
 
    NSURL *url = [NSURL URLWithString:encodedString];
    
[APIManager GETRequestWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
    
    if (data != nil) {
        
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data
                                                             options:0
                                                               error:nil];
        
        
        NSArray *venues = [[json objectForKey:@"response"] objectForKey:@"venues"];
        
        // NSLog(@"%@", venues);
        
        self.searchResults = [[NSMutableArray alloc]init];
        
        for (NSDictionary *venue in venues) {
            
            NSString *venueName = [venue objectForKey:@"name"];
            NSString *venueLocation = [venue objectForKey:@"location"];
            
            NSString *address = [venueLocation valueForKey:@"address"];
            NSString *city = [venueLocation valueForKey:@"city"];
            
            NSString *distance = [venueLocation valueForKey:@"distance"];
             NSString *state = [venueLocation valueForKey:@"state"];
            
            double distanceConvertedToDouble = [distance doubleValue];
            double metersInAMile = 1609.34;
            double distanceInMiles = distanceConvertedToDouble / metersInAMile;
            
            
            NSString *stringInMiles = [NSString stringWithFormat:@"%.2f", distanceInMiles];
            
            if (address == nil){
                address = @"";
            }
            if (city == nil){
                city = @"";
            }
            
            LocationSearchResult *resultsObject = [[LocationSearchResult alloc]init];
            
            resultsObject.restaurantName = venueName;
            resultsObject.restaurantAddress = [NSString stringWithFormat:@"%@, %@, %@", address, city, state];
            resultsObject.restaurantDistance = [NSString stringWithFormat:@"%@ miles", stringInMiles];
            resultsObject.restaurantSearchEntry = self.locationSearchEntry;
            
            [self.searchResults addObject:resultsObject];
        }
        block();
    }
}];

}

#pragma mark - textField
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [self.view endEditing:YES];
    
    [self makeNewFourSquareAPIRequestWithSearchTerm:textField.text callbackBlock:^{
        
        [self.tableView reloadData];
    }];
    return YES;
}


#pragma mark - tableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.searchResults.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchID" forIndexPath:indexPath];
    
    LocationSearchResult *currentResult = self.searchResults[indexPath.row];
    
    cell.textLabel.text = currentResult.restaurantName;
    cell.detailTextLabel.text = currentResult.restaurantAddress;
    
    return cell;
}


#pragma mark - prepareForSegue

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    LocationSearchResult *dataToPass = self.searchResults[indexPath.row];
    DetailViewController *vc = segue.destinationViewController;
    vc.dataPassed = dataToPass;
    
}

@end
