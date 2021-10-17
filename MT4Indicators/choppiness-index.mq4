
//+------------------------------------------------------------------+
//|                                             Choppiness Index.mq4 |
//|                                    Copyright © 2009, David Moser |
//|                                               dmoser71@gmail.com |
//+------------------------------------------------------------------+

#property copyright ""
#property link      ""

// This Indicator is NEVER to be SOLD individually 
// This Indicator is NEVER to be INCLUDED as part of a collection that is SOLD

//---- common control defaults
#property indicator_separate_window
#property indicator_minimum 0
#property indicator_maximum 100
#property indicator_buffers 3
#property indicator_color1 Yellow
#property indicator_width1 2
#property indicator_style1 0
#property indicator_color2 Red
#property indicator_width2 1
#property indicator_style2 0
#property indicator_color3 Red
#property indicator_width3 1
#property indicator_style3 0
#property indicator_level1  38.2
#property indicator_level2  61.8
#property indicator_levelstyle 2
#property indicator_levelcolor Silver
 
//---- indicator parameters
// Main Parameters
extern int ChoppinessPeriod=14;        // Number of bars to evaluation CI
extern int SmoothingPeriod=1;          // Number of bars to apply SMA
extern int StdDevPeriod=14;            // Number of bars to evaluate Standard Deviation of the CI
extern bool StdDevFollowPrice=false;   // True, StdDev bars follow price, False, StdDev bars centered on 50
extern bool EnableAlertOnHigh=false;   // Alert setting for entering time of choppiness
extern double AlertHighVal=61.8;       // Default value based on fib numbers
extern bool EnableAlertOnLow=false;    // Alert setting for entering time of trending
extern double AlertLowVal=38.2;        // Default value based on fib numbers
extern int MaxCalcBars=1000;           // Limit calculations back this many bars

//---- indicator buffers
double ExtMapBuffer[];
double StdDevHiBuffer[];
double StdDevLoBuffer[];
double IntMapBuffer[];
double IntStdDevBuffer[];

//---- variables
string TimeFrame;
datetime LastAlert=0;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
 
   IndicatorBuffers(5);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,ExtMapBuffer);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,StdDevHiBuffer);
   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,StdDevLoBuffer);
   SetIndexBuffer(3,IntMapBuffer);
   SetIndexBuffer(4,IntStdDevBuffer);
   
   if (ChoppinessPeriod<2) ChoppinessPeriod = 2;   // Any lower and this indicator isn't relevant
   if (SmoothingPeriod<1) SmoothingPeriod = 1;     // Avoid configuration errors
   if (StdDevPeriod<2) StdDevPeriod = 2;           // Any lower and the Standard Deviation isn't relevant
   if (MaxCalcBars>10000) MaxCalcBars = 10000;     // Any higher and may adversely affect performance on multi-chart setups
   
   SetIndexDrawBegin(0,ChoppinessPeriod+SmoothingPeriod);
   SetIndexDrawBegin(1,ChoppinessPeriod+SmoothingPeriod+StdDevPeriod);
   SetIndexDrawBegin(2,ChoppinessPeriod+SmoothingPeriod+StdDevPeriod);
   
   string short_name="Choppiness Index ("+ChoppinessPeriod+","+SmoothingPeriod+","+StdDevPeriod+")";
   IndicatorShortName(short_name);

   switch (Period())
     {
     case     1: TimeFrame = "M1";  break;
     case     5: TimeFrame = "M5";  break;
     case    15: TimeFrame = "M15"; break;
     case    30: TimeFrame = "M30"; break;
     case    60: TimeFrame = "H1";  break;
     case   240: TimeFrame = "H4";  break;
     case  1440: TimeFrame = "D1";  break;
     case 10080: TimeFrame = "W1";  break;
     case 43200: TimeFrame = "MN";  break;
   }

//---- initial zero
   for(int i=0;i<=Bars;i++) ExtMapBuffer[i]=0;  // Smoothed & visible main indicator line
   for(i=0;i<=Bars;i++) StdDevHiBuffer[i]=0;    // Upper StdDev band, visible
   for(i=0;i<=Bars;i++) StdDevLoBuffer[i]=0;    // Lower StdDev band, visible
   for(i=0;i<=Bars;i++) IntMapBuffer[i]=0;      // Raw CI, not smoothed, not visible
   for(i=0;i<=Bars;i++) IntStdDevBuffer[i]=0;   // Raw StdDev of Smoothed & visible main indicator line (ExtMapBuffer)

   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
  int counted_bars=IndicatorCounted();
  int z,limit;
  double bufferTemp1, bufferTemp2;

  if (counted_bars<0) return(-1); 
  if (counted_bars>0) counted_bars--; 
  limit=Bars-counted_bars;
  if (limit>MaxCalcBars) limit=MaxCalcBars;
  
  for (int i=limit-1; i>=0; i--) 
    {
    IntMapBuffer[i] = ChoppinessIndex(ChoppinessPeriod,i);
    bufferTemp1 = 0;
    for(int j=0; j<SmoothingPeriod; j++) { z=i+j; bufferTemp1 += IntMapBuffer[z]; }
    ExtMapBuffer[i] = bufferTemp1 / SmoothingPeriod;
    IntStdDevBuffer[i] = StdDev(i,StdDevPeriod);
    bufferTemp1 = 0;
    bufferTemp2 = 0;
    for(int n=0; n<StdDevPeriod; n++)
      {
      z=i+n;
      if (StdDevFollowPrice)
        {
        bufferTemp1 += ExtMapBuffer[z];
        bufferTemp2 += ExtMapBuffer[z];
        }
      else
        {
        bufferTemp1 += 50;
        bufferTemp2 += 50;
        }
      bufferTemp1 += IntStdDevBuffer[i]*2;
      bufferTemp2 -= IntStdDevBuffer[i]*2;
      }
    StdDevHiBuffer[i] = bufferTemp1 / StdDevPeriod;
    StdDevLoBuffer[i] = bufferTemp2 / StdDevPeriod;
    }

    if (EnableAlertOnHigh)
      if (LastAlert != Time[0])
        if ((ExtMapBuffer[1]>AlertHighVal) && (ExtMapBuffer[2]<AlertHighVal))
          {
          LastAlert = Time[0]; // No more alerts on the current bar
          Alert(Symbol()+","+TimeFrame+":Choppiness greater than "+DoubleToStr(AlertHighVal,1));
          }
    
    if (EnableAlertOnLow)
      if (LastAlert != Time[0])
        if ((ExtMapBuffer[1]<AlertLowVal) && (ExtMapBuffer[2]>AlertLowVal))
          {
          LastAlert = Time[0]; // No more alerts on the current bar
          Alert(Symbol()+","+TimeFrame+":Choppiness less than "+DoubleToStr(AlertLowVal,1));
          }

  return(0);
  }
  
  
double ChoppinessIndex(int period, int bar)
  {
    double Low0 = 0, High0 = 0, Close1 = 0;
    double TrueRangeLow = 0, TrueRangeHigh = 0, TrueRangeSum = 0, Input = 0;
    double PeriodTrueRangeLow = 999999999, PeriodTrueRangeHigh = 0, PeriodTrueRange = 0;

    for(int k=bar; k<bar+period; k++)
    {
      Low0   = iLow(NULL,0,k);
      High0  = iHigh(NULL,0,k);
      Close1 = iClose(NULL,0,k+1);

      if (Low0<Close1)  TrueRangeLow  = Low0;  else TrueRangeLow  = Close1;
      if (High0>Close1) TrueRangeHigh = High0; else TrueRangeHigh = Close1;
      
      if (TrueRangeLow <PeriodTrueRangeLow)  PeriodTrueRangeLow  = TrueRangeLow;  // find true low of period
      if (TrueRangeHigh>PeriodTrueRangeHigh) PeriodTrueRangeHigh = TrueRangeHigh; // find true high of period

      TrueRangeSum += TrueRangeHigh;
      TrueRangeSum -= TrueRangeLow;
    }

    PeriodTrueRange = PeriodTrueRangeHigh - PeriodTrueRangeLow;
    if (PeriodTrueRange==0) PeriodTrueRange = MathPow(10, -12); // avoid possibility of division by zero
    Input = TrueRangeSum / PeriodTrueRange;
    return ((logN(Input, 10, MathPow(10, -12)) / logN(period, 10, MathPow(10, -12))) * 100);
  }
  

double logN(double x, double base, double epsilon)
  {
    double integer = 0.0;
    if ((x < 1) || (base < 1)) return(0);

    while (x < 1)
    {
      integer -= 1;
      x *= base;
    }
  
    while (x >= base)
    {
      integer += 1;
      x /= base;
    }
  
    double partial = 0.5;
    x *= x;
    double decimal = 0.0;

    while (partial > epsilon)
    {
      if (x >= base)
      {
        decimal += partial;
        x = x / base;
      }
      partial *= 0.5;
      x *= x;
    }
    
    return (integer + decimal);
  } 


double StdDev(int shift, int samples)
  {
  double x0=0, x1=0, x2=0;
  for (int m=0; m<samples; m++)
    {
    x0 = ExtMapBuffer[m+shift];
    x1 += x0;
    x2 += MathPow(x0,2);
    }
  return(MathSqrt((x2-(x1*x1/samples))/(samples-1))); // minimum samples is 2, enforced in the init section
  }