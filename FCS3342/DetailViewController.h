//
//  DetailViewController.h
//  FCS3342
//
//  Created by Haoyu Gu on 2017-04-18.
//  Copyright © 2017 Haoyu Gu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *lbStat;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (copy, nonatomic) NSArray *stat;
@property (copy, nonatomic) NSArray *data;
@property (nonatomic) NSString *statString;

-(void)loadData:(NSArray*)statA and:(NSArray*)dataA and:(NSString*)statS;

@end
