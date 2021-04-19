#include <candle.mqh>
#property copyright "Banik"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window

#property indicator_buffers 2

double buy_buffer[] , sell_buffer[];

int OnInit(){  
   SetIndexBuffer(0,buy_buffer);
   SetIndexStyle(0 , DRAW_ARROW , EMPTY , EMPTY , clrGreen);
   SetIndexArrow(0, 233);
   SetIndexLabel(0,"BULL");
   SetIndexBuffer(1,sell_buffer);
   SetIndexStyle(1,DRAW_ARROW , EMPTY , EMPTY , clrRed);
   SetIndexArrow(1,234);
   SetIndexLabel(1,"BEAR");
   return(INIT_SUCCEEDED);
}


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
   candle c1 , c2 , c3 ,c4,c5;
   for(int i = Bars - 5 - IndicatorCounted() ; i >-1; i--){
      c1.pos = i;
      c2.pos = i+1;
      c3.pos = i+2;
      c4.pos = i+3;
      c5.pos = i+4;
      if (c1.bull_bear() == 1)
         if (c2.bull_bear() == 1)
            if (c3.bull_bear() == 1)
               if (c4.bull_bear() ==1)
                  buy_buffer[c1.pos] = iLow(NULL ,0 ,c1.pos);
      if (c1.bull_bear() == -1)
         if (c2.bull_bear() == -1)
            if (c3.bull_bear() == -1)
               if (c4.bull_bear() == -1)
                  sell_buffer[c1.pos] = iHigh(NULL ,0 ,c1.pos);
   }
   
   return(rates_total);
}

