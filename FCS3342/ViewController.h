//
//  ViewController.h
//  FCS3342
//
//  Created by Haoyu Gu on 2017-04-17.
//  Copyright © 2017 Haoyu Gu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *qLabel;
@property (weak, nonatomic) IBOutlet UITextField *tInput;
@property (weak, nonatomic) IBOutlet UILabel *aLabel;
@property (weak, nonatomic) IBOutlet UIButton *btnWrong;
@property (weak, nonatomic) IBOutlet UIButton *btnCorrect;

@property (weak, nonatomic) IBOutlet UILabel *lbStatus;

@end

