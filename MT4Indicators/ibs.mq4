//+------------------------------------------------------------------+
//|                                                          IBS.mq4 |
//|                                                             Rosh |
//|               http://www.investo.ru/forum/viewtopic.php?t=127513 |
//+------------------------------------------------------------------+
#property copyright "Rosh"
#property link      "http://www.investo.ru/forum/viewtopic.php?t=127513"

#property indicator_separate_window
#property indicator_minimum 0
#property indicator_maximum 100
#property indicator_buffers 1
#property indicator_color1 Red
#property indicator_level1 40
#property indicator_level2 60

//---- input parameters
extern int       Per=5;
//---- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   IndicatorBuffers(2);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexBuffer(1,ExtMapBuffer2);
   IndicatorShortName("IBS("+Per+")");
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
//----
   int i,limit;
   if (counted_bars==0) limit=Bars-1;
   if (counted_bars>0) limit=Bars-counted_bars;
   double delitel;
   limit--;
   for (i=limit;i>=0;i--)
      {
      delitel=High[i]-Low[i];
      if (delitel>0)  ExtMapBuffer2[i]=(Close[i]-Low[i])/delitel;
      else ExtMapBuffer2[i]=0.0;
      }
   for (i=limit;i>=0;i--)
      {
      ExtMapBuffer1[i]=iMAOnArray(ExtMapBuffer2,0,Per,0,MODE_SMA,i)*100.0;
      }
       
//----
   return(0);
  }
//+------------------------------------------------------------------+