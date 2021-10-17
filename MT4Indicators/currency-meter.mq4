
#property copyright ""
#property link      ""

#property indicator_separate_window
#property indicator_minimum 0.0
#property indicator_maximum 30.0

bool gi_76 = TRUE;
bool gi_80 = TRUE;
int gi_84 = 342443;
string gs_88 = "2009.11.30";
string gs_96 = "2008.08.01";
extern string Indicator1 = "Moving Average 1";
extern double Indi1_Weightage = 10.0;
extern string Method_Desc1 = "0: SMA | 1: EMA | 2: SMMA | 3: LWMA";
extern int MA1_Method = 1;
extern int MA1_Applied_Price = 0;
extern int MA1_Timeframe = 60;
extern int MA1_Period = 21;
extern int MA1_Shift = 0;
extern string Indicator2 = "Moving Average 2";
extern double Indi2_Weightage = 20.0;
extern string Method_Desc2 = "0: SMA | 1: EMA | 2: SMMA | 3: LWMA";
extern int MA2_Method = 1;
extern int MA2_Applied_Price = 0;
extern int MA2_Timeframe = 240;
extern int MA2_Period = 21;
extern int MA2_Shift = 0;
extern string Indicator3 = "Relative Strength Index";
extern double Indi3_Weightage = 5.0;
extern int RSI_Applied_Price = 0;
extern int RSI_Timeframe = 60;
extern int RSI_Period = 21;
extern int RSI_Shift = 0;
extern string Indicator4 = "Williams Percent Range";
extern double Indi4_Weightage = 10.0;
extern int William_Timeframe = 60;
extern double William_Period = 60.0;
extern int William_Shift = 0;
extern string Indicator5 = "Laguerre";
extern double Indi5_Weightage = 10.0;
extern int Laguerre_Timeframe = 60;
extern double Laguerre_gamma = 0.7;
extern int Laguerre_CountBars = 50;
extern bool SoundAlertSendEmail = FALSE;
string gsa_292[24];
int gia_296[24];
double gda_300[24];
int gia_304[24];
double gda_308[24];
double gda_312[24];
double gda_316[24];
double gda_320[24];
double gda_324[24];
int gi_328 = 9;
int gi_332 = 29;
int gi_336 = 4;
int gi_340 = 50;
int gi_344 = 38;
int gi_348 = 28;
int gi_352 = 19;
int gi_356 = 6;
int gi_360 = 35;
int gi_364 = 15;
bool gi_368 = FALSE;
bool gi_372 = FALSE;
bool gi_376 = FALSE;
bool gi_380 = FALSE;
bool gi_384 = FALSE;
bool gi_388 = FALSE;
bool gi_392 = FALSE;
bool gi_396 = FALSE;
double gd_400 = 0.0;
string gs_408 = "Currency-Meter";

int init() {
   ObjectsDeleteAll(WindowFind(gs_408));
   IndicatorShortName(gs_408);
   gsa_292[0] = "AUDUSD";
   gsa_292[1] = "AUDJPY";
   gsa_292[2] = "AUDCAD";
   gsa_292[3] = "AUDCHF";
   gsa_292[4] = "AUDNZD";
   gsa_292[5] = "CHFJPY";
   gsa_292[6] = "EURUSD";
   gsa_292[7] = "EURNZD";
   gsa_292[8] = "EURAUD";
   gsa_292[9] = "EURCAD";
   gsa_292[10] = "EURJPY";
   gsa_292[11] = "EURGBP";
   gsa_292[12] = "EURCHF";
   gsa_292[13] = "GBPUSD";
   gsa_292[14] = "GBPJPY";
   gsa_292[15] = "GBPCHF";
   gsa_292[16] = "GBPNZD";
   gsa_292[17] = "GBPCAD";
   gsa_292[18] = "NZDUSD";
   gsa_292[19] = "NZDJPY";
   gsa_292[20] = "NZDCHF";
   gsa_292[21] = "USDCHF";
   gsa_292[22] = "USDJPY";
   gsa_292[23] = "USDCAD";
   gd_400 = Indi1_Weightage + Indi2_Weightage + Indi3_Weightage + Indi4_Weightage + Indi5_Weightage;
   return (0);
}

int deinit() {
   ObjectDelete("TitleRow");
   ObjectsDeleteAll(WindowFind(gs_408));
   return (0);
}

double Get_Indi1_Value(string as_0) {
   double ld_8 = iMA(as_0, MA1_Timeframe, MA1_Period, MA1_Shift, MA1_Method, MA1_Applied_Price, 0);
   double ld_16 = 100.0 * (Indi1_Weightage / gd_400);
   double ld_24 = iClose(as_0, MA1_Timeframe, 0);
   if (ld_24 > ld_8) return (ld_16);
   if (ld_24 < ld_8) return (0 - ld_16);
   return (0);
}

double Get_Indi2_Value(string as_0) {
   double ld_8 = iMA(as_0, MA2_Timeframe, MA2_Period, MA2_Shift, MA2_Method, MA2_Applied_Price, 0);
   double ld_16 = 100.0 * (Indi2_Weightage / gd_400);
   double ld_24 = iClose(as_0, MA2_Timeframe, 0);
   if (ld_24 > ld_8) return (ld_16);
   if (ld_24 < ld_8) return (0 - ld_16);
   return (0);
}

double Get_Indi3_Value(string as_0) {
   double ld_8 = iRSI(as_0, RSI_Timeframe, RSI_Period, RSI_Applied_Price, 0);
   double ld_16 = 100.0 * (Indi3_Weightage / gd_400);
   if (ld_8 > 50.0) return (ld_16);
   if (ld_8 < 50.0) return (0 - ld_16);
   return (0);
}

double Get_Indi4_Value(string as_0) {
   double ld_8 = iWPR(as_0, William_Timeframe, William_Period, 0);
   double ld_16 = 100.0 * (Indi4_Weightage / gd_400);
   if (ld_8 > -50.0) return (ld_16);
   if (ld_8 < -50.0) return (0 - ld_16);
   return (0);
}

double Get_Indi5_Value(string as_0) {
   double ld_8 = iCustom(as_0, Laguerre_Timeframe, "Laguerre", Laguerre_gamma, Laguerre_CountBars, 0, 0);
   double ld_16 = 100.0 * (Indi5_Weightage / gd_400);
   if (ld_8 > 0.5) return (ld_16);
   if (ld_8 < 0.5) return (0 - ld_16);
   return (0);
}

void Populate_Values_Array() {
   for (int li_0 = 0; li_0 < 24; li_0++) gda_300[li_0] = Get_Indi1_Value(gsa_292[li_0]) + Get_Indi2_Value(gsa_292[li_0]) + Get_Indi3_Value(gsa_292[li_0]) + Get_Indi4_Value(gsa_292[li_0]) + Get_Indi5_Value(gsa_292[li_0]);
}

void Populate_Meter_Array() {
   for (int li_0 = 0; li_0 < 24; li_0++) gia_296[li_0] = gda_300[li_0] / 20.0;
}

void Populate_Trend_Array() {
   for (int li_0 = 0; li_0 < 24; li_0++) {
      if (gda_300[li_0] > 0.0) gia_304[li_0] = 1;
      if (gda_300[li_0] < 0.0) gia_304[li_0] = 2;
      if (gda_300[li_0] == 0.0) gia_304[li_0] = 0;
   }
}

int AUD_Status() {
   if (gia_304[0] == 1 && gia_304[1] == 1 && gia_304[2] == 1 && gia_304[3] == 1 && gia_304[4] == 1 && gia_304[8] == 2) {
      if (SoundAlertSendEmail && !gi_368) {
         Alert("AUD - All UP");
         SendMail("AUD - All UP", "AUD - All UP");
         gi_368 = TRUE;
      }
      return (1);
   }
   if (gia_304[0] == 2 && gia_304[1] == 2 && gia_304[2] == 2 && gia_304[3] == 2 && gia_304[4] == 2 && gia_304[8] == 1) {
      if (SoundAlertSendEmail && !gi_368) {
         Alert("AUD - All DOWN");
         SendMail("AUD - All DOWN", "AUD - All DOWN");
         gi_368 = TRUE;
      }
      return (2);
   }
   gi_368 = FALSE;
   return (0);
}

int USD_Status() {
   if (gia_304[0] == 2 && gia_304[6] == 2 && gia_304[13] == 2 && gia_304[18] == 2 && gia_304[21] == 1 && gia_304[22] == 1 && gia_304[23] == 1) {
      if (SoundAlertSendEmail && !gi_376) {
         Alert("USD - All UP");
         SendMail("USD - All UP", "USD - All UP");
         gi_376 = TRUE;
      }
      return (1);
   }
   if (gia_304[0] == 1 && gia_304[6] == 1 && gia_304[13] == 1 && gia_304[18] == 1 && gia_304[21] == 2 && gia_304[22] == 2 && gia_304[23] == 2) {
      if (SoundAlertSendEmail && !gi_376) {
         Alert("USD - All DOWN");
         SendMail("USD - All DOWN", "USD - All DOWN");
         gi_376 = TRUE;
      }
      return (2);
   }
   gi_376 = FALSE;
   return (0);
}

int EUR_Status() {
   if (gia_304[6] == 1 && gia_304[7] == 1 && gia_304[8] == 1 && gia_304[9] == 1 && gia_304[10] == 1 && gia_304[11] == 1 && gia_304[12] == 1) {
      if (SoundAlertSendEmail && !gi_372) {
         Alert("EUR - All UP");
         SendMail("EUR - All UP", "EUR - All UP");
         gi_372 = TRUE;
      }
      return (1);
   }
   if (gia_304[6] == 2 && gia_304[7] == 2 && gia_304[8] == 2 && gia_304[9] == 2 && gia_304[10] == 2 && gia_304[11] == 2 && gia_304[12] == 2) {
      if (SoundAlertSendEmail && !gi_372) {
         Alert("EUR - All DOWN");
         SendMail("EUR - All DOWN", "EUR - All DOWN");
         gi_372 = TRUE;
      }
      return (2);
   }
   gi_372 = FALSE;
   return (0);
}

int GBP_Status() {
   if (gia_304[11] == 2 && gia_304[13] == 1 && gia_304[14] == 1 && gia_304[15] == 1 && gia_304[16] == 1 && gia_304[17] == 1) {
      if (SoundAlertSendEmail && !gi_384) {
         Alert("GBP - All UP");
         SendMail("GBP - All UP", "GBP - All UP");
         gi_384 = TRUE;
      }
      return (1);
   }
   if (gia_304[11] == 1 && gia_304[13] == 2 && gia_304[14] == 2 && gia_304[15] == 2 && gia_304[16] == 2 && gia_304[17] == 2) {
      if (SoundAlertSendEmail && !gi_384) {
         Alert("GBP - All DOWN");
         SendMail("GBP - All DOWN", "GBP - All DOWN");
         gi_384 = TRUE;
      }
      return (2);
   }
   gi_384 = FALSE;
   return (0);
}

int CHF_Status() {
   if (gia_304[3] == 2 && gia_304[5] == 1 && gia_304[12] == 2 && gia_304[15] == 2 && gia_304[20] == 2 && gia_304[21] == 2) {
      if (SoundAlertSendEmail && !gi_380) {
         Alert("CHF - All UP");
         SendMail("CHF - All UP", "CHF - All UP");
         gi_380 = TRUE;
      }
      return (1);
   }
   if (gia_304[3] == 1 && gia_304[5] == 2 && gia_304[12] == 1 && gia_304[15] == 1 && gia_304[20] == 1 && gia_304[21] == 1) {
      if (SoundAlertSendEmail && !gi_380) {
         Alert("CHF - All DOWN");
         SendMail("CHF - All DOWN", "CHF - All DOWN");
         gi_380 = TRUE;
      }
      return (2);
   }
   gi_380 = FALSE;
   return (0);
}

int CAD_Status() {
   if (gia_304[2] == 2 && gia_304[9] == 2 && gia_304[17] == 2 && gia_304[23] == 2) {
      if (SoundAlertSendEmail && !gi_388) {
         Alert("CAD - All UP");
         SendMail("CAD - All UP", "CAD - All UP");
         gi_388 = TRUE;
      }
      return (1);
   }
   if (gia_304[2] == 1 && gia_304[9] == 1 && gia_304[17] == 1 && gia_304[23] == 1) {
      if (SoundAlertSendEmail && !gi_388) {
         Alert("CAD - All DOWN");
         SendMail("CAD - All DOWN", "CAD - All DOWN");
         gi_388 = TRUE;
      }
      return (2);
   }
   gi_388 = FALSE;
   return (0);
}

int JPY_Status() {
   if (gia_304[1] == 2 && gia_304[5] == 2 && gia_304[10] == 2 && gia_304[14] == 2 && gia_304[19] == 2 && gia_304[22] == 2) {
      if (SoundAlertSendEmail && !gi_396) {
         Alert("JPY - All UP");
         SendMail("JPY - All UP", "JPY - All UP");
         gi_396 = TRUE;
      }
      return (1);
   }
   if (gia_304[1] == 1 && gia_304[5] == 1 && gia_304[10] == 1 && gia_304[14] == 1 && gia_304[19] == 1 && gia_304[22] == 1) {
      if (SoundAlertSendEmail && !gi_396) {
         Alert("JPY - All DOWN");
         SendMail("JPY - All DOWN", "JPY - All DOWN");
         gi_396 = TRUE;
      }
      return (2);
   }
   gi_396 = FALSE;
   return (0);
}

int NZD_Status() {
   if (gia_304[4] == 2 && gia_304[7] == 2 && gia_304[16] == 2 && gia_304[18] == 1 && gia_304[19] == 1 && gia_304[20] == 1) {
      if (SoundAlertSendEmail && !gi_392) {
         Alert("NZD - All UP");
         SendMail("NZD - All UP", "NZD - All UP");
         gi_392 = TRUE;
      }
      return (1);
   }
   if (gia_304[4] == 1 && gia_304[7] == 1 && gia_304[16] == 1 && gia_304[18] == 2 && gia_304[19] == 2 && gia_304[20] == 2) {
      if (SoundAlertSendEmail && !gi_392) {
         Alert("NZD - All DOWN");
         SendMail("NZD - All DOWN", "NZD - All DOWN");
         gi_392 = TRUE;
      }
      return (2);
   }
   gi_392 = FALSE;
   return (0);
}

void EstablishOrientation() {
   int li_0 = WindowBarsPerChart() - 1;
   int li_4 = 10;
   gi_340 = li_0 - li_4;
   gi_344 = li_0 - li_4 - 12;
   gi_348 = li_0 - li_4 - 22;
   gi_352 = li_0 - li_4 - 31;
   gi_356 = li_0 - li_4 - 44;
   gi_360 = li_0 - li_4 - 23;
   gi_364 = li_0 - li_4 - 35;
}

void Draw_Table() {
   int li_4;
   int li_12;
   ObjectCreate("TitleRow", OBJ_RECTANGLE, WindowFind(gs_408), Time[gi_340 + 5], gi_332, Time[gi_364 - 18], gi_332 - 1);
   ObjectSet("TitleRow", OBJPROP_COLOR, Purple);
   ObjectSet("TitleRow", OBJPROP_TIME1, Time[gi_340 + 5]);
   ObjectSet("TitleRow", OBJPROP_TIME2, Time[gi_364 - 18]);
   ObjectCreate("LastColumn", OBJ_RECTANGLE, WindowFind(gs_408), Time[gi_364], gi_332 - 1, Time[gi_364 - 18], gi_332 - 1 - 24);
   ObjectSet("LastColumn", OBJPROP_COLOR, CornflowerBlue);
   ObjectSet("LastColumn", OBJPROP_TIME1, Time[gi_364]);
   ObjectSet("LastColumn", OBJPROP_TIME2, Time[gi_364 - 18]);
   ObjectCreate("CurrencyTitle", OBJ_TEXT, WindowFind(gs_408), Time[gi_340], gi_332);
   ObjectSetText("CurrencyTitle", "Currency", gi_328, "Courier New", White);
   ObjectSet("CurrencyTitle", OBJPROP_TIME1, Time[gi_340]);
   ObjectCreate("MeterTitle", OBJ_TEXT, WindowFind(gs_408), Time[gi_344], gi_332);
   ObjectSetText("MeterTitle", "Meter", gi_328, "Courier New", White);
   ObjectSet("MeterTitle", OBJPROP_TIME1, Time[gi_344]);
   ObjectCreate("ValueTitle", OBJ_TEXT, WindowFind(gs_408), Time[gi_348], gi_332);
   ObjectSetText("ValueTitle", "Value", gi_328, "Courier New", White);
   ObjectSet("ValueTitle", OBJPROP_TIME1, Time[gi_348]);
   ObjectCreate("TrendTitle", OBJ_TEXT, WindowFind(gs_408), Time[gi_352], gi_332);
   ObjectSetText("TrendTitle", "Trend", gi_328, "Courier New", White);
   ObjectSet("TrendTitle", OBJPROP_TIME1, Time[gi_352]);
   ObjectCreate("InfoTitle", OBJ_TEXT, WindowFind(gs_408), Time[gi_356], gi_332);
   ObjectSetText("InfoTitle", "Info Center", gi_328, "Courier New", White);
   ObjectSet("InfoTitle", OBJPROP_TIME1, Time[gi_356]);
   ObjectCreate("IndiTitle", OBJ_TEXT, WindowFind(gs_408), Time[gi_360], gi_336);
   ObjectSetText("IndiTitle", "CURRENCY METER V5.0", 13, "Arial Black", Blue);
   ObjectSet("IndiTitle", OBJPROP_TIME1, Time[gi_360]);
   for (int li_0 = 0; li_0 < 24; li_0++) {
      ObjectCreate("Row" + li_0, OBJ_RECTANGLE, WindowFind(gs_408), Time[gi_340 + 5], gi_332 - li_0 - 1, Time[gi_364], gi_332 - li_0 - 1 - 1);
      if (isEven(li_0)) ObjectSet("Row" + li_0, OBJPROP_COLOR, DarkSlateBlue);
      else ObjectSet("Row" + li_0, OBJPROP_COLOR, RoyalBlue);
      ObjectSet("Row" + li_0, OBJPROP_TIME1, Time[gi_340 + 5]);
      ObjectSet("Row" + li_0, OBJPROP_TIME2, Time[gi_364]);
   }
   for (li_0 = 0; li_0 < 24; li_0++) {
      ObjectCreate("Currency" + li_0, OBJ_TEXT, WindowFind(gs_408), Time[gi_340], gi_332 - li_0 - 1);
      ObjectSetText("Currency" + li_0, gsa_292[li_0], gi_328, "Courier New", White);
      ObjectSet("Currency" + li_0, OBJPROP_TIME1, Time[gi_340]);
   }
   for (li_0 = 0; li_0 < 24; li_0++) {
      for (int li_8 = 0; li_8 < 5; li_8++)
         if (ObjectFind("Meter-" + li_0 + "-" + li_8) != -1) ObjectDelete("Meter-" + li_0 + "-" + li_8);
   }
   for (li_0 = 0; li_0 < 24; li_0++) {
      if (gia_296[li_0] > 0) li_4 = 1;
      if (gia_296[li_0] < 0) li_4 = 2;
      li_12 = MathAbs(gia_296[li_0]);
      if (li_4 == 1) {
         for (li_8 = 0; li_8 < li_12; li_8++) {
            ObjectCreate("Meter-" + li_0 + "-" + li_8, OBJ_ARROW, WindowFind(gs_408), Time[gi_344 - li_8], gi_332 - li_0 - 1);
            ObjectSet("Meter-" + li_0 + "-" + li_8, OBJPROP_ARROWCODE, 110);
            ObjectSet("Meter-" + li_0 + "-" + li_8, OBJPROP_COLOR, DarkGreen);
            ObjectSet("Meter-" + li_0 + "-" + li_8, OBJPROP_TIME1, Time[gi_344 - li_8]);
         }
      }
      if (li_4 == 2) {
         for (li_8 = 0; li_8 < li_12; li_8++) {
            ObjectCreate("Meter-" + li_0 + "-" + li_8, OBJ_ARROW, WindowFind(gs_408), Time[gi_344 + li_8], gi_332 - li_0 - 1);
            ObjectSet("Meter-" + li_0 + "-" + li_8, OBJPROP_ARROWCODE, 110);
            ObjectSet("Meter-" + li_0 + "-" + li_8, OBJPROP_COLOR, Maroon);
            ObjectSet("Meter-" + li_0 + "-" + li_8, OBJPROP_TIME1, Time[gi_344 + li_8]);
         }
      }
   }
   for (li_0 = 0; li_0 < 24; li_0++) {
      if (gda_300[li_0] > 0.0) li_4 = 1;
      if (gda_300[li_0] < 0.0) li_4 = 2;
      if (li_4 == 1) {
         ObjectCreate("Value-" + li_0, OBJ_TEXT, WindowFind(gs_408), Time[gi_348], gi_332 - li_0 - 1);
         ObjectSetText("Value-" + li_0, DoubleToStr(gda_300[li_0], 2), gi_328, "Courier New", Chartreuse);
         ObjectSet("Value-" + li_0, OBJPROP_TIME1, Time[gi_348]);
      }
      if (li_4 == 2) {
         ObjectCreate("Value-" + li_0, OBJ_TEXT, WindowFind(gs_408), Time[gi_348], gi_332 - li_0 - 1);
         ObjectSetText("Value-" + li_0, DoubleToStr(gda_300[li_0], 2), gi_328, "Courier New", IndianRed);
         ObjectSet("Value-" + li_0, OBJPROP_TIME1, Time[gi_348]);
      }
   }
   for (li_0 = 0; li_0 < 24; li_0++) {
      if (gia_304[li_0] == 1) {
         ObjectCreate("Trend-" + li_0, OBJ_ARROW, WindowFind(gs_408), Time[gi_352], gi_332 - li_0 - 1);
         ObjectSet("Trend-" + li_0, OBJPROP_ARROWCODE, 217);
         ObjectSet("Trend-" + li_0, OBJPROP_COLOR, SpringGreen);
         ObjectSet("Trend-" + li_0, OBJPROP_TIME1, Time[gi_352]);
      }
      if (gia_304[li_0] == 2) {
         ObjectCreate("Trend-" + li_0, OBJ_ARROW, WindowFind(gs_408), Time[gi_352], gi_332 - li_0 - 1);
         ObjectSet("Trend-" + li_0, OBJPROP_ARROWCODE, 218);
         ObjectSet("Trend-" + li_0, OBJPROP_COLOR, Crimson);
         ObjectSet("Trend-" + li_0, OBJPROP_TIME1, Time[gi_352]);
      }
      if (gia_304[li_0] == 0) {
         ObjectCreate("Trend-" + li_0, OBJ_ARROW, WindowFind(gs_408), Time[gi_352], gi_332 - li_0 - 1);
         ObjectSet("Trend-" + li_0, OBJPROP_ARROWCODE, 104);
         ObjectSet("Trend-" + li_0, OBJPROP_COLOR, Orange);
         ObjectSet("Trend-" + li_0, OBJPROP_TIME1, Time[gi_352]);
      }
   }
}

void Draw_Status() {
   if (ObjectFind("AUD_Status") == -1) ObjectCreate("AUD_Status", OBJ_TEXT, WindowFind(gs_408), Time[gi_356], 15);
   if (ObjectFind("USD_Status") == -1) ObjectCreate("USD_Status", OBJ_TEXT, WindowFind(gs_408), Time[gi_356], 15);
   if (ObjectFind("EUR_Status") == -1) ObjectCreate("EUR_Status", OBJ_TEXT, WindowFind(gs_408), Time[gi_356], 15);
   if (ObjectFind("GBP_Status") == -1) ObjectCreate("GBP_Status", OBJ_TEXT, WindowFind(gs_408), Time[gi_356], 15);
   if (ObjectFind("CHF_Status") == -1) ObjectCreate("CHF_Status", OBJ_TEXT, WindowFind(gs_408), Time[gi_356], 15);
   if (ObjectFind("CAD_Status") == -1) ObjectCreate("CAD_Status", OBJ_TEXT, WindowFind(gs_408), Time[gi_356], 15);
   if (ObjectFind("JPY_Status") == -1) ObjectCreate("JPY_Status", OBJ_TEXT, WindowFind(gs_408), Time[gi_356], 15);
   if (ObjectFind("NZD_Status") == -1) ObjectCreate("NZD_Status", OBJ_TEXT, WindowFind(gs_408), Time[gi_356], 15);
   ObjectCreate("StatusTitle1", OBJ_TEXT, WindowFind(gs_408), Time[gi_356], 27);
   ObjectSet("StatusTitle1", OBJPROP_TIME1, Time[gi_356]);
   ObjectSetText("StatusTitle1", "ALL UP", 13, "Arial Black", Navy);
   ObjectCreate("StatusTitle1-1", OBJ_TEXT, WindowFind(gs_408), Time[gi_356], 26);
   ObjectSet("StatusTitle1-1", OBJPROP_TIME1, Time[gi_356]);
   ObjectSetText("StatusTitle1-1", "------------", 13, "Arial Black", Black);
   ObjectCreate("StatusTitle2", OBJ_TEXT, WindowFind(gs_408), Time[gi_356], 15);
   ObjectSet("StatusTitle2", OBJPROP_TIME1, Time[gi_356]);
   ObjectSetText("StatusTitle2", "ALL DOWN", 13, "Arial Black", Navy);
   ObjectCreate("StatusTitle2-1", OBJ_TEXT, WindowFind(gs_408), Time[gi_356], 14);
   ObjectSet("StatusTitle2-1", OBJPROP_TIME1, Time[gi_356]);
   ObjectSetText("StatusTitle2-1", "-----------------", 13, "Arial Black", Black);
   int li_0 = 25;
   int li_4 = 13;
   if (AUD_Status() == 1) {
      ObjectSetText("AUD_Status", "AUD", 11, "Arial Black", Green);
      ObjectSet("AUD_Status", OBJPROP_TIME1, Time[gi_356]);
      ObjectSet("AUD_Status", OBJPROP_PRICE1, li_0);
      li_0--;
   }
   if (AUD_Status() == 2) {
      ObjectSetText("AUD_Status", "AUD", 11, "Arial Black", Red);
      ObjectSet("AUD_Status", OBJPROP_TIME1, Time[gi_356]);
      ObjectSet("AUD_Status", OBJPROP_PRICE1, li_4);
      li_4--;
   }
   if (AUD_Status() == 0) {
      ObjectSetText("AUD_Status", "", 11, "Arial Black", CLR_NONE);
      ObjectSet("AUD_Status", OBJPROP_TIME1, Time[gi_356]);
      ObjectSet("AUD_Status", OBJPROP_PRICE1, 0);
   }
   if (USD_Status() == 1) {
      ObjectSetText("USD_Status", "USD", 11, "Arial Black", Green);
      ObjectSet("USD_Status", OBJPROP_TIME1, Time[gi_356]);
      ObjectSet("USD_Status", OBJPROP_PRICE1, li_0);
      li_0--;
   }
   if (USD_Status() == 2) {
      ObjectSetText("USD_Status", "USD", 11, "Arial Black", Red);
      ObjectSet("USD_Status", OBJPROP_TIME1, Time[gi_356]);
      ObjectSet("USD_Status", OBJPROP_PRICE1, li_4);
      li_4--;
   }
   if (USD_Status() == 0) {
      ObjectSetText("USD_Status", "", 11, "Arial Black", CLR_NONE);
      ObjectSet("USD_Status", OBJPROP_TIME1, Time[gi_356]);
      ObjectSet("USD_Status", OBJPROP_PRICE1, 0);
   }
   if (EUR_Status() == 1) {
      ObjectSetText("EUR_Status", "EUR", 11, "Arial Black", Green);
      ObjectSet("EUR_Status", OBJPROP_TIME1, Time[gi_356]);
      ObjectSet("EUR_Status", OBJPROP_PRICE1, li_0);
      li_0--;
   }
   if (EUR_Status() == 2) {
      ObjectSetText("EUR_Status", "EUR", 11, "Arial Black", Red);
      ObjectSet("EUR_Status", OBJPROP_TIME1, Time[gi_356]);
      ObjectSet("EUR_Status", OBJPROP_PRICE1, li_4);
      li_4--;
   }
   if (EUR_Status() == 0) {
      ObjectSetText("EUR_Status", "", 11, "Arial Black", CLR_NONE);
      ObjectSet("EUR_Status", OBJPROP_TIME1, Time[gi_356]);
      ObjectSet("EUR_Status", OBJPROP_PRICE1, 0);
   }
   if (GBP_Status() == 1) {
      ObjectSetText("GBP_Status", "GBP", 11, "Arial Black", Green);
      ObjectSet("GBP_Status", OBJPROP_TIME1, Time[gi_356]);
      ObjectSet("GBP_Status", OBJPROP_PRICE1, li_0);
      li_0--;
   }
   if (GBP_Status() == 2) {
      ObjectSetText("GBP_Status", "GBP", 11, "Arial Black", Red);
      ObjectSet("GBP_Status", OBJPROP_TIME1, Time[gi_356]);
      ObjectSet("GBP_Status", OBJPROP_PRICE1, li_4);
      li_4--;
   }
   if (GBP_Status() == 0) {
      ObjectSetText("GBP_Status", "", 11, "Arial Black", CLR_NONE);
      ObjectSet("GBP_Status", OBJPROP_TIME1, Time[gi_356]);
      ObjectSet("GBP_Status", OBJPROP_PRICE1, 0);
   }
   if (CHF_Status() == 1) {
      ObjectSetText("CHF_Status", "CHF", 11, "Arial Black", Green);
      ObjectSet("CHF_Status", OBJPROP_TIME1, Time[gi_356]);
      ObjectSet("CHF_Status", OBJPROP_PRICE1, li_0);
      li_0--;
   }
   if (CHF_Status() == 2) {
      ObjectSetText("CHF_Status", "CHF", 11, "Arial Black", Red);
      ObjectSet("CHF_Status", OBJPROP_TIME1, Time[gi_356]);
      ObjectSet("CHF_Status", OBJPROP_PRICE1, li_4);
      li_4--;
   }
   if (CHF_Status() == 0) {
      ObjectSetText("CHF_Status", "", 11, "Arial Black", CLR_NONE);
      ObjectSet("CHF_Status", OBJPROP_TIME1, Time[gi_356]);
      ObjectSet("CHF_Status", OBJPROP_PRICE1, 0);
   }
   if (CAD_Status() == 1) {
      ObjectSetText("CAD_Status", "CAD", 11, "Arial Black", Green);
      ObjectSet("CAD_Status", OBJPROP_TIME1, Time[gi_356]);
      ObjectSet("CAD_Status", OBJPROP_PRICE1, li_0);
      li_0--;
   }
   if (CAD_Status() == 2) {
      ObjectSetText("CAD_Status", "CAD", 11, "Arial Black", Red);
      ObjectSet("CAD_Status", OBJPROP_TIME1, Time[gi_356]);
      ObjectSet("CAD_Status", OBJPROP_PRICE1, li_4);
      li_4--;
   }
   if (CAD_Status() == 0) {
      ObjectSetText("CAD_Status", "", 11, "Arial Black", CLR_NONE);
      ObjectSet("CAD_Status", OBJPROP_TIME1, Time[gi_356]);
      ObjectSet("CAD_Status", OBJPROP_PRICE1, 0);
   }
   if (JPY_Status() == 1) {
      ObjectSetText("JPY_Status", "JPY", 11, "Arial Black", Green);
      ObjectSet("JPY_Status", OBJPROP_TIME1, Time[gi_356]);
      ObjectSet("JPY_Status", OBJPROP_PRICE1, li_0);
      li_0--;
   }
   if (JPY_Status() == 2) {
      ObjectSetText("JPY_Status", "JPY", 11, "Arial Black", Red);
      ObjectSet("JPY_Status", OBJPROP_TIME1, Time[gi_356]);
      ObjectSet("JPY_Status", OBJPROP_PRICE1, li_4);
      li_4--;
   }
   if (JPY_Status() == 0) {
      ObjectSetText("JPY_Status", "", 11, "Arial Black", CLR_NONE);
      ObjectSet("JPY_Status", OBJPROP_TIME1, Time[gi_356]);
      ObjectSet("JPY_Status", OBJPROP_PRICE1, 0);
   }
   if (NZD_Status() == 1) {
      ObjectSetText("NZD_Status", "NZD", 11, "Arial Black", Green);
      ObjectSet("NZD_Status", OBJPROP_TIME1, Time[gi_356]);
      ObjectSet("NZD_Status", OBJPROP_PRICE1, li_0);
      li_0--;
   }
   if (NZD_Status() == 2) {
      ObjectSetText("NZD_Status", "NZD", 11, "Arial Black", Red);
      ObjectSet("NZD_Status", OBJPROP_TIME1, Time[gi_356]);
      ObjectSet("NZD_Status", OBJPROP_PRICE1, li_4);
      li_4--;
   }
   if (NZD_Status() == 0) {
      ObjectSetText("NZD_Status", "", 11, "Arial Black", CLR_NONE);
      ObjectSet("NZD_Status", OBJPROP_TIME1, Time[gi_356]);
      ObjectSet("NZD_Status", OBJPROP_PRICE1, 0);
   }
}

int start() {
//   if (CheckV()) return (0);
   Populate_Values_Array();
   Populate_Meter_Array();
   Populate_Trend_Array();
   EstablishOrientation();
   Draw_Table();
   Draw_Status();
   return (0);
}

bool isEven(int ai_0) {
   if (ai_0 == 0 || MathMod(ai_0, 2) == 0.0) return (TRUE);
   return (FALSE);
}

/*bool CheckV() {
   int li_0 = TimeCurrent();
   int li_4 = StrToTime(gs_88);
   int li_8 = StrToTime(gs_96);
   if (li_0 >= li_4 || li_0 <= li_8) {
      Comment(" Currency Meter has been expired. Please, contact http://currencymeter.com to renew");
      ObjectsDeleteAll();
      return (TRUE);
   }
   if (!gi_76 && IsDemo() && gi_80 == TRUE) {
      Comment("F1");
      return (TRUE);
   }
   if (!IsDemo() && AccountNumber() != gi_84) {
      Comment("F2");
      return (TRUE);
   }
   if (IsDemo() && AccountNumber() != gi_84 && gi_80 == TRUE) {
      Comment("Wrong account Number. Robot has been disabled");
      return (TRUE);
   }
   Comment(" -- Working --");
   return (FALSE);
}*/