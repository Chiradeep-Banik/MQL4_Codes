#property copyright ""
#property link      ""

#property indicator_chart_window
#property indicator_buffers 7
#property indicator_color1 LawnGreen
#property indicator_color2 Red
#property indicator_color3 Red
#property indicator_color4 Blue
#property indicator_color5 Orange
#property indicator_color6 Red
#property indicator_color7 LawnGreen

bool Gi_84 = FALSE;
int Gi_88 = 12;
int Gi_92 = 31;
int Gi_96 = 2008;
extern bool Alert_SoundON = TRUE;
extern bool EmailON = TRUE;
extern bool ShowTradeArrowsOnly = TRUE;
extern bool ShowBuySellLines = TRUE;
extern bool ShowBadTradeExits = TRUE;
extern bool ShowFibProfitTargets = TRUE;
extern int MA_Period = 50;
extern string m = "--Moving Average Types--";
extern string m0 = " 0 = SMA";
extern string m1 = " 1 = EMA";
extern string m2 = " 2 = SMMA";
extern string m3 = " 3 = LWMA";
extern int MA_Type = 0;
extern string p = "--Applied Price Types--";
extern string p0 = " 0 = close";
extern string p1 = " 1 = open";
extern string p2 = " 2 = high";
extern string p3 = " 3 = low";
extern string p4 = " 4 = median(high+low)/2";
extern string p5 = " 5 = typical(high+low+close)/3";
extern string p6 = " 6 = weighted(high+low+close+close)/4";
extern int MA_AppliedPrice = 4;
extern double AngleTreshold = 0.25;
extern int PrevMAShift = 2;
extern int CurMAShift = 0;
int G_ma_method_256 = MODE_SMA;
bool Gi_260 = TRUE;
bool Gi_264 = TRUE;
extern string pg0 = "Bad Trade Exits";
extern string pg = "Price Gap inputs";
extern int PriceGapMN = 100;
extern int PriceGapW1 = 60;
extern int PriceGapD1 = 40;
extern int PriceGapH4 = 25;
extern int PriceGapH1 = 20;
extern int PriceGapM30 = 15;
extern int PriceGapM15 = 10;
extern int PriceGapM5 = 5;
extern int PriceGapM1 = 3;
extern string fp = "Face Position";
extern int FacePosMN = 80;
extern int FacePosW1 = 60;
extern int FacePosD1 = 48;
extern int FacePosH4 = 24;
extern int FacePosH1 = 16;
extern int FacePosM30 = 10;
extern int FacePosM15 = 8;
extern int FacePosM5 = 4;
extern int FacePosM1 = 4;
extern string tp12 = "Fib Retrace Inputs";
extern int BarsBack = 10;
extern double FibRetraceTrade1 = 100.0;
extern double FibRetraceTrade2 = 161.8;
extern double FibRetraceTrade3 = 261.8;
extern bool AddSpreadToTargets = TRUE;
extern string ap = "Arrow Position";
extern int Arrow_Position = 5;
extern string to = "---Text Object Settings---";
extern int Text_X_Offset = 20;
extern int StatusTxtSize = 10;
extern color StatusColor = White;
extern int CommentTxtSize = 10;
extern color CommentColor = White;
extern color BuyLineColor = Aqua;
extern color SellLineColor = Yellow;
extern color Fib1Color = Pink;
extern color Fib2Color = Orange;
extern color Fib3Color = Red;
int G_datetime_464;
double G_ibuf_468[];
double G_ibuf_472[];
double G_ibuf_476[];
double G_ibuf_480[];
double G_ibuf_484[];
double G_ibuf_488[];
double G_ibuf_492[];
double Gd_496;
double Gd_504;
int Gi_512;
string Gs_516 = "";
string Gs_524;
string Gs_532;
int G_datetime_540;
bool G_global_var_544;
bool G_global_var_548;
int Gi_552;
int Gi_556;
int Gi_560;
string Gs_564;
string Gs_572;
string Gs_580;
string Gs_588 = "Steinitz Fractal Breakout Status";
int Gi_596;
bool Gi_600 = FALSE;
string Gs_604 = "_SFBInd15_";
bool Gi_612;
bool Gi_616;
double Gd_620;
double Gd_628;
double G_ima_636;
double G_ima_644;
double Gd_652;
double Gd_660;
double Gd_668;
double Gd_676;
double G_ilow_684;
double G_ihigh_692;
double Gd_700;
double Gd_708;
double Gd_716;
int G_time_724 = 0;
int G_time_728 = 0;
int G_time_732 = 0;
int Gi_736 = 0;
int Gi_740;
string G_var_name_744;
string G_var_name_752;
string G_var_name_760;
string G_var_name_768;
string G_var_name_776;
string G_var_name_784;
string G_var_name_792;
string G_var_name_800;
string G_var_name_808;
string G_var_name_816;
string G_var_name_824;
string G_var_name_832;
string G_var_name_840;
string G_var_name_848;
string G_var_name_856;
bool Gi_864 = TRUE;

int init() {
   string Ls_0;
   string Ls_8;
   string Ls_16;
   bool Li_24;
   string Ls_unused_36;
   SetIndexStyle(0, DRAW_ARROW, EMPTY);
   SetIndexArrow(0, 233);
   SetIndexBuffer(0, G_ibuf_468);
   SetIndexStyle(1, DRAW_ARROW, EMPTY);
   SetIndexArrow(1, 234);
   SetIndexBuffer(1, G_ibuf_472);
   SetIndexStyle(2, DRAW_LINE, STYLE_SOLID);
   SetIndexBuffer(2, G_ibuf_476);
   SetIndexStyle(3, DRAW_LINE, STYLE_SOLID);
   SetIndexBuffer(3, G_ibuf_480);
   SetIndexStyle(4, DRAW_LINE, STYLE_SOLID);
   SetIndexBuffer(4, G_ibuf_484);
   SetIndexStyle(5, DRAW_ARROW, EMPTY);
   SetIndexArrow(5, 76);
   SetIndexBuffer(5, G_ibuf_492);
   SetIndexStyle(6, DRAW_ARROW, EMPTY);
   SetIndexArrow(6, 76);
   SetIndexBuffer(6, G_ibuf_488);
   if (MA_Type >= 4) Li_24 = FALSE;
   else Li_24 = MA_Type;
   switch (Li_24) {
   case 0:
      G_ma_method_256 = 0;
      Ls_0 = "sma10";
      Ls_8 = "sma21";
      Ls_16 = "sma50";
      break;
   case 1:
      G_ma_method_256 = 1;
      Ls_0 = "ema10";
      Ls_8 = "ema21";
      Ls_16 = "ema50";
      break;
   case 2:
      G_ma_method_256 = 2;
      Ls_0 = "smma10";
      Ls_8 = "smma21";
      Ls_16 = "smma50";
      break;
   case 3:
      G_ma_method_256 = 3;
      Ls_0 = "lwma10";
      Ls_8 = "lwma21";
      Ls_16 = "lwma50";
      break;
   default:
      G_ma_method_256 = 0;
      Ls_0 = "sma10";
      Ls_8 = "sma21";
      Ls_16 = "sma50";
   }
   SetIndexLabel(2, Ls_0);
   SetIndexLabel(3, Ls_8);
   SetIndexLabel(4, Ls_16);
   Gd_496 = Get_mFactor();
   Gi_600 = FALSE;
   ClearArrows();
   DeleteBadLabels();
   if (IsDemo() == TRUE) Gi_600 = TRUE;
   if (Gi_600 == TRUE) {
      DeleteExistingLabels();
      SetupLabels();
      ClearLabels();
      Gd_504 = SetPoint();
      Gi_512 = SetDigit();
      G_global_var_544 = FALSE;
      G_global_var_548 = FALSE;
      OutputStatusToChart(Gs_588 + " INITIALIZED SUCCESSFULLY");
      if (Gi_84 == TRUE) OutputComment1ToChart("Expires on " + Gi_88 + "/" + Gi_92 + "/" + Gi_96);
      else OutputComment1ToChart("No expiration");
   }
   if (CurMAShift >= PrevMAShift) {
      Print("Error: CurMAShift >= PrevMAShift");
      PrevMAShift = 6;
      CurMAShift = 0;
   }
   GetGlobalVars();
   DeleteFractObjects();
   DeleteBadLabels();
   int objs_total_32 = ObjectsTotal();
   return (0);
}

int deinit() {
   ClearLabels();
   DeleteExistingLabels();
   ClearArrows();
   DeleteFractObjects();
   return (0);
}

int FibRetracement(int Ai_0, int Ai_4) {
   int Li_ret_16;
   int highest_8 = iHighest(NULL, 0, MODE_HIGH, BarsBack, Ai_4);
   int lowest_12 = iLowest(NULL, 0, MODE_LOW, BarsBack, Ai_4);
   G_ihigh_692 = iHigh(NULL, 0, highest_8);
   G_ilow_684 = iLow(NULL, 0, lowest_12);
   G_ihigh_692 = Floor(G_ihigh_692, Gi_512);
   G_ilow_684 = Ceil(G_ilow_684, Gi_512);
   if (Ai_0 == 0)
      if (G_ihigh_692 > G_ilow_684) Li_ret_16 = MathFloor((G_ihigh_692 - G_ilow_684) / Gd_504);
   if (Ai_0 == 1)
      if (G_ilow_684 < G_ihigh_692) Li_ret_16 = MathFloor((G_ihigh_692 - G_ilow_684) / Gd_504);
   return (Li_ret_16);
}

void FibLines(int Ai_0, int Ai_4) {
   int Li_8 = MarketInfo(Symbol(), MODE_SPREAD);
   if (Digits == 3 || Digits == 5) Li_8 /= 10;
   int Li_12 = FibRetracement(Ai_0, Ai_4);
   if (Ai_0 == 0) {
      Gd_700 = G_ilow_684 + Li_12 * FibRetraceTrade1 / 100.0 * Gd_504;
      if (AddSpreadToTargets) Gd_700 += Li_8 * Gd_504;
      SaveFib1(Gd_700);
      Gd_708 = G_ilow_684 + Li_12 * FibRetraceTrade2 / 100.0 * Gd_504;
      if (AddSpreadToTargets) Gd_708 += Li_8 * Gd_504;
      SaveFib2(Gd_708);
      Gd_716 = G_ilow_684 + Li_12 * FibRetraceTrade3 / 100.0 * Gd_504;
      if (AddSpreadToTargets) Gd_716 += Li_8 * Gd_504;
      SaveFib3(Gd_716);
   }
   if (Ai_0 == 1) {
      Gd_700 = G_ihigh_692 - Li_12 * FibRetraceTrade1 / 100.0 * Gd_504;
      if (AddSpreadToTargets) Gd_700 -= Li_8 * Gd_504;
      SaveFib1(Gd_700);
      Gd_708 = G_ihigh_692 - Li_12 * FibRetraceTrade2 / 100.0 * Gd_504;
      if (AddSpreadToTargets) Gd_708 -= Li_8 * Gd_504;
      SaveFib2(Gd_708);
      Gd_716 = G_ihigh_692 - Li_12 * FibRetraceTrade3 / 100.0 * Gd_504;
      if (AddSpreadToTargets) Gd_716 -= Li_8 * Gd_504;
      SaveFib3(Gd_716);
   }
   RemoveLine("Fib1");
   RemoveLine("Fib2");
   RemoveLine("Fib3");
   DisplayLine("Fib1", Gd_700, Fib1Color);
   DisplayLine("Fib2", Gd_708, Fib2Color);
   DisplayLine("Fib3", Gd_716, Fib3Color);
}

int start() {
   int Li_8;
   int Li_12;
   double ilow_16;
   double ihigh_24;
   int Li_32 = IndicatorCounted();
   DeleteBadLabels();
   if (Gi_556 < 10) {
      SetupLabels();
      ClearLabels();
      DeleteExistingLabels();
      SetupLabels();
   }
   if (Gi_600 == FALSE) return (0);
   Gi_596 = CheckTradeFilters();
   if (Gi_596 == 1) return (0);
   if (Li_32 < 0) return (-1);
   if (Li_32 > 0) Li_32--;
   int Li_0 = Bars - Li_32;
   if (Gi_864) {
      ClearArrows();
      Gi_864 = FALSE;
   }
   for (int Li_4 = Li_0 - 1; Li_4 >= 0; Li_4--) {
      GetMAs(Li_4 + 1);
      Gi_612 = FALSE;
      SaveBuy(Gi_612);
      Gi_616 = FALSE;
      SaveSell(Gi_616);
      CheckMA_Angle(Li_4 + 1);
      CheckHighLowRules(Li_4 + 1);
      CheckMAs();
      if (Gi_612) {
         Gd_620 = iHigh(NULL, 0, Li_4 + 1);
         Gd_620 = Floor(Gd_620, Gi_512);
         SaveBuy1(Gd_620);
      }
      if (Gi_616) {
         Gd_628 = iLow(NULL, 0, Li_4 + 1);
         Gd_628 = Ceil(Gd_628, Gi_512);
         SaveSell1(Gd_628);
      }
      if (ShowTradeArrowsOnly) {
         if (Gi_612) {
            ihigh_24 = iHigh(NULL, 0, Li_4);
            ihigh_24 = Floor(ihigh_24, Gi_512);
            if (ihigh_24 <= Gd_620) {
               Gi_612 = FALSE;
               SaveBuy(Gi_612);
            }
         }
         if (Gi_616) {
            ilow_16 = iLow(NULL, 0, Li_4);
            ilow_16 = Floor(ilow_16, Gi_512);
            if (ilow_16 >= Gd_628) {
               Gi_616 = FALSE;
               SaveSell(Gi_616);
            }
         }
      }
      if (Gi_612) {
         if (Li_4 == 0) {
            if (ShowTradeArrowsOnly) {
               if (NewTradeBar()) ShowAlert("Buy Trade ");
            } else
               if (NewSignalBar()) ShowAlert("Buy Alert ");
         }
         Li_8 = MathRound((High[Li_4 + 1] - Gd_676) / Gd_504);
         if (ShowTradeArrowsOnly) Gs_532 = GetSignalTime(Li_4, 1);
         else Gs_532 = GetSignalTime(Li_4 + 1, 0);
         Gs_516 = Gs_524 + " - D:" + Li_8 + " A:" + DoubleToStr(Gd_652, 2) + " at " + Gs_532;
         OutputComment2ToChart(Gs_516);
         if (ShowTradeArrowsOnly) {
            G_ibuf_468[Li_4] = iLow(NULL, 0, Li_4) - Arrow_Position * Gd_504;
            if (ShowFibProfitTargets) FibLines(0, Li_4 + 1);
         } else G_ibuf_468[Li_4 + 1] = iLow(NULL, 0, Li_4 + 1) - Arrow_Position * Gd_504;
         G_global_var_544 = FALSE;
         SaveLastArrow(0);
         G_global_var_548 = TRUE;
         SaveLastSmile(1);
         G_datetime_464 = Time[0];
         if (ShowBuySellLines) {
            DisplayLine("FractBuy", Gd_620, BuyLineColor);
            RemoveLine("FractSell");
         }
      } else {
         if (Gi_616) {
            if (Li_4 == 0) {
               if (ShowTradeArrowsOnly) {
                  if (NewTradeBar()) ShowAlert("Sell Trade ");
               } else
                  if (NewSignalBar()) ShowAlert("Sell Alert ");
            }
            Li_8 = MathRound((Gd_676 - (Low[Li_4 + 1])) / Gd_504);
            if (ShowTradeArrowsOnly) Gs_532 = GetSignalTime(Li_4, 1);
            else Gs_532 = GetSignalTime(Li_4 + 1, 0);
            Gs_516 = Gs_524 + " - D:" + Li_8 + " A:" + DoubleToStr(Gd_652, 2) + " at " + Gs_532;
            OutputComment2ToChart(Gs_516);
            if (ShowTradeArrowsOnly) {
               G_ibuf_472[Li_4] = iHigh(NULL, 0, Li_4) + Arrow_Position * Gd_504;
               if (ShowFibProfitTargets) FibLines(1, Li_4 + 1);
            } else G_ibuf_472[Li_4 + 1] = iHigh(NULL, 0, Li_4 + 1) + Arrow_Position * Gd_504;
            G_global_var_544 = TRUE;
            SaveLastArrow(1);
            G_global_var_548 = FALSE;
            SaveLastSmile(0);
            G_datetime_464 = Time[0];
            if (ShowBuySellLines) {
               DisplayLine("FractSell", Gd_628, SellLineColor);
               RemoveLine("FractBuy");
            }
         }
      }
      if (ShowBadTradeExits) {
         if (G_global_var_544 == 0) {
            if (G_global_var_548 != 0) {
               if (CheckBadExit(0, Li_4 + 1)) {
                  Li_12 = GetFacePos(Period());
                  G_ibuf_488[Li_4 + 1] = iLow(NULL, 0, Li_4 + 1) - Li_12 * Gd_504;
                  G_global_var_548 = FALSE;
                  SaveLastSmile(0);
                  if (Li_4 == 0)
                     if (NewBadTradeBar()) ShowAlert("BUY Trade Exit");
               }
            }
         }
         if (G_global_var_544 == 1) {
            if (G_global_var_548 != 1) {
               if (CheckBadExit(1, Li_4 + 1)) {
                  Li_12 = GetFacePos(Period());
                  G_ibuf_492[Li_4 + 1] = iHigh(NULL, 0, Li_4 + 1) + Li_12 * Gd_504;
                  G_global_var_548 = TRUE;
                  SaveLastSmile(1);
                  if (Li_4 == 0)
                     if (NewBadTradeBar()) ShowAlert("SELL Trade Exit");
               }
            }
         }
      }
   }
   return (0);
}

double Get_mFactor() {
   double Ld_ret_8 = 10000.0;
   string Ls_0 = StringSubstr(Symbol(), 3, 3);
   if (Ls_0 == "JPY") Ld_ret_8 = 100.0;
   int Li_16 = PrevMAShift - CurMAShift;
   Ld_ret_8 /= Li_16;
   return (Ld_ret_8);
}

int NewSignalBar() {
   if (G_time_724 == Time[0]) return (0);
   G_time_724 = Time[0];
   return (1);
}

int NewTradeBar() {
   if (G_time_728 == Time[0]) return (0);
   G_time_728 = Time[0];
   return (1);
}

int NewBadTradeBar() {
   if (G_time_732 == Time[0]) return (0);
   G_time_732 = Time[0];
   return (1);
}

void GetMAs(int Ai_0) {
   Gd_660 = iMA(NULL, 0, 10, 0, G_ma_method_256, PRICE_CLOSE, Ai_0);
   Gd_668 = iMA(NULL, 0, 21, 0, G_ma_method_256, PRICE_CLOSE, Ai_0);
   Gd_676 = iMA(NULL, 0, 50, 0, G_ma_method_256, PRICE_CLOSE, Ai_0);
   G_ibuf_476[Ai_0] = Gd_660;
   G_ibuf_480[Ai_0] = Gd_668;
   G_ibuf_484[Ai_0] = Gd_676;
   Gd_660 = NormalizeDouble(Gd_660, Gi_512);
   Gd_668 = NormalizeDouble(Gd_668, Gi_512);
   Gd_676 = NormalizeDouble(Gd_676, Gi_512);
   SaveMA10(Gd_660);
   SaveMA21(Gd_668);
   SaveMA50(Gd_676);
}

void CheckMA_Angle(int Ai_0) {
   G_ima_636 = iMA(NULL, 0, MA_Period, 0, G_ma_method_256, MA_AppliedPrice, Ai_0 + CurMAShift);
   G_ima_644 = iMA(NULL, 0, MA_Period, 0, G_ma_method_256, MA_AppliedPrice, Ai_0 + PrevMAShift);
   Gd_652 = Gd_496 * (G_ima_636 - G_ima_644) / 2.0;
   Gd_652 = NormalizeDouble(Gd_652, 2);
   SavefAngle(Gd_652);
   if (Gd_652 > AngleTreshold) {
      Gi_612 = TRUE;
      SaveBuy(Gi_612);
      Gs_524 = "BUY";
      return;
   }
   if (Gd_652 < -AngleTreshold) {
      Gi_616 = TRUE;
      SaveSell(Gi_616);
      Gs_524 = "SELL";
   }
}

void CheckHighLowRules(int Ai_0) {
   double low_4;
   double high_12;
   double low_20;
   double high_28;
   if (Gi_260 == TRUE) {
      if (Gi_612) {
         low_4 = Low[Ai_0];
         low_4 = Ceil(low_4, Gi_512);
         if (low_4 > Gd_660) {
            Gi_612 = FALSE;
            SaveBuy(Gi_612);
         }
      }
      if (Gi_616) {
         high_12 = High[Ai_0];
         high_12 = Floor(high_12, Gi_512);
         if (high_12 < Gd_660) {
            Gi_616 = FALSE;
            SaveSell(Gi_616);
         }
      }
   }
   if (Gi_264 == TRUE) {
      if (Gi_612) {
         high_12 = High[Ai_0];
         high_12 = Floor(high_12, Gi_512);
         high_28 = High[Ai_0 + 1];
         high_28 = Floor(high_28, Gi_512);
         if (high_12 > high_28) {
            Gi_612 = FALSE;
            SaveBuy(Gi_612);
         }
      }
      if (Gi_616) {
         low_4 = Low[Ai_0];
         low_4 = Ceil(low_4, Gi_512);
         low_20 = Low[Ai_0 + 1];
         low_20 = Ceil(low_20, Gi_512);
         if (low_4 < low_20) {
            Gi_616 = FALSE;
            SaveSell(Gi_616);
         }
      }
   }
}

void CheckMAs() {
   if (Gi_612) {
      if (Gd_660 <= Gd_676 || Gd_668 <= Gd_676) {
         Gi_612 = FALSE;
         SaveBuy(Gi_612);
      }
   }
   if (Gi_616) {
      if (Gd_660 >= Gd_676 || Gd_668 >= Gd_676) {
         Gi_616 = FALSE;
         SaveSell(Gi_616);
      }
   }
}

string GetSignalTime(int Ai_0, bool Ai_4) {
   if (Ai_4) {
      if (Gi_736 != iTime(NULL, 0, Ai_0)) {
         G_datetime_540 = TimeCurrent();
         Gi_740 = G_datetime_540;
         SaveLastTradeSignalTime(G_datetime_540);
         Gi_736 = iTime(NULL, 0, Ai_0);
         SaveTradeCandleOpenTime(Gi_736);
      } else G_datetime_540 = Gi_740;
   } else G_datetime_540 = iTime(NULL, 0, Ai_0);
   string Ls_ret_8 = TimeToStr(G_datetime_540, TIME_DATE) + " " + TimeHour(G_datetime_540) + ":";
   if (TimeMinute(G_datetime_540) < 10) Ls_ret_8 = Ls_ret_8 + "0";
   Ls_ret_8 = Ls_ret_8 + TimeMinute(G_datetime_540);
   return (Ls_ret_8);
}

int GetFacePos(int Ai_0) {
   int Li_ret_4 = 0;
   switch (Ai_0) {
   case 43200:
      Li_ret_4 = FacePosMN;
      break;
   case 10080:
      Li_ret_4 = FacePosW1;
      break;
   case 1440:
      Li_ret_4 = FacePosD1;
      break;
   case 240:
      Li_ret_4 = FacePosH4;
      break;
   case 60:
      Li_ret_4 = FacePosH1;
      break;
   case 30:
      Li_ret_4 = FacePosM30;
      break;
   case 15:
      Li_ret_4 = FacePosM15;
      break;
   case 5:
      Li_ret_4 = FacePosM5;
      break;
   case 1:
      Li_ret_4 = FacePosM1;
      break;
   default:
      Li_ret_4 = 5;
   }
   return (Li_ret_4);
}

void ShowAlert(string As_0) {
   string Ls_8 = TimeToStr(TimeCurrent(), TIME_DATE) + " " + TimeHour(TimeCurrent()) + ":";
   if (TimeMinute(TimeCurrent()) < 10) Ls_8 = Ls_8 + "0";
   Ls_8 = Ls_8 + TimeMinute(TimeCurrent());
   if (Alert_SoundON) Alert(As_0, Symbol(), " on ", tf2txt(Period()), " ", Ls_8, " Steinitz");
   if (EmailON) SendMail(As_0 + Symbol(), "Date=" + Ls_8 + " on " + tf2txt(Period()));
}

void ClearArrows() {
   for (int Li_0 = Bars; Li_0 >= 0; Li_0--) {
      G_ibuf_472[Li_0] = 0;
      G_ibuf_468[Li_0] = 0;
      G_ibuf_492[Li_0] = 0;
      G_ibuf_488[Li_0] = 0;
   }
}

int CheckTradeFilters() {
   bool Li_4;
   bool Li_ret_0 = FALSE;
   if (Gi_84 == TRUE) {
      Li_4 = FALSE;
      if (Year() > Gi_96) Li_4 = TRUE;
      if (Li_4 == FALSE) {
         if (Year() == Gi_96 && Month() > Gi_88) Li_4 = TRUE;
         if (Li_4 == FALSE)
            if (Year() == Gi_96 && Month() == Gi_88 && Day() > Gi_92) Li_4 = TRUE;
      }
      if (Li_4 == TRUE) OutputComment1ToChart("Indicator has expired - renew license");
      Li_ret_0 = Li_4;
   }
   return (Li_ret_0);
}

double SetPoint() {
   double Ld_ret_0;
   if (Digits < 4) Ld_ret_0 = 0.01;
   else Ld_ret_0 = 0.0001;
   return (Ld_ret_0);
}

double SetDigit() {
   double Ld_ret_0;
   if (Digits < 4) Ld_ret_0 = 2;
   else Ld_ret_0 = 4;
   return (Ld_ret_0);
}

double Ceil(double Ad_0, int Ai_8) {
   double Ld_20;
   if (Ai_8 == 2) Ld_20 = 100.0;
   if (Ai_8 == 4) Ld_20 = 10000.0;
   double Ld_12 = Ad_0 * Ld_20;
   Ld_12 = MathCeil(Ld_12);
   Ld_12 /= Ld_20;
   Ld_12 = NormalizeDouble(Ld_12, Ai_8);
   return (Ld_12);
}

double Floor(double Ad_0, int Ai_8) {
   double Ld_20;
   if (Ai_8 == 2) Ld_20 = 100.0;
   if (Ai_8 == 4) Ld_20 = 10000.0;
   double Ld_12 = Ad_0 * Ld_20;
   Ld_12 = MathFloor(Ld_12);
   Ld_12 /= Ld_20;
   Ld_12 = NormalizeDouble(Ld_12, Ai_8);
   return (Ld_12);
}


void ClearLabels() {
   string Ls_0 = " ";
   OutputLabelToChart(Gs_564, Gi_552, StatusTxtSize, StatusColor, Ls_0, " ");
   OutputLabelToChart(Gs_572, Gi_556, CommentTxtSize, CommentColor, Ls_0, " ");
   OutputLabelToChart(Gs_580, Gi_560, CommentTxtSize, CommentColor, Ls_0, " ");
}

void DeleteBadLabels() {
   string name_8;
   int objs_total_4 = ObjectsTotal();
   if (objs_total_4 > 0) {
      for (int Li_0 = objs_total_4 - 1; Li_0 >= 0; Li_0--) {
         name_8 = ObjectName(Li_0);
         if (StringFind(name_8, Symbol(), 0) < 0)
            if (StringFind(name_8, Gs_604, 0) >= 0) ObjectDelete(name_8);
      }
   }
}

void DeleteExistingLabels() {
   string name_4;
   int Li_0 = ObjectsTotal(OBJ_LABEL);
   if (Li_0 > 0) {
      for (int objs_total_12 = Li_0; objs_total_12 >= 0; objs_total_12--) {
         name_4 = ObjectName(objs_total_12);
         if (StringFind(name_4, Symbol() + Gs_604 + "FractalStatus", 0) >= 0) ObjectDelete(name_4);
         else
            if (StringFind(name_4, Symbol() + Gs_604 + "FractalComment", 0) >= 0) ObjectDelete(name_4);
      }
   }
}

void SetupLabels() {
   Gi_552 = 12;
   Gi_556 = Gi_552 + StatusTxtSize + 4;
   Gi_560 = Gi_556 + CommentTxtSize + 4;
   Gs_564 = Symbol() + Gs_604 + "FractalStatus";
   Gs_572 = Symbol() + Gs_604 + "FractalComment1";
   Gs_580 = Symbol() + Gs_604 + "FractalComment2";
}

void OutputLabelToChart(string A_name_0, int A_y_8, int A_fontsize_12, color A_color_16, string A_text_20, string As_unused_28) {
   if (ObjectFind(A_name_0) != 0) {
      ObjectCreate(A_name_0, OBJ_LABEL, 0, 0, 0);
      ObjectSet(A_name_0, OBJPROP_CORNER, 0);
      ObjectSet(A_name_0, OBJPROP_XDISTANCE, Text_X_Offset);
      ObjectSet(A_name_0, OBJPROP_YDISTANCE, A_y_8);
   }
   ObjectSetText(A_name_0, A_text_20, A_fontsize_12, "Arial Bold", A_color_16);
}

void OutputStatusToChart(string As_0) {
   OutputLabelToChart(Gs_564, Gi_552, StatusTxtSize, StatusColor, As_0, "*");
}

void OutputComment1ToChart(string As_0) {
   OutputLabelToChart(Gs_572, Gi_556, CommentTxtSize, CommentColor, As_0, "*");
}

void OutputComment2ToChart(string As_0) {
   OutputLabelToChart(Gs_580, Gi_560, CommentTxtSize, CommentColor, As_0, "*");
}

string tf2txt(int Ai_0) {
   switch (Ai_0) {
   case 1:
      return ("M1");
   case 5:
      return ("M5");
   case 15:
      return ("M15");
   case 30:
      return ("M30");
   case 60:
      return ("H1");
   case 240:
      return ("H4");
   case 1440:
      return ("D1");
   case 10080:
      return ("W1");
   case 43200:
      return ("MN");
   }
   return ("??");
}

void DisplayLine(string As_0, double A_price_8, color A_color_16) {
   string name_20 = Symbol() + Gs_604 + As_0;
   if (ObjectFind(name_20) != 0) {
      ObjectCreate(name_20, OBJ_HLINE, 0, G_datetime_464, A_price_8);
      ObjectSet(name_20, OBJPROP_STYLE, STYLE_DASHDOTDOT);
      ObjectSet(name_20, OBJPROP_COLOR, A_color_16);
      ObjectSet(name_20, OBJPROP_WIDTH, 1);
      return;
   }
   ObjectMove(name_20, 0, G_datetime_464, A_price_8);
}

void DeleteFractObjects() {
   ObjectDelete(Symbol() + Gs_604 + "FractBuy");
   ObjectDelete(Symbol() + Gs_604 + "FractSell");
   ObjectDelete(Symbol() + Gs_604 + "Fib1");
   ObjectDelete(Symbol() + Gs_604 + "Fib2");
   ObjectDelete(Symbol() + Gs_604 + "Fib3");
}

void RemoveLine(string As_0) {
   ObjectDelete(Symbol() + Gs_604 + As_0);
}

int CheckBadExit(int Ai_0, int Ai_4) {
   double iopen_24 = iOpen(NULL, 0, Ai_4);
   double iclose_40 = iClose(NULL, 0, Ai_4);
   double iopen_32 = iOpen(NULL, 0, Ai_4 + 1);
   double iclose_48 = iClose(NULL, 0, Ai_4 + 1);
   double ima_8 = iMA(NULL, 0, 50, 0, G_ma_method_256, PRICE_CLOSE, Ai_4);
   double ima_16 = iMA(NULL, 0, 50, 0, G_ma_method_256, PRICE_CLOSE, Ai_4 + 1);
   int Li_56 = GetPriceGap(Period());
   double Ld_60 = Li_56 * Gd_504;
   Ld_60 = NormalizeDouble(Ld_60, Gi_512);
   iopen_24 = NormalizeDouble(iopen_24, Gi_512);
   iclose_40 = NormalizeDouble(iclose_40, Gi_512);
   iopen_32 = NormalizeDouble(iopen_32, Gi_512);
   iclose_48 = NormalizeDouble(iclose_48, Gi_512);
   ima_8 = NormalizeDouble(ima_8, Gi_512);
   ima_16 = NormalizeDouble(ima_16, Gi_512);
   switch (Ai_0) {
   case 0:
      if (iopen_24 <= iclose_40) break;
      if (iopen_32 <= iclose_48) break;
      if (iclose_40 + Ld_60 > ima_8) break;
      if (iclose_48 + Ld_60 > ima_16) break;
      return (1);
   case 1:
      if (iopen_24 >= iclose_40) break;
      if (iopen_32 >= iclose_48) break;
      if (iclose_40 - Ld_60 < ima_8) break;
      if (iclose_48 - Ld_60 < ima_16) break;
      return (1);
   }
   return (0);
}

int GetPriceGap(int Ai_0) {
   int Li_ret_4 = 0;
   switch (Ai_0) {
   case 43200:
      Li_ret_4 = PriceGapMN;
      break;
   case 10080:
      Li_ret_4 = PriceGapW1;
      break;
   case 1440:
      Li_ret_4 = PriceGapD1;
      break;
   case 240:
      Li_ret_4 = PriceGapH4;
      break;
   case 60:
      Li_ret_4 = PriceGapH1;
      break;
   case 30:
      Li_ret_4 = PriceGapM30;
      break;
   case 15:
      Li_ret_4 = PriceGapM15;
      break;
   case 5:
      Li_ret_4 = PriceGapM5;
      break;
   case 1:
      Li_ret_4 = PriceGapM1;
      break;
   default:
      Li_ret_4 = 5;
   }
   return (Li_ret_4);
}

void GetGlobalVars() {
   NameGlobalVars();
   InitGlobalVars();
   GetGlobalVarValues();
}

void GetGlobalVarValues() {
   double global_var_0 = GlobalVariableGet(G_var_name_744);
   if (global_var_0 > 0.0) Gi_612 = TRUE;
   else Gi_612 = FALSE;
   global_var_0 = GlobalVariableGet(G_var_name_752);
   if (global_var_0 > 0.0) Gi_616 = TRUE;
   else Gi_616 = FALSE;
   Gd_620 = GlobalVariableGet(G_var_name_760);
   Gd_628 = GlobalVariableGet(G_var_name_768);
   Gd_660 = GlobalVariableGet(G_var_name_776);
   Gd_668 = GlobalVariableGet(G_var_name_784);
   Gd_676 = GlobalVariableGet(G_var_name_792);
   Gd_652 = GlobalVariableGet(G_var_name_800);
   Gi_736 = GlobalVariableGet(G_var_name_808);
   Gi_740 = GlobalVariableGet(G_var_name_816);
   G_global_var_544 = GlobalVariableGet(G_var_name_824);
   G_global_var_548 = GlobalVariableGet(G_var_name_832);
   Gd_700 = GlobalVariableGet(G_var_name_840);
   Gd_708 = GlobalVariableGet(G_var_name_848);
   Gd_716 = GlobalVariableGet(G_var_name_856);
}

void InitGlobalVars() {
   if (!GlobalVariableCheck(G_var_name_744)) GlobalVariableSet(G_var_name_744, -10);
   if (!GlobalVariableCheck(G_var_name_752)) GlobalVariableSet(G_var_name_752, -10);
   if (!GlobalVariableCheck(G_var_name_760)) GlobalVariableSet(G_var_name_760, 0);
   if (!GlobalVariableCheck(G_var_name_768)) GlobalVariableSet(G_var_name_768, 0);
   if (!GlobalVariableCheck(G_var_name_776)) GlobalVariableSet(G_var_name_776, 0);
   if (!GlobalVariableCheck(G_var_name_784)) GlobalVariableSet(G_var_name_784, 0);
   if (!GlobalVariableCheck(G_var_name_792)) GlobalVariableSet(G_var_name_792, 0);
   if (!GlobalVariableCheck(G_var_name_800)) GlobalVariableSet(G_var_name_800, 0);
   if (!GlobalVariableCheck(G_var_name_808)) GlobalVariableSet(G_var_name_808, 0);
   if (!GlobalVariableCheck(G_var_name_816)) GlobalVariableSet(G_var_name_816, 0);
   if (!GlobalVariableCheck(G_var_name_824)) GlobalVariableSet(G_var_name_824, 10);
   if (!GlobalVariableCheck(G_var_name_832)) GlobalVariableSet(G_var_name_832, 10);
   if (!GlobalVariableCheck(G_var_name_840)) GlobalVariableSet(G_var_name_840, 0);
   if (!GlobalVariableCheck(G_var_name_848)) GlobalVariableSet(G_var_name_848, 0);
   if (!GlobalVariableCheck(G_var_name_856)) GlobalVariableSet(G_var_name_856, 0);
}

void NameGlobalVars() {
   string Ls_0 = "SFBI_15_" + Symbol() + tf2txt(Period());
   G_var_name_744 = Ls_0 + "_Buy";
   G_var_name_752 = Ls_0 + "_Sell";
   G_var_name_760 = Ls_0 + "_BuyLine";
   G_var_name_768 = Ls_0 + "_SellLine";
   G_var_name_776 = Ls_0 + "_MA10";
   G_var_name_784 = Ls_0 + "_MA21";
   G_var_name_792 = Ls_0 + "_MA50";
   G_var_name_800 = Ls_0 + "_fAngle";
   G_var_name_808 = Ls_0 + "_TradeCandleOT";
   G_var_name_816 = Ls_0 + "_LastTradeCandleST";
   G_var_name_824 = Ls_0 + "_LastArrow";
   G_var_name_832 = Ls_0 + "_LastSmile";
   G_var_name_840 = Ls_0 + "_Fib1";
   G_var_name_848 = Ls_0 + "_Fib2";
   G_var_name_856 = Ls_0 + "_Fib3";
}

void SaveBuy(int Ai_0) {
   if (Ai_0 == 1) {
      GlobalVariableSet(G_var_name_744, 10.0);
      return;
   }
   GlobalVariableSet(G_var_name_744, -10.0);
}

void SaveSell(int Ai_0) {
   if (Ai_0 == 1) {
      GlobalVariableSet(G_var_name_752, 10.0);
      return;
   }
   GlobalVariableSet(G_var_name_752, -10.0);
}

void SaveBuy1(double Ad_0) {
   GlobalVariableSet(G_var_name_760, Ad_0);
}

void SaveSell1(double Ad_0) {
   GlobalVariableSet(G_var_name_768, Ad_0);
}

void SaveMA10(double Ad_0) {
   GlobalVariableSet(G_var_name_776, Ad_0);
}

void SaveMA21(double Ad_0) {
   GlobalVariableSet(G_var_name_784, Ad_0);
}

void SaveMA50(double Ad_0) {
   GlobalVariableSet(G_var_name_792, Ad_0);
}

void SavefAngle(double Ad_0) {
   GlobalVariableSet(G_var_name_800, Ad_0);
}

void SaveTradeCandleOpenTime(int Ai_0) {
   GlobalVariableSet(G_var_name_808, Ai_0);
}

void SaveLastTradeSignalTime(int Ai_0) {
   GlobalVariableSet(G_var_name_816, Ai_0);
}

void SaveLastArrow(int Ai_0) {
   GlobalVariableSet(G_var_name_824, Ai_0);
}

void SaveLastSmile(int Ai_0) {
   GlobalVariableSet(G_var_name_832, Ai_0);
}

void SaveFib1(int Ai_0) {
   GlobalVariableSet(G_var_name_840, Ai_0);
}

void SaveFib2(int Ai_0) {
   GlobalVariableSet(G_var_name_848, Ai_0);
}

void SaveFib3(int Ai_0) {
   GlobalVariableSet(G_var_name_856, Ai_0);
}