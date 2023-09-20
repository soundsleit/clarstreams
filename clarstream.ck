// clarstream
// Scott Smallwood
// 2006, 2009, 2016
//
// v.03


// seed trick
Std.rand2f(.01,.09) => float seed;
seed::second => now;

//control array
int control[99];

// main volume knob
0.0 => float volMain;

// event to refresh screen
Event screenFresh;

// event to trigger/change sound
0 => int bang;
0 => int bangON	;

6 => int voices;
dac.channels() => int channels;


//declarations
Clarinet clar[voices];
Envelope clarEnv[voices];
PRCRev clarRvb[voices];
Gain clarGain[voices];

for (int i; i < voices; i++)
{
	clar[i] => clarEnv[i] => clarRvb[i] => clarGain[i] => dac.chan(i % channels);
	1.0 / voices => clarGain[i].gain;
	0 => clarRvb[i].mix;
}


//mod inits

float vgMod[voices];
float rdMod[voices];
float nzMod[voices];
float fqMod[voices];

for (int i; i < voices; i++)
{
	clar[i].vibratoGain() => vgMod[i];
	clar[i].reed() => rdMod[i];
	clar[i].noiseGain() => nzMod[i];
	clar[i].freq() => fqMod[i];
}

//main
spork ~ keys();
spork ~ tweaker();
spork ~ playClar();
spork ~ display();
while (true) 10::second => now;


// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
// Function playClar:  Start the sounds
// ---------------------
	
fun void playClar()
{
	while (true) {
	
		if (bang && !bangON) {

			initialize();
			1 => bangON;
			100::ms => now;
		}

		if (!bang) 0 => bangON;
		1::ms => now;
	}
}

// ####
// ####

//init random values for clarinet model + key on
fun void initialize(){

	for (int i; i < voices; i++)
	{
		0 => clar[i].rate;
		Std.rand2f(.8,1) => clar[i].pressure;
		Std.rand2f(15,50) => clar[i].vibratoFreq;
		Std.rand2f(0,1) => vgMod[i];
		Std.rand2f(0,1) => rdMod[i];
		Std.rand2f(0,1) => nzMod[i];
		Std.rand2f(100,500) * (i + 1) => fqMod[i];
		Std.rand2f(0,.1) => clarRvb[i].mix;
		1 => clarEnv[i].keyOn;
		1 => clarEnv[i].value;
	}

}

fun void keys ()
{

 // **** KEYBOARD SETUP

 Hid kb;
 HidMsg msg;
 if( !kb.openKeyboard( 0 ) ) 
 {
     <<<"no keyboard">>>;
     me.exit();
 }
 
 // key numbers
 [53, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 45, 46,
 20, 26, 8, 21, 23, 28, 24, 12, 18, 19, 47, 48, 49,
 4, 22, 7, 9, 10, 11, 13, 14, 15, 51, 52, 
 29, 27, 6, 25, 5, 17, 16, 54, 55, 56, 
 44]
 @=> int key[];
 
 while( true )
 {
    kb => now;

    while( kb.recv(msg) )
    {
		screenFresh.signal(); //trigger for screen refresh

    	for (0 => int i; i < key.cap(); i++)
    	{
    		if ((msg.which == key[i]) && msg.isButtonDown())
    		 1 => control[i];
    		 
    		if (msg.isButtonUp())
    		 0 => control[i];
		 }

		}
	}
}

fun void tweaker()
{
	.001 => float volslew;
	.005 => float slew;

	while (true)
	{

		control[47] => bang;

		// volume controls
		(control[13] * -.2) * volslew + volMain => volMain;
		(control[14] * -.1) * volslew + volMain => volMain;
		(control[15] * -.05) * volslew + volMain => volMain;
		(control[16] * -.01) * volslew + volMain => volMain;
		(control[19] * .01) * volslew + volMain => volMain;
		(control[20] * .05) * volslew + volMain => volMain;
		(control[21] * .1) * volslew + volMain => volMain;
		(control[22] * .2) * volslew + volMain => volMain;

	
		// volume limiter
		if (volMain <= 0) 	
			0  => volMain;
		if (volMain >= .999)
			.999 => volMain;

		// assign volume to all channel gains
		for (0 => int i; i < voices; i++)
			volMain => clarGain[i].gain;

		// timbre mods
		for (int i; i < voices; i++)
		{
			(control[26] * -.2) * slew +=> vgMod[i];
			(control[26] * -.2) * slew +=> rdMod[i];
			(control[26] * -.2) * slew +=> nzMod[i];

			(control[27] * -.1) * slew +=> vgMod[i];
			(control[27] * -.1) * slew +=> rdMod[i];
			(control[27] * -.1) * slew +=> nzMod[i];

			(control[28] * -.05) * slew +=> vgMod[i];
			(control[28] * -.05) * slew +=> rdMod[i];
			(control[28] * -.05) * slew +=> nzMod[i];

			(control[29] * -.01) * slew +=> vgMod[i];
			(control[29] * -.01) * slew +=> rdMod[i];
			(control[29] * -.01) * slew +=> nzMod[i];

			(control[32] * .01) * slew +=> vgMod[i];
			(control[32] * .01) * slew +=> rdMod[i];
			(control[32] * .01) * slew +=> nzMod[i];

			(control[33] * .05) * slew +=> vgMod[i];
			(control[33] * .05) * slew +=> rdMod[i];
			(control[33] * .05) * slew +=> nzMod[i];

			(control[34] * .1) * slew +=> vgMod[i];
			(control[34] * .1) * slew +=> rdMod[i];
			(control[34] * .1) * slew +=> nzMod[i];

			(control[35] * .2) * slew +=> vgMod[i];
			(control[35] * .2) * slew +=> rdMod[i];
			(control[35] * .2) * slew +=> nzMod[i];

			(control[37] * -5) * slew +=> fqMod[i];
			(control[38] * -1) * slew +=> fqMod[i];
			(control[39] * -.5) * slew +=> fqMod[i];
			(control[40] * -.1) * slew +=> fqMod[i];

			(control[43] * 5) * slew +=> fqMod[i];
			(control[44] * 1) * slew +=> fqMod[i];
			(control[45] * .5) * slew +=> fqMod[i];
			(control[46] * .1) * slew +=> fqMod[i];

			//limiters
			if (vgMod[i] >= 1) 1 => vgMod[i];
			if (vgMod[i] <= 0) 0 => vgMod[i];
			if (rdMod[i] >= 1) 1 => rdMod[i];
			if (rdMod[i] <= 0) 0 => rdMod[i];
			if (nzMod[i] >= 1) 1 => nzMod[i];
			if (nzMod[i] <= 0) 0 => nzMod[i];
			if (fqMod[i] >= 10000) 10000 => fqMod[i];
			if (fqMod[i] <= 0) 0 => fqMod[i];

			//go ahead and assign the temp vars to stuff

			vgMod[i] => clar[i].vibratoGain;
			rdMod[i] => clar[i].reed;
			nzMod[i] => clar[i].noiseGain;
			fqMod[i] => clar[i].freq;

		}
								
		1::ms => now;
	}
}


// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
// Function display:  what to print for feedback
// ---------------------

fun void display()
{

	while (true)
	{

	for (0 => int i; i < 40; i++)
		<<< " ", " " >>>;
	
	<<<"","">>>;
	<<<"------------------------------------------------------------------","">>>;
	<<<"       C L A R S T R E A M    G E N E R A T O R  ! !","">>>;
	<<<"------------------------------------------------------------------","">>>;
	<<<"------------------------------------------------------------------","">>>;
	<<<"             ", channels, " channels">>>;
	<<<"","">>>;
	<<<"             SPACEBAR starts/changes sound","">>>;
	<<<"","">>>;

	<<< "                ---   --   -  +   ++   +++ ", " " >>>;
	<<< "                [q][w][e][r]  [u][i][o][p] : main volume", " ">>>;
	<<< "                       {", volMain, "}" >>>;
	<<< "                [a][s][d][f]  [j][k][l][;] : timbre mod","">>>;
	<<<"","">>>;
	<<< "                [z][x][c][v]  [m][,][.][/] : pitch mod","">>>;
	<<<"","">>>;

	for (0 => int j; j < voices; j++) {
		<<< "          {", clar[j].vibratoGain(), "} {", clar[j].reed(), "} {", clar[j].noiseGain(), "}" >>>;
		<<< "                     {", clar[j].freq(), "}" >>>;}
    
	<<<"","">>>;
	<<<"------------------------------------------------------------------","">>>;



	screenFresh => now;

	}

}
