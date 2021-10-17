//+------------------------------------------------------------------+
//|                                   Trailing Stop Loss - Level.mq4 |
//|                                                           S.B.T. |
//|                                     http://sufx.core.t3-ism.net/ |
//+------------------------------------------------------------------+
#property copyright ""
#property link      ""

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 DeepPink
//---- input parameters
extern int       Mode = 0;
extern double    DeltaPrice = 0.003;
//---- buffers
double TrStop[];
double ATR[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, TrStop);
   SetIndexStyle(1, DRAW_NONE);
   SetIndexBuffer(1, ATR);

   string short_name = "Trailing Stop Loss - Level(" + Mode + ", " + DeltaPrice + ")";
   IndicatorShortName(short_name);
   SetIndexLabel(0, short_name);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
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
   int    counted_bars = IndicatorCounted();
   int limit;
   int i;

   double DeltaStop;
   
   limit = Bars;

   for(i = 0; i < limit; i ++) {
      ATR[i] = iATR(NULL, 0, 14, i);
   }

   for(i = limit - 1; i >= 0; i --) {
      if (Mode == 0) {
         DeltaStop = iMAOnArray(ATR, 0, (14 * 2) - 1, 0, MODE_EMA, i) * 2.824;
      } else {
         DeltaStop = DeltaPrice;
      }

      if (Close[i] == TrStop[i + 1]) {
         TrStop[i] = TrStop[i + 1];
      } else {
         if (Close[i + 1] < TrStop[i + 1] && Close[i] < TrStop[i + 1]) {
            TrStop[i] = MathMin(TrStop[i + 1], Close[i] + DeltaStop);
         } else {
            if (Close[i + 1] > TrStop[i + 1] && Close[i] > TrStop[i + 1]) {
               TrStop[i] = MathMax(TrStop[i + 1], Close[i] - DeltaStop);         
            } else {
               if (Close[i] > TrStop[i + 1]) TrStop[i] = Close[i] - DeltaStop; else TrStop[i] = Close[i] + DeltaStop;
            }
         }
      }
   }

//----
   return(0);
  }
//+------------------------------------------------------------------+