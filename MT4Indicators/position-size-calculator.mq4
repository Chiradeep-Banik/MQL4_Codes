//+------------------------------------------------------------------+
//|                                       PositionSizeCalculator.mq4 |
//|                             Copyright © 2012-2013, Andriy Moraru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012-2013, Andriy Moraru"
#property link      "http://www.earnforex.com"

/*
   Calculates position size based on account balance/equity,
   currency, currency pair, given entry level, stop-loss level
   and risk tolerance (set either in percentage points or in base currency).
*/

#property indicator_chart_window

extern double EntryLevel = 0;
extern double StopLossLevel = 0;
extern double Risk = 1; // Risk tolerance in percentage points
extern double MoneyRisk = 0; // Risk tolerance in base currency
extern bool UseMoneyInsteadOfPercentage = false;
extern bool UseEquityInsteadOfBalance = false;
extern bool DeleteLines = false; // If true, will delete lines on deinitialization. Otherwise will leave lines, so levels can be restored.

extern color font_color = LightBlue;
extern color ps_font_color = Red;
extern int font_size = 12;
extern string font_face = "Courier";
extern int corner = 0; //0 - for top-left corner, 1 - top-right, 2 - bottom-left, 3 - bottom-right
extern int distance_x = 10;
extern int distance_y = 15;
extern color entry_line_color = Blue;
extern color stoploss_line_color = Lime;

string SizeText;
double Size, RiskMoney;
double PositionSize;
double StopLoss;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
   if (ObjectFind("EntryLine") > -1) EntryLevel = ObjectGet("EntryLine", OBJPROP_PRICE1);
   if (ObjectFind("StopLossLine") > -1) StopLossLevel = ObjectGet("StopLossLine", OBJPROP_PRICE1);
   
   if ((EntryLevel == 0) && (StopLossLevel == 0))
   {
      Print(Symbol() + ": Entry and Stop-Loss levels not given. Using local values.");
      EntryLevel = High[0];
      StopLossLevel = Low[0];
      if (EntryLevel == StopLossLevel) StopLossLevel -= Point;
   }
   
   if (EntryLevel - StopLossLevel == 0)
   {
      Alert("Entry and Stop-Loss levels should be different and non-zero.");
      return(-1);
   }

   ObjectCreate("EntryLevel", OBJ_LABEL, 0, 0, 0);
   ObjectSet("EntryLevel", OBJPROP_CORNER, corner);
   ObjectSet("EntryLevel", OBJPROP_XDISTANCE, distance_x);
   ObjectSet("EntryLevel", OBJPROP_YDISTANCE, distance_y);
   ObjectSetText("EntryLevel", "Entry Lvl:    " + DoubleToStr(EntryLevel, Digits), font_size, font_face, font_color);

   if (ObjectFind("EntryLine") == -1) 
   {
      ObjectCreate("EntryLine", OBJ_HLINE, 0, Time[0], EntryLevel);
      ObjectSet("EntryLine", OBJPROP_STYLE, STYLE_SOLID);
      ObjectSet("EntryLine", OBJPROP_COLOR, entry_line_color);
      ObjectSet("EntryLine", OBJPROP_WIDTH, 1);
   }
   
   ObjectCreate("StopLoss", OBJ_LABEL, 0, 0, 0);
   ObjectSet("StopLoss", OBJPROP_CORNER, corner);
   ObjectSet("StopLoss", OBJPROP_XDISTANCE, distance_x);
   ObjectSet("StopLoss", OBJPROP_YDISTANCE, distance_y + 15);
   ObjectSetText("StopLoss", "Stop-Loss:    " + DoubleToStr(StopLossLevel, Digits), font_size, font_face, font_color);
      
   if (ObjectFind("StopLossLine") == -1)
   {
      ObjectCreate("StopLossLine", OBJ_HLINE, 0, Time[0], StopLossLevel);
      ObjectSet("StopLossLine", OBJPROP_STYLE, STYLE_SOLID);
      ObjectSet("StopLossLine", OBJPROP_COLOR, stoploss_line_color);
      ObjectSet("StopLossLine", OBJPROP_WIDTH, 1);
   }
   StopLoss = MathAbs(EntryLevel - StopLossLevel);
   
   if (!UseMoneyInsteadOfPercentage)
   {
      ObjectCreate("Risk", OBJ_LABEL, 0, 0, 0);
      ObjectSet("Risk", OBJPROP_CORNER, corner);
      ObjectSet("Risk", OBJPROP_XDISTANCE, distance_x);
      ObjectSet("Risk", OBJPROP_YDISTANCE, distance_y + 30);
      ObjectSetText("Risk", "Risk:         " + DoubleToStr(Risk, 2) + "%", font_size, font_face, font_color);
   }
   
   if (UseEquityInsteadOfBalance)
   {
      SizeText = "Equity";
      Size = AccountEquity();
   }
   else
   {
      SizeText = "Balance";
      Size = AccountBalance();
   }
   ObjectCreate("AccountSize", OBJ_LABEL, 0, 0, 0);
   ObjectSet("AccountSize", OBJPROP_CORNER, corner);
   ObjectSet("AccountSize", OBJPROP_XDISTANCE, distance_x);
   ObjectSet("AccountSize", OBJPROP_YDISTANCE, distance_y + 45);
   ObjectSetText("AccountSize", "Acc. " + SizeText + ": " + DoubleToStr(Size, 2), font_size, font_face, font_color);
   
   ObjectCreate("RiskMoney", OBJ_LABEL, 0, 0, 0);
   ObjectSet("RiskMoney", OBJPROP_CORNER, corner);
   ObjectSet("RiskMoney", OBJPROP_XDISTANCE, distance_x);
   ObjectSet("RiskMoney", OBJPROP_YDISTANCE, distance_y + 60);

   ObjectCreate("PositionSize", OBJ_LABEL, 0, 0, 0);
   ObjectSet("PositionSize", OBJPROP_CORNER, corner);
   ObjectSet("PositionSize", OBJPROP_XDISTANCE, distance_x);
   ObjectSet("PositionSize", OBJPROP_YDISTANCE, distance_y + 75);

   CalculateRiskAndPositionSize();

   return(0);
}

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
{
   ObjectDelete("EntryLevel");
   if (DeleteLines) ObjectDelete("EntryLine");
   ObjectDelete("StopLoss");
   if (DeleteLines) ObjectDelete("StopLossLine");
   if (!UseMoneyInsteadOfPercentage) ObjectDelete("Risk"); // Otherwise wasn't created.
   ObjectDelete("AccountSize");
   ObjectDelete("RiskMoney");
   ObjectDelete("PositionSize");
   return(0);
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
{
   if (EntryLevel - StopLossLevel == 0) return(0);

   // If could not find account currency, probably not connected.
   if (AccountCurrency() == "") return(0);
   
   double tEntryLevel = ObjectGet("EntryLine", OBJPROP_PRICE1);
   double tStopLossLevel = ObjectGet("StopLossLine", OBJPROP_PRICE1);
   ObjectSetText("EntryLevel", "Entry Lvl:    " + DoubleToStr(tEntryLevel, Digits), font_size, font_face, font_color);
   ObjectSetText("StopLoss", "Stop-Loss:    " + DoubleToStr(tStopLossLevel, Digits), font_size, font_face, font_color);

   StopLoss = MathAbs(tEntryLevel - tStopLossLevel);

   if (UseEquityInsteadOfBalance) Size = AccountEquity();
   else Size = AccountBalance();
   ObjectSetText("AccountSize", "Acc. " + SizeText + ": " + DoubleToStr(Size, 2), font_size, font_face, font_color);

   CalculateRiskAndPositionSize();

   return(0);
}

//+------------------------------------------------------------------+
//| Calculates risk size and position size. Sets object values.      |
//+------------------------------------------------------------------+
void CalculateRiskAndPositionSize()
{
   if (!UseMoneyInsteadOfPercentage) RiskMoney = Size * Risk / 100;
   else RiskMoney = MoneyRisk;
   ObjectSetText("RiskMoney", "Risk, money:  " + DoubleToStr(RiskMoney, 2), font_size, font_face, font_color);

   double UnitCost = MarketInfo(Symbol(), MODE_TICKVALUE);
   double TickSize = MarketInfo(Symbol(), MODE_TICKSIZE);
   if ((StopLoss != 0) && (UnitCost != 0) && (TickSize != 0)) PositionSize = RiskMoney / (StopLoss * UnitCost / TickSize);
   
   ObjectSetText("PositionSize", "Pos. Size:    " + DoubleToStr(PositionSize, 2), font_size + 1, font_face, ps_font_color);
}
//+------------------------------------------------------------------+