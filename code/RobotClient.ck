// =========================================================================
//  File: RobotClient.ck
//  Takes midi input from an IAC bus and sends OSC to the robot server
//  by Bruce Lott & Ness Morris
//  CalArts Music Technology: Interaction, Intelligence & Design
//  January 2014
// =========================================================================

MidiIn min;
MidiMsg msg;
OscSend xmit;
int status, chan, noteNum, vel;

<<<"","">>>;
// choose which IAC bus to use
if(me.args()){ 
    if(min.open(Std.atoi(me.arg(0)))){ // open argument as IAC bus
        <<<"Successfully connected to",min.name()+"!">>>;
    }
}
else if(min.open("IAC Driver IAC Bus 1")){ // default name of a new IAC bus 
    <<<"Successfully connected to", min.name() +"!">>>;
}
else <<<"Failed to open IAC Bus","">>>;
<<<"","">>>;

// connect to robot server
xmit.setHost("chuckServer.local",11235); 

// spork main loop
spork ~ midiLoop();

// confirm setup completion
7::second => now; // good luck time
<<<"If you didn't get any errors, you should be good to go!","">>>;

while(samp=>now);

// main loop
fun void midiLoop(){
    while(min=>now){
        while(min.recv(msg)){
            (msg.data1 & 0xF0)>>4 => status; // midi status byte
            (msg.data1 & 0x0F) => chan;      // midi channel
            if(status==9){ // note on
                msg.data2 => noteNum;
                msg.data3 => vel;
                if(chan==0){ // maha devi
                    if(noteNum > 59 & noteNum < 74){
                        xmit.startMsg("/devibot,ii");
                        oscOut(noteNum, vel);
                    }
                }
                if(chan==1){ // gana pati
                    if(noteNum > 59 & noteNum < 71){
                        xmit.startMsg("/ganapati,ii");
                        oscOut(noteNum, vel);
                    }
                }
                if(chan==2){ // breakbot
                    if(noteNum > 59 & noteNum < 86){
                        xmit.startMsg("/drumBot,ii");
                        oscOut(noteNum, vel);
                    }
                }
                if(chan==3){ // clappers
                    if(noteNum>59 & noteNum<81){
                        xmit.startMsg("/clappers,ii");
                        oscOut(noteNum, vel);
                    }
                }
                if(chan==4){ // jackbox percussion
                    if(noteNum>59 & noteNum<89){
                        xmit.startMsg("/jackperc,ii");
                        oscOut(noteNum,vel);
                    }
                }
                if(chan==5){ // jackbox bass
                    if(noteNum>59-8 & noteNum<84-8){
                        xmit.startMsg("/jackbass,ii");
                        oscOut(noteNum+8,vel);
                    }
                }
                if(chan==6){ // jackbox guitar
                    if(noteNum>59-8 & noteNum<94-8){
                        xmit.startMsg("/jackgtr,ii");
                        oscOut(noteNum+8,vel);
                    }
                }
                /*
                if(chan==7){ // MDarimBot
                    if(noteNum > 59-8 & noteNum 94 - 8){
                        xmit.startMsg("/MDarimBot,ii");
                        oscOut(noteNum+8,vel);
                    }
                }
                if(chan==8){ // Trimpbeat
                    if(noteNum > 59-8 & noteNum 94 - 8){
                        xmit.startMsg("/Trimpbeat,ii");
                        oscOut(noteNum+8,vel);
                    }
                }
                if(chan==9){ // Trimpspin
                    if(noteNum > 59-8 & noteNum 94 - 8){
                        xmit.startMsg("/Trimpspin,ii");
                        oscOut(noteNum+8,vel);
                    }
                } 
                */
            }
            if(status==8){ // note off
                if(chan==5){ // jackbox bass
                    if(noteNum>59-8 & noteNum<84-8){
                        xmit.startMsg("/jackbass,ii");
                        oscOut(noteNum+8,0);
                    }
                }
                if(chan==6){ // jackbox guitar
                    if(noteNum>59-8 & noteNum<94-8){
                        xmit.startMsg("/jackgtr,ii");
                        oscOut(noteNum+8,0);
                    }
                }
            }
        }
    }
}

fun void oscOut(int newNoteNum, int newVel){
    xmit.addInt(newNoteNum-60);
    xmit.addInt(newVel);
}
