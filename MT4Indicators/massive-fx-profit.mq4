/*
   G e n e r a t e d  by ex4-to-mq4 decompiler FREEWARE 4.0.509.5
   Website: h T t p:// wW W .Me T a q U OT eS. n e T
   E-mail : s Up P o RT @ m E tA qUOt es.n e T
*/

#property indicator_chart_window
#property indicator_buffers 8
#property indicator_color1 DeepSkyBlue
#property indicator_color2 DarkOrange
#property indicator_color3 Green
#property indicator_color4 Red
#property indicator_color5 RoyalBlue
#property indicator_color6 Orange
#property indicator_color7 Red
#property indicator_color8 Green

extern int Arrow_Period = 21;
double Gd_80 = 30.0;
double Gd_88 = 70.0;
int Gi_96 = 65280;
int Gi_100 = 255;
int Gi_104 = 15136253;
int Gi_108 = 16776960;
string Gs_unused_112 = "=== Trend Box ===";
bool Gi_unused_120 = TRUE;
int Gi_124 = 15;
int Gi_128 = 10;
string Gs_unused_132 = "=== Select corner. 0=Upper Left, 1=Upper Right, 2=lower left , 3=lower right ===";
int G_corner_140 = 0;
string Gs_unused_144 = "Настройки индикатора Stochastic";
int G_period_152 = 14;
int G_period_156 = 1;
int G_slowing_160 = 3;
string Gs_unused_164 = "0=sma, 1=ema, 2=smma, 3=lwma";
int G_ma_method_172 = MODE_SMA;
string Gs_unused_176 = "0=high/low, 1=close/close";
int G_price_field_184 = 1;
int Gi_unused_188 = 1;
int Gi_192 = 0;
int Gi_196 = 1;
int G_shift_200 = 10000;
int Gi_204 = 2;
double G_ibuf_208[];
double G_ibuf_212[];
double G_ibuf_216[];
double G_ibuf_220[];
bool Gi_unused_224 = FALSE;
bool Gi_unused_228 = FALSE;
double G_ibuf_232[];
double G_ibuf_236[];
double G_ibuf_240[];
double G_ibuf_244[];
int G_period_248 = 48;
int Gi_252 = 12;
extern int SL = 88;
extern int TP = 128;
bool Gi_264 = FALSE;
bool Gi_unused_268 = TRUE;
extern bool UseAlerts = TRUE;
extern bool EmailAlerts = TRUE;
int Gi_280 = 0;
int Gi_284 = 0;
double Gd_288 = 0.0;
double Gd_296 = 0.0;
int Gi_304 = -1;
datetime G_time_308;
string Gs_ln1121_312 = "ln1121";

// 689C35E4872BA754D7230B8ADAA28E48
double f0_6(int A_shift_0) {
   return (iStochastic(NULL, 0, G_period_152, G_period_156, G_slowing_160, G_ma_method_172, G_price_field_184, MODE_MAIN, A_shift_0));
}

// 50257C26C4E5E915F022247BABD914FE
void f0_3(string As_0, double Ad_8, double Ad_16, double Ad_24) {
   string Ls_32;
   string Ls_40;
   string Ls_48;
   string Ls_56;
   string Ls_64;
   if (UseAlerts) {
      if (Time[0] != G_time_308) {
         G_time_308 = Time[0];
         if (Ad_24 != 0.0) Ls_48 = " price " + DoubleToStr(Ad_24, 4);
         else Ls_48 = "";
         if (Ad_8 != 0.0) Ls_40 = ", TakeProfit on " + DoubleToStr(Ad_8, 4);
         else Ls_40 = "";
         if (Ad_16 != 0.0) Ls_32 = ", StopLoss on " + DoubleToStr(Ad_16, 4);
         else Ls_32 = "";
         Alert("MassiveForexProfit " + As_0 + Ls_48 + Ls_40 + Ls_32 + " ", Symbol(), ", ", Period(), " minutes chart");
         Ls_56 = "MassiveForexProfit " + As_0 + Ls_48;
         Ls_64 = "MassiveForexProfit " + As_0 + Ls_48 + Ls_40 + Ls_32 + " " + Symbol() + ", " + Period() + " minutes chart";
         if (EmailAlerts) SendMail(Ls_56, Ls_64);
      }
   }
}

// E37F0136AA3FFAF149B351F6A4C948E9
int init() {
   SetIndexStyle(4, DRAW_ARROW, EMPTY);
   SetIndexArrow(4, 233);
   SetIndexBuffer(4, G_ibuf_208);
   SetIndexStyle(5, DRAW_ARROW, EMPTY);
   SetIndexArrow(5, 234);
   SetIndexBuffer(5, G_ibuf_212);
   SetIndexStyle(0, DRAW_NONE);
   SetIndexBuffer(0, G_ibuf_232);
   SetIndexStyle(1, DRAW_NONE);
   SetIndexBuffer(1, G_ibuf_236);
   SetIndexStyle(2, DRAW_ARROW, EMPTY);
   SetIndexArrow(2, 233);
   SetIndexBuffer(2, G_ibuf_216);
   SetIndexStyle(3, DRAW_ARROW, EMPTY);
   SetIndexArrow(3, 234);
   SetIndexBuffer(3, G_ibuf_220);
   SetIndexStyle(6, DRAW_NONE, EMPTY);
   SetIndexArrow(6, SYMBOL_STOPSIGN);
   SetIndexBuffer(6, G_ibuf_240);
   SetIndexStyle(7, DRAW_NONE, EMPTY);
   SetIndexArrow(7, SYMBOL_CHECKSIGN);
   SetIndexBuffer(7, G_ibuf_244);
   return (0);
}

// 52D46093050F38C27267BCE42543EF60
int deinit() {
   Comment(" ");
   string Ls_0 = WindowExpertName();
   f0_8();
   return (0);
}

// EA2B2676C28C0DB26D39331A336C6B92
int start() {
   double close_0;
   double Ld_8;
   double Ld_16;
   int Li_24;
   f0_10();
   int Li_28 = IndicatorCounted();
   if (Li_28 < 0) return (-1);
   if (Li_28 > 0) Li_28--;
   int Li_32 = Bars - Li_28;
   if (Gi_264) {
      Li_24 = Li_32;
      Comment("");
   } else Li_24 = 1000;
   int Li_36 = 0;
   for (int Li_40 = Li_24; Li_40 > 0; Li_40--) {
      if (f0_7(Li_40)) {
         Gi_280 = 0;
         Gi_284 = Gi_304;
         Gd_288 = High[Li_40];
         Li_36 = -1;
         if (Li_40 == 1) {
            close_0 = Close[1];
            Ld_8 = High[iHighest(NULL, 0, MODE_HIGH, Gi_252, 1)] + SL * Point;
            Ld_16 = close_0 - TP * Point;
            f0_3("Sell signal", Ld_16, Ld_8, close_0);
         }
      }
      if (f0_11(Li_40)) {
         Gi_280 = 0;
         Gi_284 = Gi_304;
         Gd_288 = Low[Li_40];
         Li_36 = 1;
         if (Li_40 == 1) {
            close_0 = Close[1];
            Ld_8 = Low[iLowest(NULL, 0, MODE_LOW, Gi_252, 1)] - SL * Point;
            Ld_16 = close_0 + TP * Point;
            f0_3("Buy signal", Ld_16, Ld_8, close_0);
         }
      }
      Gd_296 = Gd_288 - Close[Li_40];
      Gi_280 += Volume[Li_40];
      Gi_284++;
      if (Li_36 == 1) {
         G_ibuf_232[Li_40] = Gi_280;
         G_ibuf_236[Li_40] = 0;
      } else {
         G_ibuf_236[Li_40] = Gi_280;
         G_ibuf_232[Li_40] = 0;
      }
   }
   f0_0();
   return (0);
}

// 6ABA3523C7A75AAEA41CC0DEC7953CC5
int f0_7(int Ai_0) {
   if (G_ibuf_220[Ai_0] == EMPTY_VALUE && G_ibuf_212[Ai_0] == EMPTY_VALUE) return (0);
   return (MathMin(G_ibuf_220[Ai_0], G_ibuf_212[Ai_0]) > 0.0);
}

// A9B24A824F70CC1232D1C2BA27039E8D
int f0_11(int Ai_0) {
   if (G_ibuf_216[Ai_0] == EMPTY_VALUE && G_ibuf_208[Ai_0] == EMPTY_VALUE) return (0);
   return (MathMin(G_ibuf_216[Ai_0], G_ibuf_208[Ai_0]) > 0.0);
}

// 9B1AEE847CFB597942D106A4135D4FE6
void f0_10() {
   int Li_0;
   double Lda_4[25000];
   double Lda_8[25000];
   double Lda_12[25000];
   double Lda_16[25000];
   double Lda_20[];
   double Lda_24[];
   if (ArraySize(Lda_24) != G_shift_200 + 5) ArrayResize(Lda_24, G_shift_200 + 5);
   if (ArraySize(Lda_20) != G_shift_200 + 5) ArrayResize(Lda_20, G_shift_200 + 5);
   for (int shift_28 = G_shift_200; shift_28 > 0; shift_28--) {
      Lda_20[shift_28] = 0;
      Lda_24[shift_28] = 0;
      G_ibuf_216[shift_28] = EMPTY_VALUE;
      G_ibuf_220[shift_28] = EMPTY_VALUE;
      G_ibuf_208[shift_28] = EMPTY_VALUE;
      G_ibuf_212[shift_28] = EMPTY_VALUE;
   }
   for (shift_28 = G_shift_200 - Arrow_Period - 1; shift_28 > 0; shift_28--) {
      Lda_4[shift_28] = iBands(NULL, 0, Arrow_Period, Gi_204, 0, PRICE_CLOSE, MODE_UPPER, shift_28);
      Lda_8[shift_28] = iBands(NULL, 0, Arrow_Period, Gi_204, 0, PRICE_CLOSE, MODE_LOWER, shift_28);
      if (Close[shift_28] > Lda_4[shift_28 + 1]) Li_0 = 1;
      if (Close[shift_28] < Lda_8[shift_28 + 1]) Li_0 = -1;
      if (Li_0 > 0 && Lda_8[shift_28] < Lda_8[shift_28 + 1]) Lda_8[shift_28] = Lda_8[shift_28 + 1];
      if (Li_0 < 0 && Lda_4[shift_28] > Lda_4[shift_28 + 1]) Lda_4[shift_28] = Lda_4[shift_28 + 1];
      Lda_12[shift_28] = Lda_4[shift_28] + (Gi_192 - 1) / 2.0 * (Lda_4[shift_28] - Lda_8[shift_28]);
      Lda_16[shift_28] = Lda_8[shift_28] - (Gi_192 - 1) / 2.0 * (Lda_4[shift_28] - Lda_8[shift_28]);
      if (Li_0 > 0 && Lda_16[shift_28] < Lda_16[shift_28 + 1]) Lda_16[shift_28] = Lda_16[shift_28 + 1];
      if (Li_0 < 0 && Lda_12[shift_28] > Lda_12[shift_28 + 1]) Lda_12[shift_28] = Lda_12[shift_28 + 1];
      if (Li_0 > 0) {
         if (Gi_196 > 0 && Lda_20[shift_28 + 1] == -1.0) {
            if (f0_1(shift_28)) G_ibuf_216[shift_28] = Lda_16[shift_28];
            else G_ibuf_208[shift_28] = Lda_16[shift_28];
            Lda_20[shift_28] = Lda_16[shift_28];
            G_ibuf_240[shift_28] = Low[iLowest(NULL, 0, MODE_LOW, Gi_252, shift_28)] - SL * Point;
            G_ibuf_244[shift_28] = Close[shift_28] + TP * Point;
         } else {
            Lda_20[shift_28] = Lda_16[shift_28];
            G_ibuf_216[shift_28] = EMPTY_VALUE;
            G_ibuf_208[shift_28] = EMPTY_VALUE;
         }
         if (Gi_196 == 2) Lda_20[shift_28] = 0;
         G_ibuf_220[shift_28] = EMPTY_VALUE;
         G_ibuf_212[shift_28] = EMPTY_VALUE;
         Lda_24[shift_28] = -1.0;
      }
      if (Li_0 < 0) {
         if (Gi_196 > 0 && Lda_24[shift_28 + 1] == -1.0) {
            if (f0_12(shift_28)) G_ibuf_220[shift_28] = Lda_12[shift_28];
            else G_ibuf_212[shift_28] = Lda_12[shift_28];
            Lda_24[shift_28] = Lda_12[shift_28];
            G_ibuf_240[shift_28] = High[iHighest(NULL, 0, MODE_HIGH, Gi_252, shift_28)] + SL * Point;
            G_ibuf_244[shift_28] = Close[shift_28] - TP * Point;
         } else {
            Lda_24[shift_28] = Lda_12[shift_28];
            G_ibuf_220[shift_28] = EMPTY_VALUE;
            G_ibuf_212[shift_28] = EMPTY_VALUE;
         }
         if (Gi_196 == 2) Lda_24[shift_28] = 0;
         G_ibuf_216[shift_28] = EMPTY_VALUE;
         G_ibuf_208[shift_28] = EMPTY_VALUE;
         Lda_20[shift_28] = -1.0;
      }
   }
}

// 58B0897F29A3AD862616D6CBF39536ED
void f0_5(string As_0) {
   string name_8;
   for (int Li_16 = ObjectsTotal() - 1; Li_16 >= 0; Li_16--) {
      name_8 = ObjectName(Li_16);
      if (StringFind(name_8, As_0) != -1) ObjectDelete(name_8);
   }
}

// 2569208C5E61CB15E209FFE323DB48B7
int f0_1(int Ai_0) {
   return (iMA(NULL, 0, G_period_248, 0, MODE_SMA, PRICE_CLOSE, Ai_0) > iMA(NULL, 0, G_period_248, 0, MODE_SMA, PRICE_CLOSE, Ai_0 + 1));
}

// D1DDCE31F1A86B3140880F6B1877CBF8
int f0_12(int Ai_0) {
   return (iMA(NULL, 0, G_period_248, 0, MODE_SMA, PRICE_CLOSE, Ai_0) < iMA(NULL, 0, G_period_248, 0, MODE_SMA, PRICE_CLOSE, Ai_0 + 1));
}

// 945D754CB0DC06D04243FCBA25FC0802
int f0_9() {
   for (int count_0 = 0; count_0 < Bars; count_0++) {
      if (f0_7(count_0)) return (1);
      if (f0_11(count_0)) return (0);
   }
   return (-1);
}

// 09CBB5F5CE12C31A043D5C81BF20AA4A
void f0_0() {
   string Ls_0;
   string dbl2str_8;
   string Ls_16;
   int Li_24;
   int Li_28;
   string Ls_32;
   string Ls_40;
   int Li_48 = f0_9();
   if (Li_48 != -1) {
      if (Li_48 == 0) {
         Ls_0 = "Up";
         Li_24 = Gi_96;
         dbl2str_8 = DoubleToStr(f0_6(0), 0);
         Ls_16 = "Buy";
         Li_28 = Gi_96;
      } else {
         Ls_0 = "Down";
         Li_24 = Gi_100;
         dbl2str_8 = DoubleToStr(100 - f0_6(0), 0);
         Ls_16 = "Sell";
         Li_28 = Gi_100;
      }
      Ls_32 = "(WEAK)";
      if (StrToDouble(dbl2str_8) > Gd_80) Ls_32 = "(MEDIUM)";
      if (StrToDouble(dbl2str_8) > Gd_88) Ls_32 = "(STRONG)";
      Ls_40 = "-----------------------";
      f0_4("Trend_Strength", "Trend Strength", 35, 15, Gi_104, 12);
      f0_4("percent", dbl2str_8 + "%", 30, 40, Li_24, 15);
      f0_4("SilaTrenda", Ls_32, 95, 40, Gi_104, 15);
      f0_4("razdel1", Ls_40, 0, 60, Gi_108, 15);
      f0_4("Trend_Direction", "Trend Direction:", 5, 80, Gi_104, 12);
      f0_4("trend", Ls_0, 160, 80, Li_24, 12);
      f0_4("razdel2", Ls_40, 0, 90, Gi_108, 15);
      f0_4("Last_Signal", "Last Signal:", 5, 110, Gi_104, 12);
      f0_4("ls", Ls_16, 115, 110, Li_28, 12);
      f0_4("razdel3", Ls_40, 0, 120, Gi_108, 15);
      f0_4("Current_Pair", "Current Pair: " + Symbol(), 5, 140, Gi_104, 12);
      f0_4("razdel4", Ls_40, 0, 150, Gi_108, 15);
      f0_4("Current_tf", "Current Timeframe: " + f0_2(), 5, 170, Gi_104, 12);
      f0_4("razdel5", Ls_40, 0, 180, Gi_108, 15);
      f0_4("Current_Time", TimeToStr(TimeCurrent()), 15, 200, Gi_104, 12);
      WindowRedraw();
   }
}

// 5710F6E623305B2C1458238C9757193B
void f0_4(string A_name_0, string A_text_8, int Ai_16, int Ai_20, color A_color_24, int A_fontsize_28 = 8, string A_fontname_32 = "Tahoma Bold") {
   A_name_0 = Gs_ln1121_312 + A_name_0;
   ObjectCreate(A_name_0, OBJ_LABEL, 0, 0, 0);
   ObjectSetText(A_name_0, A_text_8, A_fontsize_28, A_fontname_32, A_color_24);
   ObjectSet(A_name_0, OBJPROP_CORNER, G_corner_140);
   ObjectSet(A_name_0, OBJPROP_XDISTANCE, Ai_16 + Gi_124);
   ObjectSet(A_name_0, OBJPROP_YDISTANCE, Ai_20 + Gi_128);
}

// 28EFB830D150E70A8BB0F12BAC76EF35
string f0_2() {
   string Ls_ret_0;
   switch (Period()) {
   case PERIOD_M1:
      Ls_ret_0 = "M1";
      break;
   case PERIOD_M5:
      Ls_ret_0 = "M5";
      break;
   case PERIOD_M15:
      Ls_ret_0 = "M15";
      break;
   case PERIOD_M30:
      Ls_ret_0 = "M30";
      break;
   case PERIOD_H1:
      Ls_ret_0 = "H1";
      break;
   case PERIOD_H4:
      Ls_ret_0 = "H4";
      break;
   case PERIOD_D1:
      Ls_ret_0 = "D1";
      break;
   case PERIOD_W1:
      Ls_ret_0 = "W1";
      break;
   case PERIOD_MN1:
      Ls_ret_0 = "MN";
   }
   return (Ls_ret_0);
}

// 78BAA8FAE18F93570467778F2E829047
void f0_8() {
   f0_5(Gs_ln1121_312);
}
