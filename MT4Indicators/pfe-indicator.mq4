//+------------------------------------------------------------------+
//|                                                          PFE.mq4 |
//|                             ©2008, giampiero.raschetti@gmail.com |
//|                                            http://www.fxtrade.it |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2008, Gimapiero Raschetti"
#property link      "http://www.fxtrade.it/"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 DodgerBlue

//#property indicator_minimum -1
//#property indicator_maximum 1
#property indicator_level1 0

//---- input parameters
extern int PfePeriod=5;
extern bool UseAvarage=true;
extern int MaPeriod=5;

//---- buffers
double Pfe[];
double PfeBuffer[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   string short_name;
   IndicatorBuffers(2);
//---- indicator line
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,Pfe);
//---- name for DataWindow and indicator subwindow label
   short_name="PFE("+PfePeriod+")";
   IndicatorShortName(short_name);
   SetIndexLabel(0,short_name);
//----
   SetIndexDrawBegin(0,PfePeriod);
   SetIndexBuffer(1,PfeBuffer);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Momentum                                                         |
//+------------------------------------------------------------------+
int start()
  {
   int i,k,counted_bars=IndicatorCounted();
   double noise=0;
//----
   if(Bars<=PfePeriod) return(0);

   i=Bars-PfePeriod-1;
   if(counted_bars>=PfePeriod) i=Bars-counted_bars-1;

   while(i>=0)
   {
      noise=0.000000001;
      for(k=0;k<PfePeriod;k++)
       {
        noise=noise+MathAbs(Close[i+k]-Close[i+k+1]);
       }
      PfeBuffer[i]=(Close[i]-Close[i+PfePeriod])/noise;
      i--;
   }

   i=Bars-PfePeriod-1;
   if(counted_bars>=PfePeriod) i=Bars-counted_bars-1;

   while(i>=0)     
   {
      if(UseAvarage)
        Pfe[i]=iMAOnArray(PfeBuffer,Bars,MaPeriod,0,MODE_EMA,i);
      else
        Pfe[i]=PfeBuffer[i];
      i--;
   }
  
   return(0);
  }
//+------------------------------------------------------------------+