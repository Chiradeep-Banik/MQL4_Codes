//+------------------------------------------------------------------+
//|                                             Volatility.Pivot.mq4 |
//+------------------------------------------------------------------+
#property copyright ""
#property link      ""

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 DarkSeaGreen
//---- input parameters
extern double     atr_range=100;
extern double     ima_range = 10;
extern double     atr_factor=3;
extern int        Mode = 0;
extern double     DeltaPrice = 30;


//---- buffers
double TrStop[];
double ATR[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0, DRAW_LINE,STYLE_SOLID,1);
   SetIndexBuffer(0, TrStop);

   SetIndexStyle(1, DRAW_NONE);
   SetIndexBuffer(1, ATR);

   string short_name = "!! RisenbergVolatilityCapture";
   IndicatorShortName(short_name);
   SetIndexLabel(1,"range base");
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
   int counted_bars = IndicatorCounted();
   int limit;
   int i;

   double DeltaStop;
   
   limit = Bars;

   for(i = 0; i < limit; i ++) {
      ATR[i] = iATR(NULL,0,atr_range,i);
   }

   for(i = limit - 1; i >= 0; i --) {
      if (Mode == 0) {
         DeltaStop = iMAOnArray(ATR,0,ima_range,0,MODE_EMA,i) * atr_factor;
         //DeltaStop = iATR(NULL,0,atr_range,i) * atr_factor;
      } else {
         DeltaStop = DeltaPrice*Point;
      }

      if (Close[i] == TrStop[i + 1]) {
         TrStop[i] = TrStop[i + 1];
      } else {
         if (Close[i+1]<TrStop[i+1] && Close[i]<TrStop[i+1]) {
            TrStop[i] = MathMin(TrStop[i + 1], Close[i] + DeltaStop);
         } else {
            if (Close[i+1]>TrStop[i+1] && Close[i]>TrStop[i+1]) {
               TrStop[i] = MathMax(TrStop[i+1], Close[i] - DeltaStop);         
            } else {
               if (Close[i] > TrStop[i+1]) TrStop[i] = Close[i] - DeltaStop; else TrStop[i] = Close[i] + DeltaStop;
            }
         }
      }
   }

//----
   return(0);
  }
//+------------------------------------------------------------------+
