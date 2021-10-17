//+------------------------------------------------------------------+
//|                                                    3rdCandle.mq4 |
//|                                                         CommGrow |
//|                                            http://www.google.com |
//+------------------------------------------------------------------+
#property copyright ""
#property link      ""
#property indicator_buffers 2
#property indicator_color1 Blue
#property indicator_color2 Red
#property indicator_width1 2
#property indicator_width2 2
#property indicator_chart_window

double UpArrow[];
double DownArrow[];
extern int ShiftArrow = -2;
extern bool FilterBullBearCandle = false;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0, DRAW_ARROW, EMPTY,2);
   SetIndexArrow(0, 233);
   SetIndexBuffer(0, UpArrow);
   SetIndexEmptyValue(0,0.0);
   SetIndexShift(0,ShiftArrow);
   SetIndexStyle(1, DRAW_ARROW, EMPTY,2);
   SetIndexArrow(1, 234);
   SetIndexBuffer(1, DownArrow);
   SetIndexEmptyValue(1,0.0);
   SetIndexShift(1,ShiftArrow);
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
   int    counted_bars=IndicatorCounted();
   int limit, i, counter;
   if(counted_bars<0) return(-1);
//---- last counted bar will be recounted
   if(counted_bars>0) counted_bars--;

   limit=Bars-counted_bars;
//----
    for(i = 0; i <= limit; i++) {
      DownArrow[i] = 0;
      UpArrow[i] = 0;
   if(High[i+2]>High[i+1] && Low[i+2]>Low[i+1] && High[i+2]>High[i+3] && Low[i+2]>Low[i+3])
      if( Open[i+1]>Close[i+1] && Close[i+2] > Close[i+1])
         if(FilterBullBearCandle)
            {
               if( Open[i+2]>Close[i+2])
                  DownArrow[i] = High[i+2] +0.0003;//Low[i+2] + (High[i+2]-Low[i+2]);
             }
         else
             DownArrow[i] = High[i+2] +0.0003;//Low[i+2] + (High[i+2]-Low[i+2]);
   if(High[i+2]<High[i+1] && Low[i+2]<Low[i+1] && High[i+2]<High[i+3] && Low[i+2]<Low[i+3])
      if( Open[i+1]<Close[i+1] && Close[i+2] < Close[i+1])
          if(FilterBullBearCandle)
            {
               if( Open[i+2]<Close[i+2] ) 
                  UpArrow[i] = Low[i+2] - 0.0003;//High[i+2] - (High[i+2]-Low[i+2]);
            }
         else
            UpArrow[i] = Low[i+2] - 0.0003;//High[i+2] - (High[i+2]-Low[i+2]);
      }
//----
   return(0);
  }
//+-------------------------------------&-----------------------------+