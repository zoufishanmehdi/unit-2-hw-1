//
//  DetailViewController.m
//  TalkinToTheNet
//
//  Created by Zoufishan Mehdi on 9/25/15.
//  Copyright © 2015 Mike Kavouras. All rights reserved.
//

#import "APIManager.h"
#import "DetailViewController.h"
#import "STTwitter.h"
#import "LocationViewController.h"
#import "LocationSearchResult.h"


@interface DetailViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UIButton *twitterButton;
@property (weak, nonatomic) IBOutlet UITableView *tweetsTableView;

@property (nonatomic) NSString *twitterHandle;
@property (nonatomic) NSMutableArray *twitterNewsfeed;

@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.categoryLabel.text = self.dataPassed.restaurantName;
    self.locationLabel.text = self.dataPassed.restaurantAddress;
    self.distanceLabel.text = self.dataPassed.restaurantDistance;
    
    [self initialAndTwitterSetup];

}


- (void)initialAndTwitterSetup {
    self.tweetsTableView.dataSource = self;
    self.tweetsTableView.delegate = self;
    
    
    
//    NSDictionary *location = [self.foursquareData objectForKey:@"location"];
//    NSArray *formattedAddress = [location objectForKey:@"formattedAddress"];
//    
//    NSString *address = [formattedAddress firstObject];
//    self.locationLabel.text = address;
//    
//    
//    
//    NSArray *categoryArray = [self.foursquareData objectForKey:@"categories"];
//    NSDictionary *categoryObject = [categoryArray firstObject];
//    NSString *category = [categoryObject objectForKey:@"name"];
//    self.categoryLabel.text = category;

    
    
    NSDictionary *contacts = [self.foursquareData objectForKey:@"contact"];
    NSArray *allKeys = [contacts allKeys];
    if([allKeys containsObject:@"twitter"]){
        self.twitterHandle = [contacts objectForKey:@"twitter"];
    }
    else{
        self.twitterHandle = @"Doesn't have twitter account";
    }
    
}


#pragma mark TableView Data source and Delegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.twitterNewsfeed.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifierDV" forIndexPath:indexPath];
    
    if(cell == nil){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellIdentifierDV"];
    }
    
    
    NSDictionary *tweets = self.twitterNewsfeed[indexPath.row];
    cell.textLabel.text = tweets[@"text"];
    cell.imageView.image = tweets[@"image"];
    
    return cell;
    
}

#pragma mark Alert
-(void) noTweetsAlert{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"No Twitter Account Found" message:@"Sorry" preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"Ok Action");
    }];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)twitterButtonTapped:(id)sender {
    
    STTwitterAPI *twitter = [STTwitterAPI twitterAPIAppOnlyWithConsumerKey:@"JNSvKZtVsPN6UEgFZSuZsbFJn" consumerSecret:@"sFk4RbyK83Mo7S7aRwCfENS2KHa1zi5CkQ0LNHmJ5vBlpqfjaJ"];
    [twitter verifyCredentialsWithUserSuccessBlock:^(NSString *username, NSString *userID) {
        [twitter getUserTimelineWithScreenName:self.twitterHandle successBlock:^(NSArray *statuses) {
            
            self.twitterNewsfeed = [NSMutableArray arrayWithArray:statuses];
            [self.tweetsTableView reloadData];
            
            
        } errorBlock:^(NSError *error) {
            if(self.twitterNewsfeed.count == 0){
                [self noTweetsAlert];
            }
            NSLog(@"%@",error.debugDescription);
            
        }];
        
    } errorBlock:^(NSError *error) {
        if(self.twitterNewsfeed.count == 0){
            [self noTweetsAlert];
        }
        
        NSLog(@"%@",error.debugDescription);
    }];
}



     
 /*
     #pragma mark - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
     // Get the new view controller using [segue destinationViewController].
     // Pass the selected object to the new view controller.
     }
     */
     
@end
