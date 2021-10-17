//+------------------------------------------------------------------+
//|                                                     iMACross.mq4 |
//|                                Copyright © 2005, David W. Thomas |
//|                                Copyright © 2005, firedave - MOD  |
//|                                           mailto:davidwt@usa.net |
//|                                    mailto:firedave@fx-review.com |
//+------------------------------------------------------------------+
// This is the correct computation and display of MACD,
// that modified to a MA Cross Indicator
#property copyright "Copyright © 2005, Metaquotes"
#property link      "mailto:metaquotes@metaquotes.net"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Blue
#property indicator_color2 Blue


//---- input parameters
extern int       FastMAPeriod=4;
extern int       SlowMAPeriod=14;
extern int       FastMAType=1;
extern int       SlowMAType=1;

//---- buffers
double MACDLineBuffer[];
double SignalLineBuffer[];
int    FastMAMode;
int    SlowMAMode;
string strFastMAType;
string strSlowMAType;

//---- variables
double alpha = 0;
double alpha_1 = 0;
int    SignalMAPeriod = 1;




//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
switch (FastMAType)
   {
      case 1: strFastMAType="S"; FastMAMode=MODE_SMA; break;
      case 2: strFastMAType="E"; FastMAMode=MODE_EMA; break;
      case 3: strFastMAType="W"; FastMAMode=MODE_LWMA; break;
      default: strFastMAType="S"; FastMAMode=MODE_SMA; break;
   }

switch (SlowMAType)
   {
      case 1: strSlowMAType="S"; SlowMAMode=MODE_SMA; break;
      case 2: strSlowMAType="E"; SlowMAMode=MODE_EMA; break;
      case 3: strSlowMAType="W"; SlowMAMode=MODE_LWMA; break;
      default: strSlowMAType="S"; SlowMAMode=MODE_SMA; break;
   }


   IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS)+1);
   //---- indicators
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,MACDLineBuffer);
   SetIndexDrawBegin(0,SlowMAPeriod);
   SetIndexStyle(1,DRAW_LINE,STYLE_DOT);
   SetIndexBuffer(1,SignalLineBuffer);
   SetIndexDrawBegin(1,SlowMAPeriod+SignalMAPeriod);
   SetIndexDrawBegin(2,SlowMAPeriod+SignalMAPeriod);
   //---- name for DataWindow and indicator subwindow label
   IndicatorShortName("MA Cross ("+FastMAPeriod+"-"+strFastMAType+","+SlowMAPeriod+"-"+strSlowMAType+") ");
   SetIndexLabel(0,"DPO");
   SetIndexLabel(1,"Signal");
   SetLevelStyle(STYLE_DOT,1,Silver);
   SetLevelValue(0,0);
   
   //----
	alpha = 2.0 / (SignalMAPeriod + 1.0);
	alpha_1 = 1.0 - alpha;
   //----
   return(0);
}
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
{
   //---- 
   
   //----
   return(0);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
{
   int limit;
   int counted_bars = IndicatorCounted();
   //---- check for possible errors
   if (counted_bars<0) return(-1);
   //---- last counted bar will be recounted
   if (counted_bars>0) counted_bars--;
   limit = Bars - counted_bars;

   for(int i=limit; i>=0; i--)
   {
      MACDLineBuffer[i] = MathRound((iMA(NULL,0,FastMAPeriod,0,FastMAMode,PRICE_CLOSE,i) - iMA(NULL,0,SlowMAPeriod,0,SlowMAMode,PRICE_CLOSE,i))*10000);
      SignalLineBuffer[i] = alpha*MACDLineBuffer[i] + alpha_1*SignalLineBuffer[i+1];

   }
   
   //----
   return(0);
}
//+------------------------------------------------------------------+