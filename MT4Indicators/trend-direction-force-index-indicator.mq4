/*
   Generated by ex4-to-mq4 decompiler FREEWARE 4.0.451.7
   Website: H T t p :// w WW . MEtAQUO t ES. NEt
   E-mail :  S u p P OR T@ m etaquotes. n ET
*/
#property copyright ""
#property link      ""

#property indicator_separate_window
#property indicator_minimum -1.0
#property indicator_maximum 1.0
#property indicator_buffers 3
#property indicator_color1 DimGray
#property indicator_color2 DimGray
#property indicator_color3 Red

extern int trendPeriod = 20;
extern string timeFrame = "Current time frame";
double GL_ibuf_88[];
double GL_ibuf_92[];
double GL_ibuf_96[];
double GL_ibuf_100[];
double GL_ibuf_104[];
double GL_ibuf_108[];
int GLia_112[];
int GL_timeframe_116;
string GLs_120;

// E37F0136AA3FFAF149B351F6A4C948E9
int init() {
   IndicatorBuffers(6);
   SetIndexBuffer(0, GL_ibuf_92);
   SetIndexBuffer(1, GL_ibuf_96);
   SetIndexBuffer(2, GL_ibuf_88);
   SetIndexBuffer(3, GL_ibuf_100);
   SetIndexBuffer(4, GL_ibuf_104);
   SetIndexBuffer(5, GL_ibuf_108);
   SetIndexLabel(0, NULL);
   SetIndexLabel(1, NULL);
   SetIndexLabel(2, "Trend direction & force");
   GLs_120 = WindowExpertName();
   GL_timeframe_116 = f0_1(timeFrame);
   IndicatorShortName("Trend direction & force" + f0_2(GL_timeframe_116) + " (" + trendPeriod + ")");
   return (0);
}

// 52D46093050F38C27267BCE42543EF60
int deinit() {
   return (0);
}

// EA2B2676C28C0DB26D39331A336C6B92
int start() {
   double LCd_0;
   double LCd_8;
   double LCd_16;
   double LCd_24;
   double LCd_32;
   int LCi_40;
   int LCi_44 = IndicatorCounted();
   if (LCi_44 < 0) return (-1);
   if (LCi_44 > 0) LCi_44--;
   int LCi_48 = Bars - LCi_44;
   if (GL_timeframe_116 != Period()) {
      LCi_48 = MathMax(LCi_48, GL_timeframe_116 / Period());
      ArrayCopySeries(GLia_112, 5, NULL, GL_timeframe_116);
      LCi_40 = 0;
      for (int index_52 = 0; LCi_40 < LCi_48; LCi_40++) {
         if (Time[LCi_40] < GLia_112[index_52]) index_52++;
         GL_ibuf_88[LCi_40] = iCustom(NULL, GL_timeframe_116, GLs_120, trendPeriod, 2, index_52);
         GL_ibuf_92[LCi_40] = 0.05;
         GL_ibuf_96[LCi_40] = -0.05;
      }
      return (0);
   }
   for (LCi_40 = LCi_48; LCi_40 >= 0; LCi_40--) GL_ibuf_100[LCi_40] = iMA(NULL, 0, trendPeriod, 0, MODE_EMA, PRICE_CLOSE, LCi_40);
   for (LCi_40 = LCi_48; LCi_40 >= 0; LCi_40--) {
      GL_ibuf_104[LCi_40] = iMAOnArray(GL_ibuf_100, 0, trendPeriod, 0, MODE_EMA, LCi_40);
      LCd_0 = GL_ibuf_100[LCi_40] - (GL_ibuf_100[LCi_40 + 1]);
      LCd_8 = GL_ibuf_104[LCi_40] - (GL_ibuf_104[LCi_40 + 1]);
      LCd_16 = MathAbs(GL_ibuf_100[LCi_40] - GL_ibuf_104[LCi_40]) / Point;
      LCd_24 = (LCd_0 + LCd_8) / (2.0 * Point);
      GL_ibuf_108[LCi_40] = LCd_16 * MathPow(LCd_24, 3);
      LCd_32 = f0_3(GL_ibuf_108, 3 * trendPeriod, LCi_40);
      if (LCd_32 > 0.0) GL_ibuf_88[LCi_40] = GL_ibuf_108[LCi_40] / LCd_32;
      else GL_ibuf_88[LCi_40] = 0.0;
      GL_ibuf_92[LCi_40] = 0.05;
      GL_ibuf_96[LCi_40] = -0.05;
   }
   return (0);
}

// EDE372998073A98AFE4BAA6A00FF4A89
double f0_3(double ARda_0[], int ARi_4, int ARi_8) {
   double LCd_ret_12 = 0.0;
   for (int LCi_20 = ARi_4 - 1; LCi_20 >= 0; LCi_20--)
      if (LCd_ret_12 < MathAbs(ARda_0[ARi_8 + LCi_20])) LCd_ret_12 = MathAbs(ARda_0[ARi_8 + LCi_20]);
   return (LCd_ret_12);
}

// B9EDCDEA151586E355292E7EA9BE516E
int f0_1(string ARs_0) {
   int timeframe_8 = 0;
   ARs_0 = StringTrimLeft(StringTrimRight(f0_0(ARs_0)));
   if (ARs_0 == "M1" || ARs_0 == "1") timeframe_8 = 1;
   if (ARs_0 == "M5" || ARs_0 == "5") timeframe_8 = 5;
   if (ARs_0 == "M15" || ARs_0 == "15") timeframe_8 = 15;
   if (ARs_0 == "M30" || ARs_0 == "30") timeframe_8 = 30;
   if (ARs_0 == "H1" || ARs_0 == "60") timeframe_8 = 60;
   if (ARs_0 == "H4" || ARs_0 == "240") timeframe_8 = 240;
   if (ARs_0 == "D1" || ARs_0 == "1440") timeframe_8 = 1440;
   if (ARs_0 == "W1" || ARs_0 == "10080") timeframe_8 = 10080;
   if (ARs_0 == "MN" || ARs_0 == "43200") timeframe_8 = 43200;
   if (timeframe_8 < Period()) timeframe_8 = Period();
   return (timeframe_8);
}

// BE5275EB85F7B577DA8FD065F994B740
string f0_2(int ARi_0) {
   string str_concat_4 = "";
   if (ARi_0 != Period()) {
      switch (ARi_0) {
      case 1:
         str_concat_4 = "M1";
         break;
      case 5:
         str_concat_4 = "M5";
         break;
      case 15:
         str_concat_4 = "M15";
         break;
      case 30:
         str_concat_4 = "M30";
         break;
      case 60:
         str_concat_4 = "H1";
         break;
      case 240:
         str_concat_4 = "H4";
         break;
      case 1440:
         str_concat_4 = "D1";
         break;
      case 10080:
         str_concat_4 = "W1";
         break;
      case 43200:
         str_concat_4 = "MN1";
      }
      str_concat_4 = StringConcatenate(" ", str_concat_4);
   }
   return (str_concat_4);
}

// 92DFF40263F725411B5FB6096A8D564E
string f0_0(string ARs_0) {
   int LCi_8;
   string LCs_ret_12 = ARs_0;
   for (int LCi_20 = StringLen(ARs_0) - 1; LCi_20 >= 0; LCi_20--) {
      LCi_8 = StringGetChar(LCs_ret_12, LCi_20);
      if ((LCi_8 > '`' && LCi_8 < '{') || (LCi_8 > '�' && LCi_8 < 256)) LCs_ret_12 = StringSetChar(LCs_ret_12, LCi_20, LCi_8 - 32);
      else
         if (LCi_8 > -33 && LCi_8 < 0) LCs_ret_12 = StringSetChar(LCs_ret_12, LCi_20, LCi_8 + 224);
   }
   return (LCs_ret_12);
}