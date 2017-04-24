//
//  ViewController.m
//  FCS3342
//
//  Created by Haoyu Gu on 2017-04-17.
//  Copyright © 2017 Haoyu Gu. All rights reserved.
//

#import "ViewController.h"
#import "DetailViewController.h"

#define BASE_COUNT_PER_Q 1


@interface ViewController () <UIAlertViewDelegate, UITextFieldDelegate>

@property (nonatomic, retain) NSDictionary *data;
@property (nonatomic, retain) NSMutableArray *stat;
@property (nonatomic) NSInteger total;
@property (nonatomic) NSInteger prct;
@property (nonatomic, retain) NSMutableArray *hist;
@property (nonatomic) NSString *currQ;
@property (nonatomic) NSString *currA;
@property (nonatomic) NSInteger currN;
@property (nonatomic) NSInteger histPtr;

@end

@implementation ViewController

- (void)viewDidLoad {
    [self.navigationController.navigationBar setHidden:YES];
    srand (time(NULL)); 
    [super viewDidLoad];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    
    [self.btnWrong setHidden:YES];
    [self.btnCorrect setHidden:YES];
    self.stat = [[NSMutableArray alloc] init];
    self.hist = [[NSMutableArray alloc] init];
    self.prct = 0;
    self.total = 0;
    // Do any additional setup after loading the view, typically from a nib.
    NSString *pathStr = [[NSBundle mainBundle] pathForResource:@"examdatabase" ofType:@"json"];
    self.data = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:pathStr options:NSDataReadingUncached error:nil] options:NSJSONReadingMutableLeaves error:nil];
    [self.tInput setAutocorrectionType:UITextAutocorrectionTypeNo];
    [self.tInput setReturnKeyType:UIReturnKeyGo];
    self.tInput.delegate = self;
    [self load];
    [self genShow];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController.navigationBar setHidden:YES];
    [super viewWillAppear:animated];
}

-(void)save {
    [self.stat writeToFile:[NSString stringWithFormat:@"%@/save", NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0]] atomically:YES];
}

-(void)load {
    if ([[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@/save", NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0]]]) {
        @try {
            self.stat = [[NSMutableArray alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@/save", NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0]]];
            self.total = 0;
            for (int i=0;i<[self.stat count];i++) {
                self.total += [[self.stat[i] objectForKey:@"QC"] intValue];
            }
        } @catch (NSException *exception) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"User file corrupted!\nYou can reset it or restart the app to retry." delegate:self cancelButtonTitle:@"Let(Make) it(me) crash!" otherButtonTitles:@"Reset", @"Continue", nil];
            [alert show];
        } @finally {
            
        }
    }
    else {
        self.total = BASE_COUNT_PER_Q * [[self.data objectForKey:@"questions"] count];
        for (int i=0;i<[[self.data objectForKey:@"questions"] count]; i++) {
            [self.stat addObject:@{@"QSN": [NSNumber numberWithInt:i], @"QC": [NSNumber numberWithInt:BASE_COUNT_PER_Q]}];
        }
        [self save];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == [alertView cancelButtonIndex]) {
        exit(0);
    }
    else if (buttonIndex == 1) {
        self.total = BASE_COUNT_PER_Q * [[self.data objectForKey:@"questions"] count];
        for (int i=0;i<[[self.data objectForKey:@"questions"] count]; i++) {
            [self.stat addObject:@{@"QSN": [NSNumber numberWithInt:i], @"QC": @2}];
        }
        [self save];
    }
    else {
        //nothing
    }
}

- (void)genShow {
    if (self.total == 0 || self.prct == self.total) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Mastered!!" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    int n = [self genRand];
    while ([[self.stat[n] objectForKey:@"QC"] isEqual:@0]) {
        n = [self genRand];
    }
    self.currN = n;
    if ([[[self.data objectForKey:@"questions"][n] objectForKey:@"answer"] isKindOfClass:[NSArray class]]) {
        self.currA = @"";
        for (id str in [[self.data objectForKey:@"questions"][n] objectForKey:@"answer"]) {
            self.currA = [NSString stringWithFormat:@"%@\n%@", self.currA, str];
        }
    }
    else {
        self.currA = [[self.data objectForKey:@"questions"][n] objectForKey:@"answer"];
    }
    self.currQ = [[self.data objectForKey:@"questions"][n] objectForKey:@"question"];
    [self.hist addObject:[NSNumber numberWithInt:n]];
    self.histPtr = [self.hist count]-1;
    [self showQ];
    [self.lbStatus setText:[NSString stringWithFormat:@"Current progress: %.2f%%", 100.0*self.prct/self.total]];
    [self.tInput becomeFirstResponder];
}

- (void)showQ {
    [self.aLabel setText:@""];
    [self.tInput setText:@""];
    [self.qLabel setText:self.currQ];
}

- (void)showA {
    [self.aLabel setText:self.currA];
}


- (int)genRand {
    return rand()%[[self.data objectForKey:@"questions"] count];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self btnCheckTapped:nil];
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnPrevTapped:(id)sender {
    if (self.histPtr > 0) {
        self.histPtr--;
        if ([[[self.data objectForKey:@"questions"][[self.hist[_histPtr] intValue]] objectForKey:@"answer"] isKindOfClass:[NSArray class]]) {
            self.currA = @"";
            for (id str in [[self.data objectForKey:@"questions"][[self.hist[_histPtr] intValue]] objectForKey:@"answer"]) {
                self.currA = [NSString stringWithFormat:@"%@\n%@", self.currA, str];
            }
        }
        else {
            self.currA = [[self.data objectForKey:@"questions"][[self.hist[_histPtr] intValue]] objectForKey:@"answer"];
        }
        self.currQ = [[self.data objectForKey:@"questions"][[self.hist[_histPtr] intValue]] objectForKey:@"question"];
        [self showQ];
        [self showA];
    }
}
- (IBAction)btnStatisticTapped:(id)sender {
    NSString *str = [NSString stringWithFormat:@"Q_Count = %ld _prct = %ld\n_total = %ld\n_histPtr = %ld", (long)[self.stat count], (long)self.prct, (long)self.total, (long)self.histPtr];
   /* UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Statistic" message:str delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];*/
    [self performSegueWithIdentifier:@"sugueDetail" sender:nil];
}
- (IBAction)btnNextTapped:(id)sender {
    [self.aLabel setText:@""];
    if (self.histPtr == [self.hist count]-1) {
        [self genShow];
        [self.btnCorrect setHidden:YES];
        [self.btnWrong setHidden:YES];
    }
    else {
        self.histPtr++;
        if ([[[self.data objectForKey:@"questions"][[self.hist[_histPtr] intValue]] objectForKey:@"answer"] isKindOfClass:[NSArray class]]) {
            self.currA = @"";
            for (id str in [[self.data objectForKey:@"questions"][[self.hist[_histPtr] intValue]] objectForKey:@"answer"]) {
                self.currA = [NSString stringWithFormat:@"%@\n%@", self.currA, str];
            }
        }
        else {
            self.currA = [[self.data objectForKey:@"questions"][[self.hist[_histPtr] intValue]] objectForKey:@"answer"];
        }
        self.currQ = [[self.data objectForKey:@"questions"][[self.hist[_histPtr] intValue]] objectForKey:@"question"];
        [self showQ];
        [self showA];
    }
}
- (IBAction)btnWrongTapped:(id)sender {
    if (self.histPtr == [self.hist count]-1) {
        [self.stat[[self.hist[_histPtr] intValue]] setObject:[NSNumber numberWithInt:[[self.stat[[self.hist[_histPtr] intValue]] objectForKey:@"QC"] intValue]+1] forKey:@"QC"];
        self.total++;
        [self.lbStatus setText:[NSString stringWithFormat:@"Current progress: %.2f%%", 100.0*self.prct/self.total]];
        [self save];
        [self btnNextTapped:nil];
    }
}
- (IBAction)btnCheckTapped:(id)sender {
    if (self.tInput.text == self.currA) {
        [self btnCorrectTapped:nil];
    }
    else {
        [self dismissKeyboard];
        [self showA];
        [self.btnWrong setHidden:NO];
        [self.btnCorrect setHidden:NO];
    }
}
- (IBAction)btnCorrectTapped:(id)sender {
    if (self.histPtr == [self.hist count]-1) {
        if ([[self.stat[[self.hist[_histPtr] intValue]] objectForKey:@"QC"] intValue] > 0) {
            [self.stat[[self.hist[_histPtr] intValue]] setObject:[NSNumber numberWithInt:[[self.stat[[self.hist[_histPtr] intValue]] objectForKey:@"QC"] intValue]-1] forKey:@"QC"];
            self.prct++;
            [self.lbStatus setText:[NSString stringWithFormat:@"Current progress: %.2f%%", 100.0*self.prct/self.total]];
            [self save];
        }
        [self btnNextTapped:nil];
    }
}
- (IBAction)btnGoTapped:(id)sender {
}

-(void)dismissKeyboard {
    [self.tInput resignFirstResponder];
}
- (IBAction)removeUserData:(id)sender {
    if ([self.tInput.text isEqualToString:@"REMOVEUSERFILE_CONFIRM"]) {
        [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@/save", NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0]] error:nil];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Cleared" message:@"Please restart the app." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [self.view removeFromSuperview];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Howto" message:@"Please type REMOVEUSERFILE_CONFIRM at the answer field above." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    NSString *str = [segue identifier];
    if ([str isEqualToString:@"sugueDetail"]) {
        DetailViewController *dest = [segue destinationViewController];
        NSString *str = [NSString stringWithFormat:@"Q_Count = %ld  _prct = %ld\n_total = %ld  _histPtr = %ld", (long)[self.stat count], (long)self.prct, (long)self.total, (long)self.histPtr];
        [dest loadData:self.stat and:[self.data objectForKey:@"questions"] and:str];
    }
}

@end
