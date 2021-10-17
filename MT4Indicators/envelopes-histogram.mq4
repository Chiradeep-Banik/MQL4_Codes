//-----------------------------------------------------------------
#property copyright ""
#property link      ""
//------------------------------------------------------------------

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1  LawnGreen
#property indicator_color2  Red
#property indicator_color3  Yellow
#property indicator_width1  5
#property indicator_width2  5
#property indicator_width3  5
#property indicator_minimum 0
#property indicator_maximum 1

//
//
//
//
//

extern int    EnvelopePeriod  = 60;
extern int    EnvelopeMaShift = 0;
extern int    EnvelopeMaMode  = MODE_LWMA;
extern int    UpperPrice      = 0;
extern int    LowerPrice      = 0;
extern double Deviation       = 0.2;

//
//
//
//
//

double UpEnv[];
double DnEnv[];
double UpH[];
double DnH[]; 
double NuH[];   
double trend[];

//
//
//
//                    
//

int init()
{
   IndicatorBuffers(6);
   SetIndexBuffer(0,UpH);   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(1,DnH);   SetIndexStyle(1,DRAW_HISTOGRAM);   
   SetIndexBuffer(2,NuH);   SetIndexStyle(2,DRAW_HISTOGRAM);      
   SetIndexBuffer(3,UpEnv); SetIndexShift(3,EnvelopeMaShift);
   SetIndexBuffer(4,DnEnv); SetIndexShift(4,EnvelopeMaShift);
   SetIndexBuffer(5,trend);
   IndicatorShortName("Envelopes  HISTO("+EnvelopePeriod+")");
return(0);
}  
  
//+------------------------------------------------------------------
//|                             
//+------------------------------------------------------------------
//
//

int start()
{
   int counted_bars=IndicatorCounted();
   int i,limit;

   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
         limit = MathMin(Bars-counted_bars,Bars-1);
         
   //
   //
   //
   //
   //
   
   for (i = limit; i >= 0; i--)
   {
      UpEnv[i]  = (1+Deviation/100)*iMA(NULL,0,EnvelopePeriod,EnvelopeMaShift,EnvelopeMaMode,UpperPrice,i);
      DnEnv[i]  = (1-Deviation/100)*iMA(NULL,0,EnvelopePeriod,EnvelopeMaShift,EnvelopeMaMode,LowerPrice,i);
      
      //
      //
      //
      //
      //
      
      UpH[i] = EMPTY_VALUE;
      DnH[i] = EMPTY_VALUE;
      NuH[i] = EMPTY_VALUE;
      trend[i] = 0;
         if (Close[i]>UpEnv[i])                      trend[i] = 1;
         if (Close[i]<DnEnv[i])                      trend[i] =-1;
         if (Close[i]<UpEnv[i] && Close[i]>DnEnv[i]) trend[i] = 0;
         if (trend[i] == 1) UpH[i] = 1;
         if (trend[i] ==-1) DnH[i] = 1;
         if (trend[i] == 0) NuH[i] = 1;
   }
return(0);
}

