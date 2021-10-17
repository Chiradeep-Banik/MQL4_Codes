//+------------------------------------------------------------------+
//|                                           MACD with crossing.mq4 |
//|                      Copyright © 2004, MetaQuotes Software Corp. |
//|                                       http://www.metaquotes.net/ |
//+------------------------------------------------------------------+
#property  copyright ""
#property  link      ""
//---- indicator settings
#property  indicator_separate_window
#property  indicator_buffers 3
#property  indicator_color1  Gold
#property  indicator_color2  Red
#property  indicator_color3  Gray
#property  indicator_width1  2
//---- indicator parameters
extern int FastEMA=12;
extern int SlowEMA=26;
extern int SignalSMA=9;
//---- indicator buffers
double     MacdBuffer[];
double     SignalBuffer[];
double     HistogramBuffer[];
//---- globals
int        maxLines;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   SetIndexStyle(0,DRAW_LINE);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexStyle(2,DRAW_HISTOGRAM);
   //
   SetIndexBuffer(0,MacdBuffer);
   SetIndexBuffer(1,SignalBuffer);
   SetIndexBuffer(2,HistogramBuffer);
   //
   SetIndexLabel(0,"MACD");
   SetIndexLabel(1,"Signal");
   SetIndexLabel(2,"MACD-Signal");
   //
   SetIndexDrawBegin(1,SignalSMA);
   IndicatorDigits(Digits+1);
   IndicatorShortName("MACD("+FastEMA+","+SlowEMA+","+SignalSMA+")");
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int deinit()
  {
   DeleteLines();
   return(0);
  }
//+------------------------------------------------------------------+
//| Moving Averages Convergence/Divergence                           |
//+------------------------------------------------------------------+
int start()
  {
   double crossing;
   int limit,i;
   int counted_bars=IndicatorCounted();
//----
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
//----
   for(i=0; i<limit; i++) MacdBuffer[i]=iMA(NULL,0,FastEMA,0,MODE_EMA,PRICE_CLOSE,i)-iMA(NULL,0,SlowEMA,0,MODE_EMA,PRICE_CLOSE,i);
     for(i=0; i<limit; i++) 
     {
      SignalBuffer[i]=iMAOnArray(MacdBuffer,Bars,SignalSMA,0,MODE_SMA,i);
      HistogramBuffer[i]=MacdBuffer[i] - SignalBuffer[i];
     }
//----
   DeleteLines();
   for(i=WindowBarsPerChart(); i>0 ;i--)
     {
      crossing=(MacdBuffer[i]-SignalBuffer[i])*(MacdBuffer[i+1]-SignalBuffer[i+1]);
      if (crossing < 0)
        {
         maxLines+=1;
         ObjectCreate("MacdCross"+maxLines,0,0,Time[i],0);
         ObjectSet("MacdCross"+maxLines,OBJPROP_COLOR,DimGray);
         ObjectSet("MacdCross"+maxLines,OBJPROP_STYLE,STYLE_DOT);
        }
     }
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DeleteLines()
  {
   for(int i=1;i<=maxLines;i++) ObjectDelete("MacdCross"+i); maxLines=0;
  }
//+------------------------------------------------------------------+