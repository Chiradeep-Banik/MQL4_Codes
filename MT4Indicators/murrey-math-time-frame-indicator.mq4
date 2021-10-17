//+------------------------------------------------------------------+
//|                                                    TimeFrame.mq4 |
//+------------------------------------------------------------------+
#property copyright "TimeFrame.Modified"
#property link      "mailto:xard777@connectfree.co.uk"
#property indicator_chart_window
//+------------------------------------------------------------------+
//| Define the Variables to use.....                                 |
//+------------------------------------------------------------------+
extern int       beginer=0;
extern int       periodtotake=64;
extern int       SomeVar=0;
int shift=0,i2=0,WorkTime=0,Periods=0;
double sum=0,v1=0,v2=0,fractal=0;
double v45=0,mml00=0,mml0=0,mml1=0,mml2=0,mml3=0,mml4=0,mml5=0,mml6=0,mml7=0,mml8=0,mml9=0,mml98=0,mml99=0;
double mm92=0,mm94=0,mm96=0,mm82=0,mm84=0,mm86=0,mm72=0,mm74=0,mm76=0,mm62=0,mm64=0,mm66=0,mm56=0,mm54=0,mm52=0,mm46=0,mm44=0,mm42=0,mm36=0,mm34=0,mm32=0,mm26=0,mm24=0,mm22=0,mm16=0,mm14=0,mm12s=0,mm06=0,mm04=0,mm02=0,mm106=0,mm104=0,mm102=0,mm1006=0,mm1004=0,mm1002=0;
double range=0,octave=0,mn=0,mx=0,price=0;
double finalH=0,finalL=0;
double x1=0,x2=0,x3=0,x4=0,x5=0,x6=0,y1=0,y2=0,y3=0,y4=0,y5=0,y6=0;
string textArray[13]={"MM-2/8ths_txt","MM-1/8th_txt","MM 0/8th_txt","MM 1/8th_txt","MM 2/8ths_txt","MM 3/8ths_txt","MM 4/8ths_txt","MM 5/8ths_txt","MM 6/8ths_txt","MM 7/8ths_txt","MM 8/8ths_txt","MM+1/8th_txt","MM+2/8ths_txt"};
string lineArray[49]={"MM-2/8ths","MM-1/8th","MM 0/8th","MM 1/8th","MM 2/8ths","MM 3/8ths","MM 4/8ths","mm92","mm94","mm96","mm82","mm84","mm86","mm72","mm74","mm76","mm62","mm64","mm66","mm56","mm54","mm52","mm46","mm44","mm42","mm36","mm34","mm32","mm26","mm24","mm22","mm16","mm14","mm12s","mm06","mm04","mm02","mm106","mm104","mm102","mm1006","mm1004","mm1002","MM 5/8ths","MM 6/8ths","MM 7/8ths","MM 8/8ths","MM+1/8th","MM+2/8ths"};
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//---- TODO: add your code here
   ObjectsDeleteAll(0, OBJ_HLINE); 
   int count=ArraySize(textArray);
   for(int ch=0;ch<count;ch++) {
      ObjectDelete(textArray[ch]);
      ObjectDelete(lineArray[ch]);
   }
   //ObjectsDeleteAll(0, OBJ_TEXT); 
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
if( (WorkTime != Time[0]) || (Periods != Period()) ) {
//price
v1=(Low[Lowest(NULL,0,MODE_LOW,periodtotake+SomeVar,beginer)]);
v2=(High[Highest(NULL,0,MODE_HIGH,periodtotake+SomeVar,beginer)]);
//+------------------------------------------------------------------+
//| Determine which Fractal to use.....                              |
//+------------------------------------------------------------------+
   if(v2<=250000 && v2>25000) fractal = 100000;
   if(v2<=25000 && v2>2500) fractal = 10000;
   if(v2<=2500 && v2>250) fractal = 1000;
   if(v2<=250 && v2>25) fractal = 100;
   if(v2<=25 && v2>12.5) fractal = 12.5;
   if(v2<=12.5 && v2>6.25) fractal = 12.5;
   if(v2<=6.25 && v2>3.125) fractal = 6.25;
   if(v2<=3.125 && v2>1.5625) fractal = 3.125;
   if(v2<=1.5625 && v2>0.390625) fractal = 1.5625;
   if(v2<=0.390625 && v2>0) fractal = 0.1953125;
// calculating our octave....      
   range=(v2-v1); sum=MathFloor(MathLog(fractal/range)/MathLog(2));
   octave=fractal*(MathPow(0.5,sum)); mn=MathFloor(v1/octave)*octave;
   if((mn+octave)>v2)mx=mn+octave; mx=mn+(2*octave);
// calculating xx
//x2
if((v1>=(3*(mx-mn)/16+mn))&& (v2<=(9*(mx-mn)/16+mn))) x2=mn+(mx-mn)/2; else x2=0;
//x1
if((v1>=(mn-(mx-mn)/8))&& (v2<=(5*(mx-mn)/8+mn)) && (x2==0)) x1=mn+(mx-mn)/2; else x1=0;
//x4
if((v1>=(mn+7*(mx-mn)/16))&& (v2<=(13*(mx-mn)/16+mn))) x4=mn+3*(mx-mn)/4; else x4=0;
//x5
if((v1>=(mn+3*(mx-mn)/8))&& (v2<=(9*(mx-mn)/8+mn))&& (x4==0)) x5=mx; else x5=0;
//x3
if((v1>=(mn+(mx-mn)/8))&& (v2<=(7*(mx-mn)/8+mn))&& (x1==0) && (x2==0) && (x4==0) && (x5==0)) x3=mn+3*(mx-mn)/4; else x3=0;
//x6 when we have no sbj, du {}
if((x1+x2+x3+x4+x5)==0) x6=mx; else x6=0;

finalH=x1+x2+x3+x4+x5+x6;
// calculating yy
//y1
if(x1>0) y1=mn; else y1=0;
//y2
if(x2>0) y2=mn+(mx-mn)/4; else y2=0;
//y3
if(x3>0) y3=mn+(mx-mn)/4; else y3=0;
//y4
if(x4>0) y4=mn+(mx-mn)/2; else y4=0;
//y5
if(x5>0) y5=mn+(mx-mn)/2; else y5=0;
//y6
if((finalH>0) && ((y1+y2+y3+y4+y5)==0)) y6=mn; else y6=0;

finalL=y1+y2+y3+y4+y5+y6;

v45=(finalH-finalL)/8;

mml00=(finalL-v45*2); mml0=(finalL-v45); mml1=(finalL); mml2=(finalL+v45); mml3=(finalL+2*v45);
mml4=(finalL+3*v45); mml5=(finalL+4*v45); mml6=(finalL+5*v45); mml7=(finalL+6*v45); mml8=(finalL+7*v45);
mml9=(finalL+8*v45); mml99=(finalL+9*v45); mml98=(finalL+10*v45); 
//Sub 2/8th, 4/8th, & 6/8th Lines
mm1002=(finalL-1.25*v45); mm1004=(finalL-1.5*v45); mm1006=(finalL-1.75*v45); mm102=(finalL-0.25*v45);
mm104=(finalL-0.5*v45); mm106=(finalL-0.75*v45); mm02=(finalL+0.25*v45); mm04=(finalL+0.5*v45);
mm06=(finalL+0.75*v45); mm12s=(finalL+1.25*v45); mm14=(finalL+1.5*v45); mm16=(finalL+1.75*v45);
mm22=(finalL+2.25*v45); mm24=(finalL+2.5*v45); mm26=(finalL+2.75*v45); mm32=(finalL+3.25*v45);
mm34=(finalL+3.5*v45); mm36=(finalL+3.75*v45); mm42=(finalL+4.25*v45); mm44=(finalL+4.5*v45);
mm46=(finalL+4.75*v45); mm52=(finalL+5.25*v45); mm54=(finalL+5.5*v45); mm56=(finalL+5.75*v45);
mm62=(finalL+6.25*v45); mm64=(finalL+6.5*v45); mm66=(finalL+6.75*v45); mm72=(finalL+7.25*v45);
mm74=(finalL+7.5*v45); mm76=(finalL+7.75*v45); mm82=(finalL+8.25*v45); mm84=(finalL+8.5*v45);
mm86=(finalL+8.75*v45); mm92=(finalL+9.25*v45); mm94=(finalL+9.5*v45); mm96=(finalL+9.75*v45);

Comment("\n","MURREYMATH TIMEFRAME by XARD777","\n","HighClose = ",v2,"\n","LowClose = ",v1,"\n","Range = ",range,"\n","Master Square = ",fractal,"\n","Octave 8/8ths = ",finalH,"\n","Octave 0/8ths = ",finalL,"\n","Octave 8ths = ",v45,"\n","Wants to Reverse Off = ",fractal/128);

   ObjectCreate("MM-2/8ths_txt",OBJ_TEXT,0,Time[12],mml00,Time[0],mml00);
   ObjectSetText("MM-2/8ths_txt","-2/8ths Extreme Overshoot ",10,"Arial",Red);
	
	ObjectCreate("MM-1/8th_txt",OBJ_TEXT,0,Time[12],mml0,Time[0],mml0);
	ObjectSetText("MM-1/8th_txt","-1/8th Overshoot ",10,"Arial",OrangeRed);
	
	ObjectCreate("MM 0/8th_txt",OBJ_TEXT,0,Time[12],mml1,Time[0],mml1);
	ObjectSetText("MM 0/8th_txt","0/8th Ultimate Resistance ",10,"Arial",DeepSkyBlue);
	
	ObjectCreate("MM 1/8th_txt",OBJ_TEXT,0,Time[12],mml2,Time[0],mml2);
	ObjectSetText("MM 1/8th_txt","1/8th Weak, Stall & Reverse ",10,"Arial",Yellow);

   ObjectCreate("MM 2/8ths_txt",OBJ_TEXT,0,Time[12],mml3,Time[0],mml3);
	ObjectSetText("MM 2/8ths_txt","2/8ths Pivot, Reverse - major ",10,"Arial",HotPink);

   ObjectCreate("MM 3/8ths_txt",OBJ_TEXT,0,Time[12],mml4,Time[0],mml4);
	ObjectSetText("MM 3/8ths_txt","3/8ths Bottom of Trading Range ",10,"Arial",Lime);	
	
	ObjectCreate("MM 4/8ths_txt",OBJ_TEXT,0,Time[12],mml5,Time[0],mml5);
	ObjectSetText("MM 4/8ths_txt","4/8ths Major Support/Resistance ",10,"Arial",DeepSkyBlue);
	
	ObjectCreate("MM 5/8ths_txt",OBJ_TEXT,0,Time[12],mml6,Time[0],mml6);
	ObjectSetText("MM 5/8ths_txt","5/8ths Top of Trading Range ",10,"Arial",Lime);
   
   ObjectCreate("MM 6/8ths_txt",OBJ_TEXT,0,Time[12],mml7,Time[0],mml7);
	ObjectSetText("MM 6/8ths_txt","6/8ths Pivot, Reverse - major ",10,"Arial",HotPink);
	
	ObjectCreate("MM 7/8ths_txt",OBJ_TEXT,0,Time[12],mml8,Time[0],mml8);
	ObjectSetText("MM 7/8ths_txt","7/8ths Weak, Stall & Reverse ",10,"Arial",Yellow);
	
	ObjectCreate("MM 8/8ths_txt",OBJ_TEXT,0,Time[12],mml9,Time[0],mml9);
	ObjectSetText("MM 8/8ths_txt","8/8ths Ultimate Resistance ",10,"Arial",DeepSkyBlue);
	
	ObjectCreate("MM+1/8th_txt",OBJ_TEXT,0,Time[12],mml99,Time[0],mml99);
	ObjectSetText("MM+1/8th_txt","+1/8th Overshoot ",10,"Arial",OrangeRed);
	
	ObjectCreate("MM+2/8ths_txt",OBJ_TEXT,0,Time[12],mml98,Time[0],mml98);
	ObjectSetText("MM+2/8ths_txt","+2/8ths Extreme Overshoot ",10,"Arial",Red);

ObjectCreate("MM-2/8ths",OBJ_HLINE,0,Time[0],mml00,Time[0],mml00);
ObjectSet("MM-2/8ths",OBJPROP_COLOR,Red);ObjectSet("MM-2/8ths",OBJPROP_WIDTH,2);ObjectSet("MM-2/8ths",OBJPROP_STYLE,STYLE_SOLID);
// -2/8
ObjectCreate("MM-1/8th" ,OBJ_HLINE,0,Time[0],mml0,Time[0],mml0); 
ObjectSet("MM-1/8th",OBJPROP_COLOR,OrangeRed);ObjectSet("MM-1/8th",OBJPROP_WIDTH,2);ObjectSet("MM-1/8th",OBJPROP_STYLE,STYLE_SOLID);
// -1/8
ObjectCreate("MM 0/8th" ,OBJ_HLINE,0,Time[0],mml1,Time[0],mml1);
ObjectSet("MM 0/8th",OBJPROP_COLOR,DeepSkyBlue);ObjectSet("MM 0/8th",OBJPROP_WIDTH,2);ObjectSet("MM 0/8th",OBJPROP_STYLE, STYLE_SOLID);
// 0/8
ObjectCreate("MM 1/8th" ,OBJ_HLINE,0,Time[0],mml2,Time[0],mml2); 
ObjectSet("MM 1/8th",OBJPROP_COLOR,Yellow);ObjectSet("MM 1/8th",OBJPROP_WIDTH,2);ObjectSet("MM 1/8th",OBJPROP_STYLE, STYLE_SOLID);
// 1/8
ObjectCreate("MM 2/8ths" ,OBJ_HLINE,0,Time[0],mml3,Time[0],mml3); 
ObjectSet("MM 2/8ths",OBJPROP_COLOR,HotPink);ObjectSet("MM 2/8ths",OBJPROP_WIDTH,2);ObjectSet("MM 2/8ths",OBJPROP_STYLE, STYLE_SOLID);
// 2/8
ObjectCreate("MM 3/8ths" ,OBJ_HLINE,0,Time[0],mml4,Time[0],mml4); 
ObjectSet("MM 3/8ths",OBJPROP_COLOR,Lime);ObjectSet("MM 3/8ths",OBJPROP_WIDTH,2);ObjectSet("MM 3/8ths",OBJPROP_STYLE, STYLE_SOLID);
// 3/8
ObjectCreate("MM 4/8ths" ,OBJ_HLINE,0,Time[0],mml5,Time[0],mml5); 
ObjectSet("MM 4/8ths",OBJPROP_COLOR,DeepSkyBlue);ObjectSet("MM 4/8ths",OBJPROP_WIDTH,2);ObjectSet("MM 4/8ths",OBJPROP_STYLE, STYLE_SOLID);
// 4/8
ObjectCreate("MM 5/8ths" ,OBJ_HLINE,0,Time[0],mml6,Time[0],mml6); 
ObjectSet("MM 5/8ths",OBJPROP_COLOR,Lime);ObjectSet("MM 5/8ths",OBJPROP_WIDTH,2);ObjectSet("MM 5/8ths",OBJPROP_STYLE, STYLE_SOLID);
// 5/8
ObjectCreate("MM 6/8ths" ,OBJ_HLINE,0,Time[0],mml7,Time[0],mml7);
ObjectSet("MM 6/8ths",OBJPROP_COLOR,HotPink);ObjectSet("MM 6/8ths",OBJPROP_WIDTH,2);ObjectSet("MM 6/8ths",OBJPROP_STYLE, STYLE_SOLID);
// 6/8
ObjectCreate("MM 7/8ths" ,OBJ_HLINE,0,Time[0],mml8,Time[0],mml8); 
ObjectSet("MM 7/8ths",OBJPROP_COLOR,Yellow);ObjectSet("MM 7/8ths",OBJPROP_WIDTH,2);ObjectSet("MM 7/8ths",OBJPROP_STYLE, STYLE_SOLID);
// 7/8
ObjectCreate("MM 8/8ths" ,OBJ_HLINE,0,Time[0],mml9,Time[0],mml9); 
ObjectSet("MM 8/8ths",OBJPROP_COLOR,DeepSkyBlue);ObjectSet("MM 8/8ths",OBJPROP_WIDTH,2);ObjectSet("MM 8/8ths",OBJPROP_STYLE, STYLE_SOLID);
// 0/8
ObjectCreate("MM+1/8th" ,OBJ_HLINE,0,Time[0],mml99,Time[0],mml99);
ObjectSet("MM+1/8th",OBJPROP_COLOR,OrangeRed);ObjectSet("MM+1/8th",OBJPROP_WIDTH,2);ObjectSet("MM+1/8th",OBJPROP_STYLE, STYLE_SOLID);
// +2/8
ObjectCreate("MM+2/8ths" ,OBJ_HLINE,0,Time[0],mml98,Time[0],mml98);
ObjectSet("MM+2/8ths",OBJPROP_COLOR,Red);ObjectSet("MM+2/8ths",OBJPROP_WIDTH,2);ObjectSet("MM+2/8ths",OBJPROP_STYLE, STYLE_SOLID);
// +1/8
//baby 2/8th, 4/8th, & 6/8th Lines
ObjectCreate("mm1002" ,OBJ_HLINE,0,Time[0],mm1002,Time[0],mm1002); 
ObjectSet("mm1002",OBJPROP_COLOR,SlateGray);ObjectSet("mm1002",OBJPROP_WIDTH,1);ObjectSet("mm1002",OBJPROP_STYLE, STYLE_SOLID);

ObjectCreate("mm1004" ,OBJ_HLINE,0,Time[0],mm1004,Time[0],mm1004); 
ObjectSet("mm1004",OBJPROP_COLOR,SlateGray);ObjectSet("mm1004",OBJPROP_WIDTH,1);ObjectSet("mm1004",OBJPROP_STYLE, STYLE_DOT);

ObjectCreate("mm1006" ,OBJ_HLINE,0,Time[0],mm1006,Time[0],mm1006); 
ObjectSet("mm1006",OBJPROP_COLOR,SlateGray);ObjectSet("mm1006",OBJPROP_WIDTH,1);ObjectSet("mm1006",OBJPROP_STYLE, STYLE_SOLID);

ObjectCreate("mm102" ,OBJ_HLINE,0,Time[0],mm102,Time[0],mm102); 
ObjectSet("mm102",OBJPROP_COLOR,SlateGray);ObjectSet("mm102",OBJPROP_WIDTH,1);ObjectSet("mm102",OBJPROP_STYLE, STYLE_SOLID);

ObjectCreate("mm104" ,OBJ_HLINE,0,Time[0],mm104,Time[0],mm104); 
ObjectSet("mm104",OBJPROP_COLOR,SlateGray);ObjectSet("mm104",OBJPROP_WIDTH,1);ObjectSet("mm104",OBJPROP_STYLE, STYLE_DOT);

ObjectCreate("mm106" ,OBJ_HLINE,0,Time[0],mm106,Time[0],mm106); 
ObjectSet("mm106",OBJPROP_COLOR,SlateGray);ObjectSet("mm106",OBJPROP_WIDTH,1);ObjectSet("mm106",OBJPROP_STYLE, STYLE_SOLID);

ObjectCreate("mm02" ,OBJ_HLINE,0,Time[0],mm02,Time[0],mm02); 
ObjectSet("mm02",OBJPROP_COLOR,SlateGray);ObjectSet("mm02",OBJPROP_WIDTH,1);ObjectSet("mm02",OBJPROP_STYLE, STYLE_SOLID);

ObjectCreate("mm04" ,OBJ_HLINE,0,Time[0],mm04,Time[0],mm04); 
ObjectSet("mm04",OBJPROP_COLOR,SlateGray);ObjectSet("mm04",OBJPROP_WIDTH,1);ObjectSet("mm04",OBJPROP_STYLE, STYLE_DOT);

ObjectCreate("mm06" ,OBJ_HLINE,0,Time[0],mm06,Time[0],mm06); 
ObjectSet("mm06",OBJPROP_COLOR,SlateGray);ObjectSet("mm06",OBJPROP_WIDTH,1);ObjectSet("mm06",OBJPROP_STYLE, STYLE_SOLID);

ObjectCreate("mm12s" ,OBJ_HLINE,0,Time[0],mm12s,Time[0],mm12s); 
ObjectSet("mm12s",OBJPROP_COLOR,SlateGray);ObjectSet("mm12s",OBJPROP_WIDTH,1);ObjectSet("mm12s",OBJPROP_STYLE, STYLE_SOLID);

ObjectCreate("mm14" ,OBJ_HLINE,0,Time[0],mm14,Time[0],mm14); 
ObjectSet("mm14",OBJPROP_COLOR,SlateGray);ObjectSet("mm14",OBJPROP_WIDTH,1);ObjectSet("mm14",OBJPROP_STYLE, STYLE_DOT);

ObjectCreate("mm16" ,OBJ_HLINE,0,Time[0],mm16,Time[0],mm16); 
ObjectSet("mm16",OBJPROP_COLOR,SlateGray);ObjectSet("mm16",OBJPROP_WIDTH,1);ObjectSet("mm16",OBJPROP_STYLE, STYLE_SOLID);

ObjectCreate("mm22" ,OBJ_HLINE,0,Time[0],mm22,Time[0],mm22); 
ObjectSet("mm22",OBJPROP_COLOR,SlateGray);ObjectSet("mm22",OBJPROP_WIDTH,1);ObjectSet("mm22",OBJPROP_STYLE, STYLE_SOLID);

ObjectCreate("mm24" ,OBJ_HLINE,0,Time[0],mm24,Time[0],mm24); 
ObjectSet("mm24",OBJPROP_COLOR,SlateGray);ObjectSet("mm24",OBJPROP_WIDTH,1);ObjectSet("mm24",OBJPROP_STYLE, STYLE_DOT);

ObjectCreate("mm26" ,OBJ_HLINE,0,Time[0],mm26,Time[0],mm26); 
ObjectSet("mm26",OBJPROP_COLOR,SlateGray);ObjectSet("mm26",OBJPROP_WIDTH,1);ObjectSet("mm26",OBJPROP_STYLE, STYLE_SOLID);

ObjectCreate("mm32" ,OBJ_HLINE,0,Time[0],mm32,Time[0],mm32); 
ObjectSet("mm32",OBJPROP_COLOR,SlateGray);ObjectSet("mm32",OBJPROP_WIDTH,1);ObjectSet("mm32",OBJPROP_STYLE, STYLE_SOLID);

ObjectCreate("mm34" ,OBJ_HLINE,0,Time[0],mm34,Time[0],mm34); 
ObjectSet("mm34",OBJPROP_COLOR,SlateGray);ObjectSet("mm34",OBJPROP_WIDTH,1);ObjectSet("mm34",OBJPROP_STYLE, STYLE_DOT);

ObjectCreate("mm36" ,OBJ_HLINE,0,Time[0],mm36,Time[0],mm36); 
ObjectSet("mm36",OBJPROP_COLOR,SlateGray);ObjectSet("mm36",OBJPROP_WIDTH,1);ObjectSet("mm36",OBJPROP_STYLE, STYLE_SOLID);

ObjectCreate("mm42" ,OBJ_HLINE,0,Time[0],mm42,Time[0],mm42); 
ObjectSet("mm42",OBJPROP_COLOR,SlateGray);ObjectSet("mm42",OBJPROP_WIDTH,1);ObjectSet("mm42",OBJPROP_STYLE, STYLE_SOLID);

ObjectCreate("mm44" ,OBJ_HLINE,0,Time[0],mm44,Time[0],mm44); 
ObjectSet("mm44",OBJPROP_COLOR,SlateGray);ObjectSet("mm44",OBJPROP_WIDTH,1);ObjectSet("mm44",OBJPROP_STYLE, STYLE_DOT);

ObjectCreate("mm46" ,OBJ_HLINE,0,Time[0],mm46,Time[0],mm46); 
ObjectSet("mm46",OBJPROP_COLOR,SlateGray);ObjectSet("mm46",OBJPROP_WIDTH,1);ObjectSet("mm46",OBJPROP_STYLE, STYLE_SOLID);

ObjectCreate("mm52" ,OBJ_HLINE,0,Time[0],mm52,Time[0],mm52); 
ObjectSet("mm52",OBJPROP_COLOR,SlateGray);ObjectSet("mm52",OBJPROP_WIDTH,1);ObjectSet("mm52",OBJPROP_STYLE, STYLE_SOLID);

ObjectCreate("mm54" ,OBJ_HLINE,0,Time[0],mm54,Time[0],mm54); 
ObjectSet("mm54",OBJPROP_COLOR,SlateGray);ObjectSet("mm54",OBJPROP_WIDTH,1);ObjectSet("mm54",OBJPROP_STYLE, STYLE_DOT);

ObjectCreate("mm56" ,OBJ_HLINE,0,Time[0],mm56,Time[0],mm56); 
ObjectSet("mm56",OBJPROP_COLOR,SlateGray);ObjectSet("mm56",OBJPROP_WIDTH,1);ObjectSet("mm56",OBJPROP_STYLE, STYLE_SOLID);

ObjectCreate("mm62" ,OBJ_HLINE,0,Time[0],mm62,Time[0],mm62); 
ObjectSet("mm62",OBJPROP_COLOR,SlateGray);ObjectSet("mm62",OBJPROP_WIDTH,1);ObjectSet("mm62",OBJPROP_STYLE, STYLE_SOLID);

ObjectCreate("mm64" ,OBJ_HLINE,0,Time[0],mm64,Time[0],mm64); 
ObjectSet("mm64",OBJPROP_COLOR,SlateGray);ObjectSet("mm64",OBJPROP_WIDTH,1);ObjectSet("mm64",OBJPROP_STYLE, STYLE_DOT);

ObjectCreate("mm66" ,OBJ_HLINE,0,Time[0],mm66,Time[0],mm66); 
ObjectSet("mm66",OBJPROP_COLOR,SlateGray);ObjectSet("mm66",OBJPROP_WIDTH,1);ObjectSet("mm66",OBJPROP_STYLE, STYLE_SOLID);

ObjectCreate("mm72" ,OBJ_HLINE,0,Time[0],mm72,Time[0],mm72); 
ObjectSet("mm72",OBJPROP_COLOR,SlateGray);ObjectSet("mm72",OBJPROP_WIDTH,1);ObjectSet("mm72",OBJPROP_STYLE, STYLE_SOLID);

ObjectCreate("mm74" ,OBJ_HLINE,0,Time[0],mm74,Time[0],mm74); 
ObjectSet("mm74",OBJPROP_COLOR,SlateGray);ObjectSet("mm74",OBJPROP_WIDTH,1);ObjectSet("mm74",OBJPROP_STYLE, STYLE_DOT);

ObjectCreate("mm76" ,OBJ_HLINE,0,Time[0],mm76,Time[0],mm76); 
ObjectSet("mm76",OBJPROP_COLOR,SlateGray);ObjectSet("mm76",OBJPROP_WIDTH,1);ObjectSet("mm76",OBJPROP_STYLE, STYLE_SOLID);

ObjectCreate("mm82" ,OBJ_HLINE,0,Time[0],mm82,Time[0],mm82); 
ObjectSet("mm82",OBJPROP_COLOR,SlateGray);ObjectSet("mm82",OBJPROP_WIDTH,1);ObjectSet("mm82",OBJPROP_STYLE, STYLE_SOLID);

ObjectCreate("mm84" ,OBJ_HLINE,0,Time[0],mm84,Time[0],mm84); 
ObjectSet("mm84",OBJPROP_COLOR,SlateGray);ObjectSet("mm84",OBJPROP_WIDTH,1);ObjectSet("mm84",OBJPROP_STYLE, STYLE_DOT);

ObjectCreate("mm86" ,OBJ_HLINE,0,Time[0],mm86,Time[0],mm86); 
ObjectSet("mm86",OBJPROP_COLOR,SlateGray);ObjectSet("mm86",OBJPROP_WIDTH,1);ObjectSet("mm86",OBJPROP_STYLE, STYLE_SOLID);

ObjectCreate("mm92" ,OBJ_HLINE,0,Time[0],mm92,Time[0],mm92); 
ObjectSet("mm92",OBJPROP_COLOR,SlateGray);ObjectSet("mm92",OBJPROP_WIDTH,1);ObjectSet("mm92",OBJPROP_STYLE, STYLE_SOLID);

ObjectCreate("mm94" ,OBJ_HLINE,0,Time[0],mm94,Time[0],mm94); 
ObjectSet("mm94",OBJPROP_COLOR,SlateGray);ObjectSet("mm94",OBJPROP_WIDTH,1);ObjectSet("mm94",OBJPROP_STYLE, STYLE_DOT);

ObjectCreate("mm96" ,OBJ_HLINE,0,Time[0],mm96,Time[0],mm96); 
ObjectSet("mm96",OBJPROP_COLOR,SlateGray);ObjectSet("mm96",OBJPROP_WIDTH,1);ObjectSet("mm96",OBJPROP_STYLE, STYLE_SOLID);

 //if(GetLastError()!=0) Alert("Some error message");
  
//}


  WorkTime    = Time[0];
   Periods= Period();
} 
   
   
//----
   return(0);
 }

