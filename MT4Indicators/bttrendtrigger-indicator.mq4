//+------------------------------------------------------------------------+
//| MQL to MQ4 by Maloma                              BtTrendTrigger-T.mq4 |
//| Modified version of Trend Trigger Factor by Tartan                     |
//| Technical Analysis of Stocks and Commodities, Dec. 2004,p.28. M.H. Pee |
//+------------------------------------------------------------------------+
#property copyright "Paul Y. Shimada"
#property  link     "PaulYShimada@Y..."

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Gold
#property indicator_color2 Red

//---- indicator parameters
extern int    TTFbars=15; //15=default number of bars for computation.
extern int    t3_period=5;
extern double b=0.7;
extern int    ppor=50;
extern int    mpor=-50;
extern int    barBegin=1000; //<1000 recommended for faster speed, 0=All bars computed & plotted.
//---- indicator buffers
double Buffer1[];
double Buffer2[];
double ATTF[];

// Variable Specific:
string IndicatorName="py.TTF";
string Version="S01(MQL4 by maloma)";
double HighestHighRecent=0, HighestHighOlder=0, LowestLowRecent=0, LowestLowOlder=0;
double BuyPower=0, SellPower=0, TTF=0;
double t3=0, e1=0, e2=0, e3=0, e4=0, e5=0, e6=0, c1=0, c2=0, c3=0, c4=0, r=0, w1=0, w2=0, b2=0, b3=0;

// Variable Generic, mostly for module flow control:
int    shift=0, count=0;
bool   is_First=True;
int    loopBegin=0, prevBars=0, PrevTime=0, tick=0, prevShift=99999, firstPlotBar=0, badPlotBars=0; //Discarded first (old) bars with bad computed values
double CheckSum=0, CheckSumPrev=0;
string Msg="";
int    ks=0,kb=0,kss=0,ksb=0,m=0;

int init()
  {
//---- indicator buffers mapping  
    SetIndexBuffer(0,Buffer1);
    SetIndexBuffer(1,Buffer2);   
//---- drawing settings
    SetIndexStyle(0,DRAW_LINE,EMPTY,2);
    SetIndexArrow(0,217);
    SetIndexStyle(1,DRAW_LINE,EMPTY,2);
    SetIndexArrow(1,218);
//----
    SetIndexEmptyValue(0,0.0);
    SetIndexEmptyValue(1,0.0);
//---- name for DataWindow
    SetIndexLabel(0,"BTT1");
    SetIndexLabel(1,"BTT2");
//---- initialization done   
    IndicatorShortName("BtTrendTrigger");
   return(0);
  }

void CreateArrow(datetime BTime, double Price, int Code, color Color)
{
 string AN=DoubleToStr(CurTime(),0);
 ObjectCreate(AN,OBJ_ARROW,0,BTime,Price,0,0,0,0);
 ObjectSet(AN,OBJPROP_ARROWCODE,Code);
 ObjectSet(AN,OBJPROP_COLOR,Color);
 return(0);
}

int start()
{
 ArrayResize(ATTF,barBegin);
 b2 = b * b;
 b3 = b2 * b;
 c1 = (-b3);
 c2 = (3 * (b2 + b3));
 c3 = (-3) * (2 * b2 + b + b3);
 c4 = (1 + 3 * b + b3 + 3 * b2);
 
 r = t3_period;
 
 if (r < 1) r = 1;
 r = 1 + 0.5 * (r - 1);
 w1 = 2 / (r + 1);
 w2 = 1 - w1;

 /*======================*/
 /* Begin Pre-Loop Setup */
 /*======================*/
 //Check for additional bars loading or total reloadng.
 if (Bars < prevBars || Bars - prevBars > 1) is_First = True;
 prevBars = Bars;

 //Have any Inputs changed?
 CheckSum = TTF + barBegin;   
 
 if (CheckSum != CheckSumPrev) is_First = True;
 CheckSumPrev = CheckSum;
 //--------------------------------------------------------------------

 if (is_First)
  {/*This block executes ONLY First Time for each Attachment-To-Chart. If MT is closed or another Profile is selected, 
   the values & parameters for this module are saved, and when MT or this Profile is restarted, it would not be the First  
   Time Attachment-To-Chart. So this block would not execute unless the value of "Bars" has changed. */
   int SetLoopCount=0;
   
   /*==============*/
   /* Check Inputs */
   /*==============*/
   if (0 > TTFbars || TTFbars > 299)
    { 
     Msg = IndicatorName + " **Input Error** :" + " TTFbars must be between 0 and 300. Cannot=" + TTFbars;
     Alert(Msg);
     return(0);
    }
    
   //BarIndexNumber=shift=Bars-1..0
   if (barBegin > 0 && barBegin < Bars - 1) {loopBegin = barBegin;} else {loopBegin = Bars - 1;} 
   
   /*===================================*/
   /* Specific for particular indicator */
   /*===================================*/
   loopBegin = loopBegin - TTFbars; //Cannot compute early bars
  	/* end Specific */
   
   is_First = False;
  }	
   
 /*======================*/
 /* end Pre-Loop Setup   */
 /*======================*/
 loopBegin = loopBegin + 1; //Replot previous bar
 m=0;ATTF[0]=0;  
 for (shift = loopBegin; shift>=0; shift--)
  {
   m=m+1;
   /*=================================*/
   /* Standard Specific Computations */
   /*=================================*/
   HighestHighRecent = High[Highest(Symbol(),0,MODE_HIGH,TTFbars,shift-TTFbars+1)]; 
   HighestHighOlder = High[Highest(Symbol(),0,MODE_HIGH,TTFbars,shift+1)];
   LowestLowRecent = Low [Lowest(Symbol(),0,MODE_LOW,TTFbars,shift-TTFbars+1)];
   LowestLowOlder = Low [Lowest(Symbol(),0,MODE_LOW,TTFbars,shift+1)];
   BuyPower = HighestHighRecent - LowestLowOlder;
   SellPower = HighestHighOlder - LowestLowRecent;
   TTF = (BuyPower - SellPower) / (0.5 * (BuyPower + SellPower)) * 100;
   e1 = w1 * TTF + w2 * e1;
   e2 = w1 * e1 + w2 * e2;
   e3 = w1 * e2 + w2 * e3;
   e4 = w1 * e3 + w2 * e4;
   e5 = w1 * e4 + w2 * e5;
   e6 = w1 * e5 + w2 * e6;
   
   TTF = c1 * e6 + c2 * e5 + c3 * e4 + c4 * e3;
   Buffer1[shift-1]=TTF;
   
   ATTF[m]=TTF;
   if(ATTF[m-1]<ATTF[m] && ATTF[m]<ppor && ATTF[m-1]>0) kb=0;
   if(ATTF[m-1]>ATTF[m] && ATTF[m]>mpor && ATTF[m-1]<0) ks=0;
   if(ATTF[m-1]<0 && ATTF[m]>0) ksb=0;
   if(ATTF[m-1]>0 && ATTF[m]<0) kss=0;
   //Dual value trigger +/-100
   if(ATTF[m-1]<mpor && ATTF[m]>mpor && kb==0)
    {kb=1; CreateArrow(Time[shift], Low[shift]-6*Point, 242, Gold);}
   if(((ATTF[m-1]>ppor && ATTF[m]<ppor) || (ATTF[m-1]>0 && ATTF[m]<0)) && ksb==0)
    {ksb=1; CreateArrow(Time[shift], High[shift], 159, Gold);}
   
   if(ATTF[m-1]>ppor && ATTF[m]<ppor && ks==0)
    {ks=1; CreateArrow(Time[shift], High[shift]+6*Point, 241, Aqua);}
   if(((ATTF[m-1]<mpor && ATTF[m]>mpor) || (ATTF[m-1]<0 && ATTF[m]>0)) && kss==0)
    {kss=1; CreateArrow(Time[shift], Low[shift], 159, Aqua);} 
   
   Comment("TTF=",TTF," ATTF[m]=",ATTF[m]," ATTF[m-1]=",ATTF[m-1]," kb=",kb," ksb=",ksb," ks=",ks," kss=",kss," m=",m);
   
   if (TTF >= 0) {Buffer2[shift-1]=ppor;} else {Buffer2[shift-1]=mpor;}
  }
  
 return(0);
}

