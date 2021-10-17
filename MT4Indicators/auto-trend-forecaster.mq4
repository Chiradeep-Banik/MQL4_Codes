//+------------------------------------------------------------------+
//|                                                                  |
//|                                       Auto trend forecaster.mq4  |
//|                                                                  |
//+------------------------------------------------------------------+

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 DodgerBlue
#property indicator_color2 OrangeRed

extern int TMperiod = 26;
extern double Intensity = 1.9;
extern int SL_distance_pips = 200;
int g_ma_method_92 = MODE_SMMA;
int g_applied_price_96 = PRICE_LOW;
double g_ibuf_100[];
double g_ibuf_104[];
double g_ibuf_108[];
datetime g_time_112;

void DisplayAlert(string as_0, double ad_8, double ad_16, double ad_24) {
   string ls_32;
   string ls_40;
   string ls_48;
   if (Time[0] != g_time_112) {
      g_time_112 = Time[0];
      if (ad_24 != 0.0) ls_48 = "Price " + DoubleToStr(ad_24, 4);
      else ls_48 = "";
      if (ad_8 != 0.0) ls_40 = ", TakeProfit   " + DoubleToStr(ad_8, 4);
      else ls_40 = "";
      if (ad_16 != 0.0) ls_32 = ", StopLoss   " + DoubleToStr(ad_16, 4);
      else ls_32 = "";
      Alert("Auto TREND " + as_0 + ls_48 + ls_40 + ls_32 + " ", Symbol(), ", ", Period(), " min");
   }
}

int init() {
   int li_0;
   if (TMperiod == 8) li_0 = 2;
   else li_0 = 4;
   IndicatorBuffers(3);
   string ls_4 = "(" + TMperiod + ")";
   SetIndexBuffer(0, g_ibuf_100);
   SetIndexStyle(0, DRAW_LINE, STYLE_SOLID, li_0);
   SetIndexLabel(0, "" + ls_4);
   SetIndexBuffer(1, g_ibuf_104);
   SetIndexStyle(1, DRAW_LINE, STYLE_SOLID, li_0);
   SetIndexLabel(1, "" + ls_4);
   SetIndexBuffer(2, g_ibuf_108);
   ArraySetAsSeries(g_ibuf_108, TRUE);
   IndicatorShortName("AUTO TREND FORECASTER");
   IndicatorDigits(MarketInfo(Symbol(), MODE_DIGITS) + 1.0);
   return (0);
}

int deinit() {
   return (0);
}

double WMA(int ai_0, int a_period_4) {
   return (iMA(NULL, 0, a_period_4, 0, g_ma_method_92, g_applied_price_96, ai_0));
}

int start() {
   double lda_20[];
   double lda_24[];
   double ld_36;
   int l_ind_counted_0 = IndicatorCounted();
   if (l_ind_counted_0 < 0) return (-1);
   int li_4 = 1;
   int l_period_8 = MathFloor(MathSqrt(TMperiod));
   int li_12 = MathFloor(TMperiod / Intensity);
   int li_16 = Bars - l_ind_counted_0 + TMperiod + 1;
   if (li_16 > Bars) li_16 = Bars;
   ArraySetAsSeries(lda_20, TRUE);
   ArrayResize(lda_20, li_16);
   ArraySetAsSeries(lda_24, TRUE);
   ArrayResize(lda_24, li_16);
   double ld_28 = Close[1];
   for (li_4 = 0; li_4 < li_16; li_4++) lda_20[li_4] = 2.0 * WMA(li_4, li_12) - WMA(li_4, TMperiod);
   for (li_4 = 0; li_4 < li_16 - TMperiod; li_4++) g_ibuf_108[li_4] = iMAOnArray(lda_20, 0, l_period_8, 0, g_ma_method_92, li_4);
   for (li_4 = li_16 - TMperiod; li_4 > 0; li_4--) {
      lda_24[li_4] = lda_24[li_4 + 1];
      if (g_ibuf_108[li_4] > g_ibuf_108[li_4 + 1]) lda_24[li_4] = 1;
      if (g_ibuf_108[li_4] < g_ibuf_108[li_4 + 1]) lda_24[li_4] = -1;
      if (lda_24[li_4] > 0.0) {
         g_ibuf_100[li_4] = g_ibuf_108[li_4];
         if (lda_24[li_4 + 1] < 0.0) g_ibuf_100[li_4 + 1] = g_ibuf_108[li_4 + 1];
         if (lda_24[li_4 + 1] < 0.0) {
            if (li_4 == 1) {
               ld_36 = ld_28 - SL_distance_pips * Point;
               DisplayAlert("UP Buy ", 0, ld_36, ld_28);
            }
         }
         g_ibuf_104[li_4] = EMPTY_VALUE;
      } else {
         if (lda_24[li_4] < 0.0) {
            g_ibuf_104[li_4] = g_ibuf_108[li_4];
            if (lda_24[li_4 + 1] > 0.0) g_ibuf_104[li_4 + 1] = g_ibuf_108[li_4 + 1];
            if (lda_24[li_4 + 1] > 0.0) {
               if (li_4 == 1) {
                  ld_36 = ld_28 + SL_distance_pips * Point;
                  DisplayAlert("DOWN Sell ", 0, ld_36, ld_28);
               }
            }
            g_ibuf_100[li_4] = EMPTY_VALUE;
         }
      }
   }
   return (0);
}