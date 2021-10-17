//+------------------------------------------------------------------+
//|                                                 Momentum_Div.mq4 |
//+------------------------------------------------------------------+
#property copyright ""
#property link      ""
//----
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1 Blue
#property indicator_color2 Green
#property indicator_color3 Red
#property indicator_width1 1
#property indicator_width2 2
#property indicator_width3 2

//---- input parameters
extern string    separator1 = "*** Momentum Settings ***";
extern int       MomPeriod = 8;
extern string    separator2 = "0=Close, 1=Open, 2=High, 3=Low, 4=Median, 5=Typical, 6= Weighted";
extern int       MomPrice = 0;
extern string    separator3 = "*** Indicator Settings ***";
extern bool      drawDivergenceLines = true;
extern bool      displayAlert = false;
//---- buffers
double Momentum[];
double bullishDivergence[];
double bearishDivergence[];
double MomDiv[];
//----
static datetime lastAlertTime;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0, DRAW_LINE, STYLE_SOLID, 0);
   SetIndexStyle(1, DRAW_ARROW, STYLE_SOLID, 0);
   SetIndexStyle(2, DRAW_ARROW, STYLE_SOLID, 0);
   SetIndexStyle(3, DRAW_NONE);
//----   
   SetIndexBuffer(0, Momentum);
   SetIndexBuffer(1, bullishDivergence);
   SetIndexBuffer(2, bearishDivergence);
   SetIndexBuffer(3, MomDiv);
//----   
   SetIndexArrow(1, 233);
   SetIndexArrow(2, 234);
//----
   IndicatorDigits(Digits + 2);
   IndicatorShortName("Momentum_Div(" + MomPeriod + ")");
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
   for(int i = ObjectsTotal() - 1; i >= 0; i--)
     {
       string label = ObjectName(i);
       if(StringSubstr(label, 0, 14) != "DivergenceLine")
           continue;
       ObjectDelete(label);   
     }
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int countedBars = IndicatorCounted();
   if(countedBars < 0)
       countedBars = 0;
   CalculateIndicator(countedBars);
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CalculateIndicator(int countedBars)
  {
   for(int i = Bars - countedBars; i >= 0; i--)
     {
      CalculateMomDiv(i);
      CatchBullishDivergence(i + 2);
      CatchBearishDivergence(i + 2);
     }              
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CalculateMomDiv(int i)
  {
   Momentum[i] = iMomentum(NULL, 0, MomPeriod, MomPrice, i);
   MomDiv[i] = Momentum[i];
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CatchBullishDivergence(int shift)
  {
   if(IsIndicatorTrough(shift) == false)
       return;
   int currentTrough = shift;
   int lastTrough = GetIndicatorLastTrough(shift);
   if(MomDiv[currentTrough] > MomDiv[lastTrough] && Low[currentTrough] < Low[lastTrough])
     {
      bullishDivergence[currentTrough] = MomDiv[currentTrough];
      if(drawDivergenceLines == true)
        {
          DrawPriceTrendLine(Time[currentTrough], Time[lastTrough], Low[currentTrough], 
                             Low[lastTrough], Green, STYLE_SOLID);
          DrawIndicatorTrendLine(Time[currentTrough], Time[lastTrough], MomDiv[currentTrough],
                                 MomDiv[lastTrough], Green, STYLE_SOLID);
        }
      if(displayAlert == true)
          DisplayAlert("Classical bullish divergence on: ", currentTrough);  
     }
   if(MomDiv[currentTrough] < MomDiv[lastTrough] && Low[currentTrough] > Low[lastTrough])
     {
      bullishDivergence[currentTrough] = MomDiv[currentTrough];
      if(drawDivergenceLines == true)
        {
          DrawPriceTrendLine(Time[currentTrough], Time[lastTrough], Low[currentTrough], 
                             Low[lastTrough], Green, STYLE_DOT);
          DrawIndicatorTrendLine(Time[currentTrough], Time[lastTrough], MomDiv[currentTrough],
                                 MomDiv[lastTrough], Green, STYLE_DOT);
        }
      if(displayAlert == true)
          DisplayAlert("Reverse bullish divergence on: ", currentTrough);   
     }      
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CatchBearishDivergence(int shift)
  {
   if(IsIndicatorPeak(shift) == false)
       return;
   int currentPeak = shift;
   int lastPeak = GetIndicatorLastPeak(shift);
   
   if(MomDiv[currentPeak] < MomDiv[lastPeak] && High[currentPeak] > High[lastPeak])
     {
       bearishDivergence[currentPeak] = MomDiv[currentPeak];
       if(drawDivergenceLines == true)
         {
           DrawPriceTrendLine(Time[currentPeak], Time[lastPeak], High[currentPeak], 
                              High[lastPeak], Red, STYLE_SOLID);
           DrawIndicatorTrendLine(Time[currentPeak], Time[lastPeak], MomDiv[currentPeak],
                                  MomDiv[lastPeak], Red, STYLE_SOLID);
         }
       if(displayAlert == true)
           DisplayAlert("Classical bearish divergence on: ", currentPeak);  
     }
   if(MomDiv[currentPeak] > MomDiv[lastPeak] && High[currentPeak] < High[lastPeak])
     {
       bearishDivergence[currentPeak] = MomDiv[currentPeak];
       if(drawDivergenceLines == true)
         {
           DrawPriceTrendLine(Time[currentPeak], Time[lastPeak], High[currentPeak], 
                              High[lastPeak], Red, STYLE_DOT);
           DrawIndicatorTrendLine(Time[currentPeak], Time[lastPeak], MomDiv[currentPeak],
                                  MomDiv[lastPeak], Red, STYLE_DOT);
         }
       if(displayAlert == true)
           DisplayAlert("Reverse bearish divergence on: ", currentPeak);   
     }   
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsIndicatorPeak(int shift)
  {
   if(MomDiv[shift] >= MomDiv[shift+1] && MomDiv[shift] > MomDiv[shift+2] && 
      MomDiv[shift] > MomDiv[shift-1])
       return(true);
   else 
       return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsIndicatorTrough(int shift)
  {
   if(MomDiv[shift] <= MomDiv[shift+1] && MomDiv[shift] < MomDiv[shift+2] && 
      MomDiv[shift] < MomDiv[shift-1])
       return(true);
   else 
       return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int GetIndicatorLastPeak(int shift)
  {
   for(int i = shift + 5; i < Bars; i++)
     {
       if(Momentum[i] >= Momentum[i+1] && Momentum[i] >= Momentum[i+2] &&
          Momentum[i] >= Momentum[i-1] && Momentum[i] >= Momentum[i-2])
         {
           for(int j = i; j < Bars; j++)
             {
               if(MomDiv[j] >= MomDiv[j+1] && MomDiv[j] > MomDiv[j+2] &&
                  MomDiv[j] >= MomDiv[j-1] && MomDiv[j] > Momentum[j-2])
                   return(j);
             }
         }
     }
   return(-1);  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int GetIndicatorLastTrough(int shift)
  {  
    for(int i = shift + 5; i < Bars; i++)
      {
        if(Momentum[i] <= Momentum[i+1] && Momentum[i] <= Momentum[i+2] &&
           Momentum[i] <= Momentum[i-1] && Momentum[i] <= Momentum[i-2])
          {
            for (int j = i; j < Bars; j++)
              {
                if(MomDiv[j] <= MomDiv[j+1] && MomDiv[j] < MomDiv[j+2] &&
                   MomDiv[j] <= MomDiv[j-1] && MomDiv[j] < MomDiv[j-2])
                    return(j);
              }
          }
      }
    return(-1);  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DisplayAlert(string message, int shift)
  {
   if(shift <= 2 && Time[shift] != lastAlertTime)
     {
       lastAlertTime = Time[shift];
       Alert(message, Symbol(), " , ", Period(), " minutes chart");
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawPriceTrendLine(datetime x1, datetime x2, double y1, 
                        double y2, color lineColor, double style)
  {
   string label = "DivergenceLine2.1# " + DoubleToStr(x1, 0);
   ObjectDelete(label);
   ObjectCreate(label, OBJ_TREND, 0, x1, y1, x2, y2, 0, 0);
   ObjectSet(label, OBJPROP_RAY, 0);
   ObjectSet(label, OBJPROP_COLOR, lineColor);
   ObjectSet(label, OBJPROP_STYLE, style);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawIndicatorTrendLine(datetime x1, datetime x2, double y1, 
                            double y2, color lineColor, double style)
  {
   int indicatorWindow = WindowFind("Momentum_Div(" + MomPeriod + ")");
   if(indicatorWindow < 0)
       return;
   string label = "DivergenceLine2.1$# " + DoubleToStr(x1, 0);
   ObjectDelete(label);
   ObjectCreate(label, OBJ_TREND, indicatorWindow, x1, y1, x2, y2, 0, 0);
   ObjectSet(label, OBJPROP_RAY, 0);
   ObjectSet(label, OBJPROP_COLOR, lineColor);
   ObjectSet(label, OBJPROP_STYLE, style);
  }
//+------------------------------------------------------------------+



