//+------------------------------------------------------------------+
//|                                                      LRMA_BB.mq4 |
//|                      Copyright © 2006, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright ""
#property link      ""

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 BlueViolet // main line
#property indicator_color2 DodgerBlue // upper band
#property indicator_color3 DodgerBlue // lower band
//---- input parameters
extern int LRMA_Period   = 30;
extern bool BandsEnabled = true;
extern double BandsDev   = 1.0;
//---- buffers
double LRMABuffer[];
double UpperBandBuffer[];
double LowerBandBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
 {
  if (LRMA_Period <= 1) // fool-proof & to prevent zero divide error
   { LRMA_Period = 2; } 
 //---- indicators
  IndicatorDigits(Digits);
  //
  SetIndexStyle(0, DRAW_LINE);
  SetIndexBuffer(0, LRMABuffer);
  SetIndexLabel(0, "LRMA Line");
  SetIndexDrawBegin(0, LRMA_Period);
  //
  if (BandsEnabled == true) // initialize Bollinger Bands buffers
  {
   SetIndexStyle(1, DRAW_LINE);
   SetIndexBuffer(1, UpperBandBuffer);
   SetIndexLabel(1, "LRMA Upper Band");
   SetIndexDrawBegin(1, LRMA_Period);
   //
   SetIndexStyle(2, DRAW_LINE);
   SetIndexBuffer(2, LowerBandBuffer);
   SetIndexLabel(2, "LRMA Lower Band");
   SetIndexDrawBegin(2, LRMA_Period);
  }
 //----
  return(0);
 }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
 {
 //----
  Comment(""); // remove comment
 //----
  return(0);
 }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
 {
  int counted_bars = IndicatorCounted();
  int Limit, cnt, i, k;
  double old_val, new_val, sum, std_dev;
 //----
  if (counted_bars < 0) { return(-1); } // to prevent possible erors
  Limit = Bars - counted_bars;
  //
  if (Limit > LRMA_Period) // run once when getting started
   { cnt = Limit - LRMA_Period; }
  else                     // run elsewhere
   { cnt = Limit; }
  // calculate LRMA
  for (i=cnt; i>=0; i--)
   { LRMABuffer[i] = GetLRMA(i, LRMA_Period); }
    //
    if (BandsEnabled == true) // draw Bollinger Bands
     {
      // calculate standard deviation
      i = Bars - LRMA_Period;
      if (counted_bars > (LRMA_Period - 1)) 
       { i = Bars - counted_bars - 1; }
      while (i >= 0)
       {
        sum = 0.0;
        k = i + LRMA_Period - 1;
        old_val = LRMABuffer[i];
        while (k >= i)
         {
          new_val = Close[k] - old_val;
          sum += new_val * new_val;
          k--;
         }
        std_dev = MathSqrt(sum / LRMA_Period);
        // complete BB's buffers
        UpperBandBuffer[i] = old_val + BandsDev * std_dev;
        LowerBandBuffer[i] = old_val - BandsDev * std_dev;
        i--;
      }
      // optional - may be deleted without hesitations
      Comment("LRMA = ", NormalizeDouble(LRMABuffer[0], Digits), "\n",
              "UpperBand = ", NormalizeDouble(UpperBandBuffer[0], Digits), "\n",
              "LowerBand = ", NormalizeDouble(LowerBandBuffer[0], Digits));
    }
  // optional - may be deleted without hesitations
  if (BandsEnabled != true)
   { Comment("LRMA = ", NormalizeDouble(LRMABuffer[0], Digits)); }
 //----
  return(0);
 }
//+------------------------------------------------------------------+
double GetLRMA(int shift, int ma_period)
 {
  static int counter = 1;
  static int sum_x, sum_x2;
  static double den_x;
  int i, loop_begin;
  double sum_y, sum_xy, A, B, var_tmp;
  double ret_val;
 //----
  // initial accumulation - run once when getting started
  while (counter <= ma_period+1)
   {
    if (counter == ma_period+1)
     {
      den_x = ma_period * sum_x2 - sum_x * sum_x; // denominator
      counter++;
      break;
     }
    sum_x  += counter;
    sum_x2 += counter * counter;
    counter++;
   }
  // main calculation loop
  loop_begin = shift + ma_period - 1;
  sum_y  = 0.0;
  sum_xy = 0.0;
  for (i = 1; i<=ma_period; i++)
   {
    var_tmp = Close[loop_begin-i+1];
    sum_y  += var_tmp;
    sum_xy += i * var_tmp;
   }
  B = (ma_period * sum_xy - sum_x * sum_y) / den_x; // slope
  A = (sum_y - B * sum_x) / ma_period;              // intercept
  //
  ret_val = A + B * ma_period;
 //----
  return(ret_val);
 }
//+------------------------------------------------------------------+