//+------------------------------------------------------------------+
//|                                        MACD-Crossover_Signal.mq4 |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2007, Robert Hill)"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 SpringGreen
#property indicator_color2 Red

double CrossUp[];
double CrossDown[];
extern int FastEMA=12;
extern int SlowEMA=26;
extern int SignalSMA=9;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0, DRAW_ARROW, EMPTY);
   SetIndexArrow(0, 233);
   SetIndexBuffer(0, CrossUp);
   SetIndexStyle(1, DRAW_ARROW, EMPTY);
   SetIndexArrow(1, 234);
   SetIndexBuffer(1, CrossDown);
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
int start() {
   int limit, i, counter;
   double MACD_Main, MACD_Signal, MACD_MainPrevious, MACD_SignalPrevious;
   double Range, AvgRange;
   int counted_bars=IndicatorCounted();
//---- check for possible errors
   if(counted_bars<0) return(-1);
//---- last counted bar will be recounted
   if(counted_bars>0) counted_bars--;

   limit=Bars-counted_bars;
   
   for(i = 0; i <= limit; i++) {
   
      counter=i;
      Range=0;
      AvgRange=0;
      for (counter=i ;counter<=i+9;counter++) {
         AvgRange=AvgRange+MathAbs(High[counter]-Low[counter]);
      }
      Range=AvgRange/10;
       
      MACD_Main = iMACD(NULL, 0, FastEMA, SlowEMA, SignalSMA, PRICE_CLOSE, MODE_MAIN, i);
      MACD_MainPrevious = iMACD(NULL, 0, FastEMA, SlowEMA, SignalSMA, PRICE_CLOSE, MODE_MAIN, i+1);
      MACD_Signal = iMACD(NULL, 0, FastEMA, SlowEMA, SignalSMA, PRICE_CLOSE, MODE_SIGNAL, i);
      MACD_SignalPrevious = iMACD(NULL, 0, FastEMA, SlowEMA, SignalSMA, PRICE_CLOSE, MODE_SIGNAL, i+1);

      
      if ((MACD_Signal < MACD_Main) && (MACD_SignalPrevious > MACD_MainPrevious)) {
         CrossUp[i] = Low[i] - Range*0.5;
      }
      else if ((MACD_Signal > MACD_Main) && (MACD_SignalPrevious < MACD_MainPrevious)) {
         CrossDown[i] = High[i] + Range*0.5;
      }
   }
   return(0);
}

