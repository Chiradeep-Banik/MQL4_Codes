//+------------------------------------------------------------------+
//|                                                  Sigma Bands.mq4 |
//|                                              Copyright 2016, Tor |
//|                                             http://einvestor.ru/ |
//+------------------------------------------------------------------+
#property copyright ""
#property link      ""
#property version   "1.00"
#property strict
#property indicator_chart_window
#property indicator_buffers 7
#property indicator_plots 7

input int MAPeriod=1; // MA Period
input int BarsCount=200; // Bars for count Sigma
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum TypeGraph
  {
   MODE_SMA1 = 0,      // Simple MA
   MODE_EMA1 = 1,      // Exponential MA
   MODE_SMMA1 = 2,     // Smoothed MA
   MODE_LWMA1 = 3,     // Linear-weighted MA
  };
//--- input parameters
input TypeGraph TypeBandsMA=MODE_EMA1; // Type MA for Bands
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum TypePrice
  {
   PRICE_CLOSE1 = 0,       // Close price
   PRICE_OPEN1 = 1,        // Open price
   PRICE_HIGH1 = 2,        // The maximum price for the period
   PRICE_LOW1 = 3,         // The minimum price for the period
   PRICE_MEDIAN1 = 4,      // Median price, (high + low)/2
   PRICE_TYPICAL1 = 5,     // Typical price, (high + low + close)/3
   PRICE_WEIGHTED1 = 6,    // Weighted close price, (high + low + close + close)/4
  };
//--- input parameters
input TypePrice TypePriceMA=PRICE_CLOSE1; // Applied price MA

input color MAColor=clrNONE; // MA color

double SymbolMA[];
double AverageMA[];
double Dispersion[];
double AverDev[];
double AverDev2[];
double Sigma2[];
double Sigma21[];

int modema=0;
int modeprice=0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   IndicatorShortName("Sigma Bands ("+(string)MAPeriod+")");
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
   SetIndexBuffer(0,SymbolMA);
   SetIndexBuffer(1,AverageMA);
   SetIndexBuffer(2,Dispersion);
   SetIndexBuffer(3,AverDev);
   SetIndexBuffer(4,AverDev2);
   SetIndexBuffer(5,Sigma2);
   SetIndexBuffer(6,Sigma21);

   SetIndexStyle(0,DRAW_LINE,STYLE_SOLID,1,MAColor);
   SetIndexStyle(1,DRAW_LINE,STYLE_SOLID,1,clrRed);
   SetIndexStyle(2,DRAW_NONE);
   SetIndexStyle(3,DRAW_LINE,STYLE_SOLID,1,clrGreen);
   SetIndexStyle(4,DRAW_LINE,STYLE_SOLID,1,clrGreen);
   SetIndexStyle(5,DRAW_LINE,STYLE_SOLID,1,clrBlue);
   SetIndexStyle(6,DRAW_LINE,STYLE_SOLID,1,clrBlue);
   SetIndexLabel(0,"Sigma Bands");
   SetIndexLabel(1,"Average");
   SetIndexLabel(2,"Dispersion");
   SetIndexLabel(3,"Mean deviation +68%");
   SetIndexLabel(4,"Mean deviation -68%");
   SetIndexLabel(5,"Mean deviation +95.4%");
   SetIndexLabel(6,"Mean deviation -95.4%");

   modema=TypeBandsMA;
   modeprice=TypePriceMA;
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
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
//---
   int i,limit=0;
//---
//--- last counted bar will be recounted
   limit=rates_total-prev_calculated;
   if(limit<5)
     {
      limit=5;
     }
   if(limit>rates_total){ limit=rates_total; }

   for(i=limit-1; i>=0; i--)
     {
      SymbolMA[i]=iMA(Symbol(),PERIOD_CURRENT,MAPeriod,0,modema,modeprice,i);
     }

   int startlim=0;
   if(limit>5){ startlim=limit-BarsCount; }else{ startlim=limit; }
   if(ArraySize(SymbolMA)>(BarsCount+10))
     {
      for(int q=startlim-1; q>=0; q--)
        {
         double average1=0; double stotal=0;
         for(int y=q+BarsCount;y>=q; y--)
           {
            stotal=stotal+SymbolMA[y];
           }
         average1=stotal/(BarsCount+1);
         AverageMA[q]=average1;

         double SumPow=0;
         for(int y2=q+BarsCount;y2>=q+1; y2--)
           {
            double pows = MathPow(SymbolMA[y2]-average1,2);
            SumPow = SumPow+pows;
           }
         double Dispersion0=SumPow/(BarsCount);
         Dispersion[q]=Dispersion0;
         AverDev[q]=average1+MathSqrt(Dispersion0);
         AverDev2[q]= average1-MathSqrt(Dispersion0);
         Sigma2[q] = average1+2*MathSqrt(Dispersion0);
         Sigma21[q]= average1-2*MathSqrt(Dispersion0);

        }
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
