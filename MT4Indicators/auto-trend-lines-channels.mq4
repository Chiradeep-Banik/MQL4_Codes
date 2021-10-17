

#property indicator_chart_window
#property indicator_buffers 8
#property indicator_color1 Black
#property indicator_color2 Black
#property indicator_color3 Black
#property indicator_color4 Black
#property indicator_color5 Black
#property indicator_color6 Black
#property indicator_color7 Black
#property indicator_color8 Black

extern string ExtDepth = "12,12,12,0,12,12,12,12,12";
extern string ExtDeviation = "5,5,5,0,5,5,5,5,5";
extern string ExtBackstep = "3,3,3,0,3,3,3,3,3";
extern string ExtMaxBar = "5000,1000,350,350,350,350,350,350,350,350";
extern string GrossPeriod = "1,5,15,30,60,240,1440,10080,43200";
extern string zzVisible = "1,1,1,1,1,1,1,1,1";
extern string zzColor = "Tan,RoyalBlue,Brown,Blue,Red,GreenYellow,Magenta,IndianRed,MediumGreen";
extern string extColor = "Indigo,Olive,Teal";
extern bool fibofan = FALSE;
extern string fanVisible = "1,1,1,1,1,1,1,1,1";
extern string fanStyle = "2,2,2,2,2,2,2,2,2";
extern string fanWidth = "0,0,0,0,0,0,0,0,0";
extern string FiboFreeFan = "0.382,0.618,0.786";
extern bool fiboChannel = TRUE;
extern string ChannelVisible = "1,1,1,1,1,1,1,1,1";
extern string ChannelWidth = "2,2,2,2,2,2,2,2,2";
extern string ChannelStyleLevel = "2,2,2,2,2,2,2,2,2";
extern string ChannelWidthLevel = "0,0,0,0,0,0,0,0,0";
extern string FiboFreeChannel = "-2,-1.1,-0.9,-0.1,0.1,1";
extern bool ExtProcedureOfPayments = FALSE;
extern int showZigZag = 1;
extern int ExtReCalculate = 3;
extern int ExtComplect = 0;
int gia_236[] = {0, 0, 0, 0, 0, 0, 0, 0, 0};
int gia_240[] = {0, 0, 0, 0, 0, 0, 0, 0, 0};
int gia_244[] = {0, 0, 0, 0, 0, 0, 0, 0, 0};
int gia_248[] = {0, 0, 0, 0, 0, 0, 0, 0, 0};
int gia_252[] = {0, 0, 0, 0, 0, 0, 0, 0, 0};
int gia_256[] = {0, 0, 0, 0, 0, 0, 0, 0, 0};
int gia_260[] = {0, 0, 0, 0, 0, 0, 0, 0, 0};
int gia_264[] = {0, 0, 0};
int gia_268[] = {0, 0, 0, 0, 0, 0, 0, 0, 0};
int gia_272[] = {0, 0, 0, 0, 0, 0, 0, 0, 0};
int gia_276[] = {0, 0, 0, 0, 0, 0, 0, 0, 0};
int gia_280[] = {0, 0, 0, 0, 0, 0, 0, 0, 0};
int gia_284[] = {0, 0, 0, 0, 0, 0, 0, 0, 0};
int gia_288[] = {0, 0, 0, 0, 0, 0, 0, 0, 0};
int gia_292[] = {0, 0, 0, 0, 0, 0, 0, 0, 0};
int gia_296[] = {0, 0, 0, 0, 0, 0, 0, 0, 0};
double g_ibuf_300[];
double g_ibuf_304[];
double g_ibuf_308[];
double g_ibuf_312[];
double g_ibuf_316[];
double g_ibuf_320[];
double g_ibuf_324[];
double g_ibuf_328[];
double gda_332[];
double gda_336[];
double gda_340[];
double gda_344[];
double gda_348[];
double gda_352[];
double gda_356[];
double gda_360[];
double gda_364[];
double gda_368[];
double gda_372[];
double gda_376[];
double gda_380[];
double gda_384[];
double gda_388[];
double gda_392[];
double gda_396[];
double gda_400[];
bool gba_404[] = {0, 0, 0, 0, 0, 0, 0, 0, 0};
bool gba_408[] = {0, 0, 0, 0, 0, 0, 0, 0, 0};
int gia_412[] = {0, 0, 0, 0, 0, 0, 0, 0, 0};
int gia_416[] = {0, 0, 0, 0, 0, 0, 0, 0, 0};
double gda_420[] = {0, 0, 0, 0, 0, 0, 0, 0, 0};
double gda_424[] = {0, 0, 0, 0, 0, 0, 0, 0, 0};
int gia_428[] = {0, 0, 0, 0, 0, 0, 0, 0, 0};
int gia_432[] = {0, 0, 0, 0, 0, 0, 0, 0, 0};
int g_bars_436;
int gia_440[9][3];
int gi_444;
double gda_448[9][4];
int gia_452[9][4];
int gia_456[9][4];
int gi_460;
int gi_464;

int init() {
   int li_4;
   int li_12;
   string ls_24 = "";
   SetIndexBuffer(0, g_ibuf_300);
   SetIndexBuffer(1, g_ibuf_304);
   SetIndexBuffer(2, g_ibuf_308);
   SetIndexBuffer(3, g_ibuf_312);
   SetIndexBuffer(4, g_ibuf_316);
   SetIndexBuffer(5, g_ibuf_320);
   SetIndexBuffer(6, g_ibuf_324);
   SetIndexBuffer(7, g_ibuf_328);
   SetIndexEmptyValue(0, 0.0);
   SetIndexEmptyValue(1, 0.0);
   SetIndexEmptyValue(2, 0.0);
   SetIndexEmptyValue(3, 0.0);
   SetIndexEmptyValue(4, 0.0);
   SetIndexEmptyValue(5, 0.0);
   SetIndexEmptyValue(6, 0.0);
   SetIndexEmptyValue(7, 0.0);
   _stringtointarray(ExtDepth, gia_236, 9);
   _stringtointarray(ExtDeviation, gia_240, 9);
   _stringtointarray(ExtBackstep, gia_244, 9);
   _stringtointarray(ExtMaxBar, gia_248, 9);
   _stringtointarray(GrossPeriod, gia_252, 9);
   _stringtointarray(zzVisible, gia_256, 9);
   _stringtocolorarray(zzColor, gia_260, 9);
   _stringtocolorarray(extColor, gia_264, 3);
   _stringtointarray(fanVisible, gia_272, 9);
   _stringtointarray(fanStyle, gia_276, 9);
   _stringtointarray(fanWidth, gia_280, 9);
   _stringtointarray(ChannelVisible, gia_284, 9);
   _stringtointarray(ChannelWidth, gia_292, 9);
   _stringtointarray(ChannelStyleLevel, gia_288, 9);
   _stringtointarray(ChannelWidthLevel, gia_296, 9);
   gi_460 = quantityFibo(FiboFreeFan);
   gi_464 = quantityFibo(FiboFreeChannel);
   for (int l_index_0 = 0; l_index_0 < 9; l_index_0++) {
      gba_404[l_index_0] = 0;
      gba_408[l_index_0] = 0;
      li_4 = gia_252[l_index_0];
      gia_252[l_index_0] = _period(l_index_0, li_4);
      if (gia_236[l_index_0] <= 0) gia_256[l_index_0] = 0;
      if (gia_256[l_index_0] > 0) {
         li_12 = gia_244[l_index_0] + gia_236[l_index_0];
         if (gia_248[l_index_0] > iBars(NULL, gia_252[l_index_0]) - li_12 || gia_248[l_index_0] == 0) gi_444 = iBars(NULL, gia_252[l_index_0]) - li_12;
         else gi_444 = gia_248[l_index_0];
         if (l_index_0 == 0) arr_resize(gda_332, gda_336, gi_444 + li_12, l_index_0);
         else {
            if (l_index_0 == 1) arr_resize(gda_340, gda_344, gi_444 + li_12, l_index_0);
            else {
               if (l_index_0 == 2) arr_resize(gda_348, gda_352, gi_444 + li_12, l_index_0);
               else {
                  if (l_index_0 == 3) arr_resize(gda_356, gda_360, gi_444 + li_12, l_index_0);
                  else {
                     if (l_index_0 == 4) arr_resize(gda_364, gda_368, gi_444 + li_12, l_index_0);
                     else {
                        if (l_index_0 == 5) arr_resize(gda_372, gda_376, gi_444 + li_12, l_index_0);
                        else {
                           if (l_index_0 == 6) arr_resize(gda_380, gda_384, gi_444 + li_12, l_index_0);
                           else {
                              if (l_index_0 == 7) arr_resize(gda_388, gda_392, gi_444 + li_12, l_index_0);
                              else
                                 if (l_index_0 == 8) arr_resize(gda_396, gda_400, gi_444 + li_12, l_index_0);
                           }
                        }
                     }
                  }
               }
            }
         }
      }
      gia_440[l_index_0][0] = gia_252[l_index_0];
      gia_440[l_index_0][1] = l_index_0;
   }
   ArraySort(gia_440, WHOLE_ARRAY, 0, MODE_ASCEND);
   if (showZigZag < 0) showZigZag = 0;
   if (showZigZag > 2) showZigZag = 2;
   li_4 = 1;
   int l_index_8 = 0;
   int li_20 = -1;
   for (int l_index_16 = 0; l_index_16 < 9; l_index_16++) {
      l_index_0 = gia_440[l_index_16][1];
      if (gia_256[l_index_0] == 0 || li_4 > 4) gia_440[l_index_16][2] = 0;
      else {
         if (gia_252[l_index_0] == 0 || gia_252[l_index_0] > Period()) {
            if (gia_252[l_index_0] == li_20) {
               gia_260[l_index_0] = gia_264[l_index_8];
               l_index_8++;
            }
            li_20 = gia_252[l_index_0];
            if (li_4 == 1) {
               if (showZigZag == 0) {
                  SetIndexStyle(0, DRAW_ZIGZAG, EMPTY, 0, gia_260[l_index_0]);
                  SetIndexStyle(1, DRAW_ZIGZAG, EMPTY, 0, gia_260[l_index_0]);
               } else {
                  SetIndexStyle(0, DRAW_ARROW, EMPTY, 0, gia_260[l_index_0]);
                  SetIndexStyle(1, DRAW_ARROW, EMPTY, 0, gia_260[l_index_0]);
                  if (showZigZag == 1) {
                     SetIndexArrow(0, 116);
                     SetIndexArrow(1, 116);
                  } else {
                     SetIndexArrow(0, 159);
                     SetIndexArrow(1, 159);
                  }
               }
            } else {
               if (li_4 == 2) {
                  if (showZigZag == 0) {
                     SetIndexStyle(2, DRAW_ZIGZAG, EMPTY, 0, gia_260[l_index_0]);
                     SetIndexStyle(3, DRAW_ZIGZAG, EMPTY, 0, gia_260[l_index_0]);
                  } else {
                     SetIndexStyle(2, DRAW_ARROW, EMPTY, 0, gia_260[l_index_0]);
                     SetIndexStyle(3, DRAW_ARROW, EMPTY, 0, gia_260[l_index_0]);
                     if (showZigZag == 1) {
                        SetIndexArrow(2, 116);
                        SetIndexArrow(3, 116);
                     } else {
                        SetIndexArrow(2, 159);
                        SetIndexArrow(3, 159);
                     }
                  }
               } else {
                  if (li_4 == 3) {
                     if (showZigZag == 0) {
                        SetIndexStyle(4, DRAW_ZIGZAG, EMPTY, 0, gia_260[l_index_0]);
                        SetIndexStyle(5, DRAW_ZIGZAG, EMPTY, 0, gia_260[l_index_0]);
                     } else {
                        SetIndexStyle(4, DRAW_ARROW, EMPTY, 0, gia_260[l_index_0]);
                        SetIndexStyle(5, DRAW_ARROW, EMPTY, 0, gia_260[l_index_0]);
                        if (showZigZag == 1) {
                           SetIndexArrow(4, 116);
                           SetIndexArrow(5, 116);
                        } else {
                           SetIndexArrow(4, 159);
                           SetIndexArrow(5, 159);
                        }
                     }
                  } else {
                     if (li_4 == 4) {
                        if (showZigZag == 0) {
                           SetIndexStyle(6, DRAW_ZIGZAG, EMPTY, 0, gia_260[l_index_0]);
                           SetIndexStyle(7, DRAW_ZIGZAG, EMPTY, 0, gia_260[l_index_0]);
                        } else {
                           SetIndexStyle(6, DRAW_ARROW, EMPTY, 0, gia_260[l_index_0]);
                           SetIndexStyle(7, DRAW_ARROW, EMPTY, 0, gia_260[l_index_0]);
                           if (showZigZag == 1) {
                              SetIndexArrow(6, 116);
                              SetIndexArrow(7, 116);
                           } else {
                              SetIndexArrow(6, 159);
                              SetIndexArrow(7, 159);
                           }
                        }
                     }
                  }
               }
            }
            gia_440[l_index_16][2] = li_4;
            li_4++;
         }
      }
   }
   if (ExtProcedureOfPayments) ArraySort(gia_440, WHOLE_ARRAY, 0, MODE_ASCEND);
   else ArraySort(gia_440, WHOLE_ARRAY, 0, MODE_DESCEND);
   for (l_index_16 = 0; l_index_16 < 9; l_index_16++) {
      if (gia_252[gia_440[l_index_16][1]] == 0) ls_24 = "" + Period();
      else ls_24 = "" + gia_252[gia_440[l_index_16][1]];
      if (gia_440[l_index_16][2] == 1) {
         SetIndexLabel(0, "Low1_" + ls_24);
         SetIndexLabel(1, "High1_" + ls_24);
      } else {
         if (gia_440[l_index_16][2] == 2) {
            SetIndexLabel(2, "Low2_" + ls_24);
            SetIndexLabel(3, "High2_" + ls_24);
         } else {
            if (gia_440[l_index_16][2] == 3) {
               SetIndexLabel(4, "Low3_" + ls_24);
               SetIndexLabel(5, "High3_" + ls_24);
            } else {
               if (gia_440[l_index_16][2] == 4) {
                  SetIndexLabel(6, "Low4_" + ls_24);
                  SetIndexLabel(7, "High4_" + ls_24);
               }
            }
         }
      }
   }
   ArrayInitialize(gda_448, 0);
   ArrayInitialize(gia_452, 0);
   ArrayInitialize(gia_456, 0);
   g_bars_436 = 0;
   return (0);
}

int deinit() {
   _delete_fibo();
   return (0);
}

int start() {
   int li_0;
   int li_4;
   bool li_12;
   if (Bars - g_bars_436 > 1) {
      for (int l_index_8 = 0; l_index_8 < 9; l_index_8++) {
         if (gia_440[l_index_8][2] > 0) {
            li_0 = gia_440[l_index_8][1];
            gia_432[li_0] = 0;
            gia_268[li_0] = 0;
         }
      }
   }
   g_bars_436 = Bars;
   for (l_index_8 = 0; l_index_8 < 9; l_index_8++) {
      li_0 = gia_440[l_index_8][1];
      if (gia_256[li_0] != 0) {
         if (iBars(NULL, gia_252[li_0]) - gia_268[li_0] > 1) gia_432[li_0] = 0;
         gia_268[li_0] = iBars(NULL, gia_252[li_0]);
         li_4 = gia_244[li_0] + gia_236[li_0];
         if (gia_268[li_0] - 1 < li_4 || li_4 <= 0) continue;
         li_12 = FALSE;
         gi_444 = iBars(NULL, gia_252[li_0]) - gia_432[li_0] + 1;
         if (gi_444 > 2) {
            li_12 = TRUE;
            gba_404[li_0] = 0;
            gba_408[li_0] = 0;
            if (gia_248[li_0] > iBars(NULL, gia_252[li_0]) - li_4 || gia_248[li_0] == 0) gi_444 = iBars(NULL, gia_252[li_0]) - li_4;
            else gi_444 = gia_248[li_0];
            if (li_0 == 0) arr_resize(gda_332, gda_336, gi_444 + li_4, li_0);
            else {
               if (li_0 == 1) arr_resize(gda_340, gda_344, gi_444 + li_4, li_0);
               else {
                  if (li_0 == 2) arr_resize(gda_348, gda_352, gi_444 + li_4, li_0);
                  else {
                     if (li_0 == 3) arr_resize(gda_356, gda_360, gi_444 + li_4, li_0);
                     else {
                        if (li_0 == 4) arr_resize(gda_364, gda_368, gi_444 + li_4, li_0);
                        else {
                           if (li_0 == 5) arr_resize(gda_372, gda_376, gi_444 + li_4, li_0);
                           else {
                              if (li_0 == 6) arr_resize(gda_380, gda_384, gi_444 + li_4, li_0);
                              else {
                                 if (li_0 == 7) arr_resize(gda_388, gda_392, gi_444 + li_4, li_0);
                                 else
                                    if (li_0 == 8) arr_resize(gda_396, gda_400, gi_444 + li_4, li_0);
                              }
                           }
                        }
                     }
                  }
               }
            }
            if (gia_440[l_index_8][2] == 1) {
               ArrayInitialize(g_ibuf_300, 0);
               ArrayInitialize(g_ibuf_304, 0);
            } else {
               if (gia_440[l_index_8][2] == 2) {
                  ArrayInitialize(g_ibuf_308, 0);
                  ArrayInitialize(g_ibuf_312, 0);
               } else {
                  if (gia_440[l_index_8][2] == 3) {
                     ArrayInitialize(g_ibuf_316, 0);
                     ArrayInitialize(g_ibuf_320, 0);
                  } else {
                     if (gia_440[l_index_8][2] == 4) {
                        ArrayInitialize(g_ibuf_324, 0);
                        ArrayInitialize(g_ibuf_328, 0);
                     }
                  }
               }
            }
         } else
            if (gda_420[li_0] > iLow(NULL, gia_252[li_0], 0) || gda_424[li_0] < iHigh(NULL, gia_252[li_0], 0) || gia_428[li_0] != iTime(NULL, gia_252[li_0], 0)) li_12 = TRUE;
         if (li_12) {
            if (li_0 == 0) _Gross(gda_332, gda_336, gi_444, l_index_8);
            else {
               if (li_0 == 1) _Gross(gda_340, gda_344, gi_444, l_index_8);
               else {
                  if (li_0 == 2) _Gross(gda_348, gda_352, gi_444, l_index_8);
                  else {
                     if (li_0 == 3) _Gross(gda_356, gda_360, gi_444, l_index_8);
                     else {
                        if (li_0 == 4) _Gross(gda_364, gda_368, gi_444, l_index_8);
                        else {
                           if (li_0 == 5) _Gross(gda_372, gda_376, gi_444, l_index_8);
                           else {
                              if (li_0 == 6) _Gross(gda_380, gda_384, gi_444, l_index_8);
                              else {
                                 if (li_0 == 7) _Gross(gda_388, gda_392, gi_444, l_index_8);
                                 else
                                    if (li_0 == 8) _Gross(gda_396, gda_400, gi_444, l_index_8);
                              }
                           }
                        }
                     }
                  }
               }
            }
         }
      }
   }
   return (0);
}

int _Gross(double ada_0[], double ada_4[], int ai_8, int ai_12) {
   int li_16 = gia_440[ai_12][1];
   if (gia_252[li_16] == 0) {
      if (gia_440[ai_12][2] == 1) ZigZag_(g_ibuf_300, g_ibuf_304, li_16);
      else {
         if (gia_440[ai_12][2] == 2) ZigZag_(g_ibuf_308, g_ibuf_312, li_16);
         else {
            if (gia_440[ai_12][2] == 3) ZigZag_(g_ibuf_316, g_ibuf_320, li_16);
            else {
               if (gia_440[ai_12][2] == 4) ZigZag_(g_ibuf_324, g_ibuf_328, li_16);
               else {
                  if (ai_8 == 2) Shift_elements(ada_0, ada_4);
                  ZigZag_(ada_0, ada_4, li_16);
               }
            }
         }
      }
   } else {
      if (ai_8 == 2) Shift_elements(ada_0, ada_4);
      if (ZigZag_(ada_0, ada_4, li_16) == 0) {
         if (gia_440[ai_12][2] == 1) ZigZagDT(g_ibuf_300, g_ibuf_304, ada_0, ada_4, li_16);
         else {
            if (gia_440[ai_12][2] == 2) ZigZagDT(g_ibuf_308, g_ibuf_312, ada_0, ada_4, li_16);
            else {
               if (gia_440[ai_12][2] == 3) ZigZagDT(g_ibuf_316, g_ibuf_320, ada_0, ada_4, li_16);
               else
                  if (gia_440[ai_12][2] == 4) ZigZagDT(g_ibuf_324, g_ibuf_328, ada_0, ada_4, li_16);
            }
         }
      }
   }
   return (0);
}

int ZigZag_(double &ada_0[], double &ada_4[], int ai_8) {
   int l_lowest_12;
   int l_shift_24;
   int l_shift_28;
   int li_32;
   int li_40;
   int li_52;
   int li_56;
   double ld_76;
   double ld_84;
   double ld_92;
   double ld_100;
   double ld_108;
   double ld_124;
   double ld_132;
   double l_str2dbl_140;
   string l_name_152;
   string ls_160;
   string ls_168;
   string ls_176;
   int li_44 = 0;
   int li_68 = -1;
   int li_72 = -1;
   double ld_116 = gia_240[ai_8] * Point;
   bool li_148 = FALSE;
   if (gba_408[ai_8]) {
      l_shift_24 = iBarShift(NULL, gia_252[ai_8], gia_412[ai_8], TRUE);
      l_shift_28 = iBarShift(NULL, gia_252[ai_8], gia_416[ai_8], TRUE);
      if (l_shift_24 < 0 || l_shift_28 < 0) {
         gia_432[ai_8] = 0;
         return (-1);
      }
      if (gia_412[ai_8] <= gia_416[ai_8]) gi_444 = l_shift_24;
      else gi_444 = l_shift_28;
      li_32 = gi_444 - 1;
      ld_100 = iLow(NULL, gia_252[ai_8], l_shift_24);
      ld_92 = iHigh(NULL, gia_252[ai_8], l_shift_28);
   } else {
      gba_408[ai_8] = 1;
      l_shift_24 = gi_444;
      l_shift_28 = gi_444;
      li_32 = gi_444;
   }
   for (int li_60 = li_32; li_60 >= 0; li_60--) {
      if (li_60 < l_shift_24) {
         l_lowest_12 = iLowest(NULL, gia_252[ai_8], MODE_LOW, gia_236[ai_8], li_60);
         ld_108 = iLow(NULL, gia_252[ai_8], l_lowest_12);
         if (ld_108 == ld_100) ld_108 = 0.0;
         else {
            ld_100 = ld_108;
            if (iLow(NULL, gia_252[ai_8], li_60) - ld_108 > ld_116) ld_108 = 0.0;
            else {
               for (int li_64 = 1; li_64 <= gia_244[ai_8]; li_64++)
                  if (ld_108 < ada_0[l_lowest_12 + li_64]) ada_0[l_lowest_12 + li_64] = 0.0;
            }
         }
         if (l_lowest_12 == li_60) ada_0[l_lowest_12] = ld_108;
      }
      if (li_60 < l_shift_28) {
         l_lowest_12 = iHighest(NULL, gia_252[ai_8], MODE_HIGH, gia_236[ai_8], li_60);
         ld_108 = iHigh(NULL, gia_252[ai_8], l_lowest_12);
         if (ld_108 == ld_92) ld_108 = 0.0;
         else {
            ld_92 = ld_108;
            if (ld_108 - iHigh(NULL, gia_252[ai_8], li_60) > ld_116) ld_108 = 0.0;
            else {
               for (li_64 = 1; li_64 <= gia_244[ai_8]; li_64++)
                  if (ld_108 > ada_4[l_lowest_12 + li_64]) ada_4[l_lowest_12 + li_64] = 0.0;
            }
         }
         if (l_lowest_12 == li_60) ada_4[l_lowest_12] = ld_108;
      }
   }
   ld_92 = -1;
   ld_100 = -1;
   for (li_60 = gi_444; li_60 >= 0; li_60--) {
      ld_76 = ada_0[li_60];
      ld_84 = ada_4[li_60];
      if (ld_76 == 0.0 && ld_84 == 0.0) continue;
      if (ld_84 != 0.0) {
         if (ld_92 > 0.0) {
            if (ld_92 < ld_84) ada_4[li_68] = 0;
            else ada_4[li_60] = 0;
         }
         if (ld_92 < ld_84 || ld_92 < 0.0) {
            ld_92 = ld_84;
            li_68 = li_60;
         }
         ld_100 = -1;
      }
      if (ld_76 != 0.0) {
         if (ld_100 > 0.0) {
            if (ld_100 > ld_76) ada_0[li_72] = 0;
            else ada_0[li_60] = 0;
         }
         if (ld_76 < ld_100 || ld_100 < 0.0) {
            ld_100 = ld_76;
            li_72 = li_60;
         }
         ld_92 = -1;
      }
   }
   gia_432[ai_8] = iBars(NULL, gia_252[ai_8]);
   gda_420[ai_8] = iLow(NULL, gia_252[ai_8], 0);
   gda_424[ai_8] = iHigh(NULL, gia_252[ai_8], 0);
   gia_428[ai_8] = iTime(NULL, gia_252[ai_8], 0);
   int l_count_16 = 0;
   int l_count_20 = 0;
   if (fibofan || fiboChannel) li_40 = 0;
   else li_40 = 4;
   for (li_60 = 0; li_60 < gia_432[ai_8]; li_60++) {
      if (li_40 < 4) {
         if (ada_0[li_60] > 0.0 || ada_4[li_60] > 0.0) {
            if (li_44 == 0) {
               if (li_40 == 0) {
                  gia_452[ai_8][0] = iTime(NULL, gia_252[ai_8], li_60);
                  if (ada_0[li_60] > 0.0 && ada_4[li_60] > 0.0) {
                     ld_132 = ada_0[li_60];
                     ld_124 = ada_4[li_60];
                     if (gia_452[ai_8][1] != gia_452[ai_8][0]) {
                        gia_452[ai_8][1] = gia_452[ai_8][0];
                        li_148 = TRUE;
                        li_40++;
                     } else li_40 = 4;
                  } else {
                     if (ada_0[li_60] > 0.0) {
                        gda_448[ai_8][0] = ada_0[li_60];
                        li_44 = -1;
                     } else {
                        if (ada_4[li_60] > 0.0) {
                           gda_448[ai_8][0] = ada_4[li_60];
                           li_44 = 1;
                        }
                     }
                  }
                  li_40++;
               } else {
                  gia_452[ai_8][2] = iTime(NULL, gia_252[ai_8], li_60);
                  if (ada_0[li_60] > 0.0) {
                     gda_448[ai_8][0] = ld_132;
                     gda_448[ai_8][1] = ld_124;
                     gda_448[ai_8][2] = ada_0[li_60];
                     li_44 = -1;
                  } else {
                     if (ada_4[li_60] > 0.0) {
                        gda_448[ai_8][0] = ld_124;
                        gda_448[ai_8][1] = ld_132;
                        gda_448[ai_8][2] = ada_4[li_60];
                        li_44 = 1;
                     }
                  }
                  li_40++;
               }
            } else {
               if (li_40 == 1) {
                  if (gia_452[ai_8][1] != iTime(NULL, gia_252[ai_8], li_60)) {
                     gia_452[ai_8][1] = iTime(NULL, gia_252[ai_8], li_60);
                     li_148 = TRUE;
                     if (ada_0[li_60] > 0.0 && ada_4[li_60] > 0.0) {
                        gia_452[ai_8][2] = gia_452[ai_8][1];
                        if (li_44 == -1) {
                           gda_448[ai_8][1] = ada_4[li_60];
                           gda_448[ai_8][2] = ada_0[li_60];
                        } else {
                           gda_448[ai_8][1] = ada_0[li_60];
                           gda_448[ai_8][2] = ada_4[li_60];
                        }
                        li_40++;
                     } else {
                        if (ada_0[li_60] > 0.0) {
                           gda_448[ai_8][1] = ada_0[li_60];
                           li_44 = -1;
                        } else {
                           if (ada_4[li_60] > 0.0) {
                              gda_448[ai_8][1] = ada_4[li_60];
                              li_44 = 1;
                           }
                        }
                     }
                     li_40++;
                  } else li_40 = 4;
               } else {
                  if (li_40 == 2) {
                     gia_452[ai_8][2] = iTime(NULL, gia_252[ai_8], li_60);
                     if (ada_0[li_60] > 0.0 && ada_4[li_60] > 0.0) {
                        gia_452[ai_8][3] = gia_452[ai_8][2];
                        if (li_44 == -1) {
                           gda_448[ai_8][2] = ada_4[li_60];
                           gda_448[ai_8][3] = ada_0[li_60];
                        } else {
                           gda_448[ai_8][2] = ada_0[li_60];
                           gda_448[ai_8][3] = ada_4[li_60];
                        }
                        li_40++;
                     } else {
                        if (ada_0[li_60] > 0.0) {
                           gda_448[ai_8][2] = ada_0[li_60];
                           li_44 = -1;
                        } else {
                           if (ada_4[li_60] > 0.0) {
                              gda_448[ai_8][2] = ada_4[li_60];
                              li_44 = 1;
                           }
                        }
                     }
                     li_40++;
                  } else {
                     if (li_40 == 3) {
                        gia_452[ai_8][3] = iTime(NULL, gia_252[ai_8], li_60);
                        if (ada_0[li_60] > 0.0 && ada_4[li_60] > 0.0) {
                           if (li_44 == -1) gda_448[ai_8][3] = ada_4[li_60];
                           else gda_448[ai_8][3] = ada_0[li_60];
                        } else {
                           if (ada_0[li_60] > 0.0) gda_448[ai_8][3] = ada_0[li_60];
                           else
                              if (ada_4[li_60] > 0.0) gda_448[ai_8][3] = ada_4[li_60];
                        }
                        li_40++;
                     }
                  }
               }
            }
         }
      }
      if (ada_0[li_60] > 0.0) {
         if (l_count_16 <= 1) gia_412[ai_8] = iTime(NULL, gia_252[ai_8], li_60);
         l_count_16++;
      }
      if (ada_4[li_60] > 0.0) {
         if (l_count_20 <= 1) gia_416[ai_8] = iTime(NULL, gia_252[ai_8], li_60);
         l_count_20++;
      }
      if (l_count_16 > 1 && l_count_20 > 1) break;
   }
   if (!li_148) return (0);
   if (fibofan || fiboChannel) {
      if (gia_252[ai_8] == 0 || gia_252[ai_8] == Period()) {
         gia_456[ai_8][0] = gia_452[ai_8][0];
         gia_456[ai_8][1] = gia_452[ai_8][1];
         gia_456[ai_8][2] = gia_452[ai_8][2];
         gia_456[ai_8][3] = gia_452[ai_8][3];
      } else {
         if (gda_448[ai_8][0] > gda_448[ai_8][1]) li_44 = 1;
         else li_44 = -1;
         ld_124 = gda_448[ai_8][1];
         for (li_40 = 0; li_40 < 4; li_40++) {
            if (gia_452[ai_8][li_40] != 0) {
               li_60 = iBarShift(NULL, 0, gia_452[ai_8][li_40], FALSE);
               li_52 = li_60;
               li_56 = gia_452[ai_8][li_40] + 60 * gia_252[ai_8];
               if (li_56 > Time[Bars - 1]) {
                  for (int li_48 = li_60; iTime(NULL, 0, li_48) < li_56 && li_48 >= 0; li_48--) {
                     if (li_44 < 0) {
                        ld_132 = iLow(NULL, 0, li_48);
                        if (ld_124 > ld_132) {
                           ld_124 = ld_132;
                           li_52 = li_48;
                        }
                     } else {
                        ld_132 = iHigh(NULL, 0, li_48);
                        if (ld_124 < ld_132) {
                           ld_124 = ld_132;
                           li_52 = li_48;
                        }
                     }
                  }
                  gia_456[ai_8][li_40] = iTime(NULL, 0, li_52);
               }
               if (li_44 > 0) {
                  li_44 = -1;
                  ld_124 = 1000000;
               } else {
                  li_44 = 1;
                  ld_124 = 0;
               }
               if (!fiboChannel && li_40 == 2) li_40 = 4;
            }
         }
      }
   }
   if (fibofan && gia_456[ai_8][2] > 0 && gia_456[ai_8][1] && gia_272[ai_8] == 1) {
      if (gia_252[ai_8] == 0) ls_176 = _getTF(Period());
      else ls_176 = _getTF(gia_252[ai_8]);
      l_name_152 = "f_" + ExtComplect + "_" + ai_8 + "  fibo fan " + ls_176;
      ObjectDelete(l_name_152);
      ObjectCreate(l_name_152, OBJ_FIBOFAN, 0, gia_456[ai_8][2], gda_448[ai_8][2], gia_456[ai_8][1], gda_448[ai_8][1]);
      ObjectSet(l_name_152, OBJPROP_COLOR, CLR_NONE);
      ObjectSet(l_name_152, OBJPROP_LEVELCOLOR, gia_260[ai_8]);
      ObjectSet(l_name_152, OBJPROP_LEVELSTYLE, gia_276[ai_8]);
      ObjectSet(l_name_152, OBJPROP_LEVELWIDTH, gia_280[ai_8]);
      ObjectSet(l_name_152, OBJPROP_FIBOLEVELS, gi_460);
      ls_160 = FiboFreeFan;
      for (li_48 = 0; li_48 <= gi_460; li_48++) {
         li_40 = StringFind(ls_160, ",", 0);
         ls_168 = StringTrimLeft(StringTrimRight(StringSubstr(ls_160, 0, li_40)));
         l_str2dbl_140 = StrToDouble(ls_168);
         if (l_str2dbl_140 < 1.0) ls_168 = StringSubstr(ls_168, 1);
         ObjectSet(l_name_152, li_48 + 210, l_str2dbl_140);
         ObjectSetFiboDescription(l_name_152, li_48, ls_168);
         if (li_40 >= 0) ls_160 = StringSubstr(ls_160, li_40 + 1);
      }
   }
   if (fiboChannel && gia_456[ai_8][3] > 0 && gia_456[ai_8][2] > 0 && gia_456[ai_8][1] && gia_284[ai_8] == 1) {
      if (gia_252[ai_8] == 0) ls_176 = _getTF(Period());
      else ls_176 = _getTF(gia_252[ai_8]);
      l_name_152 = "f_" + ExtComplect + "_" + ai_8 + "  channel " + ls_176;
      ObjectDelete(l_name_152);
      ObjectCreate(l_name_152, OBJ_FIBOCHANNEL, 0, gia_456[ai_8][3], gda_448[ai_8][3], gia_456[ai_8][1], gda_448[ai_8][1], gia_456[ai_8][2], gda_448[ai_8][2]);
      if (gia_292[ai_8] > 0) {
         ObjectSet(l_name_152, OBJPROP_WIDTH, gia_292[ai_8]);
         ObjectSet(l_name_152, OBJPROP_COLOR, gia_260[ai_8]);
      } else ObjectSet(l_name_152, OBJPROP_COLOR, CLR_NONE);
      ObjectSet(l_name_152, OBJPROP_LEVELCOLOR, gia_260[ai_8]);
      ObjectSet(l_name_152, OBJPROP_LEVELSTYLE, gia_288[ai_8]);
      ObjectSet(l_name_152, OBJPROP_LEVELWIDTH, gia_296[ai_8]);
      ObjectSet(l_name_152, OBJPROP_FIBOLEVELS, gi_464);
      ls_160 = FiboFreeChannel;
      for (li_48 = 0; li_48 <= gi_464; li_48++) {
         li_40 = StringFind(ls_160, ",", 0);
         ls_168 = StringTrimLeft(StringTrimRight(StringSubstr(ls_160, 0, li_40)));
         l_str2dbl_140 = StrToDouble(ls_168);
         ObjectSet(l_name_152, li_48 + 210, l_str2dbl_140);
         if (li_40 >= 0) ls_160 = StringSubstr(ls_160, li_40 + 1);
      }
   }
   return (0);
}

int ZigZagDT(double &ada_0[], double &ada_4[], double ada_8[], double ada_12[], int ai_16) {
   int li_28;
   int li_32;
   int li_40;
   int l_datetime_64;
   int li_68;
   int li_20 = 0;
   int l_count_36 = 0;
   double l_low_48 = -1;
   double l_high_56 = -1;
   int li_72 = 60 * gia_252[ai_16] - 1;
   bool li_76 = FALSE;
   if (gba_404[ai_16]) {
      li_40 = ExtReCalculate + 1;
      l_datetime_64 = iTime(NULL, gia_252[ai_16], li_20);
      for (int l_index_24 = 0; l_count_36 < li_40 && l_index_24 < Bars; l_index_24++) {
         if (Period() == PERIOD_W1) {
            if (l_low_48 < 0.0 && l_high_56 < 0.0) li_76 = Time[l_index_24] < l_datetime_64;
            else li_76 = Time[l_index_24] + li_72 < l_datetime_64;
         } else li_76 = Time[l_index_24] < l_datetime_64;
         if (li_76) {
            li_20++;
            if (showZigZag == 2) li_68 = l_datetime_64 + 60 * gia_252[ai_16];
            l_datetime_64 = iTime(NULL, gia_252[ai_16], li_20);
         }
         ada_0[l_index_24] = 0;
         ada_4[l_index_24] = 0;
         if (ada_8[li_20] > 0.0) {
            if (l_low_48 >= Low[l_index_24] || l_low_48 < 0.0) {
               l_low_48 = Low[l_index_24];
               li_28 = l_index_24;
            }
         } else {
            if (l_low_48 > 0.0) {
               if (showZigZag == 2) {
                  for (int li_44 = l_index_24 - 1; Time[li_44] < li_68; li_44--) {
                     if (li_44 < 0) break;
                     ada_0[li_44] = l_low_48;
                  }
               }
               ada_0[li_28] = l_low_48;
               l_low_48 = -1;
               l_count_36++;
            }
         }
         if (ada_12[li_20] > 0.0) {
            if (l_high_56 <= High[l_index_24]) {
               l_high_56 = High[l_index_24];
               li_32 = l_index_24;
            }
         } else {
            if (l_high_56 > 0.0) {
               if (showZigZag == 2) {
                  for (li_44 = l_index_24 - 1; Time[li_44] < li_68; li_44--) {
                     if (li_44 < 0) break;
                     ada_4[li_44] = l_high_56;
                  }
               }
               ada_4[li_32] = l_high_56;
               l_high_56 = -1;
               l_count_36++;
            }
         }
      }
   } else {
      if (gi_444 <= gia_236[ai_16] + gia_244[ai_16]) {
         gia_432[ai_16] = 0;
         return (-1);
      }
      li_40 = iBarShift(NULL, Period(), iTime(NULL, gia_252[ai_16], gi_444), FALSE);
      if (li_40 <= 0) {
         gia_432[ai_16] = 0;
         return (-1);
      }
      gba_404[ai_16] = 1;
      l_datetime_64 = iTime(NULL, gia_252[ai_16], li_20);
      for (l_index_24 = 0; l_index_24 < li_40; l_index_24++) {
         if (Period() == PERIOD_W1) {
            if (l_low_48 < 0.0 && l_high_56 < 0.0) li_76 = Time[l_index_24] < l_datetime_64;
            else li_76 = Time[l_index_24] + li_72 < l_datetime_64;
         } else li_76 = Time[l_index_24] < l_datetime_64;
         if (li_76) {
            li_20++;
            if (showZigZag == 2) li_68 = l_datetime_64 + 60 * gia_252[ai_16];
            l_datetime_64 = iTime(NULL, gia_252[ai_16], li_20);
         }
         if (ada_8[li_20] > 0.0) {
            if (l_low_48 >= Low[l_index_24] || l_low_48 < 0.0) {
               l_low_48 = Low[l_index_24];
               li_28 = l_index_24;
            }
         } else {
            if (l_low_48 > 0.0) {
               if (showZigZag == 2) {
                  for (li_44 = l_index_24 - 1; Time[li_44] < li_68; li_44--) {
                     if (li_44 < 0) break;
                     ada_0[li_44] = l_low_48;
                  }
               }
               ada_0[li_28] = l_low_48;
               l_low_48 = -1;
            }
         }
         if (ada_12[li_20] > 0.0) {
            if (l_high_56 <= High[l_index_24]) {
               l_high_56 = High[l_index_24];
               li_32 = l_index_24;
            }
         } else {
            if (l_high_56 > 0.0) {
               if (showZigZag == 2) {
                  for (li_44 = l_index_24 - 1; Time[li_44] < li_68; li_44--) {
                     if (li_44 < 0) break;
                     ada_4[li_44] = l_high_56;
                  }
               }
               ada_4[li_32] = l_high_56;
               l_high_56 = -1;
            }
         }
      }
   }
   return (0);
}

int _period(int ai_0, int ai_4) {
   if (ai_4 < Period() && ai_4 > 0) gia_236[ai_0] = 0;
   if (ai_4 == Period()) return (0);
   return (ai_4);
}

void Shift_elements(double &ada_0[], double &ada_4[]) {
   int li_12 = ArraySize(ada_0) - 1;
   for (int li_8 = li_12; li_8 > 0; li_8--) {
      ada_0[li_8] = ada_0[li_8 - 1];
      ada_4[li_8] = ada_4[li_8 - 1];
   }
   ada_0[0] = 0;
   ada_4[0] = 0;
}

void arr_resize(double ada_0[], double ada_4[], int ai_8, int ai_12) {
   if (gia_252[ai_12] > 0) {
      ArrayResize(ada_0, ai_8);
      ArrayResize(ada_4, ai_8);
      ArrayInitialize(ada_0, 0);
      ArrayInitialize(ada_4, 0);
   }
}

void _stringtointarray(string as_0, int &aia_8[], int ai_12) {
   int li_20;
   int li_24 = 0;
   for (int l_index_16 = 0; l_index_16 < ai_12; l_index_16++) {
      li_20 = StringFind(as_0, ",", li_24);
      if (li_20 < 0) {
         aia_8[l_index_16] = StrToInteger(StringSubstr(as_0, li_24));
         return;
      }
      aia_8[l_index_16] = StrToInteger(StringSubstr(as_0, li_24, li_20 - li_24));
      li_24 = li_20 + 1;
   }
}

void _stringtocolorarray(string as_0, int &aia_8[], int ai_12) {
   int li_20;
   int li_24 = 0;
   for (int l_index_16 = 0; l_index_16 < ai_12; l_index_16++) {
      li_20 = StringFind(as_0, ",", li_24);
      if (li_20 < 0) {
         aia_8[l_index_16] = fStrToColor(StringSubstr(as_0, li_24));
         return;
      }
      aia_8[l_index_16] = fStrToColor(StringSubstr(as_0, li_24, li_20 - li_24));
      li_24 = li_20 + 1;
   }
}

int fStrToColor(string as_0) {
   int lia_8[] = {0, 25600, 5197615, 32896, 32768, 8421376, 8388608, 8388736, 128, 8519755, 7346457, 9109504, 3107669, 1262987, 2263842, 2330219, 5737262, 755384, 9125192, 2970272, 13434880, 2763429, 13749760, 6908265, 11186720, 13828244, 2237106, 8721863, 7451452, 1993170, 3937500, 11829830, 2139610, 10156544, 64636, 10526303, 13382297, 3329434, 3329330, 17919, 36095, 42495, 55295, 65535, 65407, 65280, 8388352, 16776960, 16760576, 16711680, 16711935, 255, 8421504, 9470064, 4163021, 14822282, 10061943, 9639167, 13422920, 16748574, 13688896, 14772545, 13458026, 7059389, 6053069, 13850042, 3145645, 11193702, 9419919, 4678655, 9408444, 14053594, 14381203, 9662683, 5275647, 15570276, 11119017, 6333684, 15624315, 9221330, 8034025, 8894686, 11823615, 7504122, 15631086, 8421616, 15453831, 8036607, 14524637, 9234160, 9498256, 13959039, 12632256, 16436871, 14599344, 15128749, 10025880, 14204888, 15130800, 11200750, 15658671, 13882323, 11788021, 11394815, 11920639, 12695295, 14474460, 12180223, 13353215, 12903679, 13826810, 13495295, 13499135, 14480885, 14150650, 14020607, 14481663, 14745599, 16777184, 15134970, 16443110, 14804223, 15136253, 16119285, 15660543, 15794175, 15794160, 16775408, 16118015, 16449525, 16448255, 16777215};
   string lsa_12[] = {"Black", "DarkGreen", "DarkSlateGray", "Olive", "Green", "Teal", "Navy", "Purple", "Maroon", "Indigo", "MidnightBlue", "DarkBlue", "DarkOliveGreen", "SaddleBrown", "ForestGreen", "OliveDrab", "SeaGreen", "DarkGoldenrod", "DarkSlateBlue", "Sienna", "MediumBlue", "Brown", "DarkTurquoise", "DimGray", "LightSeaGreen", "DarkViolet", "FireBrick", "MediumVioletRed", "MediumSeaGreen", "Chocolate", "Crimson", "SteelBlue", "Goldenrod", "MediumSpringGreen", "LawnGreen", "CadetBlue", "DarkOrchid", "YellowGreen", "LimeGreen", "OrangeRed", "DarkOrange", "Orange", "Gold", "Yellow", "Chartreuse", "Lime", "SpringGreen", "Aqua", "DeepSkyBlue", "Blue", "Magenta", "Red", "Gray", "SlateGray", "Peru", "BlueViolet", "LightSlateGray", "DeepPink", "MediumTurquoise", "DodgerBlue", "Turquoise", "RoyalBlue", "SlateBlue", "DarkKhaki", "IndianRed", "MediumOrchid", "GreenYellow", "MediumAquamarine", "DarkSeaGreen", "Tomato", "RosyBrown", "Orchid", "MediumPurple", "PaleVioletRed", "Coral", "CornflowerBlue", "DarkGray", "SandyBrown", "MediumSlateBlue", "Tan", "DarkSalmon", "BurlyWood", "HotPink", "Salmon", "Violet", "LightCoral", "SkyBlue", "LightSalmon", "Plum", "Khaki", "LightGreen", "Aquamarine", "Silver", "LightSkyBlue", "LightSteelBlue", "LightBlue", "PaleGreen", "Thistle", "PowderBlue", "PaleGoldenrod", "PaleTurquoise", "LightGray", "Wheat", "NavajoWhite", "Moccasin", "LightPink", "Gainsboro", "PeachPuff", "Pink", "Bisque", "LightGoldenrod", "BlanchedAlmond", "LemonChiffon", "Beige", "AntiqueWhite", "PapayaWhip", "Cornsilk", "LightYellow", "LightCyan", "Linen", "Lavender", "MistyRose", "OldLace", "WhiteSmoke", "Seashell", "Ivory", "Honeydew", "AliceBlue", "LavenderBlush", "MintCream", "Snow", "White"};
   as_0 = StringTrimLeft(StringTrimRight(as_0));
   for (int l_index_16 = 0; l_index_16 < ArraySize(lsa_12); l_index_16++)
      if (as_0 == lsa_12[l_index_16]) return (lia_8[l_index_16]);
   return (255);
}

void _delete_fibo() {
   string l_name_4;
   for (int l_objs_total_0 = ObjectsTotal(); l_objs_total_0 >= 0; l_objs_total_0--) {
      l_name_4 = ObjectName(l_objs_total_0);
      if (StringFind(l_name_4, "f_" + ExtComplect + "_") > -1) ObjectDelete(l_name_4);
   }
}

int quantityFibo(string as_0) {
   int li_12;
   int li_16;
   int l_count_8 = 0;
   while (true) {
      li_16 = StringFind(as_0, ",", li_12 + 1);
      if (li_16 <= 0) break;
      l_count_8++;
      li_12 = li_16;
   }
   return (l_count_8 + 1);
}

string _getTF(int ai_0) {
   switch (ai_0) {
   case 1:
      return ("m1");
   case 5:
      return ("m5");
   case 15:
      return ("m15");
   case 30:
      return ("m30");
   case 60:
      return ("h1");
   case 240:
      return ("h4");
   case 1440:
      return ("d1");
   case 10080:
      return ("w1");
   case 43200:
      return ("mn");
   }
   return ("" + ai_0);
}
