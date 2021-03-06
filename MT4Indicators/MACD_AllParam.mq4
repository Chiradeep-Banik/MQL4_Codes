//+------------------------------------------------------------------+
//|                                                MACD_AllParam.mq4 |
//|                      Copyright © 2005, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//|                                        Revised by AssassiN @2020 |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"
#property strict
//----
#property  indicator_separate_window
#property  indicator_buffers 2
#property  indicator_color1  DarkTurquoise
#property  indicator_color2  Red
//---- indicator parameters
extern ENUM_MA_METHOD FastMA_Method=MODE_EMA;
extern ENUM_APPLIED_PRICE FastMA_Price=PRICE_CLOSE;
extern int FastMA=12;
extern ENUM_MA_METHOD SlowMA_Method=MODE_EMA;
extern ENUM_APPLIED_PRICE SlowMA_Price=PRICE_CLOSE;
extern int SlowMA=26;
extern ENUM_MA_METHOD SignalMA_Method=MODE_SMA;
extern int SignalMA=9;

//---- indicator buffers
double     ind_buffer1[];
double     ind_buffer2[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- drawing settings
   SetIndexStyle(0,DRAW_LINE,STYLE_SOLID,1);
   SetIndexDrawBegin(1,SignalMA);
  // IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS)+1);
//---- indicator buffers mapping
   SetIndexBuffer(0,ind_buffer1);
   SetIndexBuffer(1,ind_buffer2);
//---- name for DataWindow and indicator subwindow label
   IndicatorShortName("MACD("+(string)FastMA+","+(string)SlowMA+","+(string)SignalMA+")");
   SetIndexLabel(0,"MACD");
   SetIndexLabel(1,"Signal");
//---- initialization done
   return(0);
  }
//+------------------------------------------------------------------+
//| Moving Averages Convergence/Divergence                           |
//+------------------------------------------------------------------+
int start()
  {
   int counted_bars=IndicatorCounted();
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   int limit=Bars-counted_bars;
   if(counted_bars==0) limit-=1+MathMax(FastMA,SlowMA);

//---- macd counted in the 1-st buffer
   for(int i=0; i<limit; i++)
      ind_buffer1[i]=iMA(NULL,0,FastMA,0,FastMA_Method,FastMA_Price,i)-iMA(NULL,0,SlowMA,0,SlowMA_Method,SlowMA_Price,i);
//---- signal line counted in the 2-nd buffer
   for(int i=0; i<limit; i++)
      ind_buffer2[i]=iMAOnArray(ind_buffer1,0,SignalMA,0,SignalMA_Method,i);
//---- done
   return(0);
  }
//+------------------------------------------------------------------+
