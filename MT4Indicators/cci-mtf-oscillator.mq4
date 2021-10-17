//+------------------------------------------------------------------+
//|                                                      CCI_MTF.mq4 |
//|                            Copyright © 2013. All rights reserved |
//|                        http://www.best-metatrader-indicators.com |
//+------------------------------------------------------------------+
#property copyright "CCI_MTF"
#property link      "http://www.best-metatrader-indicators.com"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Tomato
#property indicator_level1 0.000000
//---- input parameters
extern string TimeFrameNote="TimeFrame =0 - Current Timeframe, =1 - 1MIN, =5 - 5MIN, =5 - 5MIN, =15 - 15MIN, =30 - 30MIN, =60 - 1H, =240 - 4H, =1440 - D1, =10080 - W1, =43200 - MN1";
extern int TimeFrame=0;
extern int    Periods=12;
double ExtMapBuffer1[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicator line
   SetIndexStyle(0,DRAW_LINE,EMPTY,1);
   SetIndexBuffer(0,ExtMapBuffer1);
//---- name for DataWindow and indicator subwindow label   
   switch(TimeFrame)
     {
      case 1 : string TimeFrameStr="Period_M1"; break;
      case 5 : TimeFrameStr="Period_M5"; break;
      case 15 : TimeFrameStr="Period_M15"; break;
      case 30 : TimeFrameStr="Period_M30"; break;
      case 60 : TimeFrameStr="Period_H1"; break;
      case 240 : TimeFrameStr="Period_H4"; break;
      case 1440 : TimeFrameStr="Period_D1"; break;
      case 10080 : TimeFrameStr="Period_W1"; break;
      case 43200 : TimeFrameStr="Period_MN1"; break;
      default : TimeFrameStr="Current Timeframe";
     }
   IndicatorShortName(" CCI MTF ( "+TimeFrameStr+" ) ");
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   datetime TimeArray[];
   int    i,limit,y=0,counted_bars=IndicatorCounted();
   // Plot defined time frame on to current time frame
   ArrayCopySeries(TimeArray,MODE_TIME,Symbol(),TimeFrame);
   limit= Bars-1;
   for(i=0,y=0;i<limit;i++)
     {
      if (Time[i]<TimeArray[y]) y++;
      ExtMapBuffer1[i]=iCCI(Symbol(),TimeFrame,Periods,PRICE_CLOSE,y);
     }
   return(0);
  }
//+------------------------------------------------------------------+