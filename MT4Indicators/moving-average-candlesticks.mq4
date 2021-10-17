//+------------------------------------------------------------------+
//|                                              MA-Candlesticks.mq4 |
//| 				                      Copyright © 2010, EarnForex.com |
//|                                        http://www.earnforex.com/ |
//+------------------------------------------------------------------+
#property copyright "EarnForex.com"
#property link      "http://www.earnforex.com"

/* 
   Displays the moving average in form of the candlesticks.
   This way, the moving average is shown for Close, Open, High and Low.
   
   Works with any trading instrument, timeframe, period and MA type.
*/

#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 Yellow
#property indicator_color2 Blue
#property indicator_color3 Yellow
#property indicator_color4 Blue
#property indicator_width1 1
#property indicator_width2 1
#property indicator_width3 3
#property indicator_width4 3

//----
extern color color1 = Yellow;
extern color color2 = Blue;
extern color color3 = Yellow;
extern color color4 = Blue;

extern int     MAPeriod   = 10;
extern string  strType    = "Moving Average Types:";
extern string  strm0      = "0 = SMA,  1 = EMA";
extern string  strm1      = "2 = SMMA, 3 = LWMA";
extern int     MAType     = 0;

//---- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
double ExtMapBuffer3[];
double ExtMapBuffer4[];

//----
int ExtCountedBars = 0;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//|------------------------------------------------------------------|
int init()
{
//---- indicators
   SetIndexStyle(0, DRAW_HISTOGRAM, 0, 1, color1);
   SetIndexBuffer(0, ExtMapBuffer1);
   SetIndexStyle(1, DRAW_HISTOGRAM, 0, 1, color2);
   SetIndexBuffer(1, ExtMapBuffer2);
   SetIndexStyle(2, DRAW_HISTOGRAM, 0, 3, color3);
   SetIndexBuffer(2, ExtMapBuffer3);
   SetIndexStyle(3, DRAW_HISTOGRAM, 0, 3, color4);
   SetIndexBuffer(3, ExtMapBuffer4);

//----
   SetIndexDrawBegin(0, MAPeriod);
   SetIndexDrawBegin(1, MAPeriod);
   SetIndexDrawBegin(2, MAPeriod);
   SetIndexDrawBegin(3, MAPeriod);

//---- indicator buffers mapping
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexBuffer(1,ExtMapBuffer2);
   SetIndexBuffer(2,ExtMapBuffer3);
   SetIndexBuffer(3,ExtMapBuffer4);

   IndicatorShortName("MA-Candlesticks(" + MAPeriod + ")");

//---- initialization done
   return(0);
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
{
   double MAOpen, MAHigh, MALow, MAClose;

   if(Bars <= (MAPeriod)) return(0);
   ExtCountedBars = IndicatorCounted();

//---- check for possible errors
   if (ExtCountedBars<0) return(-1);

//---- last counted bar will be recounted
   if (ExtCountedBars>0) ExtCountedBars--;

   int pos = Bars - ExtCountedBars - 1;

   while(pos >= 0)
   {
      MAClose = iMA(NULL, 0, MAPeriod, 0, MAType, PRICE_CLOSE, pos);
      MAOpen = iMA(NULL, 0, MAPeriod, 0, MAType, PRICE_OPEN, pos);
      MAHigh = iMA(NULL, 0, MAPeriod, 0, MAType, PRICE_HIGH, pos);
      MALow = iMA(NULL, 0, MAPeriod, 0, MAType, PRICE_LOW, pos);
      
      if (MAClose > MAOpen)
      {
         ExtMapBuffer1[pos]=MALow;
         ExtMapBuffer2[pos]=MAHigh;
      }
      else
      {
         ExtMapBuffer1[pos]=MAHigh;
         ExtMapBuffer2[pos]=MALow;
      }
      ExtMapBuffer3[pos]=MAOpen;
      ExtMapBuffer4[pos]=MAClose;
 	   
 	   pos--;
   }

//----
   return(0);
}
//+------------------------------------------------------------------+