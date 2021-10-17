#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 DarkGoldenrod
#property indicator_color2 RosyBrown
#property indicator_color3 CadetBlue

double gd_76 = 6.0;
double gd_84 = 25.0;
double gd_92 = 200.0;
extern int TriggerLevel = 52;
int gi_104 = 52;
int gi_108 = 0;
int g_bars_112 = 31;
double g_ibuf_116[];
double g_ibuf_120[];
double g_ibuf_124[];

int init() {
   ObjectsDeleteAll();
   SetIndexBuffer(2, g_ibuf_116);
   SetIndexBuffer(1, g_ibuf_120);
   SetIndexBuffer(0, g_ibuf_124);
   SetIndexStyle(2, DRAW_HISTOGRAM, STYLE_SOLID, 2);
   SetIndexStyle(1, DRAW_HISTOGRAM, STYLE_SOLID, 2);
   SetIndexStyle(0, DRAW_HISTOGRAM, STYLE_SOLID, 1);
   return (0);
}

int start() {
   double l_iclose_0;
   double l_iclose_8;
   double l_iclose_16;
   double l_iclose_24;
   double l_iclose_32;
   double ld_40;
   double ld_48;
   double ld_56;
   double ld_64;
   double ld_72;
   double ld_80;
   double ld_88;
   double ld_96;
   double ld_104;
   double l_iclose_112;
   double l_iclose_120;
   double l_iclose_128;
   double l_iclose_136;
   double l_iclose_144;
   double ld_152;
   double ld_160;
   double ld_168;
   double l_iclose_176;
   double l_iclose_184;
   double l_iclose_192;
   double l_iclose_200;
   double l_iclose_208;
   double ld_216;
   double ld_224;
   double ld_232;
   double l_iclose_240;
   double l_iclose_248;
   double l_iclose_256;
   double l_iclose_264;
   double l_iclose_272;
   double ld_280;
   double ld_288;
   double ld_296;
   double l_iclose_304;
   double l_iclose_312;
   double l_iclose_320;
   double l_iclose_328;
   double l_iclose_336;
   double ld_344;
   double ld_352;
   double ld_360;
   double l_iclose_368;
   double l_iclose_376;
   double l_iclose_384;
   double l_iclose_392;
   double l_iclose_400;
   double ld_408;
   double ld_416;
   double ld_424;
   double l_iclose_432;
   double l_iclose_440;
   double l_iclose_448;
   double l_iclose_456;
   double l_iclose_464;
   double ld_472;
   double ld_480;
   double ld_488;
   double l_iclose_496;
   double l_iclose_504;
   double l_iclose_512;
   double l_iclose_520;
   double l_iclose_528;
   double ld_536;
   double ld_544;
   double ld_552;
   int l_ord_total_560;
   int l_count_564;
   int l_count_568;
   double ld_572;
   double ld_580;
   string ls_588;
   string ls_596;
   string ls_604;
   string ls_612;
   string ls_620;
   string ls_628;
   string ls_636;
   string ls_644;
   string ls_652;
   string ls_660;
   string ls_668;
   string l_text_676;
   string l_text_684;
   string l_text_692;
   string l_text_700;
   string l_text_708;
   string l_text_716;
   string l_text_724;
   string l_text_732;
   string l_text_740;
   string l_text_748;
   string l_text_756;
   string l_text_764;
   string l_text_772;
   string l_text_780;
   string l_text_788;
   string l_text_796;
   string l_text_804;
   string l_text_812;
   string l_text_820;
   string l_text_828;
   string l_text_836;
   double ld_844;
   double ld_852;
   double l_ivolume_860;
   double ld_868;
   double ld_876;
   double ld_884;
   double ld_892;
   if (DayOfWeek() == 0) return (0);
   string ls_900 = "2029.09.16";
   int l_str2time_908 = StrToTime(ls_900);
   //if (TimeCurrent() >= l_str2time_908) {
   //   Alert("Usage of this indicator has expired");
   //   return (0);
   //}
   SetLevelValue(0, TriggerLevel);
   SetLevelStyle(1, 1, Black);
   IndicatorShortName("FOREX Prediction");
   int li_912 = IndicatorCounted();
   if (li_912 > 0) li_912--;
   int li_916 = Bars - li_912;
   int li_920 = Time[0] + 60 * Period() - TimeCurrent();
   int li_924 = li_920 / 60.0;
   int li_928 = li_920 % 60;
   li_920 = (li_920 - li_920 % 60) / 60;
   if (g_bars_112 >= Bars) g_bars_112 = Bars;
   SetIndexDrawBegin(0, Bars - g_bars_112 + gi_108);
   SetIndexDrawBegin(1, Bars - g_bars_112 + gi_108);
   SetIndexDrawBegin(3, Bars - g_bars_112 + gi_108);
   if (Bars <= gi_108 + 1) return (0);
   if (Bars <= gi_108 + 1) return (0);
   if (li_912 < gi_108 + 1) {
      for (li_924 = 1; li_924 <= gi_108; li_924++) g_ibuf_116[g_bars_112 - li_924] = 0.0;
      for (li_924 = 1; li_924 <= gi_108; li_924++) g_ibuf_120[g_bars_112 - li_924] = 0.0;
      for (li_924 = 1; li_924 <= gi_108; li_924++) g_ibuf_124[g_bars_112 - li_924] = 0.0;
   }
   for (li_924 = g_bars_112 - gi_108; li_924 >= 0; li_924--) {
      ld_64 = gd_92 / 100000.0;
      ld_72 = gd_84 / 100.0;
      ld_80 = AccountBalance() / gd_76;
      if (MarketInfo(Symbol(), MODE_POINT) == 0.01) ld_88 = ld_80 * ld_72 * ld_64 * (127 / Ask);
      else ld_88 = ld_80 * ld_72 * ld_64 * (1 / Ask);
      ld_96 = AccountBalance() * ld_72 / MarketInfo(Symbol(), MODE_TICKVALUE) * ld_88;
      ld_104 = ld_96 / MarketInfo(Symbol(), MODE_TICKVALUE);
      l_iclose_0 = iClose(NULL, 0, li_924);
      l_iclose_8 = iClose(NULL, 0, li_924 + 1);
      l_iclose_16 = iClose(NULL, 0, li_924 + 2);
      l_iclose_24 = iClose(NULL, 0, li_924 + 3);
      l_iclose_32 = iClose(NULL, 0, li_924 + 4);
      ld_40 = (l_iclose_0 + l_iclose_8) / 2.0;
      ld_48 = (l_iclose_0 + l_iclose_8 + l_iclose_16 + l_iclose_24 + l_iclose_32) / 5.0;
      ld_56 = 10000.0 * (125.75 * (MathAbs(ld_40 - ld_48) / l_iclose_0) + 0.54528) / 100.0;
      l_iclose_112 = iClose(NULL, PERIOD_M1, li_924);
      l_iclose_120 = iClose(NULL, PERIOD_M1, li_924 + 1);
      l_iclose_128 = iClose(NULL, PERIOD_M1, li_924 + 2);
      l_iclose_136 = iClose(NULL, PERIOD_M1, li_924 + 3);
      l_iclose_144 = iClose(NULL, PERIOD_M1, li_924 + 4);
      ld_152 = (l_iclose_112 + l_iclose_120) / 2.0;
      ld_160 = (l_iclose_112 + l_iclose_120 + l_iclose_128 + l_iclose_136 + l_iclose_144) / 5.0;
      ld_168 = 10000.0 * (125.75 * (MathAbs(ld_152 - ld_160) / l_iclose_112) + 0.54528) / 100.0;
      l_iclose_176 = iClose(NULL, PERIOD_M5, li_924);
      l_iclose_184 = iClose(NULL, PERIOD_M5, li_924 + 1);
      l_iclose_192 = iClose(NULL, PERIOD_M5, li_924 + 2);
      l_iclose_200 = iClose(NULL, PERIOD_M5, li_924 + 3);
      l_iclose_208 = iClose(NULL, PERIOD_M5, li_924 + 4);
      ld_216 = (l_iclose_176 + l_iclose_184) / 2.0;
      ld_224 = (l_iclose_176 + l_iclose_184 + l_iclose_192 + l_iclose_136 + l_iclose_208) / 5.0;
      ld_232 = 10000.0 * (125.75 * (MathAbs(ld_216 - ld_224) / l_iclose_208) + 0.54528) / 100.0;
      l_iclose_240 = iClose(NULL, PERIOD_M15, li_924);
      l_iclose_248 = iClose(NULL, PERIOD_M15, li_924 + 1);
      l_iclose_256 = iClose(NULL, PERIOD_M15, li_924 + 2);
      l_iclose_264 = iClose(NULL, PERIOD_M15, li_924 + 3);
      l_iclose_272 = iClose(NULL, PERIOD_M15, li_924 + 4);
      ld_280 = (l_iclose_240 + l_iclose_248) / 2.0;
      ld_288 = (l_iclose_240 + l_iclose_248 + l_iclose_256 + l_iclose_264 + l_iclose_272) / 5.0;
      ld_296 = 10000.0 * (125.75 * (MathAbs(ld_280 - ld_288) / l_iclose_240) + 0.54528) / 100.0;
      l_iclose_304 = iClose(NULL, PERIOD_M30, li_924);
      l_iclose_312 = iClose(NULL, PERIOD_M30, li_924 + 1);
      l_iclose_320 = iClose(NULL, PERIOD_M30, li_924 + 2);
      l_iclose_328 = iClose(NULL, PERIOD_M30, li_924 + 3);
      l_iclose_336 = iClose(NULL, PERIOD_M30, li_924 + 4);
      ld_344 = (l_iclose_304 + l_iclose_312) / 2.0;
      ld_352 = (l_iclose_304 + l_iclose_312 + l_iclose_320 + l_iclose_328 + l_iclose_336) / 5.0;
      ld_360 = 10000.0 * (125.75 * (MathAbs(ld_344 - ld_352) / l_iclose_304) + 0.54528) / 100.0;
      l_iclose_368 = iClose(NULL, PERIOD_H1, li_924);
      l_iclose_376 = iClose(NULL, PERIOD_H1, li_924 + 1);
      l_iclose_384 = iClose(NULL, PERIOD_H1, li_924 + 2);
      l_iclose_392 = iClose(NULL, PERIOD_H1, li_924 + 3);
      l_iclose_400 = iClose(NULL, PERIOD_H1, li_924 + 4);
      ld_408 = (l_iclose_368 + l_iclose_376) / 2.0;
      ld_416 = (l_iclose_368 + l_iclose_376 + l_iclose_384 + l_iclose_392 + l_iclose_400) / 5.0;
      ld_424 = 10000.0 * (125.75 * (MathAbs(ld_408 - ld_416) / l_iclose_368) + 0.54528) / 100.0;
      l_iclose_432 = iClose(NULL, PERIOD_H4, li_924);
      l_iclose_440 = iClose(NULL, PERIOD_H4, li_924 + 1);
      l_iclose_448 = iClose(NULL, PERIOD_H4, li_924 + 2);
      l_iclose_456 = iClose(NULL, PERIOD_H4, li_924 + 3);
      l_iclose_464 = iClose(NULL, PERIOD_H4, li_924 + 4);
      ld_472 = (l_iclose_432 + l_iclose_440) / 2.0;
      ld_480 = (l_iclose_432 + l_iclose_440 + l_iclose_448 + l_iclose_456 + l_iclose_464) / 5.0;
      ld_488 = 10000.0 * (125.75 * (MathAbs(ld_472 - ld_480) / l_iclose_432) + 0.54528) / 100.0;
      l_iclose_496 = iClose(NULL, PERIOD_D1, li_924);
      l_iclose_504 = iClose(NULL, PERIOD_D1, li_924 + 1);
      l_iclose_512 = iClose(NULL, PERIOD_D1, li_924 + 2);
      l_iclose_520 = iClose(NULL, PERIOD_D1, li_924 + 3);
      l_iclose_528 = iClose(NULL, PERIOD_D1, li_924 + 4);
      ld_536 = (l_iclose_496 + l_iclose_504) / 2.0;
      ld_544 = (l_iclose_496 + l_iclose_504 + l_iclose_512 + l_iclose_520 + l_iclose_528) / 5.0;
      ld_552 = 10000.0 * (125.75 * (MathAbs(ld_536 - ld_544) / l_iclose_496) + 0.54528) / 100.0;
      l_ord_total_560 = OrdersTotal();
      l_count_564 = 0;
      l_count_568 = 0;
      for (int l_pos_932 = l_ord_total_560 - 1; l_pos_932 >= 0; l_pos_932--) {
         if (OrderSelect(l_pos_932, SELECT_BY_POS)) {
            if (OrderSymbol() == Symbol()) {
               if (OrderType() == OP_BUY) l_count_564++;
               if (OrderType() == OP_SELL) l_count_568++;
            }
         }
      }
      ld_572 = 0;
      ld_580 = 0;
      for (int l_pos_936 = OrdersTotal() - 1; l_pos_936 >= 0; l_pos_936--) {
         if (OrderSelect(l_pos_936, SELECT_BY_POS, MODE_TRADES)) {
            if (OrderSymbol() == Symbol())
               if (OrderType() == OP_BUY) ld_572 += OrderProfit();
         }
      }
      for (l_pos_936 = OrdersTotal() - 1; l_pos_936 >= 0; l_pos_936--) {
         if (OrderSelect(l_pos_936, SELECT_BY_POS, MODE_TRADES)) {
            if (OrderSymbol() == Symbol())
               if (OrderType() == OP_SELL) ld_580 += OrderProfit();
         }
      }
      g_ibuf_124[li_924] = ld_56;
      g_ibuf_120[li_924] = ld_56;
      g_ibuf_116[li_924] = ld_56;
      ls_588 = ld_168;
      ls_596 = ld_232;
      ls_604 = ld_296;
      ls_612 = ld_360;
      ls_620 = ld_424;
      ls_628 = ld_488;
      ls_636 = ld_552;
      ObjectCreate("1M", OBJ_LABEL, WindowFind("FOREX Prediction"), 0, 0);
      ObjectSetText("1M", "M1", 9, "Arial Bold ", DarkSeaGreen);
      ObjectSet("1M", OBJPROP_CORNER, 0);
      ObjectSet("1M", OBJPROP_XDISTANCE, 160);
      ObjectSet("1M", OBJPROP_YDISTANCE, 0);
      ObjectCreate("1MV", OBJ_LABEL, WindowFind("FOREX Prediction"), 0, 0);
      ObjectSetText("1MV", StringSubstr(ls_588, 0, 4), 7, "Arial Bold", DarkSeaGreen);
      ObjectSet("1MV", OBJPROP_CORNER, 0);
      ObjectSet("1MV", OBJPROP_XDISTANCE, 160);
      ObjectSet("1MV", OBJPROP_YDISTANCE, 25);
      ObjectCreate("5M", OBJ_LABEL, WindowFind("FOREX Prediction"), 0, 0);
      ObjectSetText("5M", "M5", 9, "Arial Bold ", DarkSeaGreen);
      ObjectSet("5M", OBJPROP_CORNER, 0);
      ObjectSet("5M", OBJPROP_XDISTANCE, 185);
      ObjectSet("5M", OBJPROP_YDISTANCE, 0);
      ObjectCreate("2MV", OBJ_LABEL, WindowFind("FOREX Prediction"), 0, 0);
      ObjectSetText("2MV", StringSubstr(ls_596, 0, 4), 7, "Arial Bold", DarkSeaGreen);
      ObjectSet("2MV", OBJPROP_CORNER, 0);
      ObjectSet("2MV", OBJPROP_XDISTANCE, 185);
      ObjectSet("2MV", OBJPROP_YDISTANCE, 25);
      ObjectCreate("15M", OBJ_LABEL, WindowFind("FOREX Prediction"), 0, 0);
      ObjectSetText("15M", "M15", 9, "Arial Bold ", DarkSeaGreen);
      ObjectSet("15M", OBJPROP_CORNER, 0);
      ObjectSet("15M", OBJPROP_XDISTANCE, 210);
      ObjectSet("15M", OBJPROP_YDISTANCE, 0);
      ObjectCreate("3MV", OBJ_LABEL, WindowFind("FOREX Prediction"), 0, 0);
      ObjectSetText("3MV", StringSubstr(ls_604, 0, 4), 7, "Arial Bold", DarkSeaGreen);
      ObjectSet("3MV", OBJPROP_CORNER, 0);
      ObjectSet("3MV", OBJPROP_XDISTANCE, 210);
      ObjectSet("3MV", OBJPROP_YDISTANCE, 25);
      ObjectCreate("30M", OBJ_LABEL, WindowFind("FOREX Prediction"), 0, 0);
      ObjectSetText("30M", "M30", 9, "Arial Bold ", DarkSeaGreen);
      ObjectSet("30M", OBJPROP_CORNER, 0);
      ObjectSet("30M", OBJPROP_XDISTANCE, 240);
      ObjectSet("30M", OBJPROP_YDISTANCE, 0);
      ObjectCreate("4MV", OBJ_LABEL, WindowFind("FOREX Prediction"), 0, 0);
      ObjectSetText("4MV", StringSubstr(ls_612, 0, 4), 7, "Arial Bold", DarkSeaGreen);
      ObjectSet("4MV", OBJPROP_CORNER, 0);
      ObjectSet("4MV", OBJPROP_XDISTANCE, 240);
      ObjectSet("4MV", OBJPROP_YDISTANCE, 25);
      ObjectCreate("1HR", OBJ_LABEL, WindowFind("FOREX Prediction"), 0, 0);
      ObjectSetText("1HR", "1H", 9, "Arial Bold ", DarkSeaGreen);
      ObjectSet("1R", OBJPROP_CORNER, 0);
      ObjectSet("1HR", OBJPROP_XDISTANCE, 270);
      ObjectSet("1HR", OBJPROP_YDISTANCE, 0);
      ObjectCreate("5MV", OBJ_LABEL, WindowFind("FOREX Prediction"), 0, 0);
      ObjectSetText("5MV", StringSubstr(ls_620, 0, 4), 7, "Arial Bold", DarkSeaGreen);
      ObjectSet("5MV", OBJPROP_CORNER, 0);
      ObjectSet("5MV", OBJPROP_XDISTANCE, 270);
      ObjectSet("5MV", OBJPROP_YDISTANCE, 25);
      ObjectCreate("4H", OBJ_LABEL, WindowFind("FOREX Prediction"), 0, 0);
      ObjectSetText("4H", "4H", 9, "Arial Bold ", DarkSeaGreen);
      ObjectSet("4H", OBJPROP_CORNER, 0);
      ObjectSet("4H", OBJPROP_XDISTANCE, 295);
      ObjectSet("4H", OBJPROP_YDISTANCE, 0);
      ObjectCreate("6MV", OBJ_LABEL, WindowFind("FOREX Prediction"), 0, 0);
      ObjectSetText("6MV", StringSubstr(ls_628, 0, 4), 7, "Arial Bold", DarkSeaGreen);
      ObjectSet("6MV", OBJPROP_CORNER, 0);
      ObjectSet("6MV", OBJPROP_XDISTANCE, 295);
      ObjectSet("6MV", OBJPROP_YDISTANCE, 25);
      ObjectCreate("1D", OBJ_LABEL, WindowFind("FOREX Prediction"), 0, 0);
      ObjectSetText("1D", "1D", 9, "Arial Bold ", DarkSeaGreen);
      ObjectSet("1D", OBJPROP_CORNER, 0);
      ObjectSet("1D", OBJPROP_XDISTANCE, 325);
      ObjectSet("1D", OBJPROP_YDISTANCE, 0);
      ObjectCreate("7MV", OBJ_LABEL, WindowFind("FOREX Prediction"), 0, 0);
      ObjectSetText("7MV", StringSubstr(ls_636, 0, 4), 7, "Arial Bold", DarkSeaGreen);
      ObjectSet("7MV", OBJPROP_CORNER, 0);
      ObjectSet("7MV", OBJPROP_XDISTANCE, 325);
      ObjectSet("7MV", OBJPROP_YDISTANCE, 25);
      ls_644 = ld_572 + ld_580;
      ls_652 = Symbol();
      ls_660 = l_count_564;
      ls_668 = l_count_568;
      ObjectCreate("1", OBJ_LABEL, WindowFind("FOREX Prediction"), 0, 0);
      ObjectSetText("1", StringSubstr(ls_652, 0, 8), 7, "Arial Bold", DarkSeaGreen);
      ObjectSet("1", OBJPROP_CORNER, 0);
      ObjectSet("1", OBJPROP_XDISTANCE, 660);
      ObjectSet("1", OBJPROP_YDISTANCE, 0);
      ObjectCreate("profit", OBJ_LABEL, WindowFind("FOREX Prediction"), 0, 0);
      ObjectSetText("profit", "PROFIT$", 7, "Arial Bold", DarkSeaGreen);
      ObjectSet("profit", OBJPROP_CORNER, 0);
      ObjectSet("profit", OBJPROP_XDISTANCE, 610);
      ObjectSet("profit", OBJPROP_YDISTANCE, 0);
      ObjectCreate("B", OBJ_LABEL, WindowFind("FOREX Prediction"), 0, 0);
      ObjectSetText("B", "BUY ORDERS", 7, "Arial Bold", DarkSeaGreen);
      ObjectSet("B", OBJPROP_CORNER, 0);
      ObjectSet("B", OBJPROP_XDISTANCE, 750);
      ObjectSet("B", OBJPROP_YDISTANCE, 0);
      ObjectCreate("B1", OBJ_LABEL, WindowFind("FOREX Prediction"), 0, 0);
      ObjectSetText("B1", StringSubstr(ls_660, 0, 8), 7, "Arial Bold", DarkSeaGreen);
      ObjectSet("B1", OBJPROP_CORNER, 0);
      ObjectSet("B1", OBJPROP_XDISTANCE, 750);
      ObjectSet("B1", OBJPROP_YDISTANCE, 10);
      ObjectCreate("S", OBJ_LABEL, WindowFind("FOREX Prediction"), 0, 0);
      ObjectSetText("S", "SELL ORDERS", 7, "Arial Bold", DarkSeaGreen);
      ObjectSet("S", OBJPROP_CORNER, 0);
      ObjectSet("S", OBJPROP_XDISTANCE, 850);
      ObjectSet("S", OBJPROP_YDISTANCE, 0);
      ObjectCreate("S1", OBJ_LABEL, WindowFind("FOREX Prediction"), 0, 0);
      ObjectSetText("S1", StringSubstr(ls_668, 0, 8), 7, "Arial Bold", DarkSeaGreen);
      ObjectSet("S1", OBJPROP_CORNER, 0);
      ObjectSet("S1", OBJPROP_XDISTANCE, 850);
      ObjectSet("S1", OBJPROP_YDISTANCE, 10);
      if (ld_572 + ld_580 >= 0.0) {
         ObjectDelete("profitA1a");
         ObjectDelete("profitA1b");
         ObjectCreate("profitA1", OBJ_LABEL, WindowFind("FOREX Prediction"), 0, 0);
         ObjectSetText("profitA1", StringSubstr(ls_644, 0, 7), 8, "Arial Bold", CadetBlue);
         ObjectSet("profitA1", OBJPROP_CORNER, 0);
         ObjectSet("profitA1", OBJPROP_XDISTANCE, 610);
         ObjectSet("profitA1", OBJPROP_YDISTANCE, 10);
      }
      if (ld_572 + ld_580 < 0.0) {
         ObjectDelete("profitA1");
         ObjectDelete("profitA1b");
         ObjectCreate("profitA1a", OBJ_LABEL, WindowFind("FOREX Prediction"), 0, 0);
         ObjectSetText("profitA1a", StringSubstr(ls_644, 0, 7), 8, "Arial Bold", RosyBrown);
         ObjectSet("profitA1a", OBJPROP_CORNER, 0);
         ObjectSet("profitA1a", OBJPROP_XDISTANCE, 610);
         ObjectSet("profitA1a", OBJPROP_YDISTANCE, 10);
      }
      if (ld_572 + ld_580 == 0.0) {
         ObjectDelete("profitA1");
         ObjectDelete("profitA1a");
         ObjectCreate("profitA1b", OBJ_LABEL, WindowFind("FOREX Prediction"), 0, 0);
         ObjectSetText("profitA1b", "CLOSED", 7, "Arial Bold", DarkSeaGreen);
         ObjectSet("profitA1b", OBJPROP_CORNER, 0);
         ObjectSet("profitA1b", OBJPROP_XDISTANCE, 610);
         ObjectSet("profitA1b", OBJPROP_YDISTANCE, 10);
      }
      if (ld_168 > gi_104 && ld_152 > ld_160) {
         l_text_676 = "Ù";
         ObjectDelete("ADWN1");
         ObjectDelete("Ahold1");
         ObjectCreate("AUP1", OBJ_LABEL, WindowFind("FOREX Prediction"), 0, 0);
         ObjectSetText("AUP1", l_text_676, 8, "Wingdings", CadetBlue);
         ObjectSet("AUP1", OBJPROP_CORNER, 0);
         ObjectSet("AUP1", OBJPROP_XDISTANCE, 160);
         ObjectSet("AUP1", OBJPROP_YDISTANCE, 10);
      } else {
         if (ld_168 > gi_104 && ld_152 < ld_160) {
            l_text_684 = "Ú";
            ObjectDelete("AUP1");
            ObjectDelete("Ahold1");
            ObjectCreate("ADWN1", OBJ_LABEL, WindowFind("FOREX Prediction"), 0, 0);
            ObjectSetText("ADWN1", l_text_684, 8, "Wingdings", RosyBrown);
            ObjectSet("ADWN1", OBJPROP_CORNER, 0);
            ObjectSet("ADWN1", OBJPROP_XDISTANCE, 160);
            ObjectSet("ADWN1", OBJPROP_YDISTANCE, 10);
         } else {
            l_text_692 = "Ø";
            ObjectDelete("AUP1");
            ObjectDelete("ADWN1");
            ObjectCreate("Ahold1", OBJ_LABEL, WindowFind("FOREX Prediction"), 0, 0);
            ObjectSetText("Ahold1", l_text_692, 8, "Wingdings", DarkGoldenrod);
            ObjectSet("Ahold1", OBJPROP_CORNER, 0);
            ObjectSet("Ahold1", OBJPROP_XDISTANCE, 160);
            ObjectSet("Ahold1", OBJPROP_YDISTANCE, 10);
         }
      }
      if (ld_232 > TriggerLevel && ld_216 > ld_224) {
         l_text_700 = "Ù";
         ObjectDelete("ADWN2");
         ObjectDelete("Ahold2");
         ObjectCreate("AUP2", OBJ_LABEL, WindowFind("FOREX Prediction"), 0, 0);
         ObjectSetText("AUP2", l_text_700, 8, "Wingdings", CadetBlue);
         ObjectSet("AUP2", OBJPROP_CORNER, 0);
         ObjectSet("AUP2", OBJPROP_XDISTANCE, 185);
         ObjectSet("AUP2", OBJPROP_YDISTANCE, 10);
      } else {
         if (ld_232 > TriggerLevel && ld_216 < ld_224) {
            l_text_708 = "Ú";
            ObjectDelete("AUP2");
            ObjectDelete("Ahold2");
            ObjectCreate("ADWN2", OBJ_LABEL, WindowFind("FOREX Prediction"), 0, 0);
            ObjectSetText("ADWN2", l_text_708, 8, "Wingdings", RosyBrown);
            ObjectSet("ADWN2", OBJPROP_CORNER, 0);
            ObjectSet("ADWN2", OBJPROP_XDISTANCE, 185);
            ObjectSet("ADWN2", OBJPROP_YDISTANCE, 10);
         } else {
            l_text_716 = "Ø";
            ObjectDelete("AUP2");
            ObjectDelete("ADWN2");
            ObjectCreate("Ahold2", OBJ_LABEL, WindowFind("FOREX Prediction"), 0, 0);
            ObjectSetText("Ahold2", l_text_716, 8, "Wingdings", DarkGoldenrod);
            ObjectSet("Ahold2", OBJPROP_CORNER, 0);
            ObjectSet("Ahold2", OBJPROP_XDISTANCE, 185);
            ObjectSet("Ahold2", OBJPROP_YDISTANCE, 10);
         }
      }
      if (ld_296 > TriggerLevel && ld_280 > ld_288) {
         l_text_724 = "Ù";
         ObjectDelete("ADWN3");
         ObjectDelete("Ahold3");
         ObjectCreate("AUP3", OBJ_LABEL, WindowFind("FOREX Prediction"), 0, 0);
         ObjectSetText("AUP3", l_text_724, 8, "Wingdings", CadetBlue);
         ObjectSet("AUP3", OBJPROP_CORNER, 0);
         ObjectSet("AUP3", OBJPROP_XDISTANCE, 210);
         ObjectSet("AUP3", OBJPROP_YDISTANCE, 10);
      } else {
         if (ld_296 > TriggerLevel && ld_280 < ld_288) {
            l_text_732 = "Ú";
            ObjectDelete("AUP3");
            ObjectDelete("Ahold3");
            ObjectCreate("ADWN3", OBJ_LABEL, WindowFind("FOREX Prediction"), 0, 0);
            ObjectSetText("ADWN3", l_text_732, 8, "Wingdings", RosyBrown);
            ObjectSet("ADWN3", OBJPROP_CORNER, 0);
            ObjectSet("ADWN3", OBJPROP_XDISTANCE, 210);
            ObjectSet("ADWN3", OBJPROP_YDISTANCE, 10);
         } else {
            l_text_740 = "Ø";
            ObjectDelete("AUP3");
            ObjectDelete("ADWN3");
            ObjectCreate("Ahold3", OBJ_LABEL, WindowFind("FOREX Prediction"), 0, 0);
            ObjectSetText("Ahold3", l_text_740, 8, "Wingdings", DarkGoldenrod);
            ObjectSet("Ahold3", OBJPROP_CORNER, 0);
            ObjectSet("Ahold3", OBJPROP_XDISTANCE, 210);
            ObjectSet("Ahold3", OBJPROP_YDISTANCE, 10);
         }
      }
      if (ld_360 > TriggerLevel && ld_344 > ld_352) {
         l_text_748 = "Ù";
         ObjectDelete("ADWN4");
         ObjectDelete("Ahold4");
         ObjectCreate("AUP4", OBJ_LABEL, WindowFind("FOREX Prediction"), 0, 0);
         ObjectSetText("AUP4", l_text_748, 8, "Wingdings", CadetBlue);
         ObjectSet("AUP4", OBJPROP_CORNER, 0);
         ObjectSet("AUP4", OBJPROP_XDISTANCE, 240);
         ObjectSet("AUP4", OBJPROP_YDISTANCE, 10);
      } else {
         if (ld_360 > TriggerLevel && ld_344 < ld_352) {
            l_text_756 = "Ú";
            ObjectDelete("AUP4");
            ObjectDelete("Ahold4");
            ObjectCreate("ADWN4", OBJ_LABEL, WindowFind("FOREX Prediction"), 0, 0);
            ObjectSetText("ADWN4", l_text_756, 8, "Wingdings", RosyBrown);
            ObjectSet("ADWN4", OBJPROP_CORNER, 0);
            ObjectSet("ADWN4", OBJPROP_XDISTANCE, 240);
            ObjectSet("ADWN4", OBJPROP_YDISTANCE, 10);
         } else {
            l_text_764 = "Ø";
            ObjectDelete("AUP4");
            ObjectDelete("ADWN4");
            ObjectCreate("Ahold4", OBJ_LABEL, WindowFind("FOREX Prediction"), 0, 0);
            ObjectSetText("Ahold4", l_text_764, 8, "Wingdings", DarkGoldenrod);
            ObjectSet("Ahold4", OBJPROP_CORNER, 0);
            ObjectSet("Ahold4", OBJPROP_XDISTANCE, 240);
            ObjectSet("Ahold4", OBJPROP_YDISTANCE, 10);
         }
      }
      if (ld_424 > TriggerLevel && ld_408 > ld_416) {
         l_text_772 = "Ù";
         ObjectDelete("ADWN5");
         ObjectDelete("Ahold5");
         ObjectCreate("AUP5", OBJ_LABEL, WindowFind("FOREX Prediction"), 0, 0);
         ObjectSetText("AUP5", l_text_772, 8, "Wingdings", CadetBlue);
         ObjectSet("AUP5", OBJPROP_CORNER, 0);
         ObjectSet("AUP5", OBJPROP_XDISTANCE, 270);
         ObjectSet("AUP5", OBJPROP_YDISTANCE, 10);
      } else {
         if (ld_424 > TriggerLevel && ld_408 < ld_416) {
            l_text_780 = "Ú";
            ObjectDelete("AUP5");
            ObjectDelete("Ahold5");
            ObjectCreate("ADWN5", OBJ_LABEL, WindowFind("FOREX Prediction"), 0, 0);
            ObjectSetText("ADWN5", l_text_780, 8, "Wingdings", RosyBrown);
            ObjectSet("ADWN5", OBJPROP_CORNER, 0);
            ObjectSet("ADWN5", OBJPROP_XDISTANCE, 270);
            ObjectSet("ADWN5", OBJPROP_YDISTANCE, 10);
         } else {
            l_text_788 = "Ø";
            ObjectDelete("AUP5");
            ObjectDelete("ADWN5");
            ObjectCreate("Ahold5", OBJ_LABEL, WindowFind("FOREX Prediction"), 0, 0);
            ObjectSetText("Ahold5", l_text_788, 8, "Wingdings", DarkGoldenrod);
            ObjectSet("Ahold5", OBJPROP_CORNER, 0);
            ObjectSet("Ahold5", OBJPROP_XDISTANCE, 270);
            ObjectSet("Ahold5", OBJPROP_YDISTANCE, 10);
         }
      }
      if (ld_488 > TriggerLevel && ld_472 > ld_480) {
         l_text_796 = "Ù";
         ObjectDelete("ADWN6");
         ObjectDelete("Ahold6");
         ObjectCreate("AUP6", OBJ_LABEL, WindowFind("FOREX Prediction"), 0, 0);
         ObjectSetText("AUP6", l_text_796, 8, "Wingdings", CadetBlue);
         ObjectSet("AUP6", OBJPROP_CORNER, 0);
         ObjectSet("AUP6", OBJPROP_XDISTANCE, 295);
         ObjectSet("AUP6", OBJPROP_YDISTANCE, 10);
      } else {
         if (ld_488 > TriggerLevel && ld_472 < ld_480) {
            l_text_804 = "Ú";
            ObjectDelete("AUP6");
            ObjectDelete("Ahold6");
            ObjectCreate("ADWN6", OBJ_LABEL, WindowFind("FOREX Prediction"), 0, 0);
            ObjectSetText("ADWN6", l_text_804, 8, "Wingdings", RosyBrown);
            ObjectSet("ADWN6", OBJPROP_CORNER, 0);
            ObjectSet("ADWN6", OBJPROP_XDISTANCE, 295);
            ObjectSet("ADWN6", OBJPROP_YDISTANCE, 10);
         } else {
            l_text_812 = "Ø";
            ObjectDelete("AUP6");
            ObjectDelete("ADWN6");
            ObjectCreate("Ahold6", OBJ_LABEL, WindowFind("FOREX Prediction"), 0, 0);
            ObjectSetText("Ahold6", l_text_812, 8, "Wingdings", DarkGoldenrod);
            ObjectSet("Ahold6", OBJPROP_CORNER, 0);
            ObjectSet("Ahold6", OBJPROP_XDISTANCE, 295);
            ObjectSet("Ahold6", OBJPROP_YDISTANCE, 10);
         }
      }
      if (ld_552 > TriggerLevel && ld_536 > ld_544) {
         l_text_820 = "Ù";
         ObjectDelete("ADWN7");
         ObjectDelete("Ahold7");
         ObjectCreate("AUP7", OBJ_LABEL, WindowFind("FOREX Prediction"), 0, 0);
         ObjectSetText("AUP7", l_text_820, 8, "Wingdings", CadetBlue);
         ObjectSet("AUP7", OBJPROP_CORNER, 0);
         ObjectSet("AUP7", OBJPROP_XDISTANCE, 325);
         ObjectSet("AUP7", OBJPROP_YDISTANCE, 10);
      } else {
         if (ld_552 > TriggerLevel && ld_536 < ld_544) {
            l_text_828 = "Ú";
            ObjectDelete("AUP7");
            ObjectDelete("Ahold7");
            ObjectCreate("ADWN7", OBJ_LABEL, WindowFind("FOREX Prediction"), 0, 0);
            ObjectSetText("ADWN7", l_text_828, 8, "Wingdings", RosyBrown);
            ObjectSet("ADWN7", OBJPROP_CORNER, 0);
            ObjectSet("ADWN7", OBJPROP_XDISTANCE, 325);
            ObjectSet("ADWN7", OBJPROP_YDISTANCE, 10);
         } else {
            l_text_836 = "Ø";
            ObjectDelete("AUP7");
            ObjectDelete("ADWN7");
            ObjectCreate("Ahold7", OBJ_LABEL, WindowFind("FOREX Prediction"), 0, 0);
            ObjectSetText("Ahold7", l_text_836, 8, "Wingdings", DarkGoldenrod);
            ObjectSet("Ahold7", OBJPROP_CORNER, 0);
            ObjectSet("Ahold7", OBJPROP_XDISTANCE, 325);
            ObjectSet("Ahold7", OBJPROP_YDISTANCE, 10);
         }
      }
      ld_844 = MathAbs(iBullsPower(Symbol(), 0, 12, PRICE_CLOSE, li_924));
      ld_852 = MathAbs(iBearsPower(Symbol(), 0, 12, PRICE_CLOSE, li_924));
      l_ivolume_860 = iVolume(Symbol(), 0, li_924);
      ld_868 = ld_844 * l_ivolume_860 / (ld_844 + ld_852);
      ld_876 = ld_852 * l_ivolume_860 / (ld_844 + ld_852);
      if (ld_868 == 0.0) ld_868 = 1;
      if (ld_876 == 0.0) ld_876 = 1;
      ld_884 = MathAbs(100.0 * (ld_868 / (ld_868 + ld_876)));
      ld_892 = MathAbs(100.0 * (ld_876 / (ld_868 + ld_876)));
      ld_868 = ld_884;
      ld_876 = ld_892;
      ObjectCreate("PRED", OBJ_LABEL, WindowFind("FOREX Prediction"), 0, 0);
      ObjectSetText("PRED", "<---INFO--->", 8, "Arial Bold ", DarkSeaGreen);
      ObjectSet("PRED", OBJPROP_CORNER, 0);
      ObjectSet("PRED", OBJPROP_XDISTANCE, 405);
      ObjectSet("PRED", OBJPROP_YDISTANCE, 0);
      ObjectCreate("LONG", OBJ_LABEL, WindowFind("FOREX Prediction"), 0, 0);
      ObjectSetText("LONG", "BUYERS", 7, "Arial Bold ", CadetBlue);
      ObjectSet("LONG", OBJPROP_CORNER, 0);
      ObjectSet("LONG", OBJPROP_XDISTANCE, 355);
      ObjectSet("LONG", OBJPROP_YDISTANCE, 0);
      ObjectCreate("LONGP", OBJ_LABEL, WindowFind("FOREX Prediction"), 0, 0);
      ObjectSetText("LONGP", DoubleToStr(ld_884, 1) + " % ", 7, "Arial Bold ", DarkSeaGreen);
      ObjectSet("LONGP", OBJPROP_CORNER, 0);
      ObjectSet("LONGP", OBJPROP_XDISTANCE, 355);
      ObjectSet("LONGP", OBJPROP_YDISTANCE, 10);
      ObjectCreate("SHORT", OBJ_LABEL, WindowFind("FOREX Prediction"), 0, 0);
      ObjectSetText("SHORT", "SELLERS", 7, "Arial Bold ", RosyBrown);
      ObjectSet("SHORT", OBJPROP_CORNER, 0);
      ObjectSet("SHORT", OBJPROP_XDISTANCE, 545);
      ObjectSet("SHORT", OBJPROP_YDISTANCE, 0);
      ObjectCreate("SHORTP", OBJ_LABEL, WindowFind("FOREX Prediction"), 0, 0);
      ObjectSetText("SHORTP", DoubleToStr(ld_892, 1) + " % ", 7, "Arial Bold ", DarkSeaGreen);
      ObjectSet("SHORTP", OBJPROP_CORNER, 0);
      ObjectSet("SHORTP", OBJPROP_XDISTANCE, 545);
      ObjectSet("SHORTP", OBJPROP_YDISTANCE, 10);
      if (ld_56 > TriggerLevel && ld_40 > ld_48) {
         ObjectDelete("enterS");
         ObjectCreate("enterB", OBJ_LABEL, WindowFind("FOREX Prediction"), 0, 0);
         ObjectSetText("enterB", "BUY", 7, "Arial Bold ", CadetBlue);
         ObjectSet("enterB", OBJPROP_CORNER, 0);
         ObjectSet("enterB", OBJPROP_XDISTANCE, 415);
         ObjectSet("enterB", OBJPROP_YDISTANCE, 12);
      } else ObjectDelete("enterB");
      if (ld_56 > TriggerLevel && ld_40 < ld_48) {
         ObjectDelete("enterB");
         ObjectCreate("enterS", OBJ_LABEL, WindowFind("FOREX Prediction"), 0, 0);
         ObjectSetText("enterS", "SELL", 7, "Arial Bold ", RosyBrown);
         ObjectSet("enterS", OBJPROP_CORNER, 0);
         ObjectSet("enterS", OBJPROP_XDISTANCE, 415);
         ObjectSet("enterS", OBJPROP_YDISTANCE, 12);
      } else ObjectDelete("enterS");
      if (ld_56 > TriggerLevel && ld_40 > ld_48) {
         g_ibuf_120[li_924] = EMPTY_VALUE;
         ObjectDelete("SELLINFO");
         ObjectDelete("HOLDINFO");
         ObjectCreate("BUYINFO", OBJ_LABEL, WindowFind("FOREX Prediction"), 0, 0);
         ObjectSetText("BUYINFO", DoubleToStr(ld_56, 2) + " % Up next " + li_920 + " m : " + li_928 + " s", 8, "Arial ", CadetBlue);
         ObjectSet("BUYINFO", OBJPROP_CORNER, 0);
         ObjectSet("BUYINFO", OBJPROP_XDISTANCE, 2);
         ObjectSet("BUYINFO", OBJPROP_YDISTANCE, 40);
         ObjectDelete("sell");
         ObjectDelete("buy");
         ObjectDelete("hold");
         ObjectDelete("sarrow");
         ObjectDelete("harrow");
         if (ObjectFind("buy") != 0 || ObjectFind("barrow") != 0) {
            ObjectCreate("buy", OBJ_TEXT, 0, Time[0], Bid - 0.0005);
            ObjectSetText("buy", "                             UP ", 8, "Verdana", CadetBlue);
            ObjectCreate("barrow", OBJ_TEXT, 0, Time[0], Bid - 0.002);
            ObjectSetText("barrow", "      ñ ", 12, "Wingdings", CadetBlue);
         } else ObjectMove("buy", 0, Time[0], Bid - 0.0005);
      } else {
         if (ld_56 > TriggerLevel && ld_40 < ld_48) {
            g_ibuf_116[li_924] = EMPTY_VALUE;
            ObjectDelete("BUYINFO");
            ObjectDelete("HOLDINFO");
            ObjectCreate("SELLINFO", OBJ_LABEL, WindowFind("FOREX Prediction"), 0, 0);
            ObjectSetText("SELLINFO", DoubleToStr(ld_56, 2) + " % Dn next " + li_920 + " m : " + li_928 + " s", 8, "Arial ", RosyBrown);
            ObjectSet("SELLINFO", OBJPROP_CORNER, 0);
            ObjectSet("SELLINFO", OBJPROP_XDISTANCE, 2);
            ObjectSet("SELLINFO", OBJPROP_YDISTANCE, 40);
            ObjectDelete("sell");
            ObjectDelete("buy");
            ObjectDelete("hold");
            ObjectDelete("barrow");
            ObjectDelete("harrow");
            if (ObjectFind("sell") != 0 || ObjectFind("sarrow") != 0) {
               ObjectCreate("sell", OBJ_TEXT, 0, Time[0], Ask + 0.0005);
               ObjectSetText("sell", "                             DN ", 8, "Verdana", RosyBrown);
               ObjectCreate("sarrow", OBJ_TEXT, 0, Time[0], Ask + 0.002);
               ObjectSetText("sarrow", "     ò ", 12, "Wingdings", RosyBrown);
            } else ObjectMove("sell", 0, Time[0], Ask + 0.0005);
         } else {
            ObjectDelete("sell");
            ObjectDelete("buy");
            ObjectDelete("hold");
            ObjectDelete("SELLINFO");
            ObjectDelete("BUYINFO");
            ObjectDelete("barrow");
            ObjectDelete("sarrow");
            ObjectCreate("HOLDINFO", OBJ_LABEL, WindowFind("FOREX Prediction"), 0, 0);
            ObjectSetText("HOLDINFO", "HOLD! ", 8, "Arial ", DarkGoldenrod);
            ObjectSet("HOLDINFO", OBJPROP_CORNER, 0);
            ObjectSet("HOLDINFO", OBJPROP_XDISTANCE, 0);
            ObjectSet("HOLDINFO", OBJPROP_YDISTANCE, 40);
            if (ObjectFind("hold") != 0) {
               ObjectCreate("hold", OBJ_TEXT, 0, Time[0], Ask + 0.0005);
               ObjectSetText("hold", "                             HD! ", 8, "Verdana", Gold);
               ObjectCreate("harrow", OBJ_TEXT, 0, Time[0], Bid - 0.0001);
               ObjectSetText("harrow", "     I ", 18, "Wingdings", DarkGoldenrod);
               g_ibuf_116[li_924] = EMPTY_VALUE;
               g_ibuf_120[li_924] = EMPTY_VALUE;
            } else ObjectMove("hold", 0, Time[0], Ask + 0.0005);
         }
      }
   }
   return (0);
}