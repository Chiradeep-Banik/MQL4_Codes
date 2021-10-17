//+------------------------------------------------------------------+
//|                                                  Accelerator.mq4 |
//|                      Copyright © 2005, MetaQuotes Software Corp. |
//|                                       http://www.metaquotes.net/ |
//+------------------------------------------------------------------+
#property  copyright ""
#property  link      ""
//---- indicator settings
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Red
#property indicator_color2 Yellow

extern int SlowMAPeriod = 100;
extern int FastMAPeriod = 21;

//---- input parameters
//---- variables
double       Array1[];
double       Buffer1[];
double       Array2[];
double       Buffer2[];
//---- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- 4 additional buffers are used for counting.
   IndicatorBuffers(2);
//---- indicators
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,ExtMapBuffer2);

//----
//---- initialization done
   return(0);
  }
//+------------------------------------------------------------------+
//| Accelerator/Decelerator Oscillator                               |
//+------------------------------------------------------------------+
int start()
  {
   int limit,i;
   int counted_bars=IndicatorCounted();

//---- check for possible errors
   if(counted_bars<0) return(-1);

//---- last counted bar will be recounted
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
// ---- Declare Size of Arrays
   ArrayResize(Array1,limit);
   ArrayResize(Buffer1,limit);
   ArrayResize(Array2,limit);
   ArrayResize(Buffer2,limit);

//---- Change Array to same sort of series Array as screen buffers
   ArraySetAsSeries(Array1,true);
   ArraySetAsSeries(Buffer1,true);
   ArraySetAsSeries(Array2,true);
   ArraySetAsSeries(Buffer2,true);
   
   for(i=0; i<limit; i++)
   {  
   Array1[i]=iMA(NULL,0,SlowMAPeriod,0,MODE_EMA,PRICE_CLOSE,i);
   Array2[i]=iMA(NULL,0,FastMAPeriod,0,MODE_EMA,PRICE_CLOSE,i);
   ExtMapBuffer1[i]=Array1[i];
   ExtMapBuffer2[i]=Array2[i];
   }


   //---- done
   return(0);
  }