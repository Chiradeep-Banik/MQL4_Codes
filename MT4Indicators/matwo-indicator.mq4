//+------------------------------------------------------------------+
//|                                                        MATWO.mq4 |
//|                               Copyright © 2006, Виктор Чеботарёв |
//|                                      http://www.chebotariov.com/ |
//+------------------------------------------------------------------+
#property copyright ""
#property link      ""

extern int PERIOD = 8;

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Gray
#property indicator_color2 Red
//---- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   IndicatorShortName("MATWO");
//---- indicators
   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,ExtMapBuffer2);

//----
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
   int i,counted_bars=IndicatorCounted();
//----
   i=Bars-counted_bars-1;

   while(i>=0)
     {
      double MA_Blue = iMA(NULL,0,PERIOD,0,MODE_SMA,PRICE_WEIGHTED,i);
      double MA_Red = iMA(NULL,0,PERIOD,0,MODE_EMA,PRICE_CLOSE,i);
      double MA_Blue2 = iMA(NULL,0,PERIOD*2,0,MODE_SMA,PRICE_WEIGHTED,i);
      double MA_Red2 = iMA(NULL,0,PERIOD*2,0,MODE_EMA,PRICE_CLOSE,i);

      ExtMapBuffer1[i]=((MA_Red2-MA_Blue2)+(MA_Red-MA_Blue))*1000000;
      ExtMapBuffer2[i]=(MA_Red-MA_Blue)*1000000;
      i--;
     }
//----
   return(0);
  }
//+------------------------------------------------------------------+