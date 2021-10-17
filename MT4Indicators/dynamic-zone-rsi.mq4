//+------------------------------------------------------------------+
//|                                             Dynamic Zone RSI.mq4 |
//|                                   Copyright © 2005, Pavel Kulko. |
//|                                                  polk@alba.dp.ua |
//+------------------------------------------------------------------+
#property copyright ""
#property link      ""
#property indicator_buffers 3
#property indicator_color1 Lime
#property indicator_color2 SlateBlue
#property indicator_color3 Orange

#property indicator_separate_window

extern int RSIPeriod = 5;
extern int BandPeriod = 30;

double RSIBuf[],UpZone[],DnZone[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_LINE);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(0,RSIBuf);
   SetIndexBuffer(1,UpZone);
   SetIndexBuffer(2,DnZone);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//---- 
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   double MA, RSI[];
   ArrayResize(RSI,BandPeriod);
   int counted_bars=IndicatorCounted();
   int limit = Bars-counted_bars-1;
   for(int i=limit; i>=0; i--)
   {
      RSIBuf[i] = iRSI(NULL,0,RSIPeriod,MODE_CLOSE,i);
      MA = 0;
      for(int j=i; j<i+BandPeriod; j++) {
         RSI[j-i] = RSIBuf[j];
         MA += RSIBuf[j]/BandPeriod;
      }
      UpZone[i] = MA + (1.3185 * StDev(RSI,BandPeriod));
      DnZone[i] = MA - (1.3185 * StDev(RSI,BandPeriod));  
   }
   
//----
   return(0);
  }
  
double StDev(double& Data[], int Per)
{
  return(MathSqrt(Variance(Data,Per)));
}

double Variance(double& Data[], int Per)
{
  double sum, ssum;
  for (int i=0; i<Per; i++)
  {
    sum += Data[i];
    ssum += MathPow(Data[i],2);
  }
  return((ssum*Per - sum*sum)/(Per*(Per-1)));
}
//+------------------------------------------------------------------+