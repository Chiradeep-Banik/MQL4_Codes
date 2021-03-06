#property copyright "Copyright  Scriptong©2016, Evbut ©2016"
#property link ""
#property version "1.0"
                       
#property description "Indicator looking for 11 candle patterns of Price Action"
                      
#property indicator_chart_window
#property strict
#define BULL_BAR        1
#define BEAR_BAR        -1
#define MODE_LOW 1
#define MODE_HIGH 2
#define FIRST_PART     "_1_"  

#define PREFIX         "PRACTION_"         
#define  ARRAY_RESERVE_SIZE      10                                                
enum ENUM_YESNO
  {
   NO,           
   YES           
  };
enum ENUM_STYLE
  {
   Solid,        
   Dash,         
   Dot,          
   DashDot,      
   DashDotDot    
  };
input string      A8="==== COMMON SETUP'S / ОБЩИЕ НАСТРОЙКИ ====";
input int         indBarsCount         = 1000;           //Number of History Bar to Display Patterns
input ENUM_YESNO  OverlapingPattern     = NO;            //Is Display Overlaped Paterns?
input ENUM_YESNO  FillRectangle        = YES;            //Fill Rectangle by Color
input ENUM_STYLE  LineStyle;                             //Rectangle Line Style
input int         LineWidth            = 1;              //Rectangle Line Thickness

input string      A1 = "======= DBHLC & DBLHC =======";
input ENUM_YESNO  showDBpattern = true;                  //Is Display DB Patterns?         
input int         equalPipsDB = 3;                       //Valid diviation of Hi/Lo equal, point           
input color       colorDBLHC = clrBlue;                  //Bull Rails Color    
input color       colorDBHLC = clrRed;                   //Bear Rails Color   
input string      A2 = "======= TBH & TBL =======";
input ENUM_YESNO  showTBpattern = true;                  //Is Display TB Patterns?     
input int         equalPipsTB = 3;                       //Valid diviation of Hi/Lo to equal, point         
input color       colorTB = clrGoldenrod;                //Color TB Patterns       
input string      A3="======= RAIL'S =======";
input ENUM_YESNO  IsShowRailsPattern   = YES;            //Is Display Rails Pattern?
input double      bodyGreatPercents    = 10;             //Max. Candles Body Ratio, %
input double      bodyToHeightPercents = 20;             //Min. Ratio of Candles Body to It Height, %
input color       colorBullsRails = clrDodgerBlue;       //Bull Rails Color
input color       colorBearsRails = clrFireBrick;        //Bear Rails Color
input string      A4="======= OVB  =======";
input ENUM_YESNO  IsShowOVBPattern     = YES;            //Is Display OVB Pattern?
input color       colorBUOVB = clrRoyalBlue;             //Bull OVB Color
input color       colorBEOVB = clrCrimson;               //Bear OVB Color
input string      A5="======= PPR  =======";
input ENUM_YESNO  IsShowPPRPattern     = YES;            //Is Display PPR Pattern?
input color       colorBullsPPR = clrDeepSkyBlue;        //Bull PRP Color
input color       colorBearsPPR = clrMediumVioletRed;    //Bear PPR Color
input string      A6="======= PIN_BAR  =======";
input bool        IsShowPINBARpattern = true;             //Is Display Pin-Bar?
input int         closeToHighLowPoints = 3;               //Affinity Close Price to Candle Hi-Lo, point
input double      shadowToBodyKoef = 3.0;                 //Minimum of Shadow to Body Candle Ratio
input double      noseOutsidePercent = 75.0;              //Minimum Part of Shadow Outsiding for Previous Bar, %
input color       colorBullsPINBAR = clrCadetBlue;        //Bull Pin-Bar Color
input color       colorBearsPINBAR = clrTomato;           //Bear Pin-Bar Color
input string      A7="======= WIDE RANGE BAR =======";
input ENUM_YESNO  IsShowWRBPattern  = YES;               //Is Display WRB Pattern?
input double      BodyRatio            = 1.5;            //Ratio of Body 1 to 2 & 3 to 2 Candles, %
input double      HighLowClearance     = 20;             //Сlearence between Hi First & Lo Third Candles, %
input color       colorBullsWRB = clrSkyBlue;            //Bull WRB Color
input color       colorBearsWRB = clrIndianRed;          //Bear WRB Color 

bool   g_isRussianLang,
       g_bIsActivate;
MqlRates rates[];
int ratesCnt = 0;
datetime BARflag  = 0;           //Для побарового режима

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum ENUM_PATTERN_TYPE
  {
   NONE_TYPE,      //0 - No pattern
   BULL_TYPE,     
   BEAR_TYPE,      
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum ENUM_PATTEN_NAME
  {
   NONE_INDEX =-1, //No index
   DB_PATTERN_,
   TB_PATTERN_,
   RAILS_PATTERN_,
   OVB_PATTERN_,
   PPR_PATTERN_,
   PINBAR_PATTERN_,
   WRB_PATTERN_ 
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
struct Pattern
  {
   ENUM_PATTERN_TYPE patternType;
   ENUM_PATTEN_NAME  patternName;
   datetime          leftTime;
   datetime          rightTime;
   double            patternLowPrice;
   double            patternHighPrice;
   color             patternColor;

                     Pattern()
     {
      Init();
     }

   void Init()
     {
      patternType      = NONE_TYPE;
      patternName      = NONE_INDEX;
      leftTime         = -1;
      rightTime        = -1;
      patternLowPrice  = 0.0;
      patternHighPrice = 0.0;
      patternColor     = clrNONE;
     }
  };
Pattern           g_patterns[];     //Pattern Array
//+-------------------------------------------------------------------------------------+
//| Custom indicator initialization function                                            |
//+-------------------------------------------------------------------------------------+
int OnInit()
{
   g_bIsActivate = false;
   if (!IsTuningParametersCorrect()) 
      return INIT_FAILED;
   
   
   g_bIsActivate = true;
   return INIT_SUCCEEDED;
}
//+-------------------------------------------------------------------------------------+
//| Custom indicator deinitialization function                                          |
//+-------------------------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   ArrayResize(rates,0);
   ObjectsDeleteAll(0, PREFIX);
   Comment("");
}
//+-------------------------------------------------------------------------------------+
//| Check correction parameter                                                          |
//+-------------------------------------------------------------------------------------+
bool IsTuningParametersCorrect()
{
   g_isRussianLang=(TerminalInfoString(TERMINAL_LANGUAGE)=="Russian");
 
   return(true);
}
//+-------------------------------------------------------------------------------------+
//| Determination of bar index which needed to recalculate                              |
//+-------------------------------------------------------------------------------------+
int GetRecalcIndex(int& total, const int ratesTotal, const int prevCalculated)
{
   total = ratesTotal-4;                                                                         
                                              
   if (indBarsCount > 0 && indBarsCount < total)
      total = MathMin(indBarsCount, total);                      
                                                   
   if (prevCalculated < ratesTotal - 1)                     
    {       
      ObjectsDeleteAll(0, PREFIX);
      ArrayResize(g_patterns,0);
      return (total);
    }
   
   return (MathMin(ratesTotal - prevCalculated, total));                            
}
//****FOR MT5 version **************************************************************
ENUM_TIMEFRAMES TFMigrate(int tf)
{
   switch(tf)
   {
      case 0: return(PERIOD_CURRENT);
      case 1: return(PERIOD_M1);
      case 5: return(PERIOD_M5);
      case 15: return(PERIOD_M15);
      case 30: return(PERIOD_M30);
      case 60: return(PERIOD_H1);
      case 240: return(PERIOD_H4);
      case 1440: return(PERIOD_D1);
      case 10080: return(PERIOD_W1);
      case 43200: return(PERIOD_MN1);
      
      case 2: return(PERIOD_M2);
      case 3: return(PERIOD_M3);
      case 4: return(PERIOD_M4);      
      case 6: return(PERIOD_M6);
      case 10: return(PERIOD_M10);
      case 12: return(PERIOD_M12);
      case 16385: return(PERIOD_H1);
      case 16386: return(PERIOD_H2);
      case 16387: return(PERIOD_H3);
      case 16388: return(PERIOD_H4);
      case 16390: return(PERIOD_H6);
      case 16392: return(PERIOD_H8);
      case 16396: return(PERIOD_H12);
      case 16408: return(PERIOD_D1);
      case 32769: return(PERIOD_W1);
      case 49153: return(PERIOD_MN1);      

      default: return(PERIOD_CURRENT);
   }
}
int iLowest_(string symbol, int tf, int type=MODE_LOW, int count=WHOLE_ARRAY, int start=0)
{
   if(start <0) return(-1);
   ENUM_TIMEFRAMES timeframe=TFMigrate(tf);
   
   if(count==0) count=Bars(symbol,timeframe);   
   
   if(type==MODE_LOW)
   {         
      double Arr[];
      if(CopyLow(symbol,timeframe,start,count,Arr)>0)  
         return((count-ArrayMinimum(Arr)-1)+start);
      else return(-1);
   }
  else return(-1);
}
int iHighest_(string symbol, int tf, int type=MODE_HIGH, int count=WHOLE_ARRAY, int start=0)
{
   if(start <0) return(-1);
   ENUM_TIMEFRAMES timeframe=TFMigrate(tf);

   if(count==0) count=Bars(symbol,timeframe);
   
   if(type==MODE_HIGH)
   {
      double ArrMH[];
      if(CopyHigh(symbol,timeframe,start,count,ArrMH)>0)  
         return((count-ArrayMaximum(ArrMH)-1)+start);
      else return(-1);
   } 
   else return(-1);
}
//**** END ********************************************************************
//+-------------------------------------------------------------------------------------+
//| Display the Rectangle                                                               |
//+-------------------------------------------------------------------------------------+
void ShowRectangle(string name,datetime time1,double price1,datetime time2,
                   double price2,string toolTip, color clr)
{
   if(ObjectFind(0,name)<0)                         
     {
      ObjectCreate(0,name,OBJ_RECTANGLE,0,time1,price1,time2,price2);
      ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
      ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
      ObjectSetInteger(0,name,OBJPROP_WIDTH,LineWidth);
      ObjectSetInteger(0,name,OBJPROP_STYLE,LineStyle);
      ObjectSetInteger(0,name,OBJPROP_COLOR,clr);
      ObjectSetInteger(0,name,OBJPROP_BACK,FillRectangle);
      ObjectSetInteger(0,name,OBJPROP_FILL,FillRectangle);
      ObjectSetString(0,name,OBJPROP_TOOLTIP,toolTip);
      return;
    }
}
//+-------------------------------------------------------------------------------------+
//| Reduction of a difference of two sizes to the whole value (in points)               |
//+-------------------------------------------------------------------------------------+
int PD(double greater, double less)
{
   return(int)MathRound((greater - less)/_Point);
}
//+-------------------------------------------------------------------------------------+
//| Determination of the Bull Pin Bar                                                   |
//+-------------------------------------------------------------------------------------+
bool IsBullsPINBAR(int index)
{
   if (rates[index].open < rates[index+1].low) 
      return(false);

   if (rates[index].close < rates[index+1].low)
      return(false); 

   if (rates[index].low >= rates[index+1].low)
      return(false);

   if (PD(rates[index].high, rates[index].close) > closeToHighLowPoints)
      return(false);                               
    
   double shadow = MathMin(rates[index].open, rates[index].close) - rates[index].low;
   double body = MathAbs(rates[index].open - rates[index].close);
   if (body == 0)
      body = _Point;
   if (shadow/body < shadowToBodyKoef)
       return(false);

   double noseOutside = rates[index+1].low - rates[index].low;
   if (noseOutside/shadow < noseOutsidePercent/100)
      return(false);

   return (true);
}
//+-------------------------------------------------------------------------------------+
//| Determination of the Bear Pin Bar                                                   |
//+-------------------------------------------------------------------------------------+
bool IsBearsPINBAR(int index)
{
   if (rates[index].open > rates[index+1].high)
      return(false);

   if (rates[index].close > rates[index+1].high)
      return(false);

   if (rates[index].high <= rates[index+1].high)
      return(false);
      
   if (PD(rates[index].close, rates[index].low) > closeToHighLowPoints)
      return(false);
    
   double shadow = rates[index].high - MathMax(rates[index].open, rates[index].close);
   double body = MathAbs(rates[index].open - rates[index].close);
   if (body == 0)
      body = _Point;
   if (shadow/body < shadowToBodyKoef)
       return(false);
       
   double noseOutside = rates[index].high - rates[index+1].high;
   if (noseOutside/shadow < noseOutsidePercent/100)
      return(false);

   return (true);
}
//+-------------------------------------------------------------------------------------+
//| Determination of the Rails                                                          |
//+-------------------------------------------------------------------------------------+
bool IsRails(int index,double body1,double body2)
{
   if(body1<=0)
      return(false);

   if(body2<=0)
      return(false);

   double height1=rates[index].high-rates[index].low;
   if(body1/height1<bodyToHeightPercents/100)
      return(false);

   double height2=rates[index+1].high-rates[index+1].low;
   if(body2/height2<bodyToHeightPercents/100)
      return(false);

   double ratio=100*(1-MathMin(body1,body2)/MathMax(body1,body2));
   if(ratio>bodyGreatPercents)
      return(false);
   
   return(true);
}
//+-------------------------------------------------------------------------------------+
//| Determination of the Bull Rails                                                     |
//+-------------------------------------------------------------------------------------+
bool IsBullsRailsPattern(int index)
{
   double body1 = rates[index].close - rates[index].open;
   double body2 = rates[index+1].open - rates[index+1].close;

   return(IsRails(index,body1,body2));
}
//+-------------------------------------------------------------------------------------+
//| Determination of the Bear Rails                                                     |
//+-------------------------------------------------------------------------------------+
bool IsBearsRailsPattern(int index)
{
   double body1 = rates[index].open - rates[index].close;
   double body2 = rates[index+1].close - rates[index+1].open;

   return(IsRails(index,body1,body2));
}
//+-------------------------------------------------------------------------------------+
//| Determination of the OVB                                                            |
//+-------------------------------------------------------------------------------------+
bool IsOVBPattern(int index,int type)
{
   if(rates[index].high < rates[index+1].high)
      return(false);

   if(rates[index].low > rates[index+1].low)
      return(false);

   double body1 = rates[index].close - rates[index].open;
   double body2 = rates[index+1].close - rates[index+1].open;

   return ((body1 > 0 && type == BULL_BAR) ||
           (body1 < 0 && type == BEAR_BAR));

}
//+-------------------------------------------------------------------------------------+
//| Determination of the Bull OVB                                                       |
//+-------------------------------------------------------------------------------------+
bool IsBUOVBPattern(int index)
{
   if(rates[index].close <= rates[index+1].high)
      return(false);

   return(IsOVBPattern(index,BULL_BAR));
}
//+-------------------------------------------------------------------------------------+
//| Determination of the Bear OVB                                                       |
//+-------------------------------------------------------------------------------------+
bool IsBEOVBPattern(int index)
{
   if(rates[index].close >= rates[index+1].low)
      return(false);

   return(IsOVBPattern(index,BEAR_BAR));
}
//+-------------------------------------------------------------------------------------+
//| Determination of the Bull Wide Range Bar                                            |
//+-------------------------------------------------------------------------------------+
bool IsBullsWRBPattern(int index)
{
   double body0 = MathAbs(rates[index].close - rates[index].open);
   double body1 = rates[index+1].close - rates[index+1].open;
   double body2 = MathAbs(rates[index+2].close - rates[index+2].open);
   double zazor = rates[index].low - rates[index+2].high;

   if(body0 == 0.0)  return 0;
   if(body1 / body0 < BodyRatio)
      return false;
      
   if(body2 == 0.0) return 0;   
   if(body1 / body2 < BodyRatio)
      return false;
      
   if(rates[index].high <= rates[index+1].high)
      return false;
      
   if(rates[index+2].low >= rates[index +1].low)
      return false;
   
   if(body1 == 0.0) return 0;
   if(zazor / body1 *100.0 < HighLowClearance)
      return false;
        
   return true;
}
//+-------------------------------------------------------------------------------------+
//| Determination of the Bear Wide Range Bar                                            |
//+-------------------------------------------------------------------------------------+
bool IsBearWRBPattern(int index)
{
   double body0 = MathAbs(rates[index].close  - rates[index].open);
   double body1 = rates[index+1].open - rates[index+1].close;
   double body2 = MathAbs(rates[index+2].close - rates[index+2].open);
   double zazor = rates[index+2].low - rates[index].high;
   
    if(body0 == 0.0)  return 0;
   if(body1 / body0 < BodyRatio)
      return false;
      
   if(body2 == 0.0) return 0;      
   if(body1 / body2 < BodyRatio)
      return false;
   
   if(rates[index+2].high <= rates[index+1].high)
      return false;
   
   if(rates[index].low >= rates[index+1].low)
      return false;
   
   if(body1 == 0.0) return 0;
   if(zazor/ body1 *100.0 < HighLowClearance)
      return false; 
            
   return true;
}
//+-------------------------------------------------------------------------------------+
//| Determination of the Bull PPR                                                       |
//+-------------------------------------------------------------------------------------+
bool IsBullsPPRPattern(int index)
{
   if(rates[index].close <= rates[index+1].high)                
      return(false);                               

   if (rates[index+1].low >= rates[index+2].low ||            
       rates[index+1].low >= rates[index].low)              
      return(false);                               

   if (rates[index+2].close >= rates[index+2].open) 
      return(false);                               

   return(true);                                  
}
//+-------------------------------------------------------------------------------------+
//| Determination of the Bear PPR                                                       |
//+-------------------------------------------------------------------------------------+
bool IsBearsPPRPattern(int index)
{
   if(rates[index].close >= rates[index+1].low)
      return(false);

   if (rates[index+1].high <= rates[index+2].high ||
      rates[index+1].high <= rates[index].high)
      return(false);

  if (rates[index+2].close <= rates[index+2].open)
      return(false);

   return(true);
}
//+-------------------------------------------------------------------------------------+
//| Calcilate Bars of equal maxima                                                      |
//+-------------------------------------------------------------------------------------+
bool IsTwoEqualMax(int startIndex, int total, int equalPips, int& patternStart)
{
   int i;
   for (i = startIndex+1; i < total; i++)
      if (MathAbs(rates[i].high - rates[i-1].high) > equalPips*_Point)
         break;
   if (i - startIndex < 2)
      return(false);      
   
   patternStart = i - 1;
   return(true);                         
}
//+-------------------------------------------------------------------------------------+
//| Calulate Bar of equal Minima                                                        |
//+-------------------------------------------------------------------------------------+
bool IsTwoEqualMin(int startIndex, int total, int equalPips, int& patternStart)
{
   int i;
   for (i = startIndex+1; i < total; i++)
      if (MathAbs(rates[i].low - rates[i-1].low) > equalPips*_Point)
         break;
   if (i - startIndex < 2)
      return(false);      
   
   patternStart = i - 1;
   return(true);                         
}
//+-------------------------------------------------------------------------------------+
//| Determination of the Bull DB                                                        |
//+-------------------------------------------------------------------------------------+
bool IsDBHLCPattern(int index, int total, int& patternStart)
{
   if (rates[index].close >= rates[index+1].low)
      return(false);

   if (!IsTwoEqualMax(index, total, equalPipsDB,patternStart))
      return(false);

   return(true);
}
//+-------------------------------------------------------------------------------------+
//| Determination of the Bear DB                                                        |
//+-------------------------------------------------------------------------------------+
bool IsDBLHCPattern(int index, int total, int& patternStart)
{
   if (rates[index].close <= rates[index+1].high)
      return(false);

   if (!IsTwoEqualMin(index, total, equalPipsDB,
                      patternStart)) 
      return(false); 

   return(true);
}
//+-------------------------------------------------------------------------------------+
//| Determination of the Bull TB                                                        |
//+-------------------------------------------------------------------------------------+
bool IsTBHPattern(int index, int total, int& patternStart)
{
   if (rates[index].low < rates[index+1].open)
       return(false);
   
   if (rates[index+1].close <= rates[index+1].open)
      return(false); 

   if (!IsTwoEqualMax(index, total, equalPipsTB, patternStart))
      return(false);
   
   return(true);
}
//+-------------------------------------------------------------------------------------+
//| Determination of the Bear TB                                                        |
//+-------------------------------------------------------------------------------------+
bool IsTBLPattern(int index, int total, int& patternStart)
{
   if (rates[index].high > rates[index+1].open)
       return(false);
   
   if (rates[index+1].close >= rates[index+1].open)
      return(false);

   if (!IsTwoEqualMin(index, total, equalPipsTB,patternStart))
      return(false);

   return(true);
}
//+-----------------------------------------------------------------------------+
//| Create DataBase of the Patterns                                             |
//+-----------------------------------------------------------------------------+
bool FindPatternsAndFillDB(int index, int total)
{
   ENUM_PATTERN_TYPE newPattern    = NONE_TYPE;
   ENUM_PATTEN_NAME newPatternName = NONE_INDEX;
   int startBar = index;
   int endBar   = index;
   color patternColor = clrNONE;
   
//== Найдем паттерны на текущем баре
   if (IsShowPINBARpattern == YES)
     {
      if(IsBullsPINBAR(index))
        {
         newPattern     = BULL_TYPE;
         newPatternName = PINBAR_PATTERN_;
         startBar       = index + 1;
        }
      if(IsBearsPINBAR(index))
        {
         newPattern     = BEAR_TYPE;
         newPatternName = PINBAR_PATTERN_;
         startBar       = index + 1;
        }
     }
  
   if (IsShowWRBPattern == YES && newPatternName == NONE_INDEX)
      {
       if(IsBullsWRBPattern(index))
         {
          newPattern     = BULL_TYPE;
          newPatternName = WRB_PATTERN_;
          startBar       = index + 2;
         }
       if(IsBearWRBPattern(index))
         {
          newPattern     = BEAR_TYPE;
          newPatternName = WRB_PATTERN_;
          startBar       = index + 2;
         }
      }
   if (IsShowPPRPattern == YES && newPatternName == NONE_INDEX)
      {
       if(IsBullsPPRPattern(index))
         {
          newPattern     = BULL_TYPE;
          newPatternName = PPR_PATTERN_;
          startBar       = index + 2;
         }
       if(IsBearsPPRPattern(index))
         {
          newPattern     = BEAR_TYPE;
          newPatternName = PPR_PATTERN_;
          startBar       = index + 2;
         }
      }
   if(IsShowOVBPattern && newPatternName == NONE_INDEX)
      {
        if(IsBUOVBPattern(index))
          {
           newPattern     = BULL_TYPE;
           newPatternName = OVB_PATTERN_;
           startBar       = index + 1;
          }
        if(IsBEOVBPattern(index))
          {
           newPattern     = BEAR_TYPE;
           newPatternName = OVB_PATTERN_;
           startBar       = index + 1;
          }
      }
   if (IsShowRailsPattern == YES && newPatternName == NONE_INDEX)
     {
      if(IsBullsRailsPattern(index))
        {
         newPattern     = BULL_TYPE;
         newPatternName = RAILS_PATTERN_;
         startBar       = index + 1;
        }
      if(IsBearsRailsPattern(index))
        {
         newPattern     = BEAR_TYPE;
         newPatternName = RAILS_PATTERN_;
         startBar       = index + 1;
        }
     }
   if(showTBpattern == YES && newPatternName == NONE_INDEX)
     {
      if(IsTBHPattern(index,total, startBar))
        {
         newPattern     = BEAR_TYPE;
         newPatternName = TB_PATTERN_;
         startBar       = index + 1;
        }
      if(IsBearsRailsPattern(index))
        {
         newPattern     = BULL_TYPE;
         newPatternName = TB_PATTERN_;
         startBar       = index + 1;
        }
     }
   if (showDBpattern == YES && newPatternName == NONE_INDEX)
     {
      if(IsDBLHCPattern(index,total,startBar))
        {
         newPattern     = BULL_TYPE;
         newPatternName = DB_PATTERN_;
         startBar       = index +1;
        }
      if(IsDBHLCPattern(index,total,startBar))
        {
         newPattern     = BEAR_TYPE;
         newPatternName = DB_PATTERN_;
         startBar       = index+1;
        }
     }
   if (newPatternName == NONE_INDEX)
      return true;  
      
   double lowPrice                  = rates[iLowest_(NULL,0,MODE_LOW,// Нижняя граница паттерна
                                                 startBar-endBar+1,endBar)].low;
   double highPrice                 = rates[iHighest_(NULL,0,MODE_HIGH,// Верхняя граница паттерна
                                                 startBar-endBar+1,endBar)].high;

   if (OverlapingPattern == NO)
      if (IsPatternOverlapsAnother(rates[startBar].time))
         return true;

   int patternArray = ArraySize(g_patterns); 
   if(ArrayResize(g_patterns,patternArray + 1, ARRAY_RESERVE_SIZE) < 0)
   {
        Alert(g_isRussianLang?
             ": Недостаточно памяти для продолжения работы программы. Индикатор отключен.":
             ": Not enough memory to continue work the program. Indicator is turned off.");
        return false;
   }

   g_patterns[patternArray].rightTime         = rates[endBar].time;
   g_patterns[patternArray].leftTime          = rates[startBar].time;
   g_patterns[patternArray].patternType       = newPattern;
   g_patterns[patternArray].patternName       = newPatternName;
   g_patterns[patternArray].patternHighPrice  = highPrice;
   g_patterns[patternArray].patternLowPrice   = lowPrice;
   g_patterns[patternArray].patternColor      = PatternColor(g_patterns[patternArray],patternColor);

   ShowPatterns(g_patterns[patternArray]);
  
   return true;
}
//+-------------------------------------------------------------------------------------+
//| Pattern Color                                                                       |
//+-------------------------------------------------------------------------------------+
color PatternColor(Pattern &pattern, color clr)
{
   if(pattern.patternName == PPR_PATTERN_)
    return (pattern.patternType == BEAR_TYPE)? colorBearsPPR : colorBullsPPR;
   
   if(pattern.patternName == WRB_PATTERN_)
    return (pattern.patternType == BEAR_TYPE)? colorBearsWRB : colorBullsWRB;
   
   if(pattern.patternName == TB_PATTERN_)
    if(pattern.patternType == BEAR_TYPE || pattern.patternType == BULL_TYPE) 
      return colorTB;
    
   if(pattern.patternName == DB_PATTERN_) 
      return (pattern.patternType == BEAR_TYPE)? colorDBHLC: colorDBLHC;
      
   if(pattern.patternName == PINBAR_PATTERN_) 
      return (pattern.patternType == BEAR_TYPE)? colorBearsPINBAR: colorBullsPINBAR;
      
   if(pattern.patternName == OVB_PATTERN_) 
      return (pattern.patternType == BEAR_TYPE)? colorBEOVB: colorBUOVB;  
      
   if(pattern.patternName == RAILS_PATTERN_) 
      return (pattern.patternType == BEAR_TYPE)? colorBearsRails: colorBullsRails;
   
   return clr;
}
//+-------------------------------------------------------------------------------------+
//| ToolTips of the patter                                                              |
//+-------------------------------------------------------------------------------------+
string GetUniqueID(const Pattern  &pattern,string middlePart)
{
     return(PREFIX + EnumToString(pattern.patternName)+
            EnumToString(pattern.patternType)+"\n"+
            middlePart+TimeToString(pattern.rightTime));
}
//+-----------------------------------------------------------------------------+
//| Delete objects                                                               |
//+-----------------------------------------------------------------------------+
void DeletePattern(const Pattern& pattern)
{
   string name = GetUniqueID(pattern, FIRST_PART);
   if (ObjectFind(0, name) == 0)
      ObjectDelete(0, name);
}
//+-----------------------------------------------------------------------------+
//| Displaing the pattern                                                       |
//+-----------------------------------------------------------------------------+
void ShowPatterns(const Pattern& pattern)
{
       string name = GetUniqueID(pattern,FIRST_PART);
       ShowRectangle(name,pattern.leftTime,pattern.patternLowPrice,
                          pattern.rightTime,pattern.patternHighPrice,
                          "",pattern.patternColor);
}
//+-----------------------------------------------------------------------------+
//| Deleting the specified element from specified array                         |
//+-----------------------------------------------------------------------------+
template<typename T>
int DeleteElementFromArray(T &array[], int elementToDelete)
{
   int arraySize = ArraySize(array);
   if (arraySize == 0)
      return 0;
      
   array[elementToDelete] = array[arraySize - 1];
   return ArrayResize(array, arraySize - 1, ARRAY_RESERVE_SIZE);
}
//+-----------------------------------------------------------------------------+
//| Process on overlaped pattern                                                |
//+-----------------------------------------------------------------------------+
bool IsPatternOverlapsAnother(datetime dtLeftTime)
{
   for (int i = ArraySize(g_patterns) - 1; i >= 0; i--)
      if (dtLeftTime < g_patterns[i].rightTime && dtLeftTime >= g_patterns[i].leftTime) 
         return true;
         
   return false;
}
//+-------------------------------------------------------------------------------------+
//| Displaying of indicators values                                                     |
//+-------------------------------------------------------------------------------------+
bool ShowIndicatorData(int limit, int total)
{
   for (int i = limit; i > 0; i--)
   { 
     
      if (!FindPatternsAndFillDB(i,total))
         return false;
   }

   return true;
}
//+-------------------------------------------------------------------------------------+
//| Custom indicator iteration function                                                 |
//+-------------------------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   if (!g_bIsActivate)
      return rates_total;
   
      ArraySetAsSeries(rates,true);
      CopyRates(Symbol(),PERIOD_CURRENT,0,rates_total,rates); 
   
      int total;
   
      int limit =  GetRecalcIndex(total, rates_total, prev_calculated);
   
      if (!ShowIndicatorData(limit,total))
      {
         g_bIsActivate = false;
         OnDeinit(REASON_PROGRAM);
         return rates_total;
        
      ChartRedraw();
    }
   return rates_total;
}
//+------------------------------------------------------------------+
