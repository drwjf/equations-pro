//
//  EquationsViewController.h
//  Equations
//
//  Created by Neel Somani on 5/19/12.
//  Copyright (c) 2012 Gale Ranch Middle School. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVAudioPlayer.h>
#import <AVFoundation/AVFoundation.h>

@interface EquationsViewController : UIViewController {
    AVAudioPlayer *hit_player;
    AVAudioPlayer *wrong_player;
    AVAudioPlayer *pop_player;
    AVAudioPlayer *pop_player2;
    AVAudioPlayer *pop_player3;
    
    NSMutableArray *reactantsArray;
    NSMutableArray *reactantCoefficients;
    NSMutableArray *productsArray; // array of buttons
    NSMutableArray *productCoefficients; // entered answers
    NSMutableArray *plusArray;
    
    NSMutableArray *eq_reactants;
    NSMutableArray *eq_products; // list of react and prod for equations
}

-(void)gen_equation;
-(void)setup_format;
-(void)load_equations;
-(int)x_pos:(int)pos:(int)num_divisions;
-(void)generate_side:(int)side:(int)eq_num;
-(void)generate_completed_side:(int)side:(int)eq_num;
-(void)clear_equation;
-(void)update_score;
-(BOOL)check_equation;
BOOL isPad(void);

- (IBAction)submit:(id)sender;
- (IBAction)slider_change:(id)sender;
- (IBAction)reset_equation:(id)sender;
- (IBAction)skip:(id)sender;

@property (strong, nonatomic) IBOutlet UILabel *verification;
@property (strong, nonatomic) IBOutlet UILabel *score;
@property (strong, nonatomic) IBOutlet UISlider *slider;

@end
