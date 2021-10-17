//+------------------------------------------------------------------+
//|                                                        iWPR+.mq4 |
//|                   Copyright 2005-2019, MetaQuotes Software Corp. |
//|                                              http://www.mql4.com |
//|                                              http://www.mql5.com |
//|                              https://www.mql5.com/en/users/3rjfx |
//+------------------------------------------------------------------+
#property copyright   "2005-2019, MetaQuotes Software Corp. ~ By 3rjfx ~ Created: 26/12/2019"
#property link        "http://www.mql4.com"
#property link        "http://www.mql5.com"
#property link        "https://www.mql5.com/en/users/3rjfx"
#property version     "1.00"
#property description "iWPR+ is an iWPR %Range function with a positive value."
#property description "Because I don't like the negative value of the iWPR function."
#property strict
/*Update to remove bar errors.*/
//---
#property indicator_separate_window
#property indicator_minimum    0
#property indicator_maximum    100
#property indicator_buffers    1
#property indicator_color1     clrRed
#property indicator_level1     20.0
#property indicator_level2     80.0
#property indicator_levelcolor clrSilver
#property indicator_levelstyle STYLE_SOLID
//---
//--- input parameters
input int          InpPeriod = 14; // iWPR+ Period
//--- buffers
double WPRBuffer[];
double RANGE[];
int draw_begin;
#define DATA_LIMIT  100
//---------//
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   string short_name;
   draw_begin=InpPeriod+1;
//---
   IndicatorBuffers(1);
   SetIndexBuffer(0,WPRBuffer);
//--- indicator lines
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,WPRBuffer);
   SetIndexDrawBegin(0,draw_begin);
//--- name for DataWindow and indicator subwindow label
   short_name="iWPR+%R("+IntegerToString(InpPeriod)+")";
   IndicatorShortName(short_name);
   SetIndexLabel(0,short_name);
   IndicatorDigits(2);
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
    int i,limit,barc;
//--- check for rates total
   if(rates_total<DATA_LIMIT)
      return(0);
//--- last counted bar will be recounted
   limit=rates_total-prev_calculated;
   if(limit==0) limit=DATA_LIMIT;
   if(prev_calculated>0) limit++;
   barc=limit-InpPeriod-2;
   //--
   ArrayResize(WPRBuffer,limit);
   ArrayResize(RANGE,limit);
   ArraySetAsSeries(WPRBuffer,true);
   ArraySetAsSeries(RANGE,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(time,true);
   //--
   for(i=barc; i>=0; i--)
     {
       double RHigh=high[ArrayMaximum(high,InpPeriod,i)];
       double RLow=low[ArrayMinimum(low,InpPeriod,i)];
       RANGE[i]=(RHigh-close[i])/(RHigh-RLow)*100;
       WPRBuffer[i]=fabs(100-RANGE[i]);
     }
   //---
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+