

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Lime
#property indicator_color2 Red

extern int MainFilterSpeed = 8;
extern int MainFilterSlow = 16;
extern int SmallFilterSpeed = 3;
extern int SmallFilterSlow = 12;
double gd_unused_92 = 1.0;
double gd_100 = 1.0;
int gi_108 = 0;
double gda_112[999];
double gda_116[999];
double g_ibuf_120[];
double g_ibuf_124[];

bool   SoundBuy = false;
bool   SoundSell = false;

double f0_0(int ai_0, int ai_4) {
   if (iMA(NULL, 0, 1, 0, MODE_SMA, PRICE_CLOSE, ai_4 + ai_0 + 1) == 0.0) return (0);
   int index_8 = 0;
   for (index_8 = 0; index_8 < ai_0; index_8++) gda_112[ai_0 - 1 - index_8] = MathAbs(iMA(NULL, 0, 1, 0, MODE_SMA, PRICE_CLOSE, ai_4 + index_8) - iMA(NULL, 0, 1, 0, MODE_SMA, PRICE_OPEN, ai_4 + index_8));
   double ld_12 = 2.0 / (ai_0 + 1);
   gda_116[0] = gda_112[0];
   for (index_8 = 1; index_8 < ai_0; index_8++) gda_116[index_8] = gda_112[index_8] * ld_12 + (gda_116[index_8 - 1]) * (1 - ld_12);
   return (gda_116[ai_0 - 1]);
}

double f0_1(int ai_0, int ai_4) {
   if (iMA(NULL, 0, 1, 0, MODE_SMA, PRICE_CLOSE, ai_4 + ai_0 + 1) == 0.0) return (0);
   int index_8 = 0;
   for (index_8 = 0; index_8 < ai_0; index_8++) gda_112[ai_0 - 1 - index_8] = iMA(NULL, 0, 1, 0, MODE_SMA, PRICE_CLOSE, ai_4 + index_8) - iMA(NULL, 0, 1, 0, MODE_SMA, PRICE_OPEN, ai_4 + index_8);
   double ld_12 = 2.0 / (ai_0 + 1);
   gda_116[0] = gda_112[0];
   for (index_8 = 1; index_8 < ai_0; index_8++) gda_116[index_8] = gda_112[index_8] * ld_12 + (gda_116[index_8 - 1]) * (1 - ld_12);
   return (gda_116[ai_0 - 1]);
}

int init() {
   string lsa_8[256];
   string ls_0 = "SIDUS-5";
   IndicatorBuffers(2);
   SetIndexBuffer(0, g_ibuf_120);
   SetIndexArrow(0, 233);
   SetIndexLabel(0, "Long");
   SetIndexStyle(0, DRAW_ARROW, EMPTY);
   SetIndexBuffer(1, g_ibuf_124);
   SetIndexArrow(1, 234);
   SetIndexLabel(1, "Short");
   SetIndexStyle(1, DRAW_ARROW, EMPTY);
   IndicatorShortName(ls_0);
   for (int index_12 = 0; index_12 < 256; index_12++) lsa_8[index_12] = CharToStr(index_12);
   int str2int_16 = StrToInteger(lsa_8[67] + lsa_8[111] + lsa_8[112] + lsa_8[121] + lsa_8[32] + lsa_8[82] + lsa_8[105] + lsa_8[103] + lsa_8[104] + lsa_8[116] + lsa_8[32] +
      lsa_8[169] + lsa_8[32] + lsa_8[75] + lsa_8[97] + lsa_8[122] + lsa_8[97] + lsa_8[111] + lsa_8[111] + lsa_8[32] + lsa_8[50] + lsa_8[48] + lsa_8[49] + lsa_8[49] + lsa_8[32]);
   return (0);
}

int start() {
   int li_24;
   int li_28;
   double ld_32;
   double ld_40;
   string ls_0 = "2030.09.01";
   int str2time_8 = StrToTime(ls_0);
   if (TimeCurrent() >= str2time_8) {
      Alert("Maaf Sudah Expire ! Silahkan Inbox atau hub-081381377477");
      return (0);
   }
   int li_12 = IndicatorCounted();
   if (li_12 < 0) li_12 = 0;
   else li_12--;
   int li_16 = Bars - li_12;
   for (int li_20 = 0; li_20 < li_16; li_20++) {
      li_24 = 0;
      li_28 = li_20;
      if (f0_0(MainFilterSpeed, li_28) > f0_0(MainFilterSlow, li_28 + gi_108)) {
         ld_32 = f0_1(SmallFilterSpeed, li_28);
         ld_40 = f0_0(SmallFilterSlow, li_28);
         if (ld_32 > ld_40 * gd_100) li_24 = 1;
         else
            if (ld_32 < (-ld_40) * gd_100) li_24 = -1;
      }
      if (li_24 == 1) {
         g_ibuf_120[li_20] = Low[li_20] - iATR(NULL, 0, 10, li_20);
         //Alert("Long Trade");
      }
      if (li_24 == -1) {
         g_ibuf_124[li_20] = High[li_20] + iATR(NULL, 0, 10, li_20);
         //Alert("Short Trade");
      }
   }
//-------------------
if (g_ibuf_120[0]!=EMPTY_VALUE && g_ibuf_120[0]!=0 && SoundBuy)
     {
      SoundBuy=False;
      Alert("Sidus Cross Trend going Up on ",Symbol()," ",Period());
     }
     if (!SoundBuy && (g_ibuf_120[0]==EMPTY_VALUE || g_ibuf_120[0]==0)) SoundBuy=True;
     if (g_ibuf_124[0]!=EMPTY_VALUE && g_ibuf_124[0]!=0 && SoundSell)
       {
        SoundSell=False;
        Alert("Sidus Cross Trend going Down on ",Symbol()," ",Period());
       }
     if (!SoundSell && (g_ibuf_124[0]==EMPTY_VALUE || g_ibuf_124[0]==0)) SoundSell=True;
//-------------------   
   return (0);
}

int deinit() {
   return (0);
}