#property copyright "Banik"

#property strict
#property indicator_chart_window

#property indicator_buffers 4
#property indicator_color1 clrRed
#property indicator_color2 clrRed
#property indicator_color3 clrGreen
#property indicator_color4 clrGreen
#property indicator_width1 3
#property indicator_width2 3
#property indicator_width3 3
#property indicator_width4 3

double point_1[] , point_2[] , point_3[] , point_4[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
      SetIndexBuffer(0 , point_1);
      SetIndexBuffer(1,point_2);
      SetIndexBuffer(2,point_3);
      SetIndexBuffer(3,point_4);
      SetIndexStyle(0 , DRAW_HISTOGRAM);
      SetIndexStyle(1, DRAW_HISTOGRAM);
      SetIndexStyle(2, DRAW_HISTOGRAM);
      SetIndexStyle(3, DRAW_HISTOGRAM);
      

   
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
      for (int i = MathMax(Bars -2 - IndicatorCounted(),1) ; i > -1 ; i--)
      {
        double dif = MathAbs(Open[i] - Close[i]);
        double prev_dif = MathAbs(Open[i+1] - Close[i+1]);
        
        if (dif > 3*prev_dif && Open[i] > Close[i] && High[i] > High[i-1] && Low [i-1] > Low[i])
        {
            point_1[i] = Open[i];
            point_2[i] = Close[i];
        }
        if (dif > 3*prev_dif && Open[i] < Close[i] && High[i] > High[i-1] && Low [i-1] > Low[i])
        {
            point_3[i] = Open[i];
            point_4[i] = Close[i];
        } 
      }
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
