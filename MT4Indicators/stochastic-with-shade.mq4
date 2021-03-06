//+------------------------------------------------------------------+
//|                                        Stochastic_with_Shade.mq4 |
//|                      Copyright © 2004, MetaQuotes Software Corp. |
//|                                       http://www.metaquotes.net/ |
//+------------------------------------------------------------------+
//|                               The shade is added by Serega Lykov |
//|                                       http://mtexperts.narod.ru/ |
//+------------------------------------------------------------------+

#property copyright ""
#property link      ""

#property indicator_separate_window
#property indicator_minimum 0
#property indicator_maximum 100
#property indicator_buffers 5
#property indicator_color1 Green
#property indicator_color2 Red
#property indicator_color3 Black          // color of background
#property indicator_color4 LightSeaGreen
#property indicator_color5 Red

//---- input parameters
extern int KPeriod=5;
extern int DPeriod=3;
extern int Slowing=3;

//---- buffers
double MainBuffer[];
double SignalBuffer[];
double HighesBuffer[];
double LowesBuffer[];
double UpShadeBuffer[];
double DownShadeBuffer[];
double BackgroundBuffer[];
//----
int draw_begin1=0;
int draw_begin2=0;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   string short_name;
//---- 2 additional buffers are used for counting.
   IndicatorBuffers(7);
   SetIndexBuffer(5,HighesBuffer);
   SetIndexBuffer(6,LowesBuffer);
//---- indicator lines
   SetIndexStyle(0,DRAW_HISTOGRAM,STYLE_SOLID,2);
   SetIndexBuffer(0,UpShadeBuffer);
   SetIndexStyle(1,DRAW_HISTOGRAM,STYLE_SOLID,2);
   SetIndexBuffer(1,DownShadeBuffer);
   SetIndexStyle(2,DRAW_HISTOGRAM,STYLE_SOLID,2);
   SetIndexBuffer(2,BackgroundBuffer);
   SetIndexStyle(3,DRAW_LINE);
   SetIndexBuffer(3,MainBuffer);
   SetIndexStyle(4,DRAW_LINE);
   SetIndexBuffer(4,SignalBuffer);
//---- name for DataWindow and indicator subwindow label
   short_name = "Sto(" + KPeriod + "," + DPeriod + "," + Slowing + ")";
   IndicatorShortName(short_name);
   SetIndexLabel(0,short_name);
   SetIndexLabel(1,"Signal");
//----
   draw_begin1 = KPeriod + Slowing;
   draw_begin2 = draw_begin1 + DPeriod;
   SetIndexDrawBegin(0,draw_begin1);
   SetIndexDrawBegin(1,draw_begin2);
//----
   return(0);
  }

//+------------------------------------------------------------------+
//| Stochastic oscillator                                            |
//+------------------------------------------------------------------+
int start()
  {
   int    i,k;
   int    counted_bars = IndicatorCounted();
   double price;
//----
   if(Bars <= draw_begin2) return(0);
//---- initial zero
   if(counted_bars < 1)
     {
      for(i=1; i<=draw_begin1; i++) MainBuffer[Bars-i] = 0;
      for(i=1; i<=draw_begin2; i++) SignalBuffer[Bars-i] = 0;
     }
//---- minimums counting
   i = Bars - KPeriod;
   if(counted_bars > KPeriod) i = Bars - counted_bars - 1;
   while(i >= 0)
     {
      double min = 1000000;
      k = i + KPeriod - 1;
      while(k >= i)
        {
         price = Low[k];
         if(min > price) min = price;
         k--;
        }
      LowesBuffer[i] = min;
      i--;
     }
//---- maximums counting
   i = Bars - KPeriod;
   if(counted_bars > KPeriod) i = Bars - counted_bars - 1;
   while(i >= 0)
     {
      double max = -1000000;
      k = i + KPeriod - 1;
      while(k >= i)
        {
         price = High[k];
         if(max < price) max = price;
         k--;
        }
      HighesBuffer[i] = max;
      i--;
     }
//---- %K line
   i = Bars - draw_begin1;
   if(counted_bars > draw_begin1) i = Bars - counted_bars - 1;
   while(i >= 0)
     {
      double sumlow = 0.0;
      double sumhigh = 0.0;
      for(k=(i + Slowing - 1); k>=i; k--)
        {
         sumlow += Close[k] - LowesBuffer[k];
         sumhigh += HighesBuffer[k] - LowesBuffer[k];
        }
      if(sumhigh == 0.0) MainBuffer[i] = 100.0;
      else MainBuffer[i] = sumlow / sumhigh * 100;
      i--;
     }
//---- last counted bar will be recounted
   if(counted_bars > 0) counted_bars--;
   int limit = Bars - counted_bars;
//---- signal line is simple movimg average
   for(i=0; i<limit; i++)
     {
      SignalBuffer[i] = iMAOnArray(MainBuffer,Bars,DPeriod,0,MODE_SMA,i);
      if(SignalBuffer[i] > MainBuffer[i])
        {
         UpShadeBuffer[i] = EMPTY_VALUE;
         DownShadeBuffer[i] = SignalBuffer[i];
         BackgroundBuffer[i] = MainBuffer[i];
        }
      else if(SignalBuffer[i] < MainBuffer[i])
             {
              UpShadeBuffer[i] = MainBuffer[i];
              DownShadeBuffer[i] = EMPTY_VALUE;
              BackgroundBuffer[i] = SignalBuffer[i];
             }
           else
             {
              UpShadeBuffer[i] = EMPTY_VALUE;
              DownShadeBuffer[i] = EMPTY_VALUE;
              BackgroundBuffer[i] = EMPTY_VALUE;
             }
     }   
//----
   return(0);
  }
//+------------------------------------------------------------------+