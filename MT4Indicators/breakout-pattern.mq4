#property copyright "Scriptong"
#property link      ""
#property description "English: Finding the \"Splash and shelf\" pattern"
#property version "1.30"
#property strict

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1  clrDodgerBlue

#define  FRACTALS_AMOUNT                              4                                            // Number of recent accounted fractals
#define  ARRAY_RESERVE_SIZE                           10                                                
#define  SIGN_INCLINE_LINE                            "INCLINE_"
#define  SIGN_HORIZONTAL_LINE                         "HORIZONTAL_"
#define  SIGN_ARROW_BUY                               "ARROW_BUY_"
#define  SIGN_ARROW_SELL                              "ARROW_SELL_"


enum ENUM_YESNO
{
   NO,                                                                                             // No / Нет
   YES                                                                                             // Yes / Да
};

enum ENUM_EXTREMUM_TYPE
{
   EXTREMUM_TYPE_NONE,   
   EXTREMUM_TYPE_MIN,
   EXTREMUM_TYPE_MAX
};

enum ENUM_PATTERN_TYPE
{
   PATTERN_TYPE_NONE,
   PATTERN_TYPE_BULL,
   PATTERN_TYPE_BEAR   
};

enum ENUM_FUNCTION_RESULT
{
   FUNCTION_RESULT_OK,                                                                             // The successful ending of function run
   FUNCTION_RESULT_ALRIGHT,                                                                        // The not successful ending of function run but no has critical errors
   FUNCTION_RESULT_FATAL                                                                           // The fatal error ending of function run
};

struct FractalData
{
   ENUM_EXTREMUM_TYPE type;
   datetime           time;
   double             price;  
   
   FractalData()
   {
      Init();
   } 
   
   void Init()
   {
      type = EXTREMUM_TYPE_NONE;
      time = 0;
      price = 0.0;
   }
};

struct Pattern
{
   ENUM_PATTERN_TYPE patternType;
   FractalData       fractals[FRACTALS_AMOUNT];
   int               leftBarIndex;                                                                 // Index of left bar the slope line
   int               rightBarIndex;                                                                // Index of right bar the slope line
   color             patternColor;
   
   Pattern()
   {
      Init();
   }
   
   void Init()
   {
      patternType = PATTERN_TYPE_NONE;
      leftBarIndex = -1;
      rightBarIndex = -1;
      patternColor = clrNONE;
   }
};


// Input parameters of indicator
input uint                     i_minSplashHeight     = 200;                                        // Min. height of splash, pts / Мин. высота всплеска, пп.
input uint                     i_maxBarsDuration     = 20;                                         // Max bars before crossing / Макс. баров до пересечения
input color                    i_bullPatternRegColor = clrPowderBlue;                              // Color of bull not active pattern / Цвет бычьего неактивного паттерна
input color                    i_bearPatternRegColor = clrPink;                                    // Color of bear not active pattern / Цвет медвежьего неактивного паттерна
input color                    i_bullPatternWorkColor = clrBlue;                                   // Color of bull active pattern / Цвет бычьего активного паттерна
input color                    i_bearPatternWorkColor = clrRed;                                    // Color of bear active pattern / Цвет медвежьего активного паттерна
input color                    i_buyArrowColor       = clrBlue;                                    // Buy signal arrow color / Цвет стрелки сигнала покупки
input color                    i_sellArrowColor      = clrRed;                                     // Buy signal arrow color / Цвет стрелки сигнала покупки
input ENUM_YESNO               i_isAlert             = YES;                                        // Alert on pattern found? / Сигнал при паттерне?
input ENUM_YESNO               i_isPush              = YES;                                        // Notification on pattern found? / Уведомлять о паттерне?
input int                      i_indBarsCount        = 10000;                                      // The number of bars to display / Количество баров отображения

// Other global variables of indicator
bool              g_activate,                                                                      // Sign of successful initialization of indicator
                  g_isRussianLang;

uint              g_fractalsCnt,                                                                   // Found fractals counter (0 - FRACTALS_AMOUNT)
                  g_patternsCnt;                                                                   // Current amount of patterns which not activated and not trash
                  
datetime          g_lastBuyPatternRegFractalTime,
                  g_lastSellPatternRegFractalTime;
FractalData       g_lastFractals[FRACTALS_AMOUNT];                                                 // Data of last FRACTALS_AMOUNT fractals
Pattern           g_patterns[];                                                                    // Patterns which not activated and not trash
     
       
#define PREFIX                                  "SPLASHEL_"                                        // Prefix the name of the graphic objects which displayed by indicator

//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Custom indicator initialization function                                                                                                                                                          |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
int OnInit()
{
   g_isRussianLang = (TerminalInfoString(TERMINAL_LANGUAGE) == "Russian");
   g_activate = true;                                                                              
   return INIT_SUCCEEDED;
}
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Custom indicator deinitialization function                                                                                                                                                        |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   ObjectsDeleteAll(0, PREFIX);
}
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Displaying the trend line                                                                                                                                                                         |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
void ShowTrendLine(string name, datetime time1, double price1, datetime time2, double price2, string toolTip, color clr)
{
   if (ObjectFind(0, name) < 0)
   {
      ObjectCreate(0, name, OBJ_TREND, 0, time1, price1, time2, price2);
      ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
      ObjectSetInteger(0, name, OBJPROP_BACK, false);
      ObjectSetInteger(0, name, OBJPROP_WIDTH, 2);
      ObjectSetInteger(0, name, OBJPROP_RAY, false);
      ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
      ObjectSetString(0, name, OBJPROP_TOOLTIP, toolTip);
      return;
   }
   
   ObjectMove(0, name, 0, time1, price1);
   ObjectMove(0, name, 1, time2, price2);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetString(0, name, OBJPROP_TOOLTIP, toolTip);
}
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Show the Wingdings sign                                                                                                                                                                           |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
void ShowArrow(string name, datetime time1, double price1, int code, color clr, ENUM_ARROW_ANCHOR anchor, int width, string toolTip)
{
   if (ObjectFind(0, name) < 0)
   {
      ObjectCreate(0, name, OBJ_ARROW, 0, time1, price1);
      ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
      ObjectSetInteger(0, name, OBJPROP_ARROWCODE, code);
      ObjectSetInteger(0, name, OBJPROP_ANCHOR, anchor);
      ObjectSetInteger(0, name, OBJPROP_WIDTH, width);
      ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
      ObjectSetString(0, name, OBJPROP_TOOLTIP, toolTip);
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
      return;
   }
   
   ObjectMove(0, name, 0, time1, price1);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetString(0, name, OBJPROP_TOOLTIP, toolTip);
}
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Determination of bar index which needed to recalculate                                                                                                                                            |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
int GetRecalcIndex(int& total, const int ratesTotal, const int prevCalculated)
{
   total = ratesTotal - 3;                                                                         
                                                   
   if (i_indBarsCount > 0 && i_indBarsCount < total)
      total = MathMin(i_indBarsCount, total);                      
                                                   
   if (prevCalculated < ratesTotal - 1)                     
   {       
      ObjectsDeleteAll(0, PREFIX);
      for (int i = 0; i < FRACTALS_AMOUNT; i++)
         g_lastFractals[i].Init();
      g_fractalsCnt = 0;
      return (total);
   }
   
   return (MathMin(ratesTotal - prevCalculated, total));                            
}
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Sound and Push-notifications of divergence                                                                                                                                                        |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
void SignalOnPattern(string text)
{
   if (i_isAlert)
      Alert(Symbol(), ", ", EnumToString(ENUM_TIMEFRAMES(Period())), ": ", text);
      
   if (i_isPush)
      SendNotification(Symbol() + ", " + EnumToString(ENUM_TIMEFRAMES(Period())) + ": " + text);
}
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//|                                                                                                                                                                                                   |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
double CalculateBAndKByLine(int x1, double y1, int x2, double y2, double &kKoef)
{
   if (x1 == x2)
      return DBL_MAX;
      
   kKoef = (y2 - y1) / (x2 - x1);
   return y1 - kKoef * x1;
}
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| unique identificator of graphic object                                                                                                                                                            |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
string GetUniqueID(const Pattern & pattern)
{
   return IntegerToString(pattern.fractals[0].time) + "_" + IntegerToString((int)pattern.patternType) + "_";
}
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Show the pattern                                                                                                                                                                                  |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
void ShowPattern(const Pattern & pattern)
{
   double kKoef = 0.0;
   double bKoef = CalculateBAndKByLine(pattern.leftBarIndex, pattern.fractals[2].price, pattern.rightBarIndex, pattern.fractals[0].price, kKoef);
   if (bKoef == DBL_MAX || kKoef == 0.0)
      return;
      
   int crossLinesBarIndex = int(floor((pattern.fractals[1].price - bKoef) / kKoef));
   
   datetime crossLinesTime = (crossLinesBarIndex >= 0)? iTime(NULL, 0, crossLinesBarIndex) : iTime(NULL, 0, 0) - crossLinesBarIndex * PeriodSeconds();

   string uniqID = GetUniqueID(pattern);
   ShowTrendLine(PREFIX + uniqID + SIGN_INCLINE_LINE, pattern.fractals[2].time, pattern.fractals[2].price, crossLinesTime, pattern.fractals[1].price, "", pattern.patternColor);
   ShowTrendLine(PREFIX + uniqID + SIGN_HORIZONTAL_LINE, pattern.fractals[3].time, pattern.fractals[1].price, crossLinesTime, pattern.fractals[1].price, "", pattern.patternColor);
}
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Add specified fractal to g_lastFractals array                                                                                                                                                     |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
void AddFractalToArray(ENUM_EXTREMUM_TYPE fractalType, double fractalPrice, datetime fractalTime)
{
   // if a fractal is already registered, we do not need a new registration
   if (g_lastFractals[0].type == fractalType && g_lastFractals[0].time == fractalTime)
      return;

   // Moving the elemets of array to upside
   for (int i = FRACTALS_AMOUNT - 1; i > 0; i--)
      g_lastFractals[i] = g_lastFractals[i - 1];
      
   // Save the data
   g_lastFractals[0].type = fractalType;
   g_lastFractals[0].price = fractalPrice;
   g_lastFractals[0].time = fractalTime;
   
   if (g_fractalsCnt < FRACTALS_AMOUNT)
      g_fractalsCnt++;
}
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Checking the sell pattern exists                                                                                                                                                                  |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
bool IsLowerPattern()
{
   if (g_fractalsCnt < FRACTALS_AMOUNT)
      return false;
      
   // Down pattern - it is the upper fractal in 0 element, down fractal in 1 element, upper fractal in 2 element and down fractal in 3 element
   if (g_lastFractals[0].type != EXTREMUM_TYPE_MAX || g_lastFractals[1].type != EXTREMUM_TYPE_MIN || g_lastFractals[2].type != EXTREMUM_TYPE_MAX || g_lastFractals[3].type != EXTREMUM_TYPE_MIN)
      return false;
      
   // Height of splash can be i_minSplashHeight points or greater
   if (g_lastFractals[2].price - g_lastFractals[3].price - i_minSplashHeight * Point() < -DBL_EPSILON)
      return false;
      
   // Fractals 0 and 1 must be located between 2 and 3 fractals and fractal 0 must be higher than fractal 1
   return g_lastFractals[0].time > g_lastSellPatternRegFractalTime &&
          g_lastFractals[0].price > g_lastFractals[3].price && g_lastFractals[0].price < g_lastFractals[2].price &&
          g_lastFractals[1].price > g_lastFractals[3].price && g_lastFractals[1].price < g_lastFractals[2].price &&
          g_lastFractals[0].price > g_lastFractals[1].price;
}
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Checking the buy pattern exists                                                                                                                                                                   |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
bool IsUpperPattern()
{
   if (g_fractalsCnt < FRACTALS_AMOUNT)
      return false;
      
   // Down pattern - it is the lower fractal in 0 element, upper fractal in 1 element, lower fractal in 2 element and upper fractal in 3 element
   if (g_lastFractals[0].type != EXTREMUM_TYPE_MIN || g_lastFractals[1].type != EXTREMUM_TYPE_MAX || g_lastFractals[2].type != EXTREMUM_TYPE_MIN || g_lastFractals[3].type != EXTREMUM_TYPE_MAX)
      return false;
      
   // Height of splash can be i_minSplashHeight points or greater
   if (g_lastFractals[3].price - g_lastFractals[2].price - i_minSplashHeight * Point() < -DBL_EPSILON)
      return false;
      
   // Fractals 0 and 1 must be located between 2 and 3 fractals and fractal 0 must be higher than fractal 1
   return g_lastFractals[0].time > g_lastBuyPatternRegFractalTime &&
          g_lastFractals[0].price > g_lastFractals[2].price && g_lastFractals[0].price < g_lastFractals[3].price &&
          g_lastFractals[1].price > g_lastFractals[2].price && g_lastFractals[1].price < g_lastFractals[3].price &&
          g_lastFractals[0].price < g_lastFractals[1].price;
}
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Write the new pattern to database                                                                                                                                                                 |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
ENUM_FUNCTION_RESULT AddPatternToArray()
{
   ENUM_PATTERN_TYPE newPatternType = (g_lastFractals[0].type == EXTREMUM_TYPE_MAX)? PATTERN_TYPE_BEAR : PATTERN_TYPE_BULL;
   int leftBarIndex = iBarShift(NULL, 0, g_lastFractals[2].time);
   int rightBarIndex = iBarShift(NULL, 0, g_lastFractals[0].time);

   // Finding the same pattern in array
   int arraySize = ArraySize(g_patterns);
   for (int i = arraySize - 1; i >= 0; i--)
      if (g_patterns[i].patternType == newPatternType && g_patterns[i].leftBarIndex == leftBarIndex && g_patterns[i].rightBarIndex == rightBarIndex)
         return FUNCTION_RESULT_ALRIGHT;

   // Calculate the K and B coefficients of line equation   
   double kKoef = 0.0;
   double bKoef = CalculateBAndKByLine(leftBarIndex, g_lastFractals[2].price, rightBarIndex, g_lastFractals[0].price, kKoef);
   if (bKoef == DBL_MAX || kKoef == 0.0)
      return FUNCTION_RESULT_ALRIGHT;

   int crossLinesBarIndex = int(floor((g_lastFractals[1].price - bKoef) / kKoef));
   if (rightBarIndex - crossLinesBarIndex - 3 > (int)i_maxBarsDuration)
      return FUNCTION_RESULT_ALRIGHT;


   // Resize the array
   if (ArrayResize(g_patterns, arraySize + 1, ARRAY_RESERVE_SIZE) < 0)
   {
      if (g_isRussianLang)
         Alert(WindowExpertName(), ": недостаточно памяти для продолжения работы программы. Индикатор отключен.");
      else
         Alert(WindowExpertName(), ": not enough memory to continue work the program. Indicator is turned off.");
      return FUNCTION_RESULT_FATAL;      
   }

   // Write the pattern
   g_patterns[arraySize].patternType = newPatternType;
   g_patterns[arraySize].patternColor = (g_lastFractals[0].type == EXTREMUM_TYPE_MAX)? i_bearPatternRegColor : i_bullPatternRegColor;
   g_patterns[arraySize].leftBarIndex = leftBarIndex;
   g_patterns[arraySize].rightBarIndex = rightBarIndex;
   
   for (int i = 0; i < FRACTALS_AMOUNT; i++)
      g_patterns[arraySize].fractals[i] = g_lastFractals[i];
      
   if (newPatternType == PATTERN_TYPE_BEAR)
      g_lastSellPatternRegFractalTime = g_lastFractals[0].time;
   else
      g_lastBuyPatternRegFractalTime = g_lastFractals[0].time;
      
   return FUNCTION_RESULT_OK;
}
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Process the specified pattern                                                                                                                                                                     |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
bool IsNeedToDeletePattern(Pattern &pattern, int barIndex)
{
   // Pattern can be activated through 3 bars from last fractal only
   if (pattern.rightBarIndex - barIndex < 3)
      return false;
   
   // Calculate the K and B coefficients of line equation   
   double kKoef = 0.0;
   double bKoef = CalculateBAndKByLine(pattern.leftBarIndex, pattern.fractals[2].price, pattern.rightBarIndex, pattern.fractals[0].price, kKoef);
   if (bKoef == DBL_MAX || kKoef == 0.0)
      return true;
      
   // Deleting the pattern if pattern is expired
   int crossLinesBarIndex = int(floor((pattern.fractals[1].price - bKoef) / kKoef));
   if (barIndex <= crossLinesBarIndex)
      return true;
      
   // Deleting the pattern if pattern is activated
   if (pattern.patternType == PATTERN_TYPE_BEAR && iLow(NULL, 0, barIndex) < pattern.fractals[1].price)
   {
      pattern.patternColor = i_bearPatternWorkColor;
      ShowPattern(pattern);
      string uniqID = IntegerToString(pattern.fractals[0].time) + "_" + IntegerToString((int)pattern.patternType) + "_";
      ShowArrow(PREFIX + GetUniqueID(pattern) + SIGN_ARROW_SELL, iTime(NULL, 0, barIndex), iHigh(NULL, 0, barIndex), 242, i_bearPatternWorkColor, ANCHOR_BOTTOM, 2, "Sell by pattern");
      if (barIndex == 0)
         SignalOnPattern(g_isRussianLang? "Активирован Sell паттерн" : "Sell pattern activated");
      return true;
   }
   
   if (pattern.patternType == PATTERN_TYPE_BULL && iHigh(NULL, 0, barIndex) > pattern.fractals[1].price)
   {
      pattern.patternColor = i_bullPatternWorkColor;
      ShowPattern(pattern);
      ShowArrow(PREFIX + GetUniqueID(pattern) + SIGN_ARROW_BUY, iTime(NULL, 0, barIndex), iLow(NULL, 0, barIndex), 241, i_bullPatternWorkColor, ANCHOR_TOP, 2, "Buy by pattern");
      if (barIndex == 0)
         SignalOnPattern(g_isRussianLang? "Активирован Buy паттерн" : "Buy pattern activated");
      return true;
   }

   return false;
}
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Deleting the specified element from specified array                                                                                                                                               |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
template<typename T>
void DeleteElementFromArray(T &array[], int elementToDelete)
{
   int arraySize = ArraySize(array);
   if (arraySize == 0)
      return;
      
   array[elementToDelete] = array[arraySize - 1];
   ArrayResize(array, arraySize - 1, ARRAY_RESERVE_SIZE);
}
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Process the not actived patterns                                                                                                                                                                  |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
void ProcessPatterns(int barIndex)
{
   for (int i = ArraySize(g_patterns) - 1; i >= 0; i--)
      if (IsNeedToDeletePattern(g_patterns[i], barIndex))
         DeleteElementFromArray(g_patterns, i);
}
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Process the specified bar                                                                                                                                                                         |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
bool ProcessBar(int barIndex)
{
   int potentialFractalBarIndex = barIndex + 3;

   // Upper fractal
   if (iFractals(NULL, 0, MODE_UPPER, potentialFractalBarIndex) != 0.0)
      AddFractalToArray(EXTREMUM_TYPE_MAX, iHigh(NULL, 0, potentialFractalBarIndex), iTime(NULL, 0, potentialFractalBarIndex));
   
   // Lower fractal
   if (iFractals(NULL, 0, MODE_LOWER, potentialFractalBarIndex) != 0.0)
      AddFractalToArray(EXTREMUM_TYPE_MIN, iLow(NULL, 0, potentialFractalBarIndex), iTime(NULL, 0, potentialFractalBarIndex));
      
   // Pattern found
   bool isLowerPattern = IsLowerPattern();
   bool isUpperPattern = IsUpperPattern();
   if (isLowerPattern || isUpperPattern)
   {
      ENUM_FUNCTION_RESULT result = AddPatternToArray();
      if (result == FUNCTION_RESULT_FATAL)
         return false;
      if (result == FUNCTION_RESULT_ALRIGHT)
         return true;
   
      ShowPattern(g_patterns[ArraySize(g_patterns) - 1]);
         
      string patternType = (g_patterns[ArraySize(g_patterns) - 1].patternType == PATTERN_TYPE_BEAR)? "Sell" : "Buy";
      if (barIndex == 0)
         SignalOnPattern(g_isRussianLang? "Найден паттерн " + patternType :
                                          "Found the " + patternType + " pattern");
   }
   
   // Checking the activate or deleting the pattern
   ProcessPatterns(barIndex);
   
   return true;
}
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Displaying of indicators values                                                                                                                                                                   |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
bool ShowIndicatorData(int limit, int total)
{
   if (limit > 1)
   {
      ArrayResize(g_patterns, 0, ARRAY_RESERVE_SIZE);
      g_lastBuyPatternRegFractalTime = 0;
      g_lastSellPatternRegFractalTime = 0;
   }
      
   if (limit == 1)
      for (int i = ArraySize(g_patterns) - 1; i >= 0; i--)
      {
         g_patterns[i].leftBarIndex++;
         g_patterns[i].rightBarIndex++;
      }

   for (int i = limit; i >= 0; i--)
      if (!ProcessBar(i))
         return false;

   return true;
}
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Custom indicator iteration function                                                                                                                                                               |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime& time[],
                const double& open[],
                const double& high[],
                const double& low[],
                const double& close[],
                const long& tick_volume[],
                const long& volume[],
                const int& spread[])
{
   if (!g_activate)                                                                                
      return rates_total;                                 

   int total;   
   int limit = GetRecalcIndex(total, rates_total, prev_calculated);                                

   if (!ShowIndicatorData(limit, total))
      g_activate = false;
   WindowRedraw();
   
   return rates_total;
}
