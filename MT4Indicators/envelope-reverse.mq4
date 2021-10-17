//+------------------------------------------------------------------+
//|                                           #Reverse#Envelope#.mq4 |
//|                                  Copyright 2015, BestXerof Corp. |
//|                                              bestxerof@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, BestXerof Corp."
#property link      "bestxerof@gmail.com"
#property version   "1.00"
#property strict
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 White
#property indicator_width1  1
#property indicator_color2 Black
#property indicator_width2  1

#define SIGNAL_BAR 1

input int  EnvelopePeriod = 8;    // Период индикатора Envelopes
input bool UseAlert       = false;// Использовать сигнал

double up_buffer[],dn_buffer[];

static int prev_time = 0;
static int prev_sign = 0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0,up_buffer);
   SetIndexBuffer(1,dn_buffer);

   SetIndexStyle(0,DRAW_ARROW);
   SetIndexArrow(0,233);
   SetIndexStyle(1,DRAW_ARROW);
   SetIndexArrow(1,234);

   SetIndexEmptyValue(0,0.0);
   SetIndexEmptyValue(1,0.0);

   SetIndexLabel(0,"Buy");
   SetIndexLabel(1,"Sell");

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
   ObjectsDeleteAll();

   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   RefreshRates();

   int limit=100000;
   int i,counted_bars=IndicatorCounted();

   i=Bars-counted_bars-1;

   if(i>limit-1)
      i=limit-1;

   while(i>=0)
     {
      up_buffer[i]= 0;
      dn_buffer[i]= 0;

      double low_envel = iEnvelopes(Symbol(), 0, EnvelopePeriod, MODE_LWMA, 8, PRICE_MEDIAN, 0.10, MODE_LOWER, i);
      double hi_envel  = iEnvelopes(Symbol(), 0, EnvelopePeriod, MODE_LWMA, 8, PRICE_MEDIAN, 0.10, MODE_UPPER, i);

      if(Open[i]<low_envel && Close[i]>low_envel)
        {
         up_buffer[i]=Low[i]-30*MarketInfo(Symbol(),MODE_POINT);
        }

      if(Open[i]>hi_envel && Close[i]<hi_envel)
        {
         dn_buffer[i]=High[i]+30*MarketInfo(Symbol(),MODE_POINT);
        }

      i--;
     }

// USE ALERT

   if(SIGNAL_BAR>0 && Time[0]<=prev_time)
      return(0);

   prev_time=(int)Time[0];

   if(prev_sign<=0 && UseAlert==true)
     {
      if(Close[SIGNAL_BAR]-up_buffer[SIGNAL_BAR]>0)
        {
         prev_sign=1;
         Alert("Signal (",Symbol(),", M",Period(),")  -  BUY!!!");
        }
     }
   if(prev_sign>=0 && UseAlert==true)
     {
      if(dn_buffer[SIGNAL_BAR]-Close[SIGNAL_BAR]>0)
        {
         prev_sign=-1;
         Alert("Signal (",Symbol(),", M",Period(),")  -  SELL!!!");
        }
     }
   return(0);
  }
//+------------------------------------------------------------------+
