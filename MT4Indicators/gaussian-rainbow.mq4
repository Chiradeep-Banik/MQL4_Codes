//------------------------------------------------------------------
#property copyright "mladen"
#property link      "www.forex-station.com"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 20
#property strict

enum enPrices
{
   pr_close,      // Close
   pr_open,       // Open
   pr_high,       // High
   pr_low,        // Low
   pr_median,     // Median
   pr_typical,    // Typical
   pr_weighted,   // Weighted
   pr_average,    // Average (high+low+open+close)/4
   pr_medianb,    // Average median body (open+close)/2
   pr_tbiased,    // Trend biased price
   pr_tbiased2,   // Trend biased (extreme) price
   pr_haclose,    // Heiken ashi close
   pr_haopen ,    // Heiken ashi open
   pr_hahigh,     // Heiken ashi high
   pr_halow,      // Heiken ashi low
   pr_hamedian,   // Heiken ashi median
   pr_hatypical,  // Heiken ashi typical
   pr_haweighted, // Heiken ashi weighted
   pr_haaverage,  // Heiken ashi average
   pr_hamedianb,  // Heiken ashi median body
   pr_hatbiased,  // Heiken ashi trend biased price
   pr_hatbiased2  // Heiken ashi trend biased (extreme) price
};
input int       GaussPeriod = 40;              // Period
input int       GaussOrder  = 2;               // Starting order
input enPrices  Price       = pr_close;        // Price
input color     ColorFrom   = Lime;            // Starting color for MAs
input color     ColorTo     = MediumVioletRed; // Ending color for MAs
extern int      steps       = 12;              // Gaussian steps (max 20)
input bool      Recursive   = false;           // Recursive calculation


//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

struct simpleMa { double buffer[]; };
       simpleMa aBuffers[20];
int init()
{
   steps = MathMax(MathMin(steps,20),2);

       //
       //
       //
       //
       //
       
       for (int i=0;i<steps; i++)
       {
            SetIndexBuffer(i,aBuffers[i].buffer,INDICATOR_DATA);
               SetIndexStyle(i,DRAW_LINE,EMPTY,EMPTY,gradientColor(i,steps,ColorFrom,ColorTo));
               SetIndexLabel(i,"Gaussian raindow "+(string)i);
       }
   IndicatorShortName("Gaussian rainbow");  
   return(0);
}
int deinit(){ return(0); }

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

int start()
{
   static datetime lastTime=0;
   int counted_bars=IndicatorCounted();
      if(counted_bars<0) return(-1);
      if(counted_bars>0) counted_bars--;
         int limit=MathMin(Bars-counted_bars,Bars-1);

   //
   //
   //
   //
   //

   for(int i=limit; i>=0; i--)
   {
      double price = getPrice(Price,Open,Close,High,Low,i);
      for (int k=0; k<steps; k++) 
                   aBuffers[k].buffer[i] = (k==0 || !Recursive) ? iGFilter(price,GaussPeriod,GaussOrder+k,i,k) : iGFilter(aBuffers[k-1].buffer[i],GaussPeriod,GaussOrder+k,i,k);
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


#define gfInstances 20
int     gfperiods[gfInstances][2];
double  gfcoeffs[][gfInstances*3];
double  gfilters[][gfInstances];
double iGFilter(double price, int period, int order, int i, int instanceNo=0)
{
   if (ArrayRange(gfilters,0)!=Bars)   ArrayResize(gfilters,Bars);
   if (ArrayRange(gfcoeffs,0)<order+1) ArrayResize(gfcoeffs,order+1);
   if (gfperiods[instanceNo][0]!=period || gfperiods[instanceNo][1]!=order)
   {
      gfperiods[instanceNo][0]=period;
      gfperiods[instanceNo][1]=order;
         double b = (1.0 - MathCos(2.0*M_PI/period))/(MathPow(MathSqrt(2.0),2.0/order) - 1.0);
         double a = -b + MathSqrt(b*b + 2.0*b);
         for(int r=0; r<=order; r++)
         {
             gfcoeffs[r][instanceNo*3+0] = fact(order)/(fact(order-r)*fact(r));
             gfcoeffs[r][instanceNo*3+1] = MathPow(    a,r);
             gfcoeffs[r][instanceNo*3+2] = MathPow(1.0-a,r);
         }
   }

   //
   //
   //
   //
   //
   
   i = Bars-i-1;
   if (price==EMPTY_VALUE) price=0;
   gfilters[i][instanceNo] = price*gfcoeffs[order][instanceNo*3+1];
      double sign = 1;
         for (int r=1; r<=order && (i-r)>=0; r++, sign *= -1.0)
                  gfilters[i][instanceNo] += sign*gfcoeffs[r][instanceNo*3+0]*gfcoeffs[r][instanceNo*3+2]*gfilters[i-r][instanceNo];
   return(gfilters[i][instanceNo]);
}

//
//
//
//
//

double fact(int n)
{
   double a=1; for(int i=1; i<=n; i++) a*=i;
   return(a);
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//
//

#define priceInstances 1
double workHa[][priceInstances*4];
double getPrice(int tprice, const double& open[], const double& close[], const double& high[], const double& low[], int i, int instanceNo=0)
{
  if (tprice>=pr_haclose)
   {
      if (ArrayRange(workHa,0)!= Bars) ArrayResize(workHa,Bars); instanceNo*=4;
         int r = Bars-i-1;
         
         //
         //
         //
         //
         //
         
         double haOpen;
         if (r>0)
                haOpen  = (workHa[r-1][instanceNo+2] + workHa[r-1][instanceNo+3])/2.0;
         else   haOpen  = (open[i]+close[i])/2;
         double haClose = (open[i] + high[i] + low[i] + close[i]) / 4.0;
         double haHigh  = MathMax(high[i], MathMax(haOpen,haClose));
         double haLow   = MathMin(low[i] , MathMin(haOpen,haClose));

         if(haOpen  <haClose) { workHa[r][instanceNo+0] = haLow;  workHa[r][instanceNo+1] = haHigh; } 
         else                 { workHa[r][instanceNo+0] = haHigh; workHa[r][instanceNo+1] = haLow;  } 
                                workHa[r][instanceNo+2] = haOpen;
                                workHa[r][instanceNo+3] = haClose;
         //
         //
         //
         //
         //
         
         switch (tprice)
         {
            case pr_haclose:     return(haClose);
            case pr_haopen:      return(haOpen);
            case pr_hahigh:      return(haHigh);
            case pr_halow:       return(haLow);
            case pr_hamedian:    return((haHigh+haLow)/2.0);
            case pr_hamedianb:   return((haOpen+haClose)/2.0);
            case pr_hatypical:   return((haHigh+haLow+haClose)/3.0);
            case pr_haweighted:  return((haHigh+haLow+haClose+haClose)/4.0);
            case pr_haaverage:   return((haHigh+haLow+haClose+haOpen)/4.0);
            case pr_hatbiased:
               if (haClose>haOpen)
                     return((haHigh+haClose)/2.0);
               else  return((haLow+haClose)/2.0);        
            case pr_hatbiased2:
               if (haClose>haOpen)  return(haHigh);
               if (haClose<haOpen)  return(haLow);
                                    return(haClose);        
         }
   }
   
   //
   //
   //
   //
   //
   
   switch (tprice)
   {
      case pr_close:     return(close[i]);
      case pr_open:      return(open[i]);
      case pr_high:      return(high[i]);
      case pr_low:       return(low[i]);
      case pr_median:    return((high[i]+low[i])/2.0);
      case pr_medianb:   return((open[i]+close[i])/2.0);
      case pr_typical:   return((high[i]+low[i]+close[i])/3.0);
      case pr_weighted:  return((high[i]+low[i]+close[i]+close[i])/4.0);
      case pr_average:   return((high[i]+low[i]+close[i]+open[i])/4.0);
      case pr_tbiased:   
               if (close[i]>open[i])
                     return((high[i]+close[i])/2.0);
               else  return((low[i]+close[i])/2.0);        
      case pr_tbiased2:   
               if (close[i]>open[i]) return(high[i]);
               if (close[i]<open[i]) return(low[i]);
                                     return(close[i]);        
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

color gradientColor(int step, int totalSteps, color from, color to)
{
   color newBlue  = getColor(step,totalSteps,(from & 0XFF0000)>>16,(to & 0XFF0000)>>16)<<16;
   color newGreen = getColor(step,totalSteps,(from & 0X00FF00)>> 8,(to & 0X00FF00)>> 8) <<8;
   color newRed   = getColor(step,totalSteps,(from & 0X0000FF)    ,(to & 0X0000FF)    )    ;
   return(newBlue+newGreen+newRed);
}
color getColor(int stepNo, int totalSteps, color from, color to)
{
   double step = (from-to)/(totalSteps-1.0);
   return((color)round(from-step*stepNo));
}