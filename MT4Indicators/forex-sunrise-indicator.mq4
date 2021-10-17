/*
   G e n e r a t e d  by ex4-to-mq4 decompiler FREEWARE 4.0.509.5
   Website:  HT Tp: //W WW. Me Taqu O TeS . nET
   E-mail :  s upP or t @ mEt aQU o T Es .n Et
*/
#property copyright "Copyright @ Den Murakami"
#property link      "https://www.dmurakami.com"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Blue
#property indicator_color2 DeepPink

string G_text_76 = "Forex SunRise";
extern bool OnAlert = TRUE;
extern bool OnEmail = TRUE;
double G_ibuf_92[];
double G_ibuf_96[];
int G_period_100 = 30;
double G_pips_104 = 10.0;
double Gd_112;
datetime G_time_120;
int Gi_124 = 1080;
double Gd_128;
double Gd_136;
double G_price_144;
double G_price_152;
double G_price_160;
double G_price_168;
int Gi_176 = 10;
int Gi_180 = 10;
string Gs_184 = "";
int Gi_192 = 3000;
bool Gi_196 = TRUE;

// E37F0136AA3FFAF149B351F6A4C948E9
int init() {
   SetIndexBuffer(0, G_ibuf_92);
   SetIndexBuffer(1, G_ibuf_96);
   SetIndexStyle(0, DRAW_LINE, STYLE_DOT);
   SetIndexStyle(1, DRAW_LINE, STYLE_DOT);
   G_pips_104 = 1.5;
   Gd_112 = Point;
   if (Digits == 3 || Digits == 5) Gd_112 = 10.0 * Gd_112;
   G_time_120 = Time[1];
   if (ObjectFind("FIndic") == -1) {
      ObjectCreate("FIndic", OBJ_LABEL, 0, 0, 0);
      ObjectSet("FIndic", OBJPROP_CORNER, 1);
      ObjectSet("FIndic", OBJPROP_XDISTANCE, 10);
      ObjectSet("FIndic", OBJPROP_YDISTANCE, 20);
      ObjectSetText("FIndic", G_text_76, 10, "Arial Black", Snow);
   }
   start();
   return (0);
}

// 52D46093050F38C27267BCE42543EF60
int deinit() {
   ObjectsDeleteAll(0, OBJ_TEXT);
   ObjectsDeleteAll(0, OBJ_LABEL);
   ObjectsDeleteAll(0, OBJ_ARROW);
   Comment("");
   return (0);
}

// EA2B2676C28C0DB26D39331A336C6B92
int start() {
   int Li_8;
   double Ld_16;
   double Ld_24;
   double Ld_32;
   if (!Gi_196) return (0);
   if (Gs_184 != "") {
      if (TimeCurrent() > StrToTime(Gs_184) + 86400 * Gi_192) {
         Alert("Your version is expired!");
         Comment("Your version is expired!");
         Gi_196 = FALSE;
         return (0);
      }
   }
   int ind_counted_0 = IndicatorCounted();
   for (int Li_4 = 1; Li_4 < 2000; Li_4++) {
      if (iMA(NULL, 0, G_period_100, 0, MODE_SMA, PRICE_WEIGHTED, Li_4 + 1) > iMA(NULL, 0, G_period_100, 0, MODE_SMA, PRICE_WEIGHTED, Li_4)) {
         if (iMA(NULL, 0, G_period_100, 0, MODE_SMA, PRICE_WEIGHTED, Li_4 + 1) - iMA(NULL, 0, G_period_100, 0, MODE_SMA, PRICE_WEIGHTED, Li_4) < G_pips_104 * Point) {
            G_ibuf_96[Li_4] = G_ibuf_96[Li_4 - 1];
            G_ibuf_92[Li_4] = G_ibuf_92[Li_4 - 1];
            continue;
         }
         G_ibuf_96[Li_4] = iMA(NULL, 0, G_period_100, 0, MODE_SMA, PRICE_WEIGHTED, Li_4) + 3.0 * Gd_112;
         G_ibuf_92[Li_4] = EMPTY_VALUE;
      } else {
         if (iMA(NULL, 0, G_period_100, 0, MODE_SMA, PRICE_WEIGHTED, Li_4) - iMA(NULL, 0, G_period_100, 0, MODE_SMA, PRICE_WEIGHTED, Li_4 + 1) < G_pips_104 * Point) {
            G_ibuf_96[Li_4] = G_ibuf_96[Li_4 - 1];
            G_ibuf_92[Li_4] = G_ibuf_92[Li_4 - 1];
         } else {
            G_ibuf_92[Li_4] = iMA(NULL, 0, G_period_100, 0, MODE_SMA, PRICE_WEIGHTED, Li_4) - 1.0 * Gd_112;
            G_ibuf_96[Li_4] = EMPTY_VALUE;
         }
      }
   }
   if (G_time_120 < Time[0]) {
      G_time_120 = Time[0];
      if (OnAlert == TRUE) {
         if (G_ibuf_96[1] != EMPTY_VALUE && G_ibuf_96[2] == EMPTY_VALUE) Alert(G_text_76 + " SELL " + Symbol() + " M" + Period() + " at price " + DoubleToStr(Bid, Digits));
         if (G_ibuf_92[1] != EMPTY_VALUE && G_ibuf_92[2] == EMPTY_VALUE) Alert(G_text_76 + " BUY " + Symbol() + " M" + Period() + " at price " + DoubleToStr(Ask, Digits));
      }
      if (OnEmail == TRUE) {
         if (G_ibuf_96[1] != EMPTY_VALUE && G_ibuf_96[2] == EMPTY_VALUE) SendMail(G_text_76, G_text_76 + " SELL " + Symbol() + " M" + Period() + " at price " + DoubleToStr(Bid, Digits));
         if (G_ibuf_92[1] != EMPTY_VALUE && G_ibuf_92[2] == EMPTY_VALUE) SendMail(G_text_76, G_text_76 + " BUY " + Symbol() + " M" + Period() + " at price " + DoubleToStr(Ask, Digits));
      }
      Li_8 = Gi_124 / Period();
      if (Li_8 > Bars) Li_8 = Bars;
      Ld_16 = 0;
      Ld_24 = 99999999;
      for (Li_4 = 1; Li_4 < Li_8 + 1; Li_4++) {
         if (High[Li_4] > Ld_16) Ld_16 = High[Li_4];
         if (Low[Li_4] < Ld_24) Ld_24 = Low[Li_4];
      }
      Gd_128 = Ld_16;
      Gd_136 = Ld_24;
      Ld_32 = (Gd_128 - Gd_136) / 100.0;
      G_price_144 = Gd_128 + Gi_176 * Ld_32;
      G_price_152 = Gd_128 - Gi_176 * Ld_32;
      G_price_160 = Gd_136 + Gi_180 * Ld_32;
      G_price_168 = Gd_136 - Gi_180 * Ld_32;
      ObjectDelete("koridor_h1");
      ObjectDelete("koridor_h2");
      ObjectDelete("koridor_l1");
      ObjectDelete("koridor_l2");
      ObjectCreate("koridor_h1", OBJ_HLINE, 0, D'20.02.2004 17:30', G_price_144);
      ObjectCreate("koridor_h2", OBJ_HLINE, 0, D'20.02.2004 17:30', G_price_152);
      ObjectCreate("koridor_l1", OBJ_HLINE, 0, D'20.02.2004 17:30', G_price_160);
      ObjectCreate("koridor_l2", OBJ_HLINE, 0, D'20.02.2004 17:30', G_price_168);
      ObjectSet("koridor_h1", OBJPROP_COLOR, DeepPink);
      ObjectSet("koridor_h2", OBJPROP_COLOR, DeepPink);
      ObjectSet("koridor_l1", OBJPROP_COLOR, Blue);
      ObjectSet("koridor_l2", OBJPROP_COLOR, Blue);
   }
   return (0);
}
