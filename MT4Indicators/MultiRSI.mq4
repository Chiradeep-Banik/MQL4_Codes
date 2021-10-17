//+------------------------------------------------------------------+
//|                                                     MultiRSI.mq4 |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.1"
#property strict

#property indicator_separate_window
#property indicator_plots   7
#property indicator_buffers 7

input bool                 PeriodM1  = false;            // 1 Minute
input bool                 PeriodM5  = false;            // 5 Minutes
input bool                 PeriodM15 = false;            // 15 Minutes
input bool                 PeriodM30 = false;            // 30 Minutes
input bool                 PeriodH1  = false;            // 1 Hour
input bool                 PeriodH4  = false;            // 4 Hours
input bool                 PeriodD1  = false;            // 1 Day
input int                  PeriodRSI = 14;               // RSI Period
input ENUM_APPLIED_PRICE   AppliedPrice = PRICE_CLOSE;   // RSI Applied Price

double M1Buffer[];
double M5Buffer[];
double M15Buffer[];
double M30Buffer[];
double H1Buffer[];
double H4Buffer[];
double D1Buffer[];
int shiftArray[indicator_plots];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0,M1Buffer);
   SetIndexBuffer(1,M5Buffer);
   SetIndexBuffer(2,M15Buffer);
   SetIndexBuffer(3,M30Buffer);
   SetIndexBuffer(4,H1Buffer);
   SetIndexBuffer(5,H4Buffer);
   SetIndexBuffer(6,D1Buffer);

   SetIndexLabel(0,"RSI(M1)");
   SetIndexLabel(1,"RSI(M5)");
   SetIndexLabel(2,"RSI(M15)");
   SetIndexLabel(3,"RSI(M30)");
   SetIndexLabel(4,"RSI(H1)");
   SetIndexLabel(5,"RSI(H4)");
   SetIndexLabel(6,"RSI(D1)");

   SetIndexEmptyValue(0,EMPTY_VALUE);
   SetIndexEmptyValue(1,EMPTY_VALUE);
   SetIndexEmptyValue(2,EMPTY_VALUE);
   SetIndexEmptyValue(3,EMPTY_VALUE);
   SetIndexEmptyValue(4,EMPTY_VALUE);
   SetIndexEmptyValue(5,EMPTY_VALUE);
   SetIndexEmptyValue(6,EMPTY_VALUE);

   if(PeriodM1) SetIndexStyle(0,DRAW_LINE,STYLE_SOLID,1,clrRed); else SetIndexStyle(0,DRAW_NONE);
   if(PeriodM5) SetIndexStyle(1,DRAW_LINE,STYLE_SOLID,1,clrOrange); else SetIndexStyle(1,DRAW_NONE);
   if(PeriodM15) SetIndexStyle(2,DRAW_LINE,STYLE_SOLID,1,clrGold); else SetIndexStyle(2,DRAW_NONE);
   if(PeriodM30) SetIndexStyle(3,DRAW_LINE,STYLE_SOLID,1,clrLime); else SetIndexStyle(3,DRAW_NONE);
   if(PeriodH1) SetIndexStyle(4,DRAW_LINE,STYLE_SOLID,1,clrAqua); else SetIndexStyle(4,DRAW_NONE);
   if(PeriodH4) SetIndexStyle(5,DRAW_LINE,STYLE_SOLID,1,clrBlue); else SetIndexStyle(5,DRAW_NONE);
   if(PeriodD1) SetIndexStyle(6,DRAW_LINE,STYLE_SOLID,1,clrPurple); else SetIndexStyle(6,DRAW_NONE);

   IndicatorSetDouble(INDICATOR_MINIMUM,0.0);
   IndicatorSetDouble(INDICATOR_MAXIMUM,100.0);

   IndicatorSetInteger(INDICATOR_LEVELS,3);
   IndicatorSetDouble(INDICATOR_LEVELVALUE, 0, 30.0);
   IndicatorSetDouble(INDICATOR_LEVELVALUE, 1, 50.0);
   IndicatorSetDouble(INDICATOR_LEVELVALUE, 2, 70.0);
   IndicatorDigits((int)MarketInfo(Symbol(),MODE_DIGITS));

   string timeFrames=NULL;
   if(PeriodM1) timeFrames += (PeriodM1 ? "M1" : NULL);
   if(PeriodM5) timeFrames += (timeFrames == NULL ? "M5" : ",M5");
   if(PeriodM15) timeFrames += (timeFrames == NULL ? "M15" : ",M15");
   if(PeriodM30) timeFrames += (timeFrames == NULL ? "M30" : ",M30");
   if(PeriodH1) timeFrames += (timeFrames == NULL ? "H1" : ",H1");
   if(PeriodH4) timeFrames += (timeFrames == NULL ? "H4" : ",H4");
   if(PeriodD1) timeFrames += (timeFrames == NULL ? "D1" : ",D1");
   IndicatorShortName(StringFormat("MultiRSI[%s](%d)",(timeFrames==NULL ? "none" : timeFrames),PeriodRSI));

   ArrayInitialize(shiftArray,0);

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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
   if(rates_total <= PeriodRSI) return(0);
   int limit=rates_total-prev_calculated;
   if(prev_calculated>0)
     {
      limit+=(PeriodD1 ? PERIOD_D1 :(PeriodH4 ? PERIOD_H4 :(PeriodH1 ? PERIOD_H1 :(PeriodM30 ? PERIOD_M30 :(PeriodM15 ? PERIOD_M15 :(PeriodM5 ? PERIOD_M5 : PERIOD_M1))))));
     }

   for(int i=0; i<limit; i++)
     {
      M1Buffer[i] = (PeriodM1 ? getRSI(shiftArray, 0, PERIOD_M1, time[i]) : EMPTY_VALUE);
      M5Buffer[i] = (PeriodM5 ? getRSI(shiftArray, 1, PERIOD_M5, time[i]) : EMPTY_VALUE);
      M15Buffer[i] = (PeriodM15 ? getRSI(shiftArray, 2, PERIOD_M15, time[i]) : EMPTY_VALUE);
      M30Buffer[i] = (PeriodM30 ? getRSI(shiftArray, 3, PERIOD_M30, time[i]) : EMPTY_VALUE);
      H1Buffer[i] = (PeriodH1 ? getRSI(shiftArray, 4, PERIOD_H1, time[i]) : EMPTY_VALUE);
      H4Buffer[i] = (PeriodH4 ? getRSI(shiftArray, 5, PERIOD_H4, time[i]) : EMPTY_VALUE);
      D1Buffer[i] = (PeriodD1 ? getRSI(shiftArray, 6, PERIOD_D1, time[i]) : EMPTY_VALUE);
     }

   return(rates_total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double getRSI(int &_array[],int _ind,int _tf,datetime _time)
  {
   double result=0.0;
   int shift=iBarShift(NULL,_tf,_time,false);
   if(_array[_ind]!=shift || shift==0) _array[_ind]=shift;
   result=iRSI(NULL,_tf,PeriodRSI,AppliedPrice,_array[_ind]);
   return(result > Point ? result : EMPTY_VALUE);
  }
//+------------------------------------------------------------------+
