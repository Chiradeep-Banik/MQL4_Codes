
#property copyright ""
#property link      ""

#property indicator_chart_window

extern int KLPeriod = 14;

int init() {
   drawLabel();
   return (0);
}

int deinit() {
   ObjectsDeleteAll();
   return (0);
}

int start() {
   double l_iclose_0 = iClose(NULL, PERIOD_D1, iHighest(NULL, PERIOD_D1, MODE_CLOSE, KLPeriod, 1));
   double l_iclose_8 = iClose(NULL, PERIOD_H4, iHighest(NULL, PERIOD_H4, MODE_CLOSE, KLPeriod, 1));
   double l_iclose_16 = iClose(NULL, PERIOD_H1, iHighest(NULL, PERIOD_H1, MODE_CLOSE, KLPeriod, 1));
   double l_iclose_24 = iClose(NULL, PERIOD_M30, iHighest(NULL, PERIOD_M30, MODE_CLOSE, KLPeriod, 1));
   double l_iclose_32 = iClose(NULL, PERIOD_M15, iHighest(NULL, PERIOD_M15, MODE_CLOSE, KLPeriod, 1));
   drawLine("HH_D1r %", Time[50], Time[40], l_iclose_0, l_iclose_0, 3, 3, Red, 0);
   double l_iclose_40 = iClose(NULL, PERIOD_D1, iLowest(NULL, PERIOD_D1, MODE_CLOSE, KLPeriod, 1));
   double l_iclose_48 = iClose(NULL, PERIOD_H4, iLowest(NULL, PERIOD_H4, MODE_CLOSE, KLPeriod, 1));
   double l_iclose_56 = iClose(NULL, PERIOD_H1, iLowest(NULL, PERIOD_H1, MODE_CLOSE, KLPeriod, 1));
   double l_iclose_64 = iClose(NULL, PERIOD_M30, iLowest(NULL, PERIOD_M30, MODE_CLOSE, KLPeriod, 1));
   double l_iclose_72 = iClose(NULL, PERIOD_M15, iLowest(NULL, PERIOD_M15, MODE_CLOSE, KLPeriod, 1));
   drawLine("LL_D1r", Time[50], Time[40], l_iclose_40, l_iclose_40, 3, 3, Lime, 0);
   return (0);
}

void drawLine(string a_name_0, int a_datetime_8, int a_datetime_12, double a_price_16, double a_price_24, int a_width_32, int a_bool_36, color a_color_40, int ai_44) {
   if (ObjectFind(a_name_0) != 0) {
      ObjectCreate(a_name_0, OBJ_TREND, 0, a_datetime_8, a_price_16, a_datetime_12, a_price_24);
      if (ai_44 == 1) ObjectSet(a_name_0, OBJPROP_STYLE, STYLE_SOLID);
      else {
         if (ai_44 == 2) ObjectSet(a_name_0, OBJPROP_STYLE, STYLE_DASHDOT);
         else ObjectSet(a_name_0, OBJPROP_STYLE, STYLE_DOT);
      }
      ObjectSet(a_name_0, OBJPROP_COLOR, a_color_40);
      ObjectSet(a_name_0, OBJPROP_WIDTH, a_width_32);
      ObjectSet(a_name_0, OBJPROP_RAY, a_bool_36);
      return;
   }
   ObjectDelete(a_name_0);
   ObjectCreate(a_name_0, OBJ_TREND, 0, a_datetime_8, a_price_16, a_datetime_12, a_price_24);
   if (ai_44 == 1) ObjectSet(a_name_0, OBJPROP_STYLE, STYLE_SOLID);
   else {
      if (ai_44 == 2) ObjectSet(a_name_0, OBJPROP_STYLE, STYLE_DASHDOT);
      else ObjectSet(a_name_0, OBJPROP_STYLE, STYLE_DOT);
   }
   ObjectSet(a_name_0, OBJPROP_COLOR, a_color_40);
   ObjectSet(a_name_0, OBJPROP_WIDTH, a_width_32);
   ObjectSet(a_name_0, OBJPROP_RAY, a_bool_36);
}

void drawLabel() {
   string ls_0 = " " + " ";
}