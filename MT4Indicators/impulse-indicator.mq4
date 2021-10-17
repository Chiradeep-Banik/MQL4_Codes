//+------------------------------------------------------------------+
//|                                                      eSignal.mq4 |
//|                               Copyright © 2007,  Hartono Setiono |
//|                                          http://www.mitrakom.com |
//+------------------------------------------------------------------+
#property copyright ""
#property link      ""

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Red
#property indicator_width1 3
#property indicator_color2 Green
#property indicator_width2 3
#property indicator_color3 DeepSkyBlue
#property indicator_width3 3
//---- input parameters
extern int       TimeFrame=0;
extern int       EMA_Period=13;
extern int       MACD_FastPeriod=12;
extern int       MACD_SlowPeriod=26;
extern int       MACD_SignalPeriod=9;
//---- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
double ExtMapBuffer3[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   string short_name;
   
//---- indicators
   SetIndexStyle(0,DRAW_HISTOGRAM);
   //SetIndexArrow(0,110);
   SetIndexBuffer(0,ExtMapBuffer1);
   
   SetIndexStyle(1,DRAW_HISTOGRAM);
   //SetIndexArrow(1,110);
   SetIndexBuffer(1,ExtMapBuffer2);
   
   SetIndexStyle(2,DRAW_HISTOGRAM);
   //SetIndexArrow(2,110);
   SetIndexBuffer(2,ExtMapBuffer3);

   switch(TimeFrame)
   {
      case 1 : short_name="Period_M1"; break;
      case 5 : short_name="Period_M5"; break;
      case 15 : short_name="Period_M15"; break;
      case 30 : short_name="Period_M30"; break;
      case 60 : short_name="Period_H1"; break;
      case 240 : short_name="Period_H4"; break;
      case 1440 : short_name="Period_D1"; break;
      case 10080 : short_name="Period_W1"; break;
      case 43200 : short_name="Period_MN1"; break;
      default : {short_name="Current Timeframe"; TimeFrame=0;}
   }
   short_name="Impulse Indicator("+short_name+", "+EMA_Period+":"+MACD_FastPeriod+","+MACD_SlowPeriod+","+MACD_SignalPeriod+")";

   IndicatorShortName(short_name);
   SetIndexLabel(1,NULL);
   SetIndexLabel(2,NULL);
   SetIndexLabel(3,NULL);
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
   int    i,limit,y=0,counted_bars=IndicatorCounted();
   double ema1, main1, signal1, ema0, main0, signal0;
 
   limit=Bars-counted_bars;
   for(i=0,y=0;i<limit;i++)
   {
      y = iBarShift(NULL,TimeFrame,Time[i]); 
      ema0=iMA(NULL,TimeFrame,EMA_Period,0,MODE_EMA,PRICE_CLOSE,y); 
      ema1=iMA(NULL,TimeFrame,EMA_Period,0,MODE_EMA,PRICE_CLOSE,y+1); 

      main0=iMACD(NULL, TimeFrame, MACD_FastPeriod, MACD_SlowPeriod, MACD_SignalPeriod, PRICE_CLOSE,0,y); 
      main1=iMACD(NULL, TimeFrame, MACD_FastPeriod, MACD_SlowPeriod, MACD_SignalPeriod, PRICE_CLOSE,0,y+1); 

      signal0=iMACD(NULL, TimeFrame, MACD_FastPeriod, MACD_SlowPeriod, MACD_SignalPeriod, PRICE_CLOSE,1,y); 
      signal1=iMACD(NULL, TimeFrame, MACD_FastPeriod, MACD_SlowPeriod, MACD_SignalPeriod, PRICE_CLOSE,1,y+1); 
      
      if(ema0<ema1 && main0<main1) //both down
      {
        ExtMapBuffer1[i]=1;
        ExtMapBuffer2[i]=0;
        ExtMapBuffer3[i]=0;
      } else
      if(ema0>ema1 && main0>main1) //both up
      {
        ExtMapBuffer1[i]=0;
        ExtMapBuffer2[i]=1;
        ExtMapBuffer3[i]=0;
      } else  //otherwise
      {
        ExtMapBuffer1[i]=0;
        ExtMapBuffer2[i]=0;
        ExtMapBuffer3[i]=1;
      }
   }
   return(0);
  }
//+------------------------------------------------------------------+