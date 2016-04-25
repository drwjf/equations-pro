package com.neelsomani.Equations;

import java.util.Random;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.res.Resources;
import android.graphics.Color;
import android.graphics.Typeface;
import android.os.Bundle;
import android.util.DisplayMetrics;
import android.util.TypedValue;
import android.view.View;
import android.widget.Button;
import android.widget.RelativeLayout;
import android.widget.SeekBar;
import android.widget.SeekBar.OnSeekBarChangeListener;
import android.widget.TextView;

public class EquationsActivity extends Activity implements OnSeekBarChangeListener {
    /** Called when the activity is first created. */
	
	int difficulty = 0;
	int equationNumber = 0;
	
	int correct;
	int completed;
	
	int selected; // 0 - 2 for react, 3 - 5 for prod
	
	Button productButtons[];
	Button reactantButtons[];
	TextView plus[];
	SeekBar mSeekBar;
	
	boolean isTracking = false;
	boolean isFirstTry;
	
	boolean loaded = false;
	
	String[][] reactantsQuestion;
	String[][] productsQuestion;
	
	int[][] reactantAnswers;
	int[][] productAnswers;
	
	int[] currentReactantCoefficients;
	int[] currentProductCoefficients;
	
	int[] easyArray;
	int[] hardArray;
	
	SoundManager mSoundManager;
	
	int last_line = 0; // for placing +'s

	private static final int REACTANT = 1;
	private static final int PRODUCT = -1;
	private static final int REACTANT_SIDE = 0;
	private static final int PRODUCT_SIDE = 1;
	
	private static final int EASY = 0;
	private static final int HARD = 1;

	private static final int BUTTON_WIDTH = 100;
	private int BUTTON_OFFSET, BUTTON_HEIGHT, ARROW_HEIGHT;

	private static final int BUZZ = 1;
	private static final int CORRECT = 2;
	private static final int POP = 3;
	
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.main);
        BUTTON_OFFSET = (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, 50, getResources().getDisplayMetrics());
        BUTTON_HEIGHT = (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, 60, getResources().getDisplayMetrics());
        ARROW_HEIGHT = (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, 70, getResources().getDisplayMetrics());
    }
    
    public void homeToSelect(View view){
    	setContentView(R.layout.select);
    }
    
    public void onProgressChanged(SeekBar seekBar, int progress, boolean fromTouch) {
    	if (isTracking) {
    		if (selected < 3){
	    		String current_text = reactantButtons[selected].getText().toString();
	    		int current_coefficient = currentReactantCoefficients[selected];
	    		
	    		currentReactantCoefficients[selected] = progress + 1;
	    		
	    		if (currentReactantCoefficients[selected] != 1){
	    			if (current_coefficient == 1){
	    				reactantButtons[selected].setText(currentReactantCoefficients[selected] + current_text);
	    			}
	    			else {
	    				current_text = current_text.substring(1);
	    				reactantButtons[selected].setText(currentReactantCoefficients[selected] + current_text);
	    			}
	    		}
	    		else {
	    			if (current_coefficient != 1) reactantButtons[selected].setText(current_text.substring(1));
	    		}
	    	}
	    	else {
	    		int actual_selected = selected - 3;
	    		String current_text = productButtons[actual_selected].getText().toString();
	    		int current_coefficient = currentProductCoefficients[actual_selected];
	    		
	    		currentProductCoefficients[actual_selected] = progress + 1;
	
	    		if (currentProductCoefficients[actual_selected] != 1){
	    			if (current_coefficient == 1){
	    				productButtons[actual_selected].setText(currentProductCoefficients[actual_selected] + current_text);
	    			}
	    			else {
	    				current_text = current_text.substring(1);
	    				productButtons[actual_selected].setText(currentProductCoefficients[actual_selected] + current_text);
	    			}
	    		}
	    		else {
	    			if (current_coefficient != 1) productButtons[actual_selected].setText(current_text.substring(1));
	    		}
	    	}
    	}
    }
    
    public void about(View view){
    	// about button on front page
    	
    	AlertDialog alertDialog = new AlertDialog.Builder(EquationsActivity.this).create();
    	alertDialog.setTitle("Feedback?");
    	alertDialog.setMessage("Equations was made by Neel Somani from Gale Ranch Middle School. Any suggestions, questions, or complaints can be emailed to webmaster@apptic.me.");
    	alertDialog.setButton("Got it!", new DialogInterface.OnClickListener(){
    		public void onClick(DialogInterface dialog, int which) {
    			// empty function, just close dialog
    		}
    	});
    	alertDialog.show();
    }
    
    public void skip(View view){
    	//skips equation if too difficult
    	dismiss();
    	mSoundManager.playSound(BUZZ);
		tap_to_continue();
		completed++;
		update_score();
		show_correct_answer();
    }
    
    public boolean isCorrect(){
    	boolean isCorrect = true;
    	for (int i = 0; i < 3; i++){
    		if (isCorrect){
    			if (reactantAnswers[equationNumber][i] != currentReactantCoefficients[i]){
    				isCorrect = false;
    			}
    			if (productAnswers[equationNumber][i] != currentProductCoefficients[i]){
    				isCorrect = false;
    			}
    		}
    	}
    	return isCorrect;
    }
    
    public int setCorrectPosition(Button button, int num_compounds, int number, int side) {
    	button.setVisibility(View.VISIBLE);
    	DisplayMetrics displaymetrics = new DisplayMetrics();
        getWindowManager().getDefaultDisplay().getMetrics(displaymetrics);
        int screen_height = displaymetrics.heightPixels;
        int screen_width = displaymetrics.widthPixels;
		
        button.setWidth(BUTTON_WIDTH);
        
        Resources r = getResources();
        float w = TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, 75, r.getDisplayMetrics());
        float h = BUTTON_HEIGHT;
        
		RelativeLayout.LayoutParams blp = new RelativeLayout.LayoutParams((int) w, (int) h); 
		
		int lm = screen_width / (num_compounds + 1); // get line of division
		lm *= number + 1;
		lm -= w / 2; //adjust for size of button
		
		blp.leftMargin = lm;
		
		int tm = screen_height / 2;
		tm -= h / 2;
		tm -= BUTTON_OFFSET * side;
		
		blp.topMargin = tm;
		
		
		// set title of button
		
		Typeface tf = Typeface.createFromAsset(getAssets(), "fonts/Arial Bold.ttf");
		
		String compound;
		
		if (side == REACTANT){
			compound = reactantsQuestion[equationNumber][number];
			button.setTypeface(tf);
			if (reactantAnswers[equationNumber][number] == 1){
				button.setText(compound);
			}
			else {
				button.setText(reactantAnswers[equationNumber][number] + compound);
			}
		}
		else{
			compound = productsQuestion[equationNumber][number];
			button.setTypeface(tf);
			if (productAnswers[equationNumber][number] == 1){
				button.setText(compound);
			}
			else {
				button.setText(productAnswers[equationNumber][number] + compound);
			}
		}
		
		button.setLayoutParams(blp);
		
		return lm + 50;
    }
    
    public void genCorrectSide(int side, int eq_num){
    	// gen each side of eq
    	
    	if (side == REACTANT_SIDE){
    		int num_compounds = reactantsQuestion[equationNumber].length;
    		for (int i = 0; i < num_compounds; i++) {
    			int new_line = setCorrectPosition(reactantButtons[i], num_compounds, i, REACTANT);
    			if (i != 0) {
    				DisplayMetrics displaymetrics = new DisplayMetrics();
    		        getWindowManager().getDefaultDisplay().getMetrics(displaymetrics);
    		        int screen_height = displaymetrics.heightPixels;
    				int lm = (new_line + last_line) / 2;
    				int tm = screen_height / 2;
    				tm -= - BUTTON_HEIGHT / 2 + (BUTTON_OFFSET) +  + ARROW_HEIGHT / 2;
    				
    				RelativeLayout.LayoutParams blp = 
    						new RelativeLayout.LayoutParams(RelativeLayout.LayoutParams.WRAP_CONTENT, 
    						RelativeLayout.LayoutParams.WRAP_CONTENT);
    				blp.topMargin = tm;
    				blp.leftMargin = lm;
    				plus[i - 1].setLayoutParams(blp);
    				plus[i - 1].setVisibility(View.VISIBLE);
    			}
				last_line = new_line;
    		}
    	} // reactants
    	
    	if (side == PRODUCT_SIDE){
    		int num_compounds = productsQuestion[equationNumber].length;
    		for (int i = 0; i < num_compounds; i++) {
    			int new_line = setCorrectPosition(productButtons[i], num_compounds, i, PRODUCT);
    			
    			if (i != 0) {
    				DisplayMetrics displaymetrics = new DisplayMetrics();
    		        getWindowManager().getDefaultDisplay().getMetrics(displaymetrics);
    		        int screen_height = displaymetrics.heightPixels;
    				int lm = (new_line + last_line) / 2;
    				int tm = screen_height / 2;
    				tm += BUTTON_HEIGHT / 2 + (BUTTON_OFFSET) + - ARROW_HEIGHT / 2;
    				
    				RelativeLayout.LayoutParams blp = 
    						new RelativeLayout.LayoutParams(RelativeLayout.LayoutParams.WRAP_CONTENT, 
    						RelativeLayout.LayoutParams.WRAP_CONTENT);
    				blp.topMargin = tm;
    				blp.leftMargin = lm;
    				plus[i + 1].setLayoutParams(blp);
    				plus[i + 1].setVisibility(View.VISIBLE);
    			}
    			
    			last_line = new_line;
    		}
    	} // products
    }
    
    public void show_correct_answer(){
    	// reset coefs and hide buttons
    	for (int i = 0; i < 3; i++) {
    		reactantButtons[i].setVisibility(View.INVISIBLE);
    		productButtons[i].setVisibility(View.INVISIBLE);
    		currentReactantCoefficients[i] = 1;
    		currentProductCoefficients[i] = 1;
    		plus[i].setVisibility(View.INVISIBLE);
    	}
    	plus[3].setVisibility(View.INVISIBLE); //because 3 just isn't enough
    	update_score();
    	mSeekBar.setProgress(0);
    	
    	// custom reset for getting wrong twice
    	
    	for (int i = 0; i < 2; i++) genCorrectSide(i, equationNumber);
    }
    
    public void submit(View view){
    	//verify if correct
    	
    	if (isCorrect()){
    		correct();
    		tap_to_continue();
    		completed++;
    		correct++;
    		update_score();
    	}
    	else {
    		wrong();
    		if (isFirstTry) isFirstTry = false;
    		else {
    			tap_to_continue();
    			completed++;
    			update_score();
    			show_correct_answer();
    		}
    	}
    }
    
    public void reset(View view){
    	resetEquation();
    	mSoundManager.playSound(POP);
    	for (int i = 0; i < 2; i++) genSide(i, equationNumber);
    }
    
    public void gameToSelect(View view){
    	setContentView(R.layout.select);
    }
    
    public boolean loadEquations(){
    	//populate array with equations, + difficult and easy arrays
    	
    	reactantAnswers = new int[40][3];
    	productAnswers = new int[40][3];
    	
    	easyArray = new int[]{
    			4,
    			8,
    			10,
    			11,
    			13,
    			14,
    			15,
    			16,
    			19,
    			20,
    			23,
    			24,
    			25,
    			26,
    			27,
    			28,
    			29,
    			32,
    			36,
    			39
    	};
    	
    	hardArray = new int[]{
    			0,
    			1,
    			2,
    			3,
    			5,
    			6,
    			7,
    			9,
    			12,
    			17,
    			18,
    			21,
    			22,
    			30,
    			31,
    			33,
    			34,
    			35,
    			37,
    			38
    	};
    	
    	for (int i = 0; i < reactantAnswers.length; i++){
    		for (int j = 0; j < 3; j++){
    			reactantAnswers[i][j] = 1;
    			productAnswers[i][j] = 1;
    		}
    	}
    	
    	reactantsQuestion = new String[40][];
    	productsQuestion = new String[40][];
    	
    	int equation_adding = 0;
    	reactantsQuestion[equation_adding] = new String[2];
    	reactantsQuestion[equation_adding][0] = "Ag";
    	reactantAnswers[equation_adding][0] = 2;
    	reactantsQuestion[equation_adding][1] = "H₂SO₄";
    	reactantAnswers[equation_adding][1] = 2;

    	productsQuestion[equation_adding] = new String[3];
    	productsQuestion[equation_adding][0] = "Ag₂SO₄";
    	productsQuestion[equation_adding][1] = "SO₂";
    	productsQuestion[equation_adding][2] = "H₂0";
    	productAnswers[equation_adding][2] = 2;

    	
    	equation_adding = 1;
    	reactantsQuestion[equation_adding] = new String[2];
    	reactantsQuestion[equation_adding][0] = "Cu";
    	reactantAnswers[equation_adding][0] = 3;
    	reactantsQuestion[equation_adding][1] = "HNO₃";
    	reactantAnswers[equation_adding][1] = 8;

    	productsQuestion[equation_adding] = new String[3];
    	productsQuestion[equation_adding][0] = "Cu(NO₃)₂";
    	productAnswers[equation_adding][0] = 3;
    	productsQuestion[equation_adding][1] = "NO";
    	productAnswers[equation_adding][1] = 2;
    	productsQuestion[equation_adding][2] = "H₂0";
    	productAnswers[equation_adding][2] = 4;

    	
    	equation_adding = 2;
    	reactantsQuestion[equation_adding] = new String[2];
    	reactantsQuestion[equation_adding][0] = "Bi";
    	reactantsQuestion[equation_adding][1] = "HNO₃";
    	reactantAnswers[equation_adding][1] = 4;

    	productsQuestion[equation_adding] = new String[3];
    	productsQuestion[equation_adding][0] = "Bi(NO₃)₃";
    	productsQuestion[equation_adding][1] = "H₂O";
    	productAnswers[equation_adding][1] = 2;
    	productsQuestion[equation_adding][2] = "NO";

    	
    	equation_adding = 3;
    	reactantsQuestion[equation_adding] = new String[2];
    	productsQuestion[equation_adding] = new String[3];

    	reactantsQuestion[equation_adding][0] = "Sn";
    	reactantAnswers[equation_adding][0] = 1;
    	reactantsQuestion[equation_adding][1] = "HNO₃";
    	reactantAnswers[equation_adding][1] = 4;

    	productsQuestion[equation_adding][0] = "SnO₂";
    	productAnswers[equation_adding][0] = 1;
    	productsQuestion[equation_adding][1] = "NO₂";
    	productAnswers[equation_adding][1] = 4;
    	productsQuestion[equation_adding][2] = "H₂O";
    	productAnswers[equation_adding][2] = 2;
    	
    	equation_adding = 4;
    	reactantsQuestion[equation_adding] = new String[2];
    	productsQuestion[equation_adding] = new String[3];

    	reactantsQuestion[equation_adding][0] = "PbO₂";
    	reactantAnswers[equation_adding][0] = 1;
    	reactantsQuestion[equation_adding][1] = "HCl";
    	reactantAnswers[equation_adding][1] = 4;

    	productsQuestion[equation_adding][0] = "PbCl₂";
    	productAnswers[equation_adding][0] = 1;
    	productsQuestion[equation_adding][1] = "Cl₂";
    	productAnswers[equation_adding][1] = 1;
    	productsQuestion[equation_adding][2] = "H₂O";
    	productAnswers[equation_adding][2] = 2;
    	
    	equation_adding = 5;
    	reactantsQuestion[equation_adding] = new String[3];
    	productsQuestion[equation_adding] = new String[2];

    	reactantsQuestion[equation_adding][0] = "P";
    	reactantAnswers[equation_adding][0] = 3;
    	reactantsQuestion[equation_adding][1] = "HNO₃";
    	reactantAnswers[equation_adding][1] = 5;
    	reactantsQuestion[equation_adding][2] = "H₂O";
    	reactantAnswers[equation_adding][2] = 2;

    	productsQuestion[equation_adding][0] = "H₃PO₄";
    	productAnswers[equation_adding][0] = 3;
    	productsQuestion[equation_adding][1] = "NO";
    	productAnswers[equation_adding][1] = 5;
    	
    	equation_adding = 6;
    	reactantsQuestion[equation_adding] = new String[2];
    	productsQuestion[equation_adding] = new String[3];

    	reactantsQuestion[equation_adding][0] = "CeO₂";
    	reactantAnswers[equation_adding][0] = 2;
    	reactantsQuestion[equation_adding][1] = "HCl";
    	reactantAnswers[equation_adding][1] = 8;

    	productsQuestion[equation_adding][0] = "CeCl₃";
    	productAnswers[equation_adding][0] = 2;
    	productsQuestion[equation_adding][1] = "Cl₂";
    	productAnswers[equation_adding][1] = 1;
    	productsQuestion[equation_adding][2] = "H₂O";
    	productAnswers[equation_adding][2] = 4;
    	
    	equation_adding = 7;
    	reactantsQuestion[equation_adding] = new String[2];
    	productsQuestion[equation_adding] = new String[3];

    	reactantsQuestion[equation_adding][0] = "Hg";
    	reactantAnswers[equation_adding][0] = 3;
    	reactantsQuestion[equation_adding][1] = "HNO₃";
    	reactantAnswers[equation_adding][1] = 8;

    	productsQuestion[equation_adding][0] = "Hg(NO₃)₂";
    	productAnswers[equation_adding][0] = 3;
    	productsQuestion[equation_adding][1] = "NO";
    	productAnswers[equation_adding][1] = 2;
    	productsQuestion[equation_adding][2] = "H₂O";
    	productAnswers[equation_adding][2] = 4;
    	
    	equation_adding = 8;
    	reactantsQuestion[equation_adding] = new String[2];
    	productsQuestion[equation_adding] = new String[3];

    	reactantsQuestion[equation_adding][0] = "HgCl₂";
    	reactantAnswers[equation_adding][0] = 2;
    	reactantsQuestion[equation_adding][1] = "HCOOH";
    	reactantAnswers[equation_adding][1] = 1;

    	productsQuestion[equation_adding][0] = "Hg₂Cl₂";
    	productAnswers[equation_adding][0] = 1;
    	productsQuestion[equation_adding][1] = "HCl";
    	productAnswers[equation_adding][1] = 2;
    	productsQuestion[equation_adding][2] = "CO₂";
    	productAnswers[equation_adding][2] = 1;
    	
    	equation_adding = 9;
    	reactantsQuestion[equation_adding] = new String[2];
    	productsQuestion[equation_adding] = new String[3];

    	reactantsQuestion[equation_adding][0] = "CO(NH₂)₂";
    	reactantAnswers[equation_adding][0] = 1;
    	reactantsQuestion[equation_adding][1] = "HNO₂";
    	reactantAnswers[equation_adding][1] = 2;

    	productsQuestion[equation_adding][0] = "CO₂";
    	productAnswers[equation_adding][0] = 1;
    	productsQuestion[equation_adding][1] = "N₂";
    	productAnswers[equation_adding][1] = 2;
    	productsQuestion[equation_adding][2] = "H₂O";
    	productAnswers[equation_adding][2] = 3;
    	
    	equation_adding = 10;
    	reactantsQuestion[equation_adding] = new String[2];
    	productsQuestion[equation_adding] = new String[2];

    	reactantsQuestion[equation_adding][0] = "CH₄";
    	reactantAnswers[equation_adding][0] = 1;
    	reactantsQuestion[equation_adding][1] = "S₂";
    	reactantAnswers[equation_adding][1] = 2;

    	productsQuestion[equation_adding][0] = "CS₂";
    	productAnswers[equation_adding][0] = 1;
    	productsQuestion[equation_adding][1] = "H₂S";
    	productAnswers[equation_adding][1] = 2;
    	
    	equation_adding = 11;
    	reactantsQuestion[equation_adding] = new String[1];
    	productsQuestion[equation_adding] = new String[2];

    	reactantsQuestion[equation_adding][0] = "H₂O₂";
    	reactantAnswers[equation_adding][0] = 2;

    	productsQuestion[equation_adding][0] = "H₂O";
    	productAnswers[equation_adding][0] = 2;
    	productsQuestion[equation_adding][1] = "O₂";
    	productAnswers[equation_adding][1] = 1;
    	
    	equation_adding = 12;
    	reactantsQuestion[equation_adding] = new String[3];
    	productsQuestion[equation_adding] = new String[3];

    	reactantsQuestion[equation_adding][0] = "S₂O₃-²";
    	reactantAnswers[equation_adding][0] = 1;
    	reactantsQuestion[equation_adding][1] = "OCl-";
    	reactantAnswers[equation_adding][1] = 4;
    	reactantsQuestion[equation_adding][2] = "H₂O";
    	reactantAnswers[equation_adding][2] = 3;

    	productsQuestion[equation_adding][0] = "SO₄-²";
    	productAnswers[equation_adding][0] = 2;
    	productsQuestion[equation_adding][1] = "Cl-";
    	productAnswers[equation_adding][1] = 4;
    	productsQuestion[equation_adding][2] = "H₃O+";
    	productAnswers[equation_adding][2] = 2;
    	
    	equation_adding = 13;
    	reactantsQuestion[equation_adding] = new String[1];
    	productsQuestion[equation_adding] = new String[2];

    	reactantsQuestion[equation_adding][0] = "NH₂OH";
    	reactantAnswers[equation_adding][0] = 2;

    	productsQuestion[equation_adding][0] = "NH₃";
    	productAnswers[equation_adding][0] = 2;
    	productsQuestion[equation_adding][1] = "O₂";
    	productAnswers[equation_adding][1] = 1;
    	
    	equation_adding = 14;
    	reactantsQuestion[equation_adding] = new String[2];
    	productsQuestion[equation_adding] = new String[2];

    	reactantsQuestion[equation_adding][0] = "SiO₂";
    	reactantAnswers[equation_adding][0] = 1;
    	reactantsQuestion[equation_adding][1] = "C";
    	reactantAnswers[equation_adding][1] = 3;

    	productsQuestion[equation_adding][0] = "SiC";
    	productAnswers[equation_adding][0] = 1;
    	productsQuestion[equation_adding][1] = "CO";
    	productAnswers[equation_adding][1] = 2;
    	
    	equation_adding = 15;
    	reactantsQuestion[equation_adding] = new String[1];
    	productsQuestion[equation_adding] = new String[2];

    	reactantsQuestion[equation_adding][0] = "TiCl₃";
    	reactantAnswers[equation_adding][0] = 2;

    	productsQuestion[equation_adding][0] = "TiCl₂";
    	productAnswers[equation_adding][0] = 1;
    	productsQuestion[equation_adding][1] = "TiCl₄";
    	productAnswers[equation_adding][1] = 1;
    	
    	equation_adding = 16;
    	reactantsQuestion[equation_adding] = new String[1];
    	productsQuestion[equation_adding] = new String[2];

    	reactantsQuestion[equation_adding][0] = "HgO";
    	reactantAnswers[equation_adding][0] = 2;

    	productsQuestion[equation_adding][0] = "Hg";
    	productAnswers[equation_adding][0] = 2;
    	productsQuestion[equation_adding][1] = "O₂";
    	productAnswers[equation_adding][1] = 1;
    	
    	equation_adding = 17;
    	reactantsQuestion[equation_adding] = new String[2];
    	productsQuestion[equation_adding] = new String[2];

    	reactantsQuestion[equation_adding][0] = "Bi₂S₃";
    	reactantAnswers[equation_adding][0] = 1;
    	reactantsQuestion[equation_adding][1] = "Fe";
    	reactantAnswers[equation_adding][1] = 3;

    	productsQuestion[equation_adding][0] = "Bi";
    	productAnswers[equation_adding][0] = 2;
    	productsQuestion[equation_adding][1] = "FeS";
    	productAnswers[equation_adding][1] = 3;
    	
    	equation_adding = 18;
    	reactantsQuestion[equation_adding] = new String[3];
    	productsQuestion[equation_adding] = new String[2];

    	reactantsQuestion[equation_adding][0] = "PH₃";
    	reactantAnswers[equation_adding][0] = 1;
    	reactantsQuestion[equation_adding][1] = "I₂";
    	reactantAnswers[equation_adding][1] = 2;
    	reactantsQuestion[equation_adding][2] = "H₂O";
    	reactantAnswers[equation_adding][2] = 2;

    	productsQuestion[equation_adding][0] = "H₃PO₂";
    	productAnswers[equation_adding][0] = 1;
    	productsQuestion[equation_adding][1] = "HI";
    	productAnswers[equation_adding][1] = 4;
    	
    	equation_adding = 19;
    	reactantsQuestion[equation_adding] = new String[2];
    	productsQuestion[equation_adding] = new String[2];

    	reactantsQuestion[equation_adding][0] = "In";
    	reactantAnswers[equation_adding][0] = 2;
    	reactantsQuestion[equation_adding][1] = "HgBr₂";
    	reactantAnswers[equation_adding][1] = 1;

    	productsQuestion[equation_adding][0] = "Hg";
    	productAnswers[equation_adding][0] = 1;
    	productsQuestion[equation_adding][1] = "InBr";
    	productAnswers[equation_adding][1] = 2;
    	
    	equation_adding = 20;
    	reactantsQuestion[equation_adding] = new String[2];
    	productsQuestion[equation_adding] = new String[2];

    	reactantsQuestion[equation_adding][0] = "KClO₄";
    	reactantAnswers[equation_adding][0] = 1;
    	reactantsQuestion[equation_adding][1] = "C";
    	reactantAnswers[equation_adding][1] = 2;

    	productsQuestion[equation_adding][0] = "KCl";
    	productAnswers[equation_adding][0] = 1;
    	productsQuestion[equation_adding][1] = "CO₂";
    	productAnswers[equation_adding][1] = 2;
    	
    	equation_adding = 21;
    	reactantsQuestion[equation_adding] = new String[3];
    	productsQuestion[equation_adding] = new String[2];

    	reactantsQuestion[equation_adding][0] = "PH₃";
    	reactantAnswers[equation_adding][0] = 1;
    	reactantsQuestion[equation_adding][1] = "I₂";
    	reactantAnswers[equation_adding][1] = 2;
    	reactantsQuestion[equation_adding][2] = "H₂O";
    	reactantAnswers[equation_adding][2] = 2;

    	productsQuestion[equation_adding][0] = "H₃PO₂";
    	productAnswers[equation_adding][0] = 1;
    	productsQuestion[equation_adding][1] = "HI";
    	productAnswers[equation_adding][1] = 4;
    	
    	equation_adding = 22;
    	reactantsQuestion[equation_adding] = new String[3];
    	productsQuestion[equation_adding] = new String[2];

    	reactantsQuestion[equation_adding][0] = "P₄";
    	reactantAnswers[equation_adding][0] = 1;
    	reactantsQuestion[equation_adding][1] = "KOH";
    	reactantAnswers[equation_adding][1] = 3;
    	reactantsQuestion[equation_adding][2] = "H₂O";
    	reactantAnswers[equation_adding][2] = 3;

    	productsQuestion[equation_adding][0] = "PH₃";
    	productAnswers[equation_adding][0] = 1;
    	productsQuestion[equation_adding][1] = "KH₂PO₂";
    	productAnswers[equation_adding][1] = 3;
    	
    	equation_adding = 23;
    	reactantsQuestion[equation_adding] = new String[2];
    	productsQuestion[equation_adding] = new String[2];

    	reactantsQuestion[equation_adding][0] = "Cl₂";
    	reactantAnswers[equation_adding][0] = 1;
    	reactantsQuestion[equation_adding][1] = "NaBr";
    	reactantAnswers[equation_adding][1] = 2;

    	productsQuestion[equation_adding][0] = "NaCl";
    	productAnswers[equation_adding][0] = 2;
    	productsQuestion[equation_adding][1] = "Br₂";
    	productAnswers[equation_adding][1] = 1;
    	
    	equation_adding = 24;
    	reactantsQuestion[equation_adding] = new String[2];
    	productsQuestion[equation_adding] = new String[3];

    	reactantsQuestion[equation_adding][0] = "HCl";
    	reactantAnswers[equation_adding][0] = 2;
    	reactantsQuestion[equation_adding][1] = "CaCO₃";
    	reactantAnswers[equation_adding][1] = 1;

    	productsQuestion[equation_adding][0] = "CaCl₂";
    	productAnswers[equation_adding][0] = 1;
    	productsQuestion[equation_adding][1] = "H₂O";
    	productAnswers[equation_adding][1] = 1;
    	productsQuestion[equation_adding][2] = "CO₂";
    	productAnswers[equation_adding][2] = 1;
    	
    	equation_adding = 25;
    	reactantsQuestion[equation_adding] = new String[2];
    	productsQuestion[equation_adding] = new String[1];

    	reactantsQuestion[equation_adding][0] = "Na";
    	reactantAnswers[equation_adding][0] = 4;
    	reactantsQuestion[equation_adding][1] = "O₂";
    	reactantAnswers[equation_adding][1] = 1;

    	productsQuestion[equation_adding][0] = "Na₂O";
    	productAnswers[equation_adding][0] = 2;
    	
    	equation_adding = 26;
    	reactantsQuestion[equation_adding] = new String[2];
    	productsQuestion[equation_adding] = new String[1];

    	reactantsQuestion[equation_adding][0] = "Si";
    	reactantAnswers[equation_adding][0] = 1;
    	reactantsQuestion[equation_adding][1] = "Cl₂";
    	reactantAnswers[equation_adding][1] = 2;

    	productsQuestion[equation_adding][0] = "SiCl₄";
    	productAnswers[equation_adding][0] = 1;
    	
    	equation_adding = 27;
    	reactantsQuestion[equation_adding] = new String[2];
    	productsQuestion[equation_adding] = new String[2];

    	reactantsQuestion[equation_adding][0] = "Mg";
    	reactantAnswers[equation_adding][0] = 1;
    	reactantsQuestion[equation_adding][1] = "HCl";
    	reactantAnswers[equation_adding][1] = 2;

    	productsQuestion[equation_adding][0] = "H₂";
    	productAnswers[equation_adding][0] = 1;
    	productsQuestion[equation_adding][1] = "MgCl₂";
    	productAnswers[equation_adding][1] = 1;
    	
    	equation_adding = 28;
    	reactantsQuestion[equation_adding] = new String[2];
    	productsQuestion[equation_adding] = new String[1];

    	reactantsQuestion[equation_adding][0] = "Na";
    	reactantAnswers[equation_adding][0] = 2;
    	reactantsQuestion[equation_adding][1] = "Br₂";
    	reactantAnswers[equation_adding][1] = 1;

    	productsQuestion[equation_adding][0] = "NaBr";
    	productAnswers[equation_adding][0] = 2;
    	
    	equation_adding = 29;
    	reactantsQuestion[equation_adding] = new String[1];
    	productsQuestion[equation_adding] = new String[2];

    	reactantsQuestion[equation_adding][0] = "KClO₃";
    	reactantAnswers[equation_adding][0] = 2;

    	productsQuestion[equation_adding][0] = "KCl";
    	productAnswers[equation_adding][0] = 2;
    	productsQuestion[equation_adding][1] = "O₂";
    	productAnswers[equation_adding][1] = 3;
    	
    	equation_adding = 30;
    	reactantsQuestion[equation_adding] = new String[2];
    	productsQuestion[equation_adding] = new String[2];

    	reactantsQuestion[equation_adding][0] = "AlCl₃";
    	reactantAnswers[equation_adding][0] = 2;
    	reactantsQuestion[equation_adding][1] = "H₂";
    	reactantAnswers[equation_adding][1] = 3;

    	productsQuestion[equation_adding][0] = "Al";
    	productAnswers[equation_adding][0] = 2;
    	productsQuestion[equation_adding][1] = "HCl";
    	productAnswers[equation_adding][1] = 6;
    	
    	equation_adding = 31;
    	reactantsQuestion[equation_adding] = new String[2];
    	productsQuestion[equation_adding] = new String[2];

    	reactantsQuestion[equation_adding][0] = "ZnS";
    	reactantAnswers[equation_adding][0] = 2;
    	reactantsQuestion[equation_adding][1] = "O₂";
    	reactantAnswers[equation_adding][1] = 3;

    	productsQuestion[equation_adding][0] = "ZnO";
    	productAnswers[equation_adding][0] = 2;
    	productsQuestion[equation_adding][1] = "SO₂";
    	productAnswers[equation_adding][1] = 2;
    	
    	equation_adding = 32;
    	reactantsQuestion[equation_adding] = new String[2];
    	productsQuestion[equation_adding] = new String[2];

    	reactantsQuestion[equation_adding][0] = "ZnS";
    	reactantAnswers[equation_adding][0] = 2;
    	reactantsQuestion[equation_adding][1] = "O₂";
    	reactantAnswers[equation_adding][1] = 3;

    	productsQuestion[equation_adding][0] = "ZnO";
    	productAnswers[equation_adding][0] = 2;
    	productsQuestion[equation_adding][1] = "SO₂";
    	productAnswers[equation_adding][1] = 2;
    	
    	equation_adding = 33;
    	reactantsQuestion[equation_adding] = new String[2];
    	productsQuestion[equation_adding] = new String[3];

    	reactantsQuestion[equation_adding][0] = "HCl";
    	reactantAnswers[equation_adding][0] = 2;
    	reactantsQuestion[equation_adding][1] = "K₂CO₃";
    	reactantAnswers[equation_adding][1] = 1;

    	productsQuestion[equation_adding][0] = "KCl";
    	productAnswers[equation_adding][0] = 2;
    	productsQuestion[equation_adding][1] = "H₂O";
    	productAnswers[equation_adding][1] = 1;
    	productsQuestion[equation_adding][2] = "CO₂";
    	productAnswers[equation_adding][2] = 1;
    	
    	equation_adding = 34;
    	reactantsQuestion[equation_adding] = new String[2];
    	productsQuestion[equation_adding] = new String[2];

    	reactantsQuestion[equation_adding][0] = "MoO₃";
    	reactantAnswers[equation_adding][0] = 2;
    	reactantsQuestion[equation_adding][1] = "C";
    	reactantAnswers[equation_adding][1] = 3;

    	productsQuestion[equation_adding][0] = "Mo";
    	productAnswers[equation_adding][0] = 2;
    	productsQuestion[equation_adding][1] = "CO₂";
    	productAnswers[equation_adding][1] = 3;
    	
    	equation_adding = 35;
    	reactantsQuestion[equation_adding] = new String[2];
    	productsQuestion[equation_adding] = new String[3];

    	reactantsQuestion[equation_adding][0] = "C₂H₃OCl";
    	reactantAnswers[equation_adding][0] = 1;
    	reactantsQuestion[equation_adding][1] = "O₂";
    	reactantAnswers[equation_adding][1] = 1;

    	productsQuestion[equation_adding][0] = "CO";
    	productAnswers[equation_adding][0] = 2;
    	productsQuestion[equation_adding][1] = "H₂O";
    	productAnswers[equation_adding][1] = 1;
    	productsQuestion[equation_adding][2] = "HCl";
    	productAnswers[equation_adding][2] = 1;
    	
    	equation_adding = 36;
    	reactantsQuestion[equation_adding] = new String[2];
    	productsQuestion[equation_adding] = new String[2];

    	reactantsQuestion[equation_adding][0] = "Na₂SO₄";
    	reactantAnswers[equation_adding][0] = 1;
    	reactantsQuestion[equation_adding][1] = "C";
    	reactantAnswers[equation_adding][1] = 2;

    	productsQuestion[equation_adding][0] = "Na₂S";
    	productAnswers[equation_adding][0] = 1;
    	productsQuestion[equation_adding][1] = "CO₂";
    	productAnswers[equation_adding][1] = 2;
    	
    	equation_adding = 37;
    	reactantsQuestion[equation_adding] = new String[2];
    	productsQuestion[equation_adding] = new String[1];

    	reactantsQuestion[equation_adding][0] = "Fe";
    	reactantAnswers[equation_adding][0] = 4;
    	reactantsQuestion[equation_adding][1] = "O₂";
    	reactantAnswers[equation_adding][1] = 3;

    	productsQuestion[equation_adding][0] = "Fe₂O₃";
    	productAnswers[equation_adding][0] = 2;
    	
    	equation_adding = 38;
    	reactantsQuestion[equation_adding] = new String[2];
    	productsQuestion[equation_adding] = new String[2];

    	reactantsQuestion[equation_adding][0] = "Mg";
    	reactantAnswers[equation_adding][0] = 1;
    	reactantsQuestion[equation_adding][1] = "AgNO₃";
    	reactantAnswers[equation_adding][1] = 2;

    	productsQuestion[equation_adding][0] = "Mg(NO₃)₂";
    	productAnswers[equation_adding][0] = 1;
    	productsQuestion[equation_adding][1] = "Ag";
    	productAnswers[equation_adding][1] = 2;
    	
    	equation_adding = 39;
    	reactantsQuestion[equation_adding] = new String[2];
    	productsQuestion[equation_adding] = new String[2];

    	reactantsQuestion[equation_adding][0] = "Ca";
    	reactantAnswers[equation_adding][0] = 3;
    	reactantsQuestion[equation_adding][1] = "LaFl₃";
    	reactantAnswers[equation_adding][1] = 2;

    	productsQuestion[equation_adding][0] = "La";
    	productAnswers[equation_adding][0] = 2;
    	productsQuestion[equation_adding][1] = "CaF₂";
    	productAnswers[equation_adding][1] = 3;
    	
    	
    	mSoundManager = new SoundManager();
    	mSoundManager.initSounds(getBaseContext());
    	mSoundManager.addSound(BUZZ, R.raw.buzz);
    	mSoundManager.addSound(CORRECT, R.raw.hit);
    	mSoundManager.addSound(POP, R.raw.pop);
    	
    	return true;
    }
    
    public void tap_to_continue() {
    	Button tap = (Button) findViewById(R.id.button2);
    	tap.setVisibility(View.VISIBLE);
    }
    
    public void tap_anywhere(View view){
    	view.setVisibility(View.INVISIBLE);
    	resetEquation();
    	genEquation();
    }
    
    public void wrong(){
    	TextView verify_correct = (TextView) findViewById(R.id.textView2);
    	verify_correct.setVisibility(View.VISIBLE);
    	verify_correct.setText("Wrong!");
    	verify_correct.setTextColor(Color.RED);
    	mSoundManager.playSound(BUZZ);
    }
    
    public void update_score(){
    	TextView score = (TextView) findViewById(R.id.textView1);
    	score.setText(correct + " / " + completed);
    }
    
    public void correct(){
    	TextView verify_correct = (TextView) findViewById(R.id.textView2);
    	verify_correct.setVisibility(View.VISIBLE);
    	verify_correct.setText("Correct!");
    	verify_correct.setTextColor(Color.GREEN);
    	mSoundManager.playSound(CORRECT);
    }
    
    public void dismiss(){
    	TextView verify_correct = (TextView) findViewById(R.id.textView2);
    	verify_correct.setVisibility(View.INVISIBLE);
    }
    
    public int setPosition(Button button, int num_compounds, int number, int side) {
		button.setVisibility(View.VISIBLE);
    	DisplayMetrics displaymetrics = new DisplayMetrics();
        getWindowManager().getDefaultDisplay().getMetrics(displaymetrics);
        int screen_height = displaymetrics.heightPixels;
        int screen_width = displaymetrics.widthPixels;
		
        button.setWidth(BUTTON_WIDTH);
        
        Resources r = getResources();
        float w = TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, 75, r.getDisplayMetrics());
        float h = BUTTON_HEIGHT;
        
		RelativeLayout.LayoutParams blp = new RelativeLayout.LayoutParams((int) w, (int) h); 
		
		int lm = screen_width / (num_compounds + 1); // get line of division
		lm *= number + 1;
		lm -= w / 2; //adjust for size of button
		
		blp.leftMargin = lm;
		
		int tm = screen_height / 2;
		tm -= h / 2;
		tm -= BUTTON_OFFSET * side;
		
		blp.topMargin = tm;
		
		
		// set title of button
		
		Typeface tf = Typeface.createFromAsset(getAssets(), "fonts/Arial Bold.ttf");
		
		String compound;
		
		if (side == REACTANT) compound = reactantsQuestion[equationNumber][number];
		else compound = productsQuestion[equationNumber][number];
		
		button.setTypeface(tf);
		
		button.setText(compound);
		
		button.setLayoutParams(blp);
		
		return lm + 50;
    }
    
    public void genSide(int side, int eqNum){
    	// gen each side of eq
    	
    	if (side == REACTANT_SIDE){
    		int num_compounds = reactantsQuestion[equationNumber].length;
    		for (int i = 0; i < num_compounds; i++) {
    			int new_line = setPosition(reactantButtons[i], num_compounds, i, REACTANT);
    			if (i != 0) {
    				DisplayMetrics displaymetrics = new DisplayMetrics();
    		        getWindowManager().getDefaultDisplay().getMetrics(displaymetrics);
    		        int screen_height = displaymetrics.heightPixels;
    				int lm = (new_line + last_line) / 2;
    				int tm = screen_height / 2;
    				tm -= - (BUTTON_HEIGHT / 2) + (BUTTON_OFFSET) +  + ARROW_HEIGHT / 2;
    				
    				RelativeLayout.LayoutParams blp = 
    						new RelativeLayout.LayoutParams(RelativeLayout.LayoutParams.WRAP_CONTENT, 
    						RelativeLayout.LayoutParams.WRAP_CONTENT);
    				blp.topMargin = tm;
    				blp.leftMargin = lm;
    				plus[i - 1].setLayoutParams(blp);
    				plus[i - 1].setVisibility(View.VISIBLE);
    			}
				last_line = new_line;
    		}
    	} // reactants
    	
    	if (side == PRODUCT_SIDE){
    		int num_compounds = productsQuestion[equationNumber].length;
    		for (int i = 0; i < num_compounds; i++) {
    			int new_line = setPosition(productButtons[i], num_compounds, i, PRODUCT);
    			
    			if (i != 0) {
    				DisplayMetrics displaymetrics = new DisplayMetrics();
    		        getWindowManager().getDefaultDisplay().getMetrics(displaymetrics);
    		        int screen_height = displaymetrics.heightPixels;
    				int lm = (new_line + last_line) / 2;
    				int tm = screen_height / 2;
    				tm += (BUTTON_HEIGHT / 2) + (BUTTON_OFFSET) +  - ARROW_HEIGHT / 2;
    				
    				RelativeLayout.LayoutParams blp = 
    						new RelativeLayout.LayoutParams(RelativeLayout.LayoutParams.WRAP_CONTENT, 
    						RelativeLayout.LayoutParams.WRAP_CONTENT);
    				blp.topMargin = tm;
    				blp.leftMargin = lm;
    				plus[i + 1].setLayoutParams(blp);
    				plus[i + 1].setVisibility(View.VISIBLE);
    			}
    			
    			last_line = new_line;
    		}
    	} // products
    }
    
    public void changeCoefficient(View view){
    	Button button = (Button) view;
    	String current_text = button.getText().toString();
    	boolean shouldResetToZero = false;
    	
    	int button_number = 0;
    	for (int i = 0; i < 3; i++){
    		if (button == reactantButtons[i]){
    			button_number = i;
    		}
    		else if (button == productButtons[i]){
    			button_number = i + 3; // to distinguish btw react and prod
    		}
    	}
    	
    	selected = button_number;
    	
    	// now have current text of button and which button it is
    	// going to get current coefficient
    	
    	int current_coefficient = 1;
    	
    	if (button_number < 3) {
    		current_coefficient = currentReactantCoefficients[button_number];
    		 if (currentReactantCoefficients[button_number] != 9) {
    			 currentReactantCoefficients[button_number]++; //update new coef
    		 }
    		 else {
    			 shouldResetToZero = true;
    			 currentReactantCoefficients[button_number] = 1;
    		 }
    	}
    	else {
    		int actual_button_number = button_number - 3;
    		current_coefficient = currentProductCoefficients[actual_button_number];
	   		if (currentProductCoefficients[actual_button_number] != 9) {
				currentProductCoefficients[actual_button_number]++; //update new coef
			}
			else {
				shouldResetToZero = true;
				currentProductCoefficients[actual_button_number] = 1;
			}
    	}
    	
    	int new_coef = 1;
    	if (current_coefficient == 1){
    		new_coef = current_coefficient + 1;
    		button.setText(new_coef + current_text);
    	}
    	else {
    		String compound = current_text.substring(1);
    		if (!shouldResetToZero) new_coef = current_coefficient + 1;
    		if (new_coef != 1) button.setText(new_coef + compound);
    		else button.setText(compound);
    	}
    	
    	mSeekBar.setProgress(new_coef - 1);
    	dismiss();
    	mSoundManager.playSound(POP);
    }
    
    public void genEquation(){
    	isFirstTry = true;
    	// choose equation num, gen
    	
    	int old_eq_num = equationNumber;
    	
    	while (equationNumber == old_eq_num){
    	    Random rand = new Random(); // to change to levels later
    	    int tempNumber = rand.nextInt(reactantsQuestion.length / 2);
    	    if (difficulty == EASY){
    	    	equationNumber = easyArray[tempNumber];
    	    }
    	    else {
    	    	equationNumber = hardArray[tempNumber];
    	    }
    	}
    	
    	for (int i = 0; i < 2; i++) genSide(i, equationNumber);
    }
    
    public void formatButtons(){
    	//create buttons and setup
    	Button[] productButtonsTemp = {
    			(Button) findViewById(R.id.products1),
    			(Button) findViewById(R.id.products2),
    	    	(Button) findViewById(R.id.products3)
    	}; //make temp array to hold buttons
    	
    	productButtons = productButtonsTemp; //sync global array with local
    	
    	Button[] reactantButtonsTemp = {
    			(Button) findViewById(R.id.reactants1),
    			(Button) findViewById(R.id.reactants2),
    	    	(Button) findViewById(R.id.reactants3)
    	};
    	
    	reactantButtons = reactantButtonsTemp;
    	
    	currentReactantCoefficients = new int[3];
    	currentProductCoefficients = new int [3];
    	
    	for (int i = 0; i < 3; i++){
    		currentReactantCoefficients[i] = 1;
    		currentProductCoefficients[i] = 1;
    	}
    	
    	mSeekBar = (SeekBar)findViewById(R.id.seekBar1);
        mSeekBar.setOnSeekBarChangeListener(this);
        
        TextView[] plusTemp = {
        		(TextView) findViewById(R.id.plus1),
        		(TextView) findViewById(R.id.plus2),
        		(TextView) findViewById(R.id.plus3),
        		(TextView) findViewById(R.id.plus4)
        };
        
        plus = plusTemp;
    }
    
    public void setVariables(){
    	correct = 0;
    	completed = 0;
    	
    	selected = 0;
    	
    	isFirstTry = true;
    }
    
    public void resetEquation(){
    	// reset coefs and hide buttons
    	for (int i = 0; i < 3; i++) {
    		reactantButtons[i].setVisibility(View.INVISIBLE);
    		productButtons[i].setVisibility(View.INVISIBLE);
    		currentReactantCoefficients[i] = 1;
    		currentProductCoefficients[i] = 1;
    		plus[i].setVisibility(View.INVISIBLE);
    	}
    	plus[3].setVisibility(View.INVISIBLE); //because 3 just isn't enough
    	dismiss();
    	update_score();
    	mSeekBar.setProgress(0);
    }
    
    public void init(){
    	if (!loaded) {
    		loaded = loadEquations();
    	}
    	formatButtons();
    	setVariables();
    	resetEquation();
    	genEquation();
    }
    
    public void easy(View view){
    	difficulty = EASY;
    	setContentView(R.layout.game);
    	init(); // change view, then setup
    }
    
    public void hard(View view){
    	difficulty = HARD;
    	setContentView(R.layout.game);
    	init();
    }
    
    public void selectToHome(View view){
    	setContentView(R.layout.main);
    }
    
    public void homeToInstructions(View view){
    	setContentView(R.layout.instructions);
    }

	@Override
	public void onStartTrackingTouch(SeekBar seekBar) {
		isTracking = true;
		
	}

	@Override
	public void onStopTrackingTouch(SeekBar seekBar) {
		isTracking = false;
	}
}