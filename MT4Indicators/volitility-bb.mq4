//+------------------------------------------------------------------+
//|                                                Volitility_BB.mq4 |
//|                                                      nicholishen |
//|                            http://www.reddit.com/u/nicholishenFX |
//+------------------------------------------------------------------+
#property copyright ""
#property link      ""
#property version   "1.00"
#property strict
#property indicator_separate_window
#property indicator_buffers 1
#property indicator_plots   1
//--- plot Percent
#property indicator_label1  "Percent"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrOrangeRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
#property indicator_maximum 1.1
#property indicator_minimum -0.1
#property indicator_level1  1.0
#property indicator_level2  0.0
#property indicator_levelcolor clrSilver
#property indicator_levelstyle STYLE_DOT
//--- input parameters
input int      bb_period=100;//Bands Period
//--- indicator buffers
double         Buffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
//--- indicator buffers mapping
   SetIndexBuffer(0,Buffer);
   
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
   int total = rates_total - prev_calculated <= 1 ? 1 : rates_total - bb_period -1;
   for(int i=total;i>=0;i--)
   {
      double max=DBL_MIN_10_EXP,min=DBL_MAX,curr=0;
      for(int j=i;j<i+bb_period;j++)
      {
         double width = bands(MODE_UPPER,j) - bands(MODE_LOWER,j);
         if(j==i)
            curr = width;
         if(width < min)
            min=width;
         if(width > max)
            max=width;
      }
      double range = max - min;
      double delta = curr - min;
      double perc  = delta / range;
      Buffer[i] = perc;
      
   }
//--- return value of prev_calculated for next call
   return(rates_total);
}
//+------------------------------------------------------------------+

double bands(const int mode,const int shift)
{
   return iBands(Symbol(),Period(),bb_period,2.0,0,PRICE_CLOSE,mode,shift);
}