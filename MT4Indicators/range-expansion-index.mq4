//+------------------------------------------------------------------+
//|                                          RangeExpansionIndex.mq4 |
//|                                  Copyright © 2010, EarnForex.com |
//|                                        http://www.earnforex.com/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2010, EarnForex.com"
#property link      "http://www.earnforex.com"

/*
   Calculates Tom DeMark's Range Expansion Index.
   Going above 60 and then dropping below 60 signals price weakness.
   Going below -60 and the rising above -60 signals price strength.
   For more info see The New Science of Technical Analysis.
*/   

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Blue
#property indicator_width1 1
#property indicator_style1 STYLE_SOLID
#property indicator_level1 60
#property indicator_level2 -60

extern int REI_Period = 8;

// Buffers
double REI[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
   IndicatorBuffers(1);   
   IndicatorShortName("REI (" + REI_Period + ")");

   SetIndexBuffer(0, REI);
   SetIndexStyle(0, DRAW_LINE);
   SetIndexDrawBegin(0, REI_Period + 8);

   return(0);
}

//+------------------------------------------------------------------+
//| Range Expansion Index                                            |
//+------------------------------------------------------------------+
int start()
{
   if (Bars <= 8 + REI_Period) return(0);

   int counted_bars = IndicatorCounted();
   if (counted_bars > 0) counted_bars--;
   int limit = Bars - counted_bars;   

   for(int i = 0; i <= limit; i++)
   {      
      double SubValueSum = 0;
      double AbsDailyValueSum = 0;   
      for(int j = 0; j < REI_Period; j++)
      {   
         SubValueSum += SubValue(i + j);         
         AbsDailyValueSum += AbsDailyValue(i + j);
      }
      if (AbsDailyValueSum != 0) REI[i] = SubValueSum / AbsDailyValueSum * 100;
      else REI[i] = 0;
   }

   return(0);
}

//+------------------------------------------------------------------+
//| Calculate the Conditional Value                                  |
//+------------------------------------------------------------------+
double SubValue(int i)
{
   double diff1 = High[i] - High[i + 2];
   double diff2 = Low[i] - Low[i + 2];
   int num_zero1, num_zero2;
   
   if ((High[i + 2] < Close[i + 7]) && (High[i + 2] < Close[i + 8]) && (High[i] < High[i + 5]) && (High[i] < High[i + 6]))
      num_zero1 = 0;
   else
      num_zero1 = 1;
   
   if ((Low[i + 2] > Close[i + 7]) && (Low[i + 2] > Close[i + 8]) && (Low[i] > Low[i + 5]) && (Low[i] > Low[i + 6]))
      num_zero2 = 0;
   else
      num_zero2 = 1;
   
   return(num_zero1 * num_zero2 * (diff1 + diff2));
}

//+------------------------------------------------------------------+
//| Calculate the Absolute Value                                     |
//+------------------------------------------------------------------+
double AbsDailyValue(int i = 0)
{
   double diff1 = MathAbs(High[i] - High[i + 2]);
   double diff2 = MathAbs(Low[i] - Low[i + 2]);
   
   return(diff1 + diff2);
}
//+------------------------------------------------------------------+