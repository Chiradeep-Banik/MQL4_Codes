//+------------------------------------------------------------------+
//|                                                    Delta RSI.mq4 |
//|                                              Copyright 2015, Tor |
//+------------------------------------------------------------------+
#property version   "1.00"
#property strict
#property indicator_buffers 6
#property indicator_plots   6
#property indicator_separate_window

input int RSIPeriod1 = 14; // Fast RSI Period
input int RSIPeriod2 = 50; // Slow RSI Period
input int Level=50; // Signal Level
input int bar=0; // Bar
input color activeUp=clrRed; // OverBuy Color
input color activeDown=clrGreen; // OverSell Color
input color passive=clrGray; // No Signal Color
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum TypeGraph
  {
   Histogram=0,// Full Histogram
   Cute=1,// Cute Histogram
  };
//--- input parameters
input TypeGraph TypeGr=Histogram; // Type graph

double rsi1[];
double rsi2[];
double delta[];
double UP[];
double Down[];
double Pass[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,rsi1);
   SetIndexBuffer(1,rsi2);
   SetIndexBuffer(2,delta);
   SetIndexBuffer(3,UP);
   SetIndexBuffer(4,Down);
   SetIndexBuffer(5,Pass);
   IndicatorShortName("Delta RSI");
   SetIndexStyle(0,DRAW_NONE,STYLE_SOLID,1,clrYellow);
   SetIndexStyle(1,DRAW_NONE,STYLE_SOLID,1,clrOrange);
   if(TypeGr==1)
     {
      SetIndexStyle(2,DRAW_NONE,STYLE_SOLID,1,clrGray);
      SetIndexStyle(3,DRAW_HISTOGRAM,STYLE_SOLID,2,activeUp);
      SetIndexStyle(4,DRAW_HISTOGRAM,STYLE_SOLID,2,activeDown);
      SetIndexStyle(5,DRAW_HISTOGRAM,STYLE_SOLID,1,passive);
      IndicatorSetDouble(INDICATOR_MINIMUM,0);
      IndicatorSetDouble(INDICATOR_MAXIMUM,1);
        }else{
      SetIndexStyle(2,DRAW_LINE,STYLE_SOLID,1,clrGray);
      SetIndexStyle(3,DRAW_HISTOGRAM,STYLE_SOLID,2,activeUp);
      SetIndexStyle(4,DRAW_HISTOGRAM,STYLE_SOLID,2,activeDown);
      SetIndexStyle(5,DRAW_HISTOGRAM,STYLE_SOLID,1,passive);
     }
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---
   int limit;
   static bool alrt=false;
   static datetime altime=0;
   int maxLevel = 100-(100-Level);
   int minLevel = 100-Level;

//---
   if(rates_total<=1)
      return(0);
//--- last counted bar will be recounted
   limit=rates_total-prev_calculated;
   if(prev_calculated>0)
      limit=limit+1;

   for(int x=limit-1; x>=0; x--)
     {
      rsi1[x] = iRSI(Symbol(), 0, RSIPeriod1, PRICE_CLOSE, x+bar);
      rsi2[x] = iRSI(Symbol(), 0, RSIPeriod2, PRICE_CLOSE, x+bar);
      delta[x] = rsi1[x]-rsi2[x];
      if(TypeGr==1)
        {
         Pass[x]=1;
           }else{
         Pass[x]=delta[x];
        }
      if(rsi2[x]>maxLevel && rsi1[x]>rsi2[x])
        {
         if(TypeGr==1)
           {
            UP[x]=1;
              }else{
            UP[x]=delta[x];
           }
         Pass[x]=EMPTY_VALUE;
        }
      if(rsi2[x]<minLevel && rsi1[x]<rsi2[x])
        {
         if(TypeGr==1)
           {
            Down[x]=1;
              }else{
            Down[x]=delta[x];
           }
         Pass[x]=EMPTY_VALUE;
        }
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
