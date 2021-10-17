/*
   G e n e r a t e d  by ex4-to-mq4 decompiler FREEWARE 4.0.509.5
   Website: hT t P :// Ww w .me taquo te S.NE T
   E-mail :  s UP p O rt@ me T aqu O te S .n E t
*/
#property copyright "Copyright © 2016"
#property link      ""

#property indicator_chart_window

extern bool alert = TRUE;
int Gi_80 = 7;
double Gd_84 = 1.7;
int Gi_92 = 0;
int Gi_96 = 2000;
int G_count_100;
int Gi_104;
int Gi_108;
int Gi_112;
int Gi_116;
double G_ibuf_120[];
double G_ibuf_124[];
bool Gi_128 = FALSE;
bool Gi_132 = FALSE;
bool Gi_unused_136 = FALSE;
bool Gi_unused_140 = FALSE;
extern int SRPeriod = 5;
double G_point_148;
string Gs_156 = "";

int init() {
   drawLabel();
   SetIndexStyle(0, DRAW_LINE, STYLE_SOLID, 2);
   SetIndexStyle(1, DRAW_LINE, STYLE_SOLID, 2);
   SetIndexBuffer(0, G_ibuf_120);
   SetIndexBuffer(1, G_ibuf_124);
   IndicatorDigits(MarketInfo(Symbol(), MODE_DIGITS));
   SetIndexLabel(0, "StepMA Stoch 1");
   SetIndexLabel(1, "StepMA Stoch 2");
   SetIndexDrawBegin(0, Gi_80);
   SetIndexDrawBegin(1, Gi_80);
   ArrayInitialize(G_ibuf_120, 0);
   ArrayInitialize(G_ibuf_124, 0);
   SetIndexEmptyValue(0, 0);
   SetIndexEmptyValue(1, 0);
   return (0);
}

int deinit() {
   ObjectsDeleteAll();
   for (G_count_100 = 0; G_count_100 < Bars; G_count_100++) {
      ObjectDelete("BS" + G_count_100);
      ObjectDelete("BT" + G_count_100 + "txt");
      ObjectDelete("SS" + G_count_100);
      ObjectDelete("ST" + G_count_100 + "txt");
   }
   return (0);
}

int start() {
   double iclose_0 = iClose(NULL, PERIOD_D1, iHighest(NULL, PERIOD_D1, MODE_CLOSE, SRPeriod, 1));
   double iclose_8 = iClose(NULL, PERIOD_H4, iHighest(NULL, PERIOD_H4, MODE_CLOSE, SRPeriod, 1));
   double iclose_16 = iClose(NULL, PERIOD_H1, iHighest(NULL, PERIOD_H1, MODE_CLOSE, SRPeriod, 1));
   double iclose_24 = iClose(NULL, PERIOD_M30, iHighest(NULL, PERIOD_M30, MODE_CLOSE, SRPeriod, 1));
   double iclose_32 = iClose(NULL, PERIOD_M15, iHighest(NULL, PERIOD_M15, MODE_CLOSE, SRPeriod, 1));
   drawLine("HH_D1r %", Time[50], Time[40], iclose_0, iclose_0, 2, 2, Blue, 0);
   double iclose_40 = iClose(NULL, PERIOD_D1, iLowest(NULL, PERIOD_D1, MODE_CLOSE, SRPeriod, 1));
   double iclose_48 = iClose(NULL, PERIOD_H4, iLowest(NULL, PERIOD_H4, MODE_CLOSE, SRPeriod, 1));
   double iclose_56 = iClose(NULL, PERIOD_H1, iLowest(NULL, PERIOD_H1, MODE_CLOSE, SRPeriod, 1));
   double iclose_64 = iClose(NULL, PERIOD_M30, iLowest(NULL, PERIOD_M30, MODE_CLOSE, SRPeriod, 1));
   double iclose_72 = iClose(NULL, PERIOD_M15, iLowest(NULL, PERIOD_M15, MODE_CLOSE, SRPeriod, 1));
   drawLine("LL_D1r", Time[50], Time[40], iclose_40, iclose_40, 2, 2, Red, 0);
   return (0);
}

void drawLine(string A_name_0, int A_datetime_8, int A_datetime_12, double A_price_16, double A_price_24, int A_width_32, int A_bool_36, color A_color_40, int Ai_44) {
   if (ObjectFind(A_name_0) != 0) {
      ObjectCreate(A_name_0, OBJ_TREND, 0, A_datetime_8, A_price_16, A_datetime_12, A_price_24);
      if (Ai_44 == 1) ObjectSet(A_name_0, OBJPROP_STYLE, STYLE_SOLID);
      else {
         if (Ai_44 == 2) ObjectSet(A_name_0, OBJPROP_STYLE, STYLE_DASHDOT);
         else ObjectSet(A_name_0, OBJPROP_STYLE, STYLE_DOT);
      }
      ObjectSet(A_name_0, OBJPROP_COLOR, A_color_40);
      ObjectSet(A_name_0, OBJPROP_WIDTH, A_width_32);
      ObjectSet(A_name_0, OBJPROP_RAY, A_bool_36);
      return;
   }
   ObjectDelete(A_name_0);
   ObjectCreate(A_name_0, OBJ_TREND, 0, A_datetime_8, A_price_16, A_datetime_12, A_price_24);
   if (Ai_44 == 1) ObjectSet(A_name_0, OBJPROP_STYLE, STYLE_SOLID);
   else {
      if (Ai_44 == 2) ObjectSet(A_name_0, OBJPROP_STYLE, STYLE_DASHDOT);
      else ObjectSet(A_name_0, OBJPROP_STYLE, STYLE_DOT);
   }
   ObjectSet(A_name_0, OBJPROP_COLOR, A_color_40);
   ObjectSet(A_name_0, OBJPROP_WIDTH, A_width_32);
   ObjectSet(A_name_0, OBJPROP_RAY, A_bool_36);
}

void drawLabel() {
   int Li_8;
   int Li_12;
   int Li_16;
   double Ld_20;
   double Ld_28;
   double Ld_36;
   double Ld_44;
   double Ld_52;
   double Ld_60;
   double Ld_68;
   double Ld_76;
   double Ld_84;
   double Ld_92;
   double Ld_100;
   double Ld_108;
   double Ld_116;
   double Ld_124;
   double Ld_132;
   double Ld_140;
   double Ld_148;
   double Ld_156;
   double Ld_164;
   double Ld_172;
   double Ld_180;
   double Ld_188;
   double Ld_196;
   double Ld_204;
   int Li_212;
   int Li_216;
   int Li_220;
   string Ls_0 = " " + " ";
   if (Point == 0.00001) G_point_148 = 0.0001;
   else {
      if (Point == 0.001) G_point_148 = 0.01;
      else G_point_148 = Point;
   }
   Comment("" 
      + "\n" 
      + "FOREX INVINCIBLE" 
      + "\n" 
      + "------------------------------------------------" 
      + "\n" 
      + "BROKER DATA:" 
      + "\n" 
      + "Company:      " + AccountCompany() 
      + "\n" 
      + "------------------------------------------------" 
      + "\n" 
      + "ACCOUNT DATA:" 
      + "\n" 
      + "Name:          " + AccountName() 
      + "\n" 
      + "Number:       " + AccountNumber() 
      + "\n" 
      + "Leverage:     " + DoubleToStr(AccountLeverage(), 0) 
      + "\n" 
      + "Balance:       " + DoubleToStr(AccountBalance(), 2) 
      + "\n" 
      + "Currency:     " + AccountCurrency() 
      + "\n" 
      + "Equity:         " + DoubleToStr(AccountEquity(), 2) 
      + "\n" 
      + "------------------------------------------------" 
      + "\n" 
      + "MARGIN DATA:" 
      + "\n" 
      + "Free Margin:              " + DoubleToStr(AccountFreeMargin(), 2) 
      + "\n" 
      + "Used Margin:              " + DoubleToStr(AccountMargin(), 2) 
      + "\n" 
      + "------------------------------------------------" 
   + "\n");
   string Ls_224 = "Max bars to count: |" + ((Bars - 1)) + "| ";
   IndicatorShortName(Ls_224);
   double Ld_232 = 0;
   double Ld_unused_240 = 0;
   ObjectsDeleteAll(0, OBJ_ARROW);
   ObjectsDeleteAll(0, OBJ_TEXT);
   for (int Li_248 = Gi_96 - 1; Li_248 >= 0; Li_248--) {
      Ld_52 = 0;
      for (int Li_252 = Gi_80 - 1; Li_252 >= 0; Li_252--) {
         Ld_60 = 1.0 * (Gi_80 - Li_252) / Gi_80 + 1.0;
         Ld_52 += Ld_60 * MathAbs(High[Li_252 + Li_248] - (Low[Li_252 + Li_248]));
      }
      Ld_68 = Ld_52 / Gi_80;
      Ld_76 = MathMax(Ld_68, Ld_76);
      if (Li_248 == Gi_96 - 1 - Gi_80) Ld_84 = Ld_68;
      Ld_84 = MathMin(Ld_68, Ld_84);
      Li_212 = MathRound(Gd_84 * Ld_84 / G_point_148);
      Li_216 = MathRound(Gd_84 * Ld_76 / G_point_148);
      Li_220 = MathRound(Gd_84 / 2.0 * (Ld_76 + Ld_84) / G_point_148);
      if (Gi_92 > 0) {
         Ld_28 = Low[Li_248] + Li_212 * 2 * G_point_148;
         Ld_20 = High[Li_248] - Li_212 * 2 * G_point_148;
         Ld_100 = Low[Li_248] + Li_216 * 2 * G_point_148;
         Ld_92 = High[Li_248] - Li_216 * 2 * G_point_148;
         Ld_132 = Low[Li_248] + Li_220 * 2 * G_point_148;
         Ld_124 = High[Li_248] - Li_220 * 2 * G_point_148;
         if (Close[Li_248] > Ld_44) Li_8 = 1;
         if (Close[Li_248] < Ld_36) Li_8 = -1;
         if (Close[Li_248] > Ld_116) Li_12 = 1;
         if (Close[Li_248] < Ld_108) Li_12 = -1;
         if (Close[Li_248] > Ld_148) Li_16 = 1;
         if (Close[Li_248] < Ld_140) Li_16 = -1;
      }
      if (Gi_92 == 0) {
         Ld_28 = Close[Li_248] + Li_212 * 2 * G_point_148;
         Ld_20 = Close[Li_248] - Li_212 * 2 * G_point_148;
         Ld_100 = Close[Li_248] + Li_216 * 2 * G_point_148;
         Ld_92 = Close[Li_248] - Li_216 * 2 * G_point_148;
         Ld_132 = Close[Li_248] + Li_220 * 2 * G_point_148;
         Ld_124 = Close[Li_248] - Li_220 * 2 * G_point_148;
         if (Close[Li_248] > Ld_44) Li_8 = 1;
         if (Close[Li_248] < Ld_36) Li_8 = -1;
         if (Close[Li_248] > Ld_116) Li_12 = 1;
         if (Close[Li_248] < Ld_108) Li_12 = -1;
         if (Close[Li_248] > Ld_148) Li_16 = 1;
         if (Close[Li_248] < Ld_140) Li_16 = -1;
      }
      if (Li_8 > 0 && Ld_20 < Ld_36) Ld_20 = Ld_36;
      if (Li_8 < 0 && Ld_28 > Ld_44) Ld_28 = Ld_44;
      if (Li_12 > 0 && Ld_92 < Ld_108) Ld_92 = Ld_108;
      if (Li_12 < 0 && Ld_100 > Ld_116) Ld_100 = Ld_116;
      if (Li_16 > 0 && Ld_124 < Ld_140) Ld_124 = Ld_140;
      if (Li_16 < 0 && Ld_132 > Ld_148) Ld_132 = Ld_148;
      if (Li_8 > 0) Ld_156 = Ld_20 + Li_212 * G_point_148;
      if (Li_8 < 0) Ld_156 = Ld_28 - Li_212 * G_point_148;
      if (Li_12 > 0) Ld_164 = Ld_92 + Li_216 * G_point_148;
      if (Li_12 < 0) Ld_164 = Ld_100 - Li_216 * G_point_148;
      if (Li_16 > 0) Ld_172 = Ld_124 + Li_220 * G_point_148;
      if (Li_16 < 0) Ld_172 = Ld_132 - Li_220 * G_point_148;
      if (Period() == PERIOD_M1) {
         Gi_104 = 2;
         Gi_108 = 4;
         Gi_112 = 2;
         Gi_116 = 4;
      }
      if (Period() == PERIOD_M5) {
         Gi_104 = 3;
         Gi_108 = 6;
         Gi_112 = 3;
         Gi_116 = 7;
      }
      if (Period() == PERIOD_M15) {
         Gi_104 = 3;
         Gi_108 = 6;
         Gi_112 = 4;
         Gi_116 = 9;
      }
      if (Period() == PERIOD_M30) {
         Gi_104 = 3;
         Gi_108 = 8;
         Gi_112 = 5;
         Gi_116 = 12;
      }
      if (Period() == PERIOD_H1) {
         Gi_104 = 3;
         Gi_108 = 10;
         Gi_112 = 7;
         Gi_116 = 15;
      }
      if (Period() == PERIOD_H4) {
         Gi_104 = 3;
         Gi_108 = 15;
         Gi_112 = 10;
         Gi_116 = 28;
      }
      if (Period() == PERIOD_D1) {
         Gi_104 = 4;
         Gi_108 = 30;
         Gi_112 = 30;
         Gi_116 = 70;
      }
      if (Period() == PERIOD_W1) {
         Gi_104 = 5;
         Gi_108 = 40;
         Gi_112 = 40;
         Gi_116 = 80;
      }
      if (Period() == PERIOD_MN1) {
         Gi_104 = 6;
         Gi_108 = 50;
         Gi_112 = 50;
         Gi_116 = 90;
      }
      Ld_196 = Ld_164 - Li_216 * G_point_148;
      Ld_204 = Ld_164 + Li_216 * G_point_148;
      Ld_180 = NormalizeDouble((Ld_156 - Ld_196) / (Ld_204 - Ld_196), 6);
      Ld_188 = NormalizeDouble((Ld_172 - Ld_196) / (Ld_204 - Ld_196), 6);
      Ld_232 = Ld_180 - Ld_188;
      if (Ld_232 < 0.0) {
         G_ibuf_120[Li_248] = Ld_232;
         G_ibuf_124[Li_248] = 0;
         if (Ld_232 < 0.0 && Gs_156 == "Buy" || Gs_156 == "") {
            drawArrow1("SS" + Li_248, Red, 234, "", Time[Li_248], High[Li_248] + Gi_112 * G_point_148);
            drawArrow2("ST" + Li_248, White, 0, "Sell", Time[Li_248], High[Li_248] + Gi_116 * G_point_148);
            Gs_156 = "Sell";
         }
      } else {
         if (Ld_232 > 0.0) {
            G_ibuf_124[Li_248] = Ld_232;
            G_ibuf_120[Li_248] = 0;
            if (Ld_232 > 0.0 && Gs_156 == "Sell" || Gs_156 == "") {
               drawArrow1("BS" + Li_248, Blue, 233, "", Time[Li_248], Low[Li_248] - Gi_104 * G_point_148);
               drawArrow2("BT" + Li_248, White, 0, "Buy", Time[Li_248], Low[Li_248] - Gi_108 * G_point_148);
               Gs_156 = "Buy";
            }
         }
      }
      Ld_36 = Ld_20;
      Ld_44 = Ld_28;
      Ld_108 = Ld_92;
      Ld_116 = Ld_100;
      Ld_140 = Ld_124;
      Ld_148 = Ld_132;
   }
   if (alert == TRUE && Gi_132 == FALSE && Gs_156 == "Buy") {
      Alert("FOREX INVINCIBLE SIGNAL ", 
         "\n" 
      + Symbol() + " " + Period() + " Minute " + Gs_156 + " at " + DoubleToStr(Bid, 4) + " Date " + TimeToStr(TimeCurrent(), TIME_DATE) + " Time " + TimeToStr(TimeCurrent(),
         TIME_MINUTES));
      Gi_132 = TRUE;
      Gi_128 = FALSE;
   }
   if (alert == TRUE && Gi_128 == FALSE && Gs_156 == "Sell") {
      Alert("FOREX INVINCIBLE SIGNAL ", 
         "\n" 
      + Symbol() + " " + Period() + " Minute " + Gs_156 + " at " + DoubleToStr(Ask, 4) + " Date " + TimeToStr(TimeCurrent(), TIME_DATE) + " Time " + TimeToStr(TimeCurrent(),
         TIME_MINUTES));
      Gi_132 = FALSE;
      Gi_128 = TRUE;
   }
}

void drawArrow1(string A_name_0, color A_color_8, int Ai_12, string As_unused_16, int A_datetime_24, double A_price_28) {
   ObjectCreate(A_name_0, OBJ_ARROW, 0, A_datetime_24, A_price_28);
   ObjectSet(A_name_0, OBJPROP_ARROWCODE, Ai_12);
   ObjectSet(A_name_0, OBJPROP_COLOR, A_color_8);
   ObjectSet(A_name_0, OBJPROP_WIDTH, 3);
}

void drawArrow2(string As_0, color A_color_8, int Ai_unused_12, string A_text_16, int A_datetime_24, double A_price_28) {
   ObjectCreate(As_0 + "txt", OBJ_TEXT, 0, A_datetime_24, A_price_28);
   ObjectSetText(As_0 + "txt", A_text_16, 12, "Tahoma", A_color_8);
}
