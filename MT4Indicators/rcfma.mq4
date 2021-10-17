//+------------------------------------------------------------------+
//|                                                        RCFMA.mq4 |
//|                                         Copyright © 2009, LeMan. |
//|                                                 b-market@mail.ru |
//+------------------------------------------------------------------+
#property  copyright "Copyright © 2009, LeMan."
#property  link      "b-market@mail.ru"
//---- настройки индикатора
#property  indicator_separate_window
#property  indicator_buffers 2
#property  indicator_color1  Blue
#property  indicator_color2  Red
#property  indicator_width1  1
#property  indicator_width2  1
//---- Входные параметры
extern int FastMA   = 4; // Длина быстрого МА
extern int MiddleMA = 9; // Длина промежуточного МА
extern int SlowMA    = 18; // Длина медленного МА
extern int TypeMA    = 0; // 0 - простое(SMA), 1 - экспоненциальное(EMA), 2 - сглаженное(SSMA), 3 - линейно-взвешенное(LWMA)
extern int TypePrice = 0; // 0 - Закрытие, 1 - Открытие, 2 - максимальная, 3 - минимальная, 4 - средняя, 5 - типичная, 6 - взвешенная закрытия
//---- Буферы индикатора
double     WASOMBuffer[];
double     DFMABuffer[];
//+------------------------------------------------------------------+
int init() {
//----
   SetIndexStyle(0, DRAW_HISTOGRAM);
   SetIndexStyle(1, DRAW_LINE);
   SetIndexDrawBegin(1, SlowMA);
   IndicatorDigits(Digits+1);
//----
   SetIndexBuffer(0,WASOMBuffer);
   SetIndexBuffer(1,DFMABuffer);
//----
   IndicatorShortName("RCFMA ("+FastMA+","+MiddleMA+","+SlowMA+")");
   SetIndexLabel(0, "WASOM");
   SetIndexLabel(1, "DFMA");
//----
   return(0);
}
//+------------------------------------------------------------------+
int start() {
   int limit;
   int counted_bars = IndicatorCounted();
//----
   if (counted_bars > 0) counted_bars--;
   limit = Bars-counted_bars;
//----
   for (int i = 0; i < limit; i++) {
      WASOMBuffer[i] = iMA(NULL,0,MiddleMA,0,TypeMA,TypePrice,i)-iMA(NULL,0,SlowMA,0,TypeMA,TypePrice,i);
   }
//----
   for (i = 0; i < limit; i++) {
      DFMABuffer[i] = iMA(NULL,0,FastMA,0,TypeMA,TypePrice,i)-iMA(NULL,0,FastMA,0,TypeMA,TypePrice,i+1);
   }
//----
   return(0);
}
//+------------------------------------------------------------------+