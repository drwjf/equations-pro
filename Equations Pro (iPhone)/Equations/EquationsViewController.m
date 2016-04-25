//
//  EquationsViewController.m
//  Equations
//
//  Created by Neel Somani on 5/19/12.
//  Copyright (c) 2012 Gale Ranch Middle School. All rights reserved.
//

#import "EquationsViewController.h"
#import "AppDelegate.h"

int SCREEN_HEIGHT = 1024;
int SCREEN_WIDTH = 768;
int selected = 0; // selected is the button currently active. 0 - 4 reactants, 5 - 9 products
int stored_bound = 0; //used to align plus signs
int equation_num = 0; // used for verification
int reactantCoefficientAnswers[100][5];
int productCoefficientAnswers[100][5]; // correct answers
int num_reactants[100];
int num_products[100]; // num of reactants and products    
BOOL first_try = YES;
int pop_alt = 0; //alternate popping noises
int completed = 0;
int correct = 0;
int levelNumber = 0;
int easyProblems[100]; //listing of problem #'s of easy and hard
int hardProblems[100];

@implementation EquationsViewController
@synthesize verification;
@synthesize slider;
@synthesize score;


BOOL isPad() {
#ifdef UI_USER_INTERFACE_IDIOM
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
#else
    return NO;
#endif
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(int)x_pos:(int)pos:(int)num_divisions{
    float div = SCREEN_WIDTH / num_divisions;
    float bound1 = div * (pos - 1);
    float bound2 = div * pos;
    float x = (bound1 + bound2) / 2;
    
    x -= 75; //adjust for center of button
    return x;
}

-(BOOL)check_equation {
    BOOL is_correct = YES;
    for (int i = 0; i < 5; i++){
        int num1 = reactantCoefficientAnswers[equation_num][i];
        NSNumber *nsnum2 = [reactantCoefficients objectAtIndex:i];
        int num2 = [nsnum2 intValue];
        if (num1 != num2) is_correct = NO;
    }
    for (int i = 0; i < 5; i++){
        int num1 = productCoefficientAnswers[equation_num][i];
        NSNumber *nsnum2 = [productCoefficients objectAtIndex:i];
        int num2 = [nsnum2 intValue];
        if (num1 != num2) is_correct = NO;
    }
    return is_correct;
}

-(void)generate_completed_side:(int)side:(int)eq_num{
    int y_pos = (side == 0 ? (SCREEN_HEIGHT / 3) - 100 : (SCREEN_HEIGHT / 3) + 100);
    if (side == 0){
        int num_divisions = num_reactants[eq_num];
        for (int i = 0; i < num_divisions; i++) { // set reactant buttons
            UIButton *myButton = [reactantsArray objectAtIndex:i];
            myButton.frame = CGRectMake([self x_pos:i + 1 :num_divisions], y_pos, 150, 90);
            NSString *theString = [[eq_reactants objectAtIndex:eq_num] objectAtIndex:i];
            int coef = reactantCoefficientAnswers[eq_num][i];
            NSString *fullString = [NSString stringWithFormat:@"%d%@", coef, theString];
            if (coef != 1) [myButton setTitle:fullString forState:UIControlStateNormal];
            else [myButton setTitle:theString forState:UIControlStateNormal];
            
            // create plus
            
            if (i != 0) {
                int plus_x = (stored_bound + [self x_pos:i + 1 :num_divisions] + 75) / 2;
                [[plusArray objectAtIndex:i] setText:@"+"];
                UILabel *plus = [plusArray objectAtIndex:i];
                plus.frame = CGRectMake(plus_x - 100, y_pos, 200, 100);
            }
            stored_bound = [self x_pos:i + 1 :num_divisions] + 75;
        }
    }
    else {
        int num_divisions = num_products[eq_num];
        for (int i = 0; i < num_divisions; i++) { // set product buttons
            UIButton *myButton = [productsArray objectAtIndex:i];
            myButton.frame = CGRectMake([self x_pos:i + 1 :num_divisions], y_pos, 150, 90);
            NSString *theString = [[eq_products objectAtIndex:eq_num] objectAtIndex:i];
            int coef = productCoefficientAnswers[eq_num][i];
            NSString *fullString = [NSString stringWithFormat:@"%d%@", coef, theString];
            if (coef != 1) [myButton setTitle:fullString forState:UIControlStateNormal];
            else [myButton setTitle:theString forState:UIControlStateNormal];
            
            // create plus
            
            if (i != 0) {
                int plus_x = (stored_bound + [self x_pos:i + 1 :num_divisions] + 75) / 2;
                [[plusArray objectAtIndex:i + 4] setText:@"+"];
                UILabel *plus = [plusArray objectAtIndex:i + 4];
                plus.frame = CGRectMake(plus_x - 100, y_pos - 5, 200, 100);
            }
            stored_bound = [self x_pos:i + 1 :num_divisions] + 75;
        }
    }
}

-(void)generate_side:(int)side:(int)eq_num{
    int y_pos = (side == 0 ? (SCREEN_HEIGHT / 3) - 100 : (SCREEN_HEIGHT / 3) + 100);
    if (side == 0){
        int num_divisions = num_reactants[eq_num];
        for (int i = 0; i < num_divisions; i++) { // set reactant buttons
            UIButton *myButton = [reactantsArray objectAtIndex:i];
            myButton.frame = CGRectMake([self x_pos:i + 1 :num_divisions], y_pos, 150, 90);
            NSMutableArray *reactants = [eq_reactants objectAtIndex:equation_num];
            NSString *reactant = [reactants objectAtIndex:i];
            [myButton setTitle:reactant forState:UIControlStateNormal];
            // create plus
            
            if (i != 0) {
                int plus_x = (stored_bound + [self x_pos:i + 1 :num_divisions] + 75) / 2;
                [[plusArray objectAtIndex:i] setText:@"+"];
                UILabel *plus = [plusArray objectAtIndex:i];
                plus.frame = CGRectMake(plus_x - 100, y_pos - 5, 200, 100);
            }
            stored_bound = [self x_pos:i + 1 :num_divisions] + 75;
        }
    }
    else {
        int num_divisions = num_products[eq_num];
        for (int i = 0; i < num_divisions; i++) { // set product buttons
            UIButton *myButton = [productsArray objectAtIndex:i];
            myButton.frame = CGRectMake([self x_pos:i + 1 :num_divisions], y_pos, 150, 90);
            [myButton setTitle:[[eq_products objectAtIndex:eq_num] objectAtIndex:i] forState:UIControlStateNormal];
            
            // create plus
            
            if (i != 0) {
                int plus_x = (stored_bound + [self x_pos:i + 1 :num_divisions] + 75) / 2;
                [[plusArray objectAtIndex:i + 4] setText:@"+"];
                UILabel *plus = [plusArray objectAtIndex:i + 4];
                plus.frame = CGRectMake(plus_x - 100, y_pos, 200, 100);
            }
            stored_bound = [self x_pos:i + 1 :num_divisions] + 75;
        }
    }
}


- (IBAction)reset_equation:(id)sender {
    [self clear_equation];
    for (int i = 0; i < 2; i++) [self generate_side:i:equation_num]; //reactants and products
    [pop_player play];
}

- (IBAction)skip:(id)sender {
    completed++;
    [self update_score];
    [self clear_equation];
    for (int i = 0; i < 2; i++) [self generate_completed_side:i:equation_num]; //reactants and products
    [wrong_player play];
}

-(void)gen_equation {
    int old_eq_num = equation_num;
    BOOL run = YES;
    while (run){
        int num_in_equation_array = arc4random() % 25;
        
        if (levelNumber == 0) {
            equation_num = easyProblems[num_in_equation_array];
        }
        else {
            equation_num = hardProblems[num_in_equation_array];
        }
        
        
        if (old_eq_num == equation_num){
            run = YES;
        }
        else if (!isPad()){
            BOOL set = NO;
            if (num_reactants[equation_num] > 3){
                set = YES;
            }
            else if (num_products[equation_num] > 3){
                set = YES;
            }
            run = set;
        }
        else {
            run = NO;
        }
    }
    first_try = YES;
    for (int i = 0; i < 2; i++) [self generate_side:i:equation_num]; //reactants and products
    
    NSLog(@"Equation #%d", equation_num);
}

-(void)clear_equation {
    for (int i = 0; i < 5; i++){
        [[reactantsArray objectAtIndex:i] setTitle:@"" forState:UIControlStateNormal];
        UIButton *button = [reactantsArray objectAtIndex:i];
        button.frame = CGRectMake(-500, -500, 200, 100);
        
        NSNumber *new_coefficient = [NSNumber numberWithInteger:1]; //replace old
        [reactantCoefficients replaceObjectAtIndex:i withObject:new_coefficient];
    }
    for (int i = 0; i < 5; i++){
        [[productsArray objectAtIndex:i] setTitle:@"" forState:UIControlStateNormal];
        UIButton *button = [productsArray objectAtIndex:i];
        button.frame = CGRectMake(-500, -500, 200, 100);
        
        NSNumber *new_coefficient = [NSNumber numberWithInteger:1]; //replace old
        [productCoefficients replaceObjectAtIndex:i withObject:new_coefficient];
    }
    for (int i = 0; i < 9; i++){
        [[plusArray objectAtIndex:i] setText:@""];
    }
    verification.text = @"";
    selected = 0;
    slider.value = 1;
}


- (IBAction)slider_change:(id)sender {
    int new_coefficient = slider.value; // get coefficient to set
    if (selected < 5) {
        NSString *current_title = [[reactantsArray objectAtIndex:selected] currentTitle]; //get current title, current coeffiecient
        NSNumber *current_coefficient = [reactantCoefficients objectAtIndex:selected];
        int int_coefficient = [current_coefficient intValue];
        if (int_coefficient > 1) current_title = [current_title substringFromIndex:1]; //delete old coef.
        if (new_coefficient != 1) current_title = [NSString stringWithFormat:@"%d%@", int_coefficient, current_title];// add new coefficient
    
        [[reactantsArray objectAtIndex:selected] setTitle:current_title forState:UIControlStateNormal];
    
        NSNumber *coefficientToAdd = [NSNumber numberWithInteger:new_coefficient]; //replace old
        [reactantCoefficients replaceObjectAtIndex:selected withObject:coefficientToAdd];
    }
    else {
        int product_object_index = selected - 5;
        NSString *current_title = [[productsArray objectAtIndex:product_object_index] currentTitle]; //get current title, current coeffiecient
        NSNumber *current_coefficient = [productCoefficients objectAtIndex:product_object_index];
        int int_coefficient = [current_coefficient intValue];
        if (int_coefficient > 1) current_title = [current_title substringFromIndex:1]; //delete old coef.
        if (new_coefficient != 1) current_title = [NSString stringWithFormat:@"%d%@", int_coefficient, current_title];// add new coefficient
        
        [[productsArray objectAtIndex:product_object_index] setTitle:current_title forState:UIControlStateNormal];
        
        NSNumber *coefficientToAdd = [NSNumber numberWithInteger:new_coefficient]; //replace old
        [productCoefficients replaceObjectAtIndex:product_object_index withObject:coefficientToAdd];
    }
    verification.text = @"";
}

- (IBAction)change_coefficient:(id)sender {
    NSString *current = [sender currentTitle]; //get title of button
    UIButton *button = (UIButton *)sender; // cast button
    
    int button_num = [button tag]; // button array num
    selected = button_num;
    
    if (selected < 5) {
        NSNumber *coefficient = [reactantCoefficients objectAtIndex:button_num];
        int int_coefficient = [coefficient intValue];
        if (int_coefficient > 1) current = [current substringFromIndex:1]; //delete old coef.
    
        if (int_coefficient < 9) int_coefficient += 1; // set new coefficient
        else int_coefficient = 1;
    
        if (int_coefficient != 1) current = [NSString stringWithFormat:@"%d%@", int_coefficient, current]; //add new coeff.
        [sender setTitle:current forState:UIControlStateNormal]; // set title
    
        NSNumber *new_coefficient = [NSNumber numberWithInteger:int_coefficient]; //replace old
        [reactantCoefficients replaceObjectAtIndex:button_num withObject:new_coefficient];
        slider.value = int_coefficient;
    }
    else {
        int product_button_num = selected - 5;
        NSNumber *coefficient = [productCoefficients objectAtIndex:product_button_num];
        int int_coefficient = [coefficient intValue];
        if (int_coefficient > 1) current = [current substringFromIndex:1]; //delete old coef.
        
        if (int_coefficient < 9) int_coefficient += 1; // set new coefficient
        else int_coefficient = 1;
        
        if (int_coefficient != 1) current = [NSString stringWithFormat:@"%d%@", int_coefficient, current]; //add new coeff.
        [sender setTitle:current forState:UIControlStateNormal]; // set title
        
        NSNumber *new_coefficient = [NSNumber numberWithInteger:int_coefficient]; //replace old
        [productCoefficients replaceObjectAtIndex:product_button_num withObject:new_coefficient];
        slider.value = int_coefficient;
    }
    verification.text = @"";
    if (pop_alt == 0){
        pop_alt = 1;
        [pop_player play];
    }
    else if (pop_alt == 1) {
        pop_alt = 2;
        [pop_player2 play];
    }
    else {
        pop_alt = 0;
        [pop_player3 play];
    }
}
     
- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

- (void)setup_format {
    if (!isPad()){
        SCREEN_WIDTH = 320;
        SCREEN_HEIGHT = 480;
    }
    reactantsArray = [NSMutableArray arrayWithCapacity:5]; //initialize reactants array
    plusArray = [NSMutableArray arrayWithCapacity:9]; //initialize plus array
    reactantCoefficients = [NSMutableArray arrayWithCapacity:5];
    productsArray = [NSMutableArray arrayWithCapacity:5]; //initialize products array
    productCoefficients = [NSMutableArray arrayWithCapacity:5];
    
    int y_pos = (SCREEN_HEIGHT / 3);
    int num_divisions = 5; // set up for 5 reactants max
    
    for (int i = 0; i < num_divisions; i++) { // create 5 reactant buttons
        UIButton *myButton = [UIButton buttonWithType:UIButtonTypeCustom];
        myButton.frame = CGRectMake([self x_pos:i + 1 :num_divisions], y_pos, 200, 100);
        [myButton setTitle:@"Lorem..." forState:UIControlStateNormal];
        [myButton addTarget:self action:@selector(change_coefficient:) forControlEvents:UIControlEventTouchUpInside];
        if (isPad()){
            myButton.titleLabel.font = [UIFont fontWithName:@"Arial" size: 25.0];
        }
        else {
            myButton.titleLabel.font = [UIFont fontWithName:@"Arial" size: 20.0];
        }
        myButton.titleLabel.textColor = [UIColor whiteColor];
        myButton.backgroundColor = [UIColor clearColor];
        myButton.tag = i; // set tag for function
        [self.view addSubview:myButton];
        
        [reactantsArray addObject:myButton]; // add button to array
        NSNumber *coefficient = [NSNumber numberWithInteger:1];
        [reactantCoefficients addObject:coefficient];
    }
    for (int i = 0; i < num_divisions; i++) { // create 5 product buttons
        UIButton *myButton = [UIButton buttonWithType:UIButtonTypeCustom];
        myButton.frame = CGRectMake([self x_pos:i + 1 :num_divisions], y_pos, 200, 100);
        [myButton setTitle:@"Lorem..." forState:UIControlStateNormal];
        [myButton addTarget:self action:@selector(change_coefficient:) forControlEvents:UIControlEventTouchUpInside];
        if (isPad()){
            myButton.titleLabel.font = [UIFont fontWithName:@"Arial" size: 25.0];
        }
        else {
            myButton.titleLabel.font = [UIFont fontWithName:@"Arial" size: 20.0];
        }
        myButton.titleLabel.textColor = [UIColor whiteColor];
        myButton.backgroundColor = [UIColor clearColor];
        myButton.tag = i + 5; // set tag for function
        [self.view addSubview:myButton];
        
        [productsArray addObject:myButton]; // add button to array
        NSNumber *coefficient = [NSNumber numberWithInteger:1];
        [productCoefficients addObject:coefficient];
    }
    
    for (int i = 0; i < 9; i++) { // create 8 plus signs
        UILabel *theLabel = [[UILabel alloc] initWithFrame:CGRectMake(i * 20, 100, 200, 100)];
        theLabel.text = @"+";
        if (isPad()){
            theLabel.font = [UIFont fontWithName:@"Helvetica" size: 25.0];
        }
        else {
            theLabel.font = [UIFont fontWithName:@"Helvetica" size: 20.0];
        }
        theLabel.textColor = [UIColor whiteColor];
        theLabel.backgroundColor = [UIColor clearColor];
        theLabel.textAlignment = UITextAlignmentCenter;
        [self.view addSubview:theLabel];
        
        [plusArray addObject:theLabel];
    }
    
    NSString *hitPath = [[NSBundle mainBundle] pathForResource:@"hit" ofType:@"caf"];
    hit_player =[[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:hitPath] error:NULL];
    
    NSString *wrongPath = [[NSBundle mainBundle] pathForResource:@"buzz" ofType:@"wav"];
    wrong_player =[[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:wrongPath] error:NULL];
    
    NSString *popPath = [[NSBundle mainBundle] pathForResource:@"pop" ofType:@"caf"];
    pop_player =[[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:popPath] error:NULL];
    pop_player2 =[[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:popPath] error:NULL];
    pop_player3 =[[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:popPath] error:NULL];
    
    [hit_player prepareToPlay];
    [pop_player prepareToPlay];
    [pop_player2 prepareToPlay];
    [pop_player3 prepareToPlay];
    [wrong_player prepareToPlay];
    
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    levelNumber = (int) appDelegate.levelnumber;
    
    completed = 0;
    correct = 0; //reset variables
}

-(void)load_equations{
    NSUInteger objIdx = [eq_reactants indexOfObject: 0]; //check if array exists
    if(objIdx != NSNotFound) {
        eq_reactants = [NSMutableArray arrayWithCapacity:100];
        eq_products = [NSMutableArray arrayWithCapacity:100];
        for (int i = 0; i < 100; i++) {
            for (int y = 0; y < 5; y++){
                reactantCoefficientAnswers[i][y] = 1;
                productCoefficientAnswers[i][y] = 1;
            }
        } // init all arrays
        
        easyProblems[0] = 0;
        easyProblems[1] = 4;
        easyProblems[2] = 10;
        easyProblems[3] = 11;
        easyProblems[4] = 12;
        easyProblems[5] = 14;
        easyProblems[6] = 16;
        easyProblems[7] = 17;
        easyProblems[8] = 19;
        easyProblems[9] = 22;
        easyProblems[10] = 23;
        easyProblems[11] = 26;
        easyProblems[12] = 27;
        easyProblems[13] = 31;
        easyProblems[14] = 32;
        easyProblems[15] = 34;
        easyProblems[16] = 35;
        easyProblems[17] = 36;
        easyProblems[18] = 37;
        easyProblems[19] = 43;
        easyProblems[20] = 44;
        easyProblems[21] = 45;
        easyProblems[22] = 46;
        easyProblems[23] = 48;
        easyProblems[24] = 20;
        
        hardProblems[0] = 1;
        hardProblems[1] = 2;
        hardProblems[2] = 3;
        hardProblems[3] = 5;
        hardProblems[4] = 6;
        hardProblems[5] = 7;
        hardProblems[6] = 8;
        hardProblems[7] = 9;
        hardProblems[8] = 13;
        hardProblems[9] = 15;
        hardProblems[10] = 18;
        hardProblems[11] = 49;
        hardProblems[12] = 21;
        hardProblems[13] = 24;
        hardProblems[14] = 25;
        hardProblems[15] = 28;
        hardProblems[16] = 29;
        hardProblems[17] = 30;
        hardProblems[18] = 33;
        hardProblems[19] = 38;
        hardProblems[20] = 39;
        hardProblems[21] = 40;
        hardProblems[22] = 41;
        hardProblems[23] = 42;
        hardProblems[24] = 47;
        
        int eq_number = 0;
        
        [eq_reactants addObject:[NSMutableArray arrayWithCapacity:2]];
        [eq_products addObject:[NSMutableArray arrayWithCapacity:3]]; // add products and reactants arrays in 1st pos
        
        [[eq_reactants objectAtIndex:eq_number] addObject:@"Ag"];
        [[eq_reactants objectAtIndex:eq_number] addObject:@"H₂SO₄"];
        [[eq_products objectAtIndex:eq_number] addObject:@"Ag₂SO₄"];
        [[eq_products objectAtIndex:eq_number] addObject:@"SO₂"];
        [[eq_products objectAtIndex:eq_number] addObject:@"H₂0"]; // fill arrays
        
        num_reactants[eq_number] = 2;
        num_products[eq_number] = 3;
        
        reactantCoefficientAnswers[eq_number][0] = 2;
        reactantCoefficientAnswers[eq_number][1] = 2;
        productCoefficientAnswers[eq_number][2] = 2; // set answers
        
        eq_number = 1;
        
        [eq_reactants addObject:[NSMutableArray arrayWithCapacity:2]];
        [eq_products addObject:[NSMutableArray arrayWithCapacity:3]]; // add products and reactants arrays in 1st pos
        
        [[eq_reactants objectAtIndex:eq_number] addObject:@"Cu"];
        [[eq_reactants objectAtIndex:eq_number] addObject:@"HNO₃"];
        [[eq_products objectAtIndex:eq_number] addObject:@"Cu(NO₃)₂"];
        [[eq_products objectAtIndex:eq_number] addObject:@"NO"];
        [[eq_products objectAtIndex:eq_number] addObject:@"H₂0"]; // fill arrays
        
        num_reactants[eq_number] = 2;
        num_products[eq_number] = 3;
        
        reactantCoefficientAnswers[eq_number][0] = 3;
        reactantCoefficientAnswers[eq_number][1] = 8;
        productCoefficientAnswers[eq_number][0] = 3;
        productCoefficientAnswers[eq_number][1] = 2;
        productCoefficientAnswers[eq_number][2] = 4; // set answers
        
        eq_number = 2;
        
        [eq_reactants addObject:[NSMutableArray arrayWithCapacity:2]];
        num_reactants[eq_number] = 2;
        [[eq_reactants objectAtIndex:eq_number] addObject:@"Bi"];
        reactantCoefficientAnswers[eq_number][0] = 1;
        [[eq_reactants objectAtIndex:eq_number] addObject:@"HNO₃"];
        reactantCoefficientAnswers[eq_number][1] = 4;
        
        [eq_products addObject:[NSMutableArray arrayWithCapacity:3]];
        num_products[eq_number] = 3;
        [[eq_products objectAtIndex:eq_number] addObject:@"Bi(NO₃)₃"];
        productCoefficientAnswers[eq_number][0] = 1;
        [[eq_products objectAtIndex:eq_number] addObject:@"H₂O"];
        productCoefficientAnswers[eq_number][1] = 2;
        [[eq_products objectAtIndex:eq_number] addObject:@"NO"];
        productCoefficientAnswers[eq_number][2] = 1;
        
        eq_number = 3;
        
        [eq_reactants addObject:[NSMutableArray arrayWithCapacity:2]];
        num_reactants[eq_number] = 2;
        [[eq_reactants objectAtIndex:eq_number] addObject:@"Sn"];
        reactantCoefficientAnswers[eq_number][0] = 1;
        [[eq_reactants objectAtIndex:eq_number] addObject:@"HNO₃"];
        reactantCoefficientAnswers[eq_number][1] = 4;
        
        [eq_products addObject:[NSMutableArray arrayWithCapacity:3]];
        num_products[eq_number] = 3;
        [[eq_products objectAtIndex:eq_number] addObject:@"SnO₂"];
        productCoefficientAnswers[eq_number][0] = 1;
        [[eq_products objectAtIndex:eq_number] addObject:@"NO₂"];
        productCoefficientAnswers[eq_number][1] = 4;
        [[eq_products objectAtIndex:eq_number] addObject:@"H₂O"];
        productCoefficientAnswers[eq_number][2] = 2;
        
        eq_number = 4;
        
        [eq_reactants addObject:[NSMutableArray arrayWithCapacity:2]];
        num_reactants[eq_number] = 2;
        [[eq_reactants objectAtIndex:eq_number] addObject:@"PbO₂"];
        reactantCoefficientAnswers[eq_number][0] = 1;
        [[eq_reactants objectAtIndex:eq_number] addObject:@"HCl"];
        reactantCoefficientAnswers[eq_number][1] = 4;
        
        [eq_products addObject:[NSMutableArray arrayWithCapacity:3]];
        num_products[eq_number] = 3;
        [[eq_products objectAtIndex:eq_number] addObject:@"PbCl₂"];
        productCoefficientAnswers[eq_number][0] = 1;
        [[eq_products objectAtIndex:eq_number] addObject:@"Cl₂"];
        productCoefficientAnswers[eq_number][1] = 1;
        [[eq_products objectAtIndex:eq_number] addObject:@"H₂O"];
        productCoefficientAnswers[eq_number][2] = 2;

        eq_number = 5;
        
        [eq_reactants addObject:[NSMutableArray arrayWithCapacity:2]];
        num_reactants[eq_number] = 2;
        [[eq_reactants objectAtIndex:eq_number] addObject:@"Mn₂O₇"];
        reactantCoefficientAnswers[eq_number][0] = 2;
        [[eq_reactants objectAtIndex:eq_number] addObject:@"H₂SO₄"];
        reactantCoefficientAnswers[eq_number][1] = 4;
        
        [eq_products addObject:[NSMutableArray arrayWithCapacity:3]];
        num_products[eq_number] = 3;
        [[eq_products objectAtIndex:eq_number] addObject:@"MnSO₄"];
        productCoefficientAnswers[eq_number][0] = 4;
        [[eq_products objectAtIndex:eq_number] addObject:@"H₂O"];
        productCoefficientAnswers[eq_number][1] = 4;
        [[eq_products objectAtIndex:eq_number] addObject:@"O₂"];
        productCoefficientAnswers[eq_number][2] = 5;
        
        eq_number = 6;
        
        [eq_reactants addObject:[NSMutableArray arrayWithCapacity:2]];
        num_reactants[eq_number] = 2;
        [[eq_reactants objectAtIndex:eq_number] addObject:@"Sb₂S₅"];
        reactantCoefficientAnswers[eq_number][0] = 1;
        [[eq_reactants objectAtIndex:eq_number] addObject:@"HCl"];
        reactantCoefficientAnswers[eq_number][1] = 6;
        
        [eq_products addObject:[NSMutableArray arrayWithCapacity:3]];
        num_products[eq_number] = 3;
        [[eq_products objectAtIndex:eq_number] addObject:@"H₂S"];
        productCoefficientAnswers[eq_number][0] = 3;
        [[eq_products objectAtIndex:eq_number] addObject:@"S"];
        productCoefficientAnswers[eq_number][1] = 2;
        [[eq_products objectAtIndex:eq_number] addObject:@"SbCl₃"];
        productCoefficientAnswers[eq_number][2] = 2;
        
        eq_number = 7;
        
        [eq_reactants addObject:[NSMutableArray arrayWithCapacity:3]];
        num_reactants[eq_number] = 3;
        [[eq_reactants objectAtIndex:eq_number] addObject:@"P"];
        reactantCoefficientAnswers[eq_number][0] = 3;
        [[eq_reactants objectAtIndex:eq_number] addObject:@"HNO₃"];
        reactantCoefficientAnswers[eq_number][1] = 5;
        [[eq_reactants objectAtIndex:eq_number] addObject:@"H₂O"];
        reactantCoefficientAnswers[eq_number][2] = 2;
        
        [eq_products addObject:[NSMutableArray arrayWithCapacity:2]];
        num_products[eq_number] = 2;
        [[eq_products objectAtIndex:eq_number] addObject:@"H₃PO₄"];
        productCoefficientAnswers[eq_number][0] = 3;
        [[eq_products objectAtIndex:eq_number] addObject:@"NO"];
        productCoefficientAnswers[eq_number][1] = 5;
        
        eq_number = 8;
        
        [eq_reactants addObject:[NSMutableArray arrayWithCapacity:2]];
        num_reactants[eq_number] = 2;
        [[eq_reactants objectAtIndex:eq_number] addObject:@"CeO₂"];
        reactantCoefficientAnswers[eq_number][0] = 2;
        [[eq_reactants objectAtIndex:eq_number] addObject:@"HCl"];
        reactantCoefficientAnswers[eq_number][1] = 8;
        
        [eq_products addObject:[NSMutableArray arrayWithCapacity:3]];
        num_products[eq_number] = 3;
        [[eq_products objectAtIndex:eq_number] addObject:@"CeCl₃"];
        productCoefficientAnswers[eq_number][0] = 2;
        [[eq_products objectAtIndex:eq_number] addObject:@"Cl₂"];
        productCoefficientAnswers[eq_number][1] = 1;
        [[eq_products objectAtIndex:eq_number] addObject:@"H₂O"];
        productCoefficientAnswers[eq_number][2] = 4;
        
        eq_number = 9;
        
        [eq_reactants addObject:[NSMutableArray arrayWithCapacity:2]];
        num_reactants[eq_number] = 2;
        [[eq_reactants objectAtIndex:eq_number] addObject:@"Hg"];
        reactantCoefficientAnswers[eq_number][0] = 3;
        [[eq_reactants objectAtIndex:eq_number] addObject:@"HNO₃"];
        reactantCoefficientAnswers[eq_number][1] = 8;
        
        [eq_products addObject:[NSMutableArray arrayWithCapacity:3]];
        num_products[eq_number] = 3;
        [[eq_products objectAtIndex:eq_number] addObject:@"Hg(NO₃)₂"];
        productCoefficientAnswers[eq_number][0] = 3;
        [[eq_products objectAtIndex:eq_number] addObject:@"NO"];
        productCoefficientAnswers[eq_number][1] = 2;
        [[eq_products objectAtIndex:eq_number] addObject:@"H₂O"];
        productCoefficientAnswers[eq_number][2] = 4;
        
        eq_number = 10;
        
        [eq_reactants addObject:[NSMutableArray arrayWithCapacity:2]];
        num_reactants[eq_number] = 2;
        [[eq_reactants objectAtIndex:eq_number] addObject:@"HgCl₂"];
        reactantCoefficientAnswers[eq_number][0] = 2;
        [[eq_reactants objectAtIndex:eq_number] addObject:@"HCOOH"];
        reactantCoefficientAnswers[eq_number][1] = 1;
        
        [eq_products addObject:[NSMutableArray arrayWithCapacity:3]];
        num_products[eq_number] = 3;
        [[eq_products objectAtIndex:eq_number] addObject:@"Hg₂Cl₂"];
        productCoefficientAnswers[eq_number][0] = 1;
        [[eq_products objectAtIndex:eq_number] addObject:@"HCl"];
        productCoefficientAnswers[eq_number][1] = 2;
        [[eq_products objectAtIndex:eq_number] addObject:@"CO₂"];
        productCoefficientAnswers[eq_number][2] = 1;
        
        eq_number = 11;
        
        [eq_reactants addObject:[NSMutableArray arrayWithCapacity:2]];
        num_reactants[eq_number] = 2;
        [[eq_reactants objectAtIndex:eq_number] addObject:@"KClO₃"];
        reactantCoefficientAnswers[eq_number][0] = 2;
        [[eq_reactants objectAtIndex:eq_number] addObject:@"H2C₂O₄"];
        reactantCoefficientAnswers[eq_number][1] = 2;
        
        [eq_products addObject:[NSMutableArray arrayWithCapacity:4]];
        num_products[eq_number] = 4;
        [[eq_products objectAtIndex:eq_number] addObject:@"K₂C₂O₄"];
        productCoefficientAnswers[eq_number][0] = 1;
        [[eq_products objectAtIndex:eq_number] addObject:@"CO₂"];
        productCoefficientAnswers[eq_number][1] = 2;
        [[eq_products objectAtIndex:eq_number] addObject:@"ClO₂"];
        productCoefficientAnswers[eq_number][2] = 2;
        [[eq_products objectAtIndex:eq_number] addObject:@"H₂O"];
        productCoefficientAnswers[eq_number][3] = 2;
        
        eq_number = 12;
        
        [eq_reactants addObject:[NSMutableArray arrayWithCapacity:2]];
        num_reactants[eq_number] = 2;
        [[eq_reactants objectAtIndex:eq_number] addObject:@"CO(NH₂)₂"];
        reactantCoefficientAnswers[eq_number][0] = 1;
        [[eq_reactants objectAtIndex:eq_number] addObject:@"HNO₂"];
        reactantCoefficientAnswers[eq_number][1] = 2;
        
        [eq_products addObject:[NSMutableArray arrayWithCapacity:3]];
        num_products[eq_number] = 3;
        [[eq_products objectAtIndex:eq_number] addObject:@"CO₂"];
        productCoefficientAnswers[eq_number][0] = 1;
        [[eq_products objectAtIndex:eq_number] addObject:@"N₂"];
        productCoefficientAnswers[eq_number][1] = 2;
        [[eq_products objectAtIndex:eq_number] addObject:@"H₂O"];
        productCoefficientAnswers[eq_number][2] = 3;
        
        eq_number = 13;
        
        [eq_reactants addObject:[NSMutableArray arrayWithCapacity:3]];
        num_reactants[eq_number] = 3;
        [[eq_reactants objectAtIndex:eq_number] addObject:@"C₂H₅OH"];
        reactantCoefficientAnswers[eq_number][0] = 5;
        [[eq_reactants objectAtIndex:eq_number] addObject:@"KMnO₄"];
        reactantCoefficientAnswers[eq_number][1] = 2;
        [[eq_reactants objectAtIndex:eq_number] addObject:@"H₂SO₄"];
        reactantCoefficientAnswers[eq_number][2] = 3;
        
        [eq_products addObject:[NSMutableArray arrayWithCapacity:4]];
        num_products[eq_number] = 4;
        [[eq_products objectAtIndex:eq_number] addObject:@"C₂H₄O"];
        productCoefficientAnswers[eq_number][0] = 5;
        [[eq_products objectAtIndex:eq_number] addObject:@"MnSO₄"];
        productCoefficientAnswers[eq_number][1] = 2;
        [[eq_products objectAtIndex:eq_number] addObject:@"K2SO₄"];
        productCoefficientAnswers[eq_number][2] = 1;
        [[eq_products objectAtIndex:eq_number] addObject:@"H₂O"];
        productCoefficientAnswers[eq_number][3] = 8;
        
        eq_number = 14;
        
        [eq_reactants addObject:[NSMutableArray arrayWithCapacity:3]];
        num_reactants[eq_number] = 3;
        [[eq_reactants objectAtIndex:eq_number] addObject:@"V₂O₅"];
        reactantCoefficientAnswers[eq_number][0] = 1;
        [[eq_reactants objectAtIndex:eq_number] addObject:@"H₂SO₄"];
        reactantCoefficientAnswers[eq_number][1] = 2;
        [[eq_reactants objectAtIndex:eq_number] addObject:@"C₂H₅OH"];
        reactantCoefficientAnswers[eq_number][2] = 1;
        
        [eq_products addObject:[NSMutableArray arrayWithCapacity:3]];
        num_products[eq_number] = 3;
        [[eq_products objectAtIndex:eq_number] addObject:@"VOSO₄"];
        productCoefficientAnswers[eq_number][0] = 2;
        [[eq_products objectAtIndex:eq_number] addObject:@"H₂O"];
        productCoefficientAnswers[eq_number][1] = 3;
        [[eq_products objectAtIndex:eq_number] addObject:@"CH₃CHO"];
        productCoefficientAnswers[eq_number][2] = 1;
        
        eq_number = 15;
        
        [eq_reactants addObject:[NSMutableArray arrayWithCapacity:3]];
        num_reactants[eq_number] = 3;
        [[eq_reactants objectAtIndex:eq_number] addObject:@"H₂PtCl₆"];
        reactantCoefficientAnswers[eq_number][0] = 1;
        [[eq_reactants objectAtIndex:eq_number] addObject:@"HCHO"];
        reactantCoefficientAnswers[eq_number][1] = 1;
        [[eq_reactants objectAtIndex:eq_number] addObject:@"OH⁻"];
        reactantCoefficientAnswers[eq_number][2] = 6;
        
        [eq_products addObject:[NSMutableArray arrayWithCapacity:4]];
        num_products[eq_number] = 4;
        [[eq_products objectAtIndex:eq_number] addObject:@"CO₂"];
        productCoefficientAnswers[eq_number][0] = 1;
        [[eq_products objectAtIndex:eq_number] addObject:@"Cl⁻"];
        productCoefficientAnswers[eq_number][1] = 6;
        [[eq_products objectAtIndex:eq_number] addObject:@"Pt"];
        productCoefficientAnswers[eq_number][2] = 1;
        [[eq_products objectAtIndex:eq_number] addObject:@"H₂O"];
        productCoefficientAnswers[eq_number][3] = 5;
        
        eq_number = 16;
        
        [eq_reactants addObject:[NSMutableArray arrayWithCapacity:2]];
        num_reactants[eq_number] = 2;
        [[eq_reactants objectAtIndex:eq_number] addObject:@"CH₄"];
        reactantCoefficientAnswers[eq_number][0] = 1;
        [[eq_reactants objectAtIndex:eq_number] addObject:@"S₂"];
        reactantCoefficientAnswers[eq_number][1] = 2;
        
        [eq_products addObject:[NSMutableArray arrayWithCapacity:2]];
        num_products[eq_number] = 2;
        [[eq_products objectAtIndex:eq_number] addObject:@"CS₂"];
        productCoefficientAnswers[eq_number][0] = 1;
        [[eq_products objectAtIndex:eq_number] addObject:@"H₂S"];
        productCoefficientAnswers[eq_number][1] = 2;
        
        eq_number = 17;
        
        [eq_reactants addObject:[NSMutableArray arrayWithCapacity:1]];
        num_reactants[eq_number] = 1;
        [[eq_reactants objectAtIndex:eq_number] addObject:@"H₂O₂"];
        reactantCoefficientAnswers[eq_number][0] = 2;
        
        [eq_products addObject:[NSMutableArray arrayWithCapacity:2]];
        num_products[eq_number] = 2;
        [[eq_products objectAtIndex:eq_number] addObject:@"H₂O"];
        productCoefficientAnswers[eq_number][0] = 2;
        [[eq_products objectAtIndex:eq_number] addObject:@"O₂"];
        productCoefficientAnswers[eq_number][1] = 1;
        
        eq_number = 18;
        
        [eq_reactants addObject:[NSMutableArray arrayWithCapacity:3]];
        num_reactants[eq_number] = 3;
        [[eq_reactants objectAtIndex:eq_number] addObject:@"S₂O₃⁻²"];
        reactantCoefficientAnswers[eq_number][0] = 1;
        [[eq_reactants objectAtIndex:eq_number] addObject:@"OCl-"];
        reactantCoefficientAnswers[eq_number][1] = 4;
        [[eq_reactants objectAtIndex:eq_number] addObject:@"H₂O"];
        reactantCoefficientAnswers[eq_number][2] = 3;
        
        [eq_products addObject:[NSMutableArray arrayWithCapacity:3]];
        num_products[eq_number] = 3;
        [[eq_products objectAtIndex:eq_number] addObject:@"SO₄⁻²"];
        productCoefficientAnswers[eq_number][0] = 2;
        [[eq_products objectAtIndex:eq_number] addObject:@"Cl⁻"];
        productCoefficientAnswers[eq_number][1] = 4;
        [[eq_products objectAtIndex:eq_number] addObject:@"H₃O⁺"];
        productCoefficientAnswers[eq_number][2] = 2;
        
        eq_number = 19;
        
        [eq_reactants addObject:[NSMutableArray arrayWithCapacity:1]];
        num_reactants[eq_number] = 1;
        [[eq_reactants objectAtIndex:eq_number] addObject:@"NH₂OH"];
        reactantCoefficientAnswers[eq_number][0] = 2;
        
        [eq_products addObject:[NSMutableArray arrayWithCapacity:2]];
        num_products[eq_number] = 2;
        [[eq_products objectAtIndex:eq_number] addObject:@"NH₃"];
        productCoefficientAnswers[eq_number][0] = 2;
        [[eq_products objectAtIndex:eq_number] addObject:@"O₂"];
        productCoefficientAnswers[eq_number][1] = 1;
        
        eq_number = 20;
        
        [eq_reactants addObject:[NSMutableArray arrayWithCapacity:2]];
        num_reactants[eq_number] = 2;
        [[eq_reactants objectAtIndex:eq_number] addObject:@"SiO₂"];
        reactantCoefficientAnswers[eq_number][0] = 1;
        [[eq_reactants objectAtIndex:eq_number] addObject:@"C"];
        reactantCoefficientAnswers[eq_number][1] = 3;
        
        [eq_products addObject:[NSMutableArray arrayWithCapacity:2]];
        num_products[eq_number] = 2;
        [[eq_products objectAtIndex:eq_number] addObject:@"SiC"];
        productCoefficientAnswers[eq_number][0] = 1;
        [[eq_products objectAtIndex:eq_number] addObject:@"CO"];
        productCoefficientAnswers[eq_number][1] = 2;
        
        eq_number = 21;
        
        [eq_reactants addObject:[NSMutableArray arrayWithCapacity:2]];
        num_reactants[eq_number] = 2;
        [[eq_reactants objectAtIndex:eq_number] addObject:@"Al"];
        reactantCoefficientAnswers[eq_number][0] = 4;
        [[eq_reactants objectAtIndex:eq_number] addObject:@"K₂SiF₆"];
        reactantCoefficientAnswers[eq_number][1] = 3;
        
        [eq_products addObject:[NSMutableArray arrayWithCapacity:3]];
        num_products[eq_number] = 3;
        [[eq_products objectAtIndex:eq_number] addObject:@"Si"];
        productCoefficientAnswers[eq_number][0] = 3;
        [[eq_products objectAtIndex:eq_number] addObject:@"KF"];
        productCoefficientAnswers[eq_number][1] = 6;
        [[eq_products objectAtIndex:eq_number] addObject:@"AlF₃"];
        productCoefficientAnswers[eq_number][2] = 4;
        
        eq_number = 22;
        
        [eq_reactants addObject:[NSMutableArray arrayWithCapacity:1]];
        num_reactants[eq_number] = 1;
        [[eq_reactants objectAtIndex:eq_number] addObject:@"TiCl₃"];
        reactantCoefficientAnswers[eq_number][0] = 2;
        
        [eq_products addObject:[NSMutableArray arrayWithCapacity:2]];
        num_products[eq_number] = 2;
        [[eq_products objectAtIndex:eq_number] addObject:@"TiCl₂"];
        productCoefficientAnswers[eq_number][0] = 1;
        [[eq_products objectAtIndex:eq_number] addObject:@"TiCl₄"];
        productCoefficientAnswers[eq_number][1] = 1;
        
        eq_number = 23;
        
        [eq_reactants addObject:[NSMutableArray arrayWithCapacity:1]];
        num_reactants[eq_number] = 1;
        [[eq_reactants objectAtIndex:eq_number] addObject:@"HgO"];
        reactantCoefficientAnswers[eq_number][0] = 2;
        
        [eq_products addObject:[NSMutableArray arrayWithCapacity:2]];
        num_products[eq_number] = 2;
        [[eq_products objectAtIndex:eq_number] addObject:@"Hg"];
        productCoefficientAnswers[eq_number][0] = 2;
        [[eq_products objectAtIndex:eq_number] addObject:@"O₂"];
        productCoefficientAnswers[eq_number][1] = 1;
        
        eq_number = 24;
        
        [eq_reactants addObject:[NSMutableArray arrayWithCapacity:2]];
        num_reactants[eq_number] = 2;
        [[eq_reactants objectAtIndex:eq_number] addObject:@"Bi₂S₃"];
        reactantCoefficientAnswers[eq_number][0] = 1;
        [[eq_reactants objectAtIndex:eq_number] addObject:@"Fe"];
        reactantCoefficientAnswers[eq_number][1] = 3;
        
        [eq_products addObject:[NSMutableArray arrayWithCapacity:2]];
        num_products[eq_number] = 2;
        [[eq_products objectAtIndex:eq_number] addObject:@"Bi"];
        productCoefficientAnswers[eq_number][0] = 2;
        [[eq_products objectAtIndex:eq_number] addObject:@"FeS"];
        productCoefficientAnswers[eq_number][1] = 3;
        
        eq_number = 25;
        
        [eq_reactants addObject:[NSMutableArray arrayWithCapacity:3]];
        num_reactants[eq_number] = 3;
        [[eq_reactants objectAtIndex:eq_number] addObject:@"PH₃"];
        reactantCoefficientAnswers[eq_number][0] = 1;
        [[eq_reactants objectAtIndex:eq_number] addObject:@"I₂"];
        reactantCoefficientAnswers[eq_number][1] = 2;
        [[eq_reactants objectAtIndex:eq_number] addObject:@"H₂O"];
        reactantCoefficientAnswers[eq_number][2] = 2;
        
        [eq_products addObject:[NSMutableArray arrayWithCapacity:2]];
        num_products[eq_number] = 2;
        [[eq_products objectAtIndex:eq_number] addObject:@"H₃PO₂"];
        productCoefficientAnswers[eq_number][0] = 1;
        [[eq_products objectAtIndex:eq_number] addObject:@"HI"];
        productCoefficientAnswers[eq_number][1] = 4;
        
        eq_number = 26;
        
        [eq_reactants addObject:[NSMutableArray arrayWithCapacity:2]];
        num_reactants[eq_number] = 2;
        [[eq_reactants objectAtIndex:eq_number] addObject:@"In"];
        reactantCoefficientAnswers[eq_number][0] = 2;
        [[eq_reactants objectAtIndex:eq_number] addObject:@"HgBr₂"];
        reactantCoefficientAnswers[eq_number][1] = 1;
        
        [eq_products addObject:[NSMutableArray arrayWithCapacity:2]];
        num_products[eq_number] = 2;
        [[eq_products objectAtIndex:eq_number] addObject:@"Hg"];
        productCoefficientAnswers[eq_number][0] = 1;
        [[eq_products objectAtIndex:eq_number] addObject:@"InBr"];
        productCoefficientAnswers[eq_number][1] = 2;
        
        eq_number = 27;
        
        [eq_reactants addObject:[NSMutableArray arrayWithCapacity:2]];
        num_reactants[eq_number] = 2;
        [[eq_reactants objectAtIndex:eq_number] addObject:@"KClO₄"];
        reactantCoefficientAnswers[eq_number][0] = 1;
        [[eq_reactants objectAtIndex:eq_number] addObject:@"C"];
        reactantCoefficientAnswers[eq_number][1] = 2;
        
        [eq_products addObject:[NSMutableArray arrayWithCapacity:2]];
        num_products[eq_number] = 2;
        [[eq_products objectAtIndex:eq_number] addObject:@"KCl"];
        productCoefficientAnswers[eq_number][0] = 1;
        [[eq_products objectAtIndex:eq_number] addObject:@"CO₂"];
        productCoefficientAnswers[eq_number][1] = 2;
        
        eq_number = 28;
        
        [eq_reactants addObject:[NSMutableArray arrayWithCapacity:3]];
        num_reactants[eq_number] = 3;
        [[eq_reactants objectAtIndex:eq_number] addObject:@"PH₃"];
        reactantCoefficientAnswers[eq_number][0] = 1;
        [[eq_reactants objectAtIndex:eq_number] addObject:@"I₂"];
        reactantCoefficientAnswers[eq_number][1] = 2;
        [[eq_reactants objectAtIndex:eq_number] addObject:@"H₂O"];
        reactantCoefficientAnswers[eq_number][2] = 2;
        
        [eq_products addObject:[NSMutableArray arrayWithCapacity:2]];
        num_products[eq_number] = 2;
        [[eq_products objectAtIndex:eq_number] addObject:@"H₃PO₂"];
        productCoefficientAnswers[eq_number][0] = 1;
        [[eq_products objectAtIndex:eq_number] addObject:@"HI"];
        productCoefficientAnswers[eq_number][1] = 4;
        
        
        eq_number = 29;
        
        [eq_reactants addObject:[NSMutableArray arrayWithCapacity:3]];
        num_reactants[eq_number] = 3;
        [[eq_reactants objectAtIndex:eq_number] addObject:@"P₄"];
        reactantCoefficientAnswers[eq_number][0] = 1;
        [[eq_reactants objectAtIndex:eq_number] addObject:@"KOH"];
        reactantCoefficientAnswers[eq_number][1] = 3;
        [[eq_reactants objectAtIndex:eq_number] addObject:@"H₂O"];
        reactantCoefficientAnswers[eq_number][2] = 3;
        
        [eq_products addObject:[NSMutableArray arrayWithCapacity:2]];
        num_products[eq_number] = 2;
        [[eq_products objectAtIndex:eq_number] addObject:@"PH₃"];
        productCoefficientAnswers[eq_number][0] = 1;
        [[eq_products objectAtIndex:eq_number] addObject:@"KH₂PO₂"];
        productCoefficientAnswers[eq_number][1] = 3;
        
        eq_number = 30;
        
        [eq_reactants addObject:[NSMutableArray arrayWithCapacity:2]];
        num_reactants[eq_number] = 2;
        [[eq_reactants objectAtIndex:eq_number] addObject:@"P₄"];
        reactantCoefficientAnswers[eq_number][0] = 1;
        [[eq_reactants objectAtIndex:eq_number] addObject:@"N₂O"];
        reactantCoefficientAnswers[eq_number][1] = 6;
        
        [eq_products addObject:[NSMutableArray arrayWithCapacity:2]];
        num_products[eq_number] = 2;
        [[eq_products objectAtIndex:eq_number] addObject:@"P₄O₆"];
        productCoefficientAnswers[eq_number][0] = 1;
        [[eq_products objectAtIndex:eq_number] addObject:@"N₂"];
        productCoefficientAnswers[eq_number][1] = 6;
        
        eq_number = 31;
        
        [eq_reactants addObject:[NSMutableArray arrayWithCapacity:2]];
        num_reactants[eq_number] = 2;
        [[eq_reactants objectAtIndex:eq_number] addObject:@"Cl₂"];
        reactantCoefficientAnswers[eq_number][0] = 1;
        [[eq_reactants objectAtIndex:eq_number] addObject:@"NaBr"];
        reactantCoefficientAnswers[eq_number][1] = 2;
        
        [eq_products addObject:[NSMutableArray arrayWithCapacity:2]];
        num_products[eq_number] = 2;
        [[eq_products objectAtIndex:eq_number] addObject:@"NaCl"];
        productCoefficientAnswers[eq_number][0] = 2;
        [[eq_products objectAtIndex:eq_number] addObject:@"Br₂"];
        productCoefficientAnswers[eq_number][1] = 1;
        
        eq_number = 32;
        
        [eq_reactants addObject:[NSMutableArray arrayWithCapacity:2]];
        num_reactants[eq_number] = 2;
        [[eq_reactants objectAtIndex:eq_number] addObject:@"HCl"];
        reactantCoefficientAnswers[eq_number][0] = 2;
        [[eq_reactants objectAtIndex:eq_number] addObject:@"CaCO₃"];
        reactantCoefficientAnswers[eq_number][1] = 1;
        
        [eq_products addObject:[NSMutableArray arrayWithCapacity:3]];
        num_products[eq_number] = 3;
        [[eq_products objectAtIndex:eq_number] addObject:@"CaCl₂"];
        productCoefficientAnswers[eq_number][0] = 1;
        [[eq_products objectAtIndex:eq_number] addObject:@"H₂O"];
        productCoefficientAnswers[eq_number][1] = 1;
        [[eq_products objectAtIndex:eq_number] addObject:@"CO₂"];
        productCoefficientAnswers[eq_number][2] = 1;
        
        eq_number = 33;
        
        [eq_reactants addObject:[NSMutableArray arrayWithCapacity:2]];
        num_reactants[eq_number] = 2;
        [[eq_reactants objectAtIndex:eq_number] addObject:@"Na"];
        reactantCoefficientAnswers[eq_number][0] = 4;
        [[eq_reactants objectAtIndex:eq_number] addObject:@"O₂"];
        reactantCoefficientAnswers[eq_number][1] = 1;
        
        [eq_products addObject:[NSMutableArray arrayWithCapacity:1]];
        num_products[eq_number] = 1;
        [[eq_products objectAtIndex:eq_number] addObject:@"Na₂O"];
        productCoefficientAnswers[eq_number][0] = 2;
        
        eq_number = 34;
        
        [eq_reactants addObject:[NSMutableArray arrayWithCapacity:2]];
        num_reactants[eq_number] = 2;
        [[eq_reactants objectAtIndex:eq_number] addObject:@"Si"];
        reactantCoefficientAnswers[eq_number][0] = 1;
        [[eq_reactants objectAtIndex:eq_number] addObject:@"Cl₂"];
        reactantCoefficientAnswers[eq_number][1] = 2;
        
        [eq_products addObject:[NSMutableArray arrayWithCapacity:1]];
        num_products[eq_number] = 1;
        [[eq_products objectAtIndex:eq_number] addObject:@"SiCl₄"];
        productCoefficientAnswers[eq_number][0] = 1;
        
        eq_number = 35;
        
        [eq_reactants addObject:[NSMutableArray arrayWithCapacity:2]];
        num_reactants[eq_number] = 2;
        [[eq_reactants objectAtIndex:eq_number] addObject:@"Mg"];
        reactantCoefficientAnswers[eq_number][0] = 1;
        [[eq_reactants objectAtIndex:eq_number] addObject:@"HCl"];
        reactantCoefficientAnswers[eq_number][1] = 2;
        
        [eq_products addObject:[NSMutableArray arrayWithCapacity:2]];
        num_products[eq_number] = 2;
        [[eq_products objectAtIndex:eq_number] addObject:@"H₂"];
        productCoefficientAnswers[eq_number][0] = 1;
        [[eq_products objectAtIndex:eq_number] addObject:@"MgCl₂"];
        productCoefficientAnswers[eq_number][1] = 1;
        
        eq_number = 36;
        
        [eq_reactants addObject:[NSMutableArray arrayWithCapacity:2]];
        num_reactants[eq_number] = 2;
        [[eq_reactants objectAtIndex:eq_number] addObject:@"Na"];
        reactantCoefficientAnswers[eq_number][0] = 2;
        [[eq_reactants objectAtIndex:eq_number] addObject:@"Br₂"];
        reactantCoefficientAnswers[eq_number][1] = 1;
        
        [eq_products addObject:[NSMutableArray arrayWithCapacity:1]];
        num_products[eq_number] = 1;
        [[eq_products objectAtIndex:eq_number] addObject:@"NaBr"];
        productCoefficientAnswers[eq_number][0] = 2;
        
        eq_number = 37;
        
        [eq_reactants addObject:[NSMutableArray arrayWithCapacity:1]];
        num_reactants[eq_number] = 1;
        [[eq_reactants objectAtIndex:eq_number] addObject:@"KClO₃"];
        reactantCoefficientAnswers[eq_number][0] = 2;
        
        [eq_products addObject:[NSMutableArray arrayWithCapacity:2]];
        num_products[eq_number] = 2;
        [[eq_products objectAtIndex:eq_number] addObject:@"KCl"];
        productCoefficientAnswers[eq_number][0] = 2;
        [[eq_products objectAtIndex:eq_number] addObject:@"O₂"];
        productCoefficientAnswers[eq_number][1] = 3;
        
        eq_number = 38;
        
        [eq_reactants addObject:[NSMutableArray arrayWithCapacity:1]];
        num_reactants[eq_number] = 1;
        [[eq_reactants objectAtIndex:eq_number] addObject:@"P₄O₈"];
        reactantCoefficientAnswers[eq_number][0] = 1;
        
        [eq_products addObject:[NSMutableArray arrayWithCapacity:2]];
        num_products[eq_number] = 2;
        [[eq_products objectAtIndex:eq_number] addObject:@"P"];
        productCoefficientAnswers[eq_number][0] = 4;
        [[eq_products objectAtIndex:eq_number] addObject:@"O₂"];
        productCoefficientAnswers[eq_number][1] = 4;
        
        eq_number = 39;
        
        [eq_reactants addObject:[NSMutableArray arrayWithCapacity:2]];
        num_reactants[eq_number] = 2;
        [[eq_reactants objectAtIndex:eq_number] addObject:@"AlCl₃"];
        reactantCoefficientAnswers[eq_number][0] = 2;
        [[eq_reactants objectAtIndex:eq_number] addObject:@"H₂"];
        reactantCoefficientAnswers[eq_number][1] = 3;
        
        [eq_products addObject:[NSMutableArray arrayWithCapacity:2]];
        num_products[eq_number] = 2;
        [[eq_products objectAtIndex:eq_number] addObject:@"Al"];
        productCoefficientAnswers[eq_number][0] = 2;
        [[eq_products objectAtIndex:eq_number] addObject:@"HCl"];
        productCoefficientAnswers[eq_number][1] = 6;
        
        eq_number = 40;
        
        [eq_reactants addObject:[NSMutableArray arrayWithCapacity:2]];
        num_reactants[eq_number] = 2;
        [[eq_reactants objectAtIndex:eq_number] addObject:@"ZnS"];
        reactantCoefficientAnswers[eq_number][0] = 2;
        [[eq_reactants objectAtIndex:eq_number] addObject:@"O₂"];
        reactantCoefficientAnswers[eq_number][1] = 3;
        
        [eq_products addObject:[NSMutableArray arrayWithCapacity:2]];
        num_products[eq_number] = 2;
        [[eq_products objectAtIndex:eq_number] addObject:@"ZnO"];
        productCoefficientAnswers[eq_number][0] = 2;
        [[eq_products objectAtIndex:eq_number] addObject:@"SO₂"];
        productCoefficientAnswers[eq_number][1] = 2;
        
        eq_number = 41;
        
        [eq_reactants addObject:[NSMutableArray arrayWithCapacity:2]];
        num_reactants[eq_number] = 2;
        [[eq_reactants objectAtIndex:eq_number] addObject:@"ZnS"];
        reactantCoefficientAnswers[eq_number][0] = 2;
        [[eq_reactants objectAtIndex:eq_number] addObject:@"O₂"];
        reactantCoefficientAnswers[eq_number][1] = 3;
        
        [eq_products addObject:[NSMutableArray arrayWithCapacity:2]];
        num_products[eq_number] = 2;
        [[eq_products objectAtIndex:eq_number] addObject:@"ZnO"];
        productCoefficientAnswers[eq_number][0] = 2;
        [[eq_products objectAtIndex:eq_number] addObject:@"SO₂"];
        productCoefficientAnswers[eq_number][1] = 2;
        
        eq_number = 42;
        
        [eq_reactants addObject:[NSMutableArray arrayWithCapacity:2]];
        num_reactants[eq_number] = 2;
        [[eq_reactants objectAtIndex:eq_number] addObject:@"C₆H₅F"];
        reactantCoefficientAnswers[eq_number][0] = 1;
        [[eq_reactants objectAtIndex:eq_number] addObject:@"O₂"];
        reactantCoefficientAnswers[eq_number][1] = 4;
        
        [eq_products addObject:[NSMutableArray arrayWithCapacity:3]];
        num_products[eq_number] = 3;
        [[eq_products objectAtIndex:eq_number] addObject:@"CO"];
        productCoefficientAnswers[eq_number][0] = 6;
        [[eq_products objectAtIndex:eq_number] addObject:@"H₂O"];
        productCoefficientAnswers[eq_number][1] = 2;
        [[eq_products objectAtIndex:eq_number] addObject:@"HF"];
        productCoefficientAnswers[eq_number][2] = 1;
        
        eq_number = 43;
        
        [eq_reactants addObject:[NSMutableArray arrayWithCapacity:2]];
        num_reactants[eq_number] = 2;
        [[eq_reactants objectAtIndex:eq_number] addObject:@"HCl"];
        reactantCoefficientAnswers[eq_number][0] = 2;
        [[eq_reactants objectAtIndex:eq_number] addObject:@"K₂CO₃"];
        reactantCoefficientAnswers[eq_number][1] = 1;
        
        [eq_products addObject:[NSMutableArray arrayWithCapacity:3]];
        num_products[eq_number] = 3;
        [[eq_products objectAtIndex:eq_number] addObject:@"KCl"];
        productCoefficientAnswers[eq_number][0] = 2;
        [[eq_products objectAtIndex:eq_number] addObject:@"H₂O"];
        productCoefficientAnswers[eq_number][1] = 1;
        [[eq_products objectAtIndex:eq_number] addObject:@"CO₂"];
        productCoefficientAnswers[eq_number][2] = 1;
        
        eq_number = 44;
        
        [eq_reactants addObject:[NSMutableArray arrayWithCapacity:2]];
        num_reactants[eq_number] = 2;
        [[eq_reactants objectAtIndex:eq_number] addObject:@"MoO₃"];
        reactantCoefficientAnswers[eq_number][0] = 2;
        [[eq_reactants objectAtIndex:eq_number] addObject:@"C"];
        reactantCoefficientAnswers[eq_number][1] = 3;
        
        [eq_products addObject:[NSMutableArray arrayWithCapacity:2]];
        num_products[eq_number] = 2;
        [[eq_products objectAtIndex:eq_number] addObject:@"Mo"];
        productCoefficientAnswers[eq_number][0] = 2;
        [[eq_products objectAtIndex:eq_number] addObject:@"CO₂"];
        productCoefficientAnswers[eq_number][1] = 3;
        
        eq_number = 45;
        
        [eq_reactants addObject:[NSMutableArray arrayWithCapacity:2]];
        num_reactants[eq_number] = 2;
        [[eq_reactants objectAtIndex:eq_number] addObject:@"C₂H₃OCl"];
        reactantCoefficientAnswers[eq_number][0] = 1;
        [[eq_reactants objectAtIndex:eq_number] addObject:@"O₂"];
        reactantCoefficientAnswers[eq_number][1] = 1;
        
        [eq_products addObject:[NSMutableArray arrayWithCapacity:3]];
        num_products[eq_number] = 3;
        [[eq_products objectAtIndex:eq_number] addObject:@"CO"];
        productCoefficientAnswers[eq_number][0] = 2;
        [[eq_products objectAtIndex:eq_number] addObject:@"H₂O"];
        productCoefficientAnswers[eq_number][1] = 1;
        [[eq_products objectAtIndex:eq_number] addObject:@"HCl"];
        productCoefficientAnswers[eq_number][2] = 1;
        
        eq_number = 46;
        
        [eq_reactants addObject:[NSMutableArray arrayWithCapacity:2]];
        num_reactants[eq_number] = 2;
        [[eq_reactants objectAtIndex:eq_number] addObject:@"Na₂SO₄"];
        reactantCoefficientAnswers[eq_number][0] = 1;
        [[eq_reactants objectAtIndex:eq_number] addObject:@"C"];
        reactantCoefficientAnswers[eq_number][1] = 2;
        
        [eq_products addObject:[NSMutableArray arrayWithCapacity:2]];
        num_products[eq_number] = 2;
        [[eq_products objectAtIndex:eq_number] addObject:@"Na₂S"];
        productCoefficientAnswers[eq_number][0] = 1;
        [[eq_products objectAtIndex:eq_number] addObject:@"CO₂"];
        productCoefficientAnswers[eq_number][1] = 2;
        
        eq_number = 47;
        
        [eq_reactants addObject:[NSMutableArray arrayWithCapacity:2]];
        num_reactants[eq_number] = 2;
        [[eq_reactants objectAtIndex:eq_number] addObject:@"Fe"];
        reactantCoefficientAnswers[eq_number][0] = 4;
        [[eq_reactants objectAtIndex:eq_number] addObject:@"O₂"];
        reactantCoefficientAnswers[eq_number][1] = 3;
        
        [eq_products addObject:[NSMutableArray arrayWithCapacity:1]];
        num_products[eq_number] = 1;
        [[eq_products objectAtIndex:eq_number] addObject:@"Fe₂O₃"];
        productCoefficientAnswers[eq_number][0] = 2;
        
        eq_number = 48;
        
        [eq_reactants addObject:[NSMutableArray arrayWithCapacity:2]];
        num_reactants[eq_number] = 2;
        [[eq_reactants objectAtIndex:eq_number] addObject:@"Mg"];
        reactantCoefficientAnswers[eq_number][0] = 1;
        [[eq_reactants objectAtIndex:eq_number] addObject:@"AgNO₃"];
        reactantCoefficientAnswers[eq_number][1] = 2;
        
        [eq_products addObject:[NSMutableArray arrayWithCapacity:2]];
        num_products[eq_number] = 2;
        [[eq_products objectAtIndex:eq_number] addObject:@"Mg(NO₃)₂"];
        productCoefficientAnswers[eq_number][0] = 1;
        [[eq_products objectAtIndex:eq_number] addObject:@"Ag"];
        productCoefficientAnswers[eq_number][1] = 2;
        
        eq_number = 49;
        
        [eq_reactants addObject:[NSMutableArray arrayWithCapacity:2]];
        num_reactants[eq_number] = 2;
        [[eq_reactants objectAtIndex:eq_number] addObject:@"Ca"];
        reactantCoefficientAnswers[eq_number][0] = 3;
        [[eq_reactants objectAtIndex:eq_number] addObject:@"LaFl₃"];
        reactantCoefficientAnswers[eq_number][1] = 2;
        
        [eq_products addObject:[NSMutableArray arrayWithCapacity:2]];
        num_products[eq_number] = 2;
        [[eq_products objectAtIndex:eq_number] addObject:@"La"];
        productCoefficientAnswers[eq_number][0] = 2;
        [[eq_products objectAtIndex:eq_number] addObject:@"CaF₂"];
        productCoefficientAnswers[eq_number][1] = 3;
    }
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [self setup_format];
    [self load_equations];
    [self clear_equation];
    [self gen_equation];
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [self setSlider:nil];
    [self setVerification:nil];
    [self setScore:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ((interfaceOrientation == UIInterfaceOrientationLandscapeLeft) || (interfaceOrientation == UIInterfaceOrientationLandscapeRight)) {
        return NO;
    }
    else{
        return YES;
    }
}

-(IBAction)tap_continue:(id)sender{
    UIButton *button = (UIButton *) sender;
    button.frame = CGRectMake(-500, -500, 50, 50);
    [self clear_equation];
    [self gen_equation];
}

-(void)update_score {
    NSString *theScore = [NSString stringWithFormat:@"%d / %d", correct, completed];
    score.text = theScore;
    UIButton *myButton = [UIButton buttonWithType:UIButtonTypeCustom];
    myButton.frame = CGRectMake(0, 0, SCREEN_WIDTH + 20, SCREEN_HEIGHT + 50);
    [myButton setTitle:@"Tap to Continue..." forState:UIControlStateNormal];
    [myButton addTarget:self action:@selector(tap_continue:) forControlEvents:UIControlEventTouchUpInside];
    if (isPad()){
        myButton.titleLabel.font = [UIFont fontWithName:@"Arial" size: 25.0];
    }
    else {
        myButton.titleLabel.font = [UIFont fontWithName:@"Arial" size: 20.0];
    }
    myButton.titleLabel.textColor = [UIColor yellowColor];
    myButton.backgroundColor = [UIColor clearColor];
    [self.view addSubview:myButton];
}

- (IBAction)submit:(id)sender {
    BOOL isCorrect = [self check_equation];
    if (isCorrect) {
        //code if correct
        verification.textColor = [UIColor greenColor];
        verification.text = @"Correct!";
        correct++;
        completed++;
        [hit_player play];
        [self update_score];
    }
    else {
        //code if incorrect
        verification.textColor = [UIColor redColor];
        verification.text = @"Wrong!";
        if (!first_try){
            completed++;
            [self update_score];
            [self clear_equation];
            for (int i = 0; i < 2; i++) [self generate_completed_side:i:equation_num]; //reactants and products
            verification.textColor = [UIColor redColor];
            [wrong_player play];
            verification.text = @"Wrong!";
        }
        else {
            first_try = NO;
            [wrong_player play];
        }
    }
}

@end