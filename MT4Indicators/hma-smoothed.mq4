//+----------------------------------------------------------------------------------+
//|                                                   Heiken ashi - HMA smoothed.mq4 |
//|                                                                           mladen |
//+----------------------------------------------------------------------------------+
#property copyright ""
#property link      ""

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1  LimeGreen
#property indicator_color2  DarkOrange
#property indicator_width1  2
#property indicator_width2  2
#property indicator_minimum 0
#property indicator_maximum 1

//
//
//
//
//

extern int HmaPeriod = 30;

//
//
//
//
//

double bufferUp[];
double bufferDo[];
double working[][12];
int    HalfPeriod;
int    HullPeriod;

//+----------------------------------------------------------------------------------+
//|                                                                                  |
//+----------------------------------------------------------------------------------+
//
//
//
//
//

int init()
{
   SetIndexBuffer(0,bufferUp); SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(1,bufferDo); SetIndexStyle(1,DRAW_HISTOGRAM);
   
   //
   //
   //
   //
   //
      
   HmaPeriod  = MathMax(2,HmaPeriod);
   HalfPeriod = MathFloor(HmaPeriod/2.0);
   HullPeriod = MathFloor(MathSqrt(HmaPeriod));
   return(0);
}
int deinit()
{
   return(0);
}

//+----------------------------------------------------------------------------------+
//|                                                                                  |
//+----------------------------------------------------------------------------------+
//
//
//
//
//

#define _hrOpen  0
#define _haOpen  1
#define _hrClose 2
#define _haClose 3
#define _hrHigh  4
#define _haHigh  5
#define _hrLow   6
#define _haLow   7

#define _hfOpen  8
#define _hfClose 9
#define _hfHigh  10
#define _hfLow   11
//
//
//
//
//

int start()
{
   int counted_bars=IndicatorCounted();
   int i,r,limit;

   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
         limit = Bars-counted_bars;
         if (ArrayRange(working,0) != Bars) ArrayResize(working,Bars);

   //
   //
   //
   //
   //
        
   for(i=limit, r=Bars-i-1; i >= 0; i--,r++)
   {
      working[r][_hrOpen]  = iMA(NULL,0,HalfPeriod,0,MODE_LWMA,PRICE_OPEN,i)*2-iMA(NULL,0,HmaPeriod,0,MODE_LWMA,PRICE_OPEN,i);
      working[r][_haOpen]  = iLwma(_hrOpen,HullPeriod,r);
      working[r][_hrClose] = iMA(NULL,0,HalfPeriod,0,MODE_LWMA,PRICE_CLOSE,i)*2-iMA(NULL,0,HmaPeriod,0,MODE_LWMA,PRICE_CLOSE,i);
      working[r][_haClose] = iLwma(_hrClose,HullPeriod,r);
      working[r][_hrHigh]  = iMA(NULL,0,HalfPeriod,0,MODE_LWMA,PRICE_HIGH,i)*2-iMA(NULL,0,HmaPeriod,0,MODE_LWMA,PRICE_HIGH,i);
      working[r][_haHigh]  = iLwma(_hrHigh,HullPeriod,r);
      working[r][_hrLow]   = iMA(NULL,0,HalfPeriod,0,MODE_LWMA,PRICE_LOW,i)*2-iMA(NULL,0,HmaPeriod,0,MODE_LWMA,PRICE_LOW,i);
      working[r][_haLow]   = iLwma(_hrLow,HullPeriod,r);
      
      //
      //
      //
      //
      //
      
      double haOpen  = (working[r-1][_hfOpen]+working[r-1][_hfClose])/2.0; 
      double haClose = (working[r][_haOpen]+working[r][_haClose]+working[r][_haHigh]+working[r][_haLow])/4.0;
      double haHigh  = MathMax(working[r][_haHigh],MathMax(haOpen,haClose));
      double haLow   = MathMin(working[r][_haLow] ,MathMin(haOpen,haClose));

      if (haOpen<haClose) 
         {
            bufferUp[i]         = 1;
            bufferDo[i]         = EMPTY_VALUE;
            working[r][_hfLow]  = haLow;
            working[r][_hfHigh] = haHigh;
         } 
      else
         {
            bufferDo[i]         = 1;
            bufferUp[i]         = EMPTY_VALUE;
            working[r][_hfHigh] = haLow;
            working[r][_hfLow]  = haHigh;
         }
      working[r][_hfOpen]  = haOpen;
      working[r][_hfClose] = haClose;
   }
   
   //
   //
   //
   //
   //
   
   return(0);
}

//+----------------------------------------------------------------------------------+
//|                                                                                  |
//+----------------------------------------------------------------------------------+
//
//
//
//
//

double iLwma(int forBuffer, int period, int shift)
{
   double weight=0;
   double sum   =0;
   int    i,k;
   
   if (shift>=period)
   {
      for (i=0,k=period; i<period; i++,k--)
      {
            weight += k;
            sum    += working[shift-i][forBuffer]*k;
        }
        if (weight !=0)
                return(sum/weight);
        else    return(0.0);
    }
    else return(working[shift][forBuffer]);
}