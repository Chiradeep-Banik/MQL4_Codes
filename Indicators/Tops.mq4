//+------------------------------------------------------------------+
//|                                                         Tops.mq4 |
//|                                                            Banik |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Banik"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window

#property indicator_buffers 2

double top[];
double bottoms[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping

      SetIndexBuffer(0 , top);
      SetIndexStyle(0 , DRAW_LINE , STYLE_SOLID , 1, clrBlueViolet);
      SetIndexBuffer(1 , bottoms);
      SetIndexStyle(1 , DRAW_LINE , STYLE_SOLID , 1, clrBlueViolet);
   
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
   for (int i = Bars-1-IndicatorCounted() ; i > -1 ; i--)
   {
      top[i] = High[i];
      bottoms[i] = Low[i];
   }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
