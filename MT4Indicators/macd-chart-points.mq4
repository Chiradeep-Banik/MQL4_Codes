//+------------------------------------------------------------------+
//|                                                  Custom MACD.mq4 |
//|                      Copyright © 2004, MetaQuotes Software Corp. |
//|                                       http://www.metaquotes.net/ |
//+------------------------------------------------------------------+
#property  copyright ""
#property  link      ""
//---- indicator settings
#property  indicator_chart_window
#property  indicator_buffers 4
#property  indicator_color1  Blue
#property  indicator_color2  Red
#property  indicator_color3  Blue
#property  indicator_color4  Red
//---- indicator parameters
extern int FastEMA=12;
extern int SlowEMA=26;
extern int SignalSMA=9;
//---- indicator buffers
double     ind_buffer1[];
double     ind_buffer2[];

double     ind_buffer3[];
double     ind_buffer4[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- drawing settings
   SetIndexStyle(0,DRAW_NONE);
   SetIndexStyle(1,DRAW_NONE);
   SetIndexDrawBegin(1,SignalSMA);
   IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS)+1);
//---- indicator buffers mapping
   if(!SetIndexBuffer(0,ind_buffer1) && !SetIndexBuffer(1,ind_buffer2))
      Print("cannot set indicator buffers!");

   SetIndexStyle(2, DRAW_ARROW, STYLE_SOLID, 0);
   SetIndexArrow(2, 108);
   SetIndexBuffer(2, ind_buffer3);

   SetIndexStyle(3, DRAW_ARROW, STYLE_SOLID, 0);
   SetIndexArrow(3, 108);
   SetIndexBuffer(3, ind_buffer4);
//---- initialization done
   return(0);
  }
//+------------------------------------------------------------------+
//| Moving Averages Convergence/Divergence                           |
//+------------------------------------------------------------------+
int start()
  {
   int limit;
   int counted_bars=IndicatorCounted();
//---- check for possible errors
   if(counted_bars<0) return(-1);
//---- last counted bar will be recounted
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
//---- macd counted in the 1-st buffer
   for(int i=0; i<limit; i++)
      ind_buffer1[i]=iMA(NULL,0,FastEMA,0,MODE_EMA,PRICE_CLOSE,i)-iMA(NULL,0,SlowEMA,0,MODE_EMA,PRICE_CLOSE,i);
//---- signal line counted in the 2-nd buffer
   for(i=0; i<limit; i++)
      ind_buffer2[i]=iMAOnArray(ind_buffer1,Bars,SignalSMA,0,MODE_SMA,i);
      
   for (i=0; i<limit; i++)
   {
      ind_buffer3[i] = EMPTY_VALUE; ind_buffer4[i] = EMPTY_VALUE; 
      if (ind_buffer1[i] > ind_buffer2[i] && ind_buffer1[i+1] < ind_buffer2[i+1])
         ind_buffer3[i] = Low[i] - 1 * Point;
         
      if (ind_buffer1[i] < ind_buffer2[i] && ind_buffer1[i+1] > ind_buffer2[i+1])
         ind_buffer4[i] = High[i] + 1 * Point;
   }    
//---- done
   return(0);
  }