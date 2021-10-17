//+------------------------------------------------------------------+
//|                                                          KVO.mq4 |
//|                                         Copyright © 2009, LeMan. |
//+------------------------------------------------------------------+
#property copyright ""
#property link      ""

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Silver
#property indicator_color2 Red
//---- input parameters
extern int       FastEMA = 34;
extern int       SlowEMA = 55;
extern int       SignalEMA = 13;
//---- buffers
double MainBuffer[];
double SignalBuffer[];
double v[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   IndicatorBuffers(3);
   SetIndexStyle(0, DRAW_HISTOGRAM);
   SetIndexStyle(1, DRAW_LINE);   
   SetIndexBuffer(0, MainBuffer);
   SetIndexBuffer(1, SignalBuffer);
   SetIndexBuffer(2, v);
   IndicatorShortName("KVO ("+FastEMA+","+SlowEMA+","+SignalEMA+") ");
   SetIndexLabel(0,"Main");
   SetIndexLabel(1,"Signal");   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
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
//----  
   int  i, limit, counted = IndicatorCounted();
   double tpc, tpp;
//---- last counted bar will be recounted
   if (counted > 0) {
      counted--;
   }
   limit = Bars - counted;   
//----
   for (i = limit; i >= 0; i--) {
      tpc = (High[i] + Low[i] + Close[i])/3;
      tpp = (High[i+1] + Low[i+1] + Close[i+1])/3;
      if (tpc > tpp) {
         v[i] = Volume[i];
      }
      if (tpc < tpp) {
         v[i] = -Volume[i];
      }
      if (tpc == tpp) {
         v[i] = 0.0;
      }
      
                              
   }
   for (i = limit; i >= 0; i--) {
      MainBuffer[i] = iMAOnArray(v, 0, FastEMA, 0, MODE_EMA, i) - iMAOnArray(v, 0, SlowEMA, 0, MODE_EMA, i);
   }
   for (i = limit; i >= 0; i--) {
      SignalBuffer[i] = iMAOnArray(MainBuffer, 0, SignalEMA, 0, MODE_EMA, i);
   }   
//----
   return(0);
  }
//+------------------------------------------------------------------+