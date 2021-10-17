#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Lime
#property indicator_color2 Red
#property indicator_width1 3
#property indicator_width2 3

extern int Periods = 3;
extern bool Comments = TRUE;
extern bool Sound = TRUE;
extern string WAV = "news.wav";
extern int ras = 50;
double Buf_up[];
double Buf_dn[];

int g_digits_96;
datetime g_time_100;
int g_bars_104;
int gi_108;
int gi_116 = 1;
bool gi_120;
double gd_124;
double g_iwpr_132;
double g_high_140;
double g_low_148;
double g_high_156;
double g_low_164;

int init() {
   SetIndexStyle(0, DRAW_ARROW, 3);
   SetIndexArrow(0, 233);
   SetIndexBuffer(0, Buf_up);
   SetIndexStyle(1, DRAW_ARROW, 3);
   SetIndexArrow(1, 234);
   SetIndexBuffer(1, Buf_dn);
   
   g_digits_96 = MarketInfo(Symbol(), MODE_DIGITS);
   return (0);
}

int deinit() {
   return (0);
}

int start() {
   string ls_48;
   string ls_56;
   string ls_64;
   if (g_time_100 == Time[0] && gi_108 == -1) return (0);
   g_time_100 = Time[0];
   if (Bars < 100) return (0);
   if (Bars < g_bars_104 || Bars - g_bars_104 > 1) gi_120 = TRUE;
   g_bars_104 = Bars;
   if (gi_120 == TRUE) {
      if (Close[Bars - 100] > Open[Bars - 100]) gd_124 = 0.5;
      else gd_124 = -0.5;
      gi_108 = Bars - 100;
      if (gi_108 < 0) return (0);
      gi_120 = FALSE;
   }
   gi_108++;
   for (int i = gi_108; i >= 0; i--) 
   {
      g_iwpr_132 = iWPR(NULL, 0, Periods, i);
      if (gi_116 == -1 && g_iwpr_132 > -30.0) 
      {
         gi_116 = 1;
         g_low_164 = g_low_148;
         g_high_140 = High[i];
      }
      if (gi_116 == 1 && g_iwpr_132 < -70.0) 
      {
         gi_116 = -1;
         g_high_156 = g_high_140;
         g_low_148 = Low[i];
      }
      if (gi_116 == 1 && High[i] > g_high_140) g_high_140 = High[i];
      if (gi_116 == -1 && Low[i] < g_low_148) g_low_148 = Low[i];
      if (gd_124 == -0.5 && g_high_140 > g_high_156) 
      {
         gd_124 = 0.5;
         Buf_up[i] = Low[i] - ras * Point;
      }
      if (gd_124 == 0.5 && g_low_148 < g_low_164) 
      {
         gd_124 = -0.5;
         Buf_dn[i] = High[i] + ras * Point;
      }
   }
   double l_global_var_0 = GlobalVariableGet("GGT1" + Symbol() + Period());
   double l_global_var_8 = GlobalVariableGet("GGT2" + Symbol() + Period());
   double l_hour_24 = Hour();
   double l_minute_32 = Minute();
   double l_second_40 = Seconds();
   string ls_72 = DoubleToStr(Day(), 0) + "." + DoubleToStr(Month(), 0) + "." + DoubleToStr(Year(), 0);
   if (l_hour_24 < 10.0) ls_48 = "0" + DoubleToStr(Hour(), 0);
   else ls_48 = DoubleToStr(Hour(), 0);
   if (l_minute_32 < 10.0) ls_56 = "0" + DoubleToStr(Minute(), 0);
   else ls_56 = DoubleToStr(Minute(), 0);
   if (l_second_40 < 10.0) ls_64 = "0" + DoubleToStr(Seconds(), 0);
   else ls_64 = DoubleToStr(Seconds(), 0);
   if (Comments == TRUE) {
      if (Buf_up[1] != 0.0 && Buf_up[1] != l_global_var_0) {
         Comment("Terminal Signal", "Time: " + ls_48 + ":" + ls_56 + ":" + ls_64 + "   " + ls_72 + ";" 
            + "\n" 
            + "Symbol: " + Symbol() + ";" 
            + "\n" 
            + "Period: " + Period() + ";" 
            + "\n" 
            + "Signal: Buy;" 
            + "\n" 
            + "Price(Bid): " + DoubleToStr(Bid, g_digits_96) + ";" 
            + "\n" 
            + "Price(Ask): " + DoubleToStr(Ask, g_digits_96) + ";" 
            + "\n" 
            + "High: " + DoubleToStr(High[1], g_digits_96) + ";" 
            + "\n" 
            + "Low: " + DoubleToStr(Low[1], g_digits_96) + ";" 
         + "\n");
         GlobalVariableSet("GGT1" + Symbol() + Period(), Buf_up[1]);
         if (Sound == TRUE) PlaySound(WAV);
      }
      if (Buf_dn[1] != 0.0 && Buf_dn[1] != l_global_var_8) {
         Comment("Terminal Signal", "Time: " + ls_48 + ":" + ls_56 + ":" + ls_64 + "   " + ls_72 + ";" 
            + "\n" 
            + "Symbol: " + Symbol() + ";" 
            + "\n" 
            + "Period: " + Period() + ";" 
            + "\n" 
            + "Signal: Sell;" 
            + "\n" 
            + "Price(Bid): " + DoubleToStr(Bid, g_digits_96) + ";" 
            + "\n" 
            + "Price(Ask): " + DoubleToStr(Ask, g_digits_96) + ";" 
            + "\n" 
            + "High: " + DoubleToStr(High[1], g_digits_96) + ";" 
            + "\n" 
            + "Low: " + DoubleToStr(Low[1], g_digits_96) + ";" 
         + "\n");
         GlobalVariableSet("GGT2" + Symbol() + Period(), Buf_dn[1]);
         if (Sound == TRUE) PlaySound(WAV);
      }
   }
   return (0);
}