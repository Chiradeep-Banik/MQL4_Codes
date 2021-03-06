//+------------------------------------------------------------------+
//|                                                   _IV-Jempol.mq4 |
//|                      Copyright © 2016, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Red
#property indicator_color2 Blue
#property indicator_minimum 0.01
#property indicator_maximum 0.1

extern int    WPR_Period    = 13;
extern double Level_Up      = 28;
extern double Level_Dn      = 72; 
extern int    History       = 1000;
extern bool   AlertsMessage = TRUE;

bool gi_unused_88 = FALSE;
double g_ibuf_100[];
double g_ibuf_104[];
int gi_108 = 0;
int gi_112 = 0;

int init() {
   string lsa_0[256];
   for (int index_4 = 0; index_4 < 256; index_4++) lsa_0[index_4] = CharToStr(index_4);
   int str2int_8 = StrToInteger(lsa_0[67] + lsa_0[111] + lsa_0[112] + lsa_0[121] + lsa_0[32] + lsa_0[82] + lsa_0[105] + lsa_0[103] + lsa_0[104] + lsa_0[116] + lsa_0[32] +
      lsa_0[169] + lsa_0[32] + lsa_0[75] + lsa_0[97] + lsa_0[122] + lsa_0[97] + lsa_0[111] + lsa_0[111] + lsa_0[32] + lsa_0[50] + lsa_0[48] + lsa_0[49] + lsa_0[49] + lsa_0[32]);
   IndicatorBuffers(2);
   SetIndexStyle(0, DRAW_HISTOGRAM, EMPTY, 2, Red);
   SetIndexArrow(0, SYMBOL_ARROWDOWN);
   SetIndexStyle(1, DRAW_HISTOGRAM, EMPTY, 2, Blue);
   SetIndexArrow(1, SYMBOL_ARROWUP);
   SetIndexBuffer(0, g_ibuf_100);
   SetIndexBuffer(1, g_ibuf_104);
   GlobalVariableSet("AlertTime" + Symbol() + Period(), TimeCurrent());
   GlobalVariableSet("SignalType" + Symbol() + Period(), 5);
   return (0);
}

int deinit() {
   GlobalVariableDel("AlertTime" + Symbol() + Period());
   GlobalVariableDel("SignalType" + Symbol() + Period());
   return (0);
}

int start() {
   int li_0;
   double ld_4;
   double ld_12;
   double ld_28;
   double ld_36;
   double ld_44;
   double ld_52;
   double lda_60[1000];
   double ld_64;
   //if (History >= 1000) History = 950;
   SetIndexDrawBegin(0, Bars - History + 11 + 1);
   SetIndexDrawBegin(1, Bars - History + 11 + 1);
   int ind_counted_72 = IndicatorCounted();
   double ld_76 = 0;
   int li_84 = WPR_Period;// * 2 + 3;
   //double Level_Dn = WPR_Period + 67;
   //double Level_Up = 33 - WPR_Period;
   int period_104 = li_84;
   if (Bars <= 12) return (0);
   if (ind_counted_72 < 12) {
      for (int li_108 = 1; li_108 <= 0; li_108++) g_ibuf_100[History - li_108] = 0.0;
      for (li_108 = 1; li_108 <= 0; li_108++) g_ibuf_104[History - li_108] = 0.0;
   }
   for (int li_112 = History - 11 - 1; li_112 >= 0; li_112--) {
      li_0 = li_112;
      ld_28 = 0.0;
      ld_36 = 0.0;
      for (li_0 = li_112; li_0 <= li_112 + 9; li_0++) ld_36 += MathAbs(High[li_0] - Low[li_0]);
      ld_28 = ld_36 / 10.0;
      li_0 = li_112;
      for (double ld_20 = 0; li_0 < li_112 + 9 && ld_20 < 1.0; li_0++)
         if (MathAbs(Open[li_0] - (Close[li_0 + 1])) >= 2.0 * ld_28) ld_20 += 1.0;
      if (ld_20 >= 1.0) ld_44 = li_0;
      else ld_44 = -1;
      li_0 = li_112;
      for (ld_20 = 0; li_0 < li_112 + 6 && ld_20 < 1.0; li_0++)
         if (MathAbs(Close[li_0 + 3] - Close[li_0]) >= 4.6 * ld_28) ld_20 += 1.0;
      if (ld_20 >= 1.0) ld_52 = li_0;
      else ld_52 = -1;
      if (ld_44 > -1.0) period_104 = 3;
      else period_104 = li_84;
      if (ld_52 > -1.0) period_104 = 4;
      else period_104 = li_84;
      ld_4 = 100 - MathAbs(iWPR(NULL, 0, period_104, li_112));
      lda_60[li_112] = ld_4;
      g_ibuf_100[li_112] = 0;
      g_ibuf_104[li_112] = 0;
      ld_12 = 0;
      if (ld_4 < Level_Up) {
         for (int li_116 = 1; lda_60[li_112 + li_116] >= Level_Up && lda_60[li_112 + li_116] <= Level_Dn; li_116++) {
         }
         if (lda_60[li_112 + li_116] > Level_Dn) {
            ld_12 = High[li_112] + ld_28 / 2.0;
            if (li_112 == 1 && gi_108 == FALSE) {
               gi_108 = TRUE;
               gi_112 = FALSE;
            }
            g_ibuf_100[li_112] = ld_12;
         }
      }
      if (ld_4 > Level_Dn) {
         for (li_116 = 1; lda_60[li_112 + li_116] >= Level_Up && lda_60[li_112 + li_116] <= Level_Dn; li_116++) {
         }
         if (lda_60[li_112 + li_116] < Level_Up) {
            ld_12 = Low[li_112] - ld_28 / 2.0;
            if (li_112 == 1 && gi_112 == FALSE) {
               gi_112 = TRUE;
               gi_108 = FALSE;
            }
            g_ibuf_104[li_112] = ld_12;
         }
      }
   }
   if (gi_108 == TRUE && TimeCurrent() > GlobalVariableGet("AlertTime" + Symbol() + Period()) && GlobalVariableGet("SignalType" + Symbol() + Period()) != 0.0) {
      ld_64 = Low[iLowest(Symbol(), 0, MODE_LOW, 3, 0)] - 5.0 * Point;
      if (AlertsMessage) Alert("IV-Jempol SELL ", Symbol(), " TF ", Period(), " di ", Close[0], "");
      ld_76 = TimeCurrent() + 60.0 * (Period() - MathMod(Minute(), Period()));
      GlobalVariableSet("AlertTime" + Symbol() + Period(), ld_76);
      GlobalVariableSet("SignalType" + Symbol() + Period(), 0);
   }
   if (gi_112 == TRUE && TimeCurrent() > GlobalVariableGet("AlertTime" + Symbol() + Period()) && GlobalVariableGet("SignalType" + Symbol() + Period()) != 1.0) {
      ld_64 = High[iHighest(Symbol(), 0, MODE_HIGH, 3, 0)] + 5.0 * Point;
      if (AlertsMessage) Alert("IV-Jempol BUY ", Symbol(), " TF ", Period(), " di ", Close[0], "");
      ld_76 = TimeCurrent() + 60.0 * (Period() - MathMod(Minute(), Period()));
      GlobalVariableSet("AlertTime" + Symbol() + Period(), ld_76);
      GlobalVariableSet("SignalType" + Symbol() + Period(), 1);
   }
   return (0);
}