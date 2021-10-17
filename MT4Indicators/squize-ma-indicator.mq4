//+------------------------------------------------------------------+
//|                                                    Squize_MA.mq4 |
//|                                                          Kalenzo |
//|                                      bartlomiej.gorski@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Kalenzo"
#property link      "bartlomiej.gorski@gmail.com"
//----
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Blue
#property indicator_color2 Red
//----
double upma[];
double dnma[];
//----
extern int MaDifrential=5;
extern int Ma1Type=MODE_EMA;
extern int Ma1Price=PRICE_CLOSE;
extern int Ma1Period=5;
extern int Ma2Type=MODE_EMA;
extern int Ma2Price=PRICE_CLOSE;
extern int Ma2Period=20;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexBuffer(0,upma);
   SetIndexBuffer(1,dnma);
   SetIndexStyle(0,DRAW_LINE,STYLE_SOLID,2);
   SetIndexStyle(1,DRAW_LINE,STYLE_SOLID,2);
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
   int limit;
   int counted_bars=IndicatorCounted();
   if(counted_bars<0) counted_bars=0;
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
//----
   for(int i=0 ;i<=limit ;i++)
     {
      double ma1=iMA(Symbol(),0,Ma1Period,0,Ma1Type,Ma1Price,i);
      double ma2=iMA(Symbol(),0,Ma2Period,0,Ma2Type,Ma2Price,i);
      double madif=MathAbs(ma1-ma2);
      if(madif/Point > MaDifrential)
        {
         upma[i]=ma1;
         dnma[i]=ma2;
        }
      else
        {
         if(ma1>ma2)
           {
            upma[i]=ma1 - (madif/2);
            dnma[i]=ma1 - (madif/2);
           }
         else
           {
            upma[i]=ma2 - (madif/2);
            dnma[i]=ma2 - (madif/2);
           }
        }
     }
//----
   return(0);
  }
//+------------------------------------------------------------------+