//
//  DetailViewController.m
//  FCS3342
//
//  Created by Haoyu Gu on 2017-04-18.
//  Copyright © 2017 Haoyu Gu. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic) BOOL filtered;
@property (nonatomic) NSMutableArray *filterArray;

@end

@implementation DetailViewController
@synthesize stat;
@synthesize statString;
@synthesize data;
- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.filtered = NO;
    // Do any additional setup after loading the view.
    self.tableView.delegate  = self;
    self.tableView.dataSource = self;
    //self.tableView.allowsSelection = NO;
    [self.lbStat setText:self.statString];
    [self.tableView reloadData];
    [self.view layoutIfNeeded];
}

-(void)viewWillAppear:(BOOL)animated {
    [self.navigationController.navigationBar setHidden:NO];
    [self.navigationController setTitle:@"Statistic"];
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)backBtnTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.filtered) {
        return [self.filterArray count];
    }
    else {
        return [self.stat count];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(void)loadData:(NSArray*)statA and:(NSArray*)dataA and:(NSString*)statS {
    self.stat = [[NSArray alloc] initWithArray:statA];
    self.data = [[NSArray alloc] initWithArray:dataA];
    self.statString = statS;
    [self.lbStat setText:self.statString];
    //[self.tableView reloadData];
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString* const cellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    if (self.filtered) {
        cell.textLabel.text = [NSString stringWithFormat:@"[%ld] Count: %@", indexPath.row, [self.stat[[self.filterArray[indexPath.row] integerValue]] objectForKey:@"QC"]];
        
    }
    else {
        cell.textLabel.text = [NSString stringWithFormat:@"[%ld] Count: %@", indexPath.row, [self.stat[indexPath.row] objectForKey:@"QC"]];
    }
    
    return cell;
}
- (IBAction)btnFilterTapped:(id)sender {
    if (_filtered) {
        _filtered = NO;
    }
    else {
        self.filterArray = [[NSMutableArray alloc] init];
        for (int i=0;i<[self.stat count];i++) {
            if (![[self.stat[i] objectForKey:@"QC"] isEqual:@0]) {
                [self.filterArray addObject:[NSNumber numberWithInt:i]];
            }
        }
        _filtered = YES;
    }
    [self.tableView reloadData];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIAlertView *alert;
    if (self.filtered) {
        alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"[%ld] Count: %@", indexPath.row, [self.stat[[self.filterArray[indexPath.row] integerValue]] objectForKey:@"QC"]] message:[NSString stringWithFormat:@"%@\n\n%@", [self.data[[self.filterArray[indexPath.row] integerValue]] objectForKey:@"question"], [self.data[[self.filterArray[indexPath.row] integerValue]] objectForKey:@"answer"]] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    }
    else {
        alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"[%ld] Count: %@", indexPath.row, [self.stat[indexPath.row] objectForKey:@"QC"]] message:[NSString stringWithFormat:@"%@\n\n%@", [self.data[indexPath.row] objectForKey:@"question"], [self.data[indexPath.row] objectForKey:@"answer"]] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    }
    
    [alert show];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
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
