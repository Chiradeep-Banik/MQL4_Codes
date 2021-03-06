//+------------------------------------------------------------------+
//|                                      MACDBars.mq4 modified from  |
//|                                              mtt-ErgodicMACD.mq4 |
//|                   Copyright © 2004-07, MetaQuotes Software Corp. |
//|                                       http://www.metaquotes.net/ |
//+------------------------------------------------------------------+
#property  copyright ""
#property  link      ""
//---- indicator settings
#property  indicator_separate_window
#property  indicator_buffers 2
#property  indicator_color1  DarkGreen
#property  indicator_color2  Red
#property indicator_width1 4
#property indicator_width2 4
#property  indicator_minimum 0
#property  indicator_maximum 1

// MACD
extern int FastEma = 12;
extern int SlowEma = 26;
extern int SignalSMMA = 9;
extern string note1 = "0=Close,1=Open,2=High,3=Low";
extern string note2 = "4=Median Price,5=Typical Price";
extern string note3 = "6=Weighted Price";
extern int PriceField = 0;
extern string note4 = "Numbers of bars to calculate";
extern int MaxBars=392; 

//---- indicator buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   
//---- drawing settings

   SetIndexStyle(0,DRAW_HISTOGRAM,STYLE_SOLID,4,indicator_color1);
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexLabel(0,"BuyZone");
   
   SetIndexStyle(1,DRAW_HISTOGRAM,STYLE_SOLID,4,indicator_color2);
   SetIndexBuffer(1,ExtMapBuffer2);
   SetIndexLabel(1,"SellZone");
   
//---- name for DataWindow and indicator subwindow label

   string shortName = "MACD ("+FastEma+","+SlowEma+","+SignalSMMA+")";
   IndicatorShortName(shortName);   
//---- initialization done
   return(0);
  }
//+------------------------------------------------------------------+
//| Calculations                                    |
//+------------------------------------------------------------------+
int start()
  {
   int limit;
   
   int counted_bars=IndicatorCounted();
//---- check for possible errors
   if(counted_bars<0) return(-1);
//---- last counted bar will be recounted
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
   if(limit>MaxBars) limit=MaxBars;
 
//---- main loop
   
for(int i=0; i<limit; i++)
{
ExtMapBuffer1[i] = 0; ExtMapBuffer2[i] = 0;
/*
double indMacdMain0 = iCustom(NULL, 0,"MACDsmoothed", FastEma, SlowEma, SignalSMMA, 0, i);
double indMacdMain1 = iCustom(NULL, 0, "MACDsmoothed", FastEma, SlowEma, SignalSMMA, 0, i+1);
double indMacdSignal0 = iCustom(NULL, 0, "MACDsmoothed",FastEma, SlowEma, SignalSMMA, 1, i);
double indMacdSignal1 = iCustom(NULL, 0, "MACDsmoothed",FastEma, SlowEma, SignalSMMA, 1, i+1);
*/
double indMacdMain0 = iMACD(NULL,0,FastEma, SlowEma, SignalSMMA,PriceField,0,i);
double indMacdMain1 = iMACD(NULL,0,FastEma, SlowEma, SignalSMMA,PriceField,0,i+1);
double indMacdSignal0 = iMACD(NULL,0,FastEma, SlowEma, SignalSMMA,PriceField,1,i);
double indMacdSignal1 = iMACD(NULL,0,FastEma, SlowEma, SignalSMMA,PriceField,1,i+1);
   
if (indMacdMain0 > indMacdSignal0) ExtMapBuffer1[i]=2;
else if (indMacdMain0 < indMacdSignal0 ) ExtMapBuffer2[i]=2;
}
return(0);
  }
//+------------------------------------------------------------------+

