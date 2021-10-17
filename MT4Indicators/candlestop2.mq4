/***************************
* File: CandleStop.mq4
* Author: CrushD
***************************/

#property copyright ""

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Magenta
#property indicator_color2 Lime

//---- input parameters
extern int TrailPeriods=5;

//---- buffers
double LongTrailBuffer[];
double ShortTrailBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_LINE, STYLE_DASH);
   SetIndexLabel(0, "Short Trail Stop");
   SetIndexBuffer(0,ShortTrailBuffer);
   SetIndexStyle(1,DRAW_LINE, STYLE_DASH);
   SetIndexLabel(1, "Long Trail Stop");
   SetIndexBuffer(1,LongTrailBuffer);
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
   int counted_bars=IndicatorCounted();
   int i;
   if(counted_bars>0) counted_bars--;
   int limit=Bars-counted_bars;

   for(i=0; i<=limit; i++)
   {
      //calc short stop
      //Highest High of last n periods
      ShortTrailBuffer[i] = High[Highest(NULL, 0, MODE_HIGH, TrailPeriods, i+TrailPeriods)];
      //calc long stop
      //Lowest Low of last n periods
      LongTrailBuffer[i] = Low[Lowest(NULL, 0, MODE_LOW, TrailPeriods, i+TrailPeriods)];

   }
   
   
//----
   return(0);
  }
//+------------------------------------------------------------------+