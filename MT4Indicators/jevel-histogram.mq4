//------------------------------------------------------------------
#property copyright ""
//------------------------------------------------------------------
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

extern int Length =  14;
extern int Price  =   0;

double vel[];
double hu[];
double hd[];
double trend[];

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

int init()
{
   IndicatorBuffers(4);
   SetIndexBuffer(0,hu); SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(1,hd); SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexBuffer(2,vel);
   SetIndexBuffer(3,trend);
   IndicatorShortName("JVEL ("+Length+")");
   return(0);
}
int start()
{
   int counted_bars=IndicatorCounted();
      if(counted_bars<0) return(-1);
      if(counted_bars>0) counted_bars--;
         int limit = MathMin(Bars-counted_bars,Bars-1);

   //
   //
   //
   //
   //
   
   for(int i=limit; i>=0; i--)
   {
      vel[i]   = iVelocity(iMA(NULL,0,1,0,MODE_SMA,Price,i),Length,i);
      trend[i] = trend[i+1];
      hu[i]    = EMPTY_VALUE;
      hd[i]    = EMPTY_VALUE;
         if (vel[i]>0) trend[i] =  1;
         if (vel[i]<0) trend[i] = -1;
         if (trend[i] == 1) hu[i] = 1;
         if (trend[i] ==-1) hd[i] = 1;
   }         
   return(0);
}

  
//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

double prices[];
double iVelocity(double price, double length, int i)
{
   if (ArraySize(prices)!=Bars) ArrayResize(prices,Bars); i=Bars-i-1;
   
      prices[i] = price;
      double suma = 0.0, sumwa=0;
      double sumb = 0.0, sumwb=0;

      for(int k=0; k<length; k++)
      {
         double weight = length-k;
            suma  += prices[i-k] * weight;
            sumb  += prices[i-k] * weight * weight;
            sumwa += weight;
            sumwb += weight*weight;
      }
   return(sumb/sumwb-suma/sumwa);
}