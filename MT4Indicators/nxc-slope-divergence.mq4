//+------------------------------------------------------------------+
//|                                                 Jim Sloman's ndx |
//|                                                      ocn ndx.mq4 |
//|                                                           mladen |
//|  tools changed from tema smooth to jurik smooth and added nxc ma |
//+------------------------------------------------------------------+
#property copyright "mladen"
#property link      "mladenfx@gmail.com"

#property indicator_separate_window
#property indicator_buffers    2
#property indicator_color1     DeepSkyBlue
#property indicator_color2     Ivory
#property indicator_width1     2
#property indicator_style2     STYLE_DASH
#property indicator_levelcolor DarkSlateGray

//
//
//
//
//

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
   pr_haclose,    // Heiken ashi close
   pr_haopen ,    // Heiken ashi open
   pr_hahigh,     // Heiken ashi high
   pr_halow,      // Heiken ashi low
   pr_hamedian,   // Heiken ashi median
   pr_hatypical,  // Heiken ashi typical
   pr_haweighted, // Heiken ashi weighted
   pr_haaverage,  // Heiken ashi average
   pr_hamedianb,  // Heiken ashi median body
   pr_hatbiased   // Heiken ashi trend biased price
};

extern ENUM_TIMEFRAMES TimeFrame                     = PERIOD_CURRENT;
extern int             NdxPeriod                     = 40;
extern int             NdxSmoothLength               = 20;
extern double          NdxSmoothPhase                = 0;
extern bool            NdxSmoothDouble               = false;
extern enPrices        NdxPrice                      = pr_average; 
extern int             NstPeriod                     = 20;
extern int             NstSmoothLength               = 10;
extern double          NstSmoothPhase                = 0;
extern bool            NstSmoothDouble               = false;
extern int             NxcMaPeriod                   = 7;
extern ENUM_MA_METHOD  NxcMaMode                     = MODE_LWMA;
extern int             LinearRegressionLength        = 150;
extern double          LinearRegressionChannelWidth  = 2.0;
extern string          IndicatorUniqueID             = "Nxc slope divergence";
extern color           ChartLineColor                = MediumOrchid;
extern ENUM_LINE_STYLE ChartLineMiddleStyle          = STYLE_DOT;
extern ENUM_LINE_STYLE ChartLineStyle                = STYLE_DASH;
extern color           NxcLineColor                  = MediumOrchid;
extern ENUM_LINE_STYLE NxcLineMiddleStyle            = STYLE_DOT;
extern ENUM_LINE_STYLE NxcLineStyle                  = STYLE_DASH;
extern int             levelOb                       = 50;
extern int             levelOs                       = -50; 
extern bool            Interpolate                   = true;

//
//
//
//
//

double nxc[];
double nxcma[];
double tBuffer[][7];
string indicatorFileName;
bool   returnBars;
string shortName;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

int init()
{
   SetIndexBuffer(0,nxc);
   SetIndexBuffer(1,nxcma);
   SetLevelValue(0,0);
   SetLevelValue(1,levelOb);
   SetLevelValue(2,levelOs);
   
   NdxSmoothLength   = MathMax(NdxSmoothLength,1);
   NdxPeriod         = MathMax(NdxPeriod,1);
   NstSmoothLength   = MathMax(NstSmoothLength,1);
   NstPeriod         = MathMax(NstPeriod,1);
   indicatorFileName = WindowExpertName();
   returnBars        = (TimeFrame==-99);
   TimeFrame         = MathMax(TimeFrame,_Period);
   
   shortName = IndicatorUniqueID+" - "+timeFrameToString(TimeFrame)+" nxc (ndx: "+NdxPeriod+","+NdxSmoothLength+") (nst: "+NstPeriod+","+NstSmoothLength+")";
   IndicatorShortName(shortName);
return(0);
}

//
//
//
//
//

int deinit()
{
   for (int i=ObjectsTotal(); i>=0; i--)
   {
      string name = ObjectName(i); if (StringFind(name,IndicatorUniqueID)==0) ObjectDelete(name);
   }
   return(0);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

#define iPrc 6

int start()
{
   int    counted_bars=IndicatorCounted();
   int    i,k,r,limit;

   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
         limit = MathMin(Bars-counted_bars,Bars-NdxPeriod-1);
         limit = MathMin(limit            ,Bars-NstPeriod-1);
         if (returnBars) { nxc[0] = limit+1; return(0); }

   //
   //
   //
   //
   //
   
   if (TimeFrame==Period())
   {
     if (ArrayRange(tBuffer,0) != Bars) ArrayResize(tBuffer,Bars);
     for(i=limit, r=Bars-i-1; i >= 0; i--,r++)
     {
        double currPrice = getPrice(NdxPrice,Open,Close,High,Low,i);
         if (currPrice > 0)
               tBuffer[r][iPrc] = MathLog(currPrice);
         else  tBuffer[r][iPrc] = 0.00;
      
      //
      //
      //
      //
      //

         double sumMom = 0;
         double sumDen = 0;
         double sumDif = 0;

            for (k=1; k < NdxPeriod; k++)
            {
               sumDif += MathAbs(tBuffer[r-k+1][iPrc]-tBuffer[r-k][iPrc]);
               if (sumDif !=0)
                     double stoch = (tBuffer[r][iPrc]-tBuffer[r-k][iPrc])/sumDif;
               else         stoch = 0;
               double coeff = 1.0/MathSqrt(k);
          
               sumMom += coeff*stoch;
               sumDen += coeff;
            }
         
            double ndxTemp = iDSmooth(100.0*(sumMom/sumDen),NdxSmoothLength,NdxSmoothPhase,NdxSmoothDouble,i,0);
               if (ndxTemp > 90) ndxTemp =  90+( ndxTemp-90)*0.5;
               if (ndxTemp <-90) ndxTemp = -90-(-ndxTemp-90)*0.5;

      //
      //
      //   
      //
      //
      
         double max    = High[i];
         double min    = Low[i];
         double sumSto = 0;
      
            for (k=0, sumDen=0; k < NstPeriod; k++)
            {
               if (max < High[i+k]) max = High[i+k];
               if (min >  Low[i+k]) min =  Low[i+k];
               if (max!=min)
                     stoch = (Close[i]-min)/(max-min);
               else  stoch = 0;
               coeff = 1.0/MathSqrt(k+1.0);
          
               sumSto += coeff*stoch;
               sumDen += coeff;
            }

            double nstTemp = iDSmooth((200.0*sumSto/sumDen)-100.0,NstSmoothLength,NstSmoothPhase,NstSmoothDouble,i,20);
               if (nstTemp > 85) nstTemp =  85+( nstTemp-85)*0.5;
               if (nstTemp <-85) nstTemp = -85-(-nstTemp-85)*0.5;

      //
      //
      //
      //
      //
      
            nxc[i] = ((MathAbs(ndxTemp)*nstTemp)+(MathAbs(nstTemp)*ndxTemp))*0.5;
            if (nxc[i]>0)
                  nxc[i] = MathSqrt(nxc[i]);
            else  nxc[i] = MathSqrt(MathAbs(nxc[i]))*(-1);
            fillLrArray(i,0,nxc[i]);
            fillLrArray(i,1,getPrice(NdxPrice,Open,Close,High,Low,i));
   }
   for(i = limit; i >= 0 ; i--) nxcma[i] = iMAOnArray(nxc,0,NxcMaPeriod,0,NxcMaMode,i);
   double nxcError; double nxcSlope; double lrnxc = iLrValue(nxc[0],                                  LinearRegressionLength,nxcSlope,nxcError,0,0);
   double prcError; double prcSlope; double lrPrc = iLrValue(getPrice(NdxPrice,Open,Close,High,Low,0),LinearRegressionLength,prcSlope,prcError,0,1);
   int window = WindowFind(shortName);
   createLine(window,lrnxc,lrnxc-(LinearRegressionLength-1.0)*nxcSlope,"nxcLine",NxcLineColor  ,NxcLineStyle  ,NxcLineMiddleStyle  ,nxcError*LinearRegressionChannelWidth);
   createLine(0     ,lrPrc,lrPrc-(LinearRegressionLength-1.0)*prcSlope,"prcLine",ChartLineColor,ChartLineStyle,ChartLineMiddleStyle,prcError*LinearRegressionChannelWidth);  
   return(0);
   }
   
   //
   //
   //
   //
   //
   

   limit = MathMax(limit,MathMin(Bars-1,iCustom(NULL,TimeFrame,indicatorFileName,-99,0,0)*TimeFrame/Period()));
   for(i=limit; i>=0; i--)
   {
      int y = iBarShift(NULL,TimeFrame,Time[i]);
         nxc[i]   = iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,NdxPeriod,NdxSmoothLength,NdxSmoothPhase,NdxSmoothDouble,NdxPrice,NstPeriod,NstSmoothLength,NstSmoothPhase,NstSmoothDouble,NxcMaPeriod,NxcMaMode,LinearRegressionLength,LinearRegressionChannelWidth,IndicatorUniqueID,ChartLineColor,ChartLineMiddleStyle,ChartLineStyle,NxcLineColor,NxcLineMiddleStyle,NxcLineStyle,levelOb,levelOs,0,y);
         nxcma[i] = iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,NdxPeriod,NdxSmoothLength,NdxSmoothPhase,NdxSmoothDouble,NdxPrice,NstPeriod,NstSmoothLength,NstSmoothPhase,NstSmoothDouble,NxcMaPeriod,NxcMaMode,LinearRegressionLength,LinearRegressionChannelWidth,IndicatorUniqueID,ChartLineColor,ChartLineMiddleStyle,ChartLineStyle,NxcLineColor,NxcLineMiddleStyle,NxcLineStyle,levelOb,levelOs,1,y);
         
         //
         //
         //
         //
         //
      
         if (!Interpolate || y==iBarShift(NULL,TimeFrame,Time[i-1])) continue;

         //
         //
         //
         //
         //

         datetime time = iTime(NULL,TimeFrame,y);
            for(int n = 1; i+n < Bars && Time[i+n] >= time; n++) continue;	
            for(int j = 1; j < n; j++) 
            {
               nxc[i+j]   = nxc[i]   + (nxc[i+n]   - nxc[i])   * j/n;
               nxcma[i+j] = nxcma[i] + (nxcma[i+n] - nxcma[i]) * j/n;
            }
   }
   return(0);         
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

double wrk[][40];

#define bsmax  5
#define bsmin  6
#define volty  7
#define vsum   8
#define avolty 9

//
//
//
//
//

double iDSmooth(double price, double length, double phase, bool isDouble, int i, int s=0)
{
   if (isDouble)
         return (iSmooth(iSmooth(price,MathSqrt(length),phase,i,s),MathSqrt(length),phase,i,s+10));
   else  return (iSmooth(price,length,phase,i,s));
}

//
//
//
//
//

double iSmooth(double price, double length, double phase, int i, int s=0)
{
   if (length <=1) return(price);
   if (ArrayRange(wrk,0) != Bars) ArrayResize(wrk,Bars);
   
   int r = Bars-i-1; 
      if (r==0) { for(int k=0; k<7; k++) wrk[r][k+s]=price; for(; k<10; k++) wrk[r][k+s]=0; return(price); }

   //
   //
   //
   //
   //
   
      double len1   = MathMax(MathLog(MathSqrt(0.5*(length-1)))/MathLog(2.0)+2.0,0);
      double pow1   = MathMax(len1-2.0,0.5);
      double del1   = price - wrk[r-1][bsmax+s];
      double del2   = price - wrk[r-1][bsmin+s];
      double div    = 1.0/(10.0+10.0*(MathMin(MathMax(length-10,0),100))/100);
      int    forBar = MathMin(r,10);
	
         wrk[r][volty+s] = 0;
               if(MathAbs(del1) > MathAbs(del2)) wrk[r][volty+s] = MathAbs(del1); 
               if(MathAbs(del1) < MathAbs(del2)) wrk[r][volty+s] = MathAbs(del2); 
         wrk[r][vsum+s] =	wrk[r-1][vsum+s] + (wrk[r][volty+s]-wrk[r-forBar][volty+s])*div;
         
         //
         //
         //
         //
         //
   
         wrk[r][avolty+s] = wrk[r-1][avolty+s]+(2.0/(MathMax(4.0*length,30)+1.0))*(wrk[r][vsum+s]-wrk[r-1][avolty+s]);
            if (wrk[r][avolty+s] > 0)
               double dVolty = wrk[r][volty+s]/wrk[r][avolty+s]; else dVolty = 0;   
	               if (dVolty > MathPow(len1,1.0/pow1)) dVolty = MathPow(len1,1.0/pow1);
                  if (dVolty < 1)                      dVolty = 1.0;

      //
      //
      //
      //
      //
	        
   	double pow2 = MathPow(dVolty, pow1);
      double len2 = MathSqrt(0.5*(length-1))*len1;
      double Kv   = MathPow(len2/(len2+1), MathSqrt(pow2));

         if (del1 > 0) wrk[r][bsmax+s] = price; else wrk[r][bsmax+s] = price - Kv*del1;
         if (del2 < 0) wrk[r][bsmin+s] = price; else wrk[r][bsmin+s] = price - Kv*del2;
	
   //
   //
   //
   //
   //
      
      double R     = MathMax(MathMin(phase,100),-100)/100.0 + 1.5;
      double beta  = 0.45*(length-1)/(0.45*(length-1)+2);
      double alpha = MathPow(beta,pow2);

         wrk[r][0+s] = price + alpha*(wrk[r-1][0+s]-price);
         wrk[r][1+s] = (price - wrk[r][0+s])*(1-beta) + beta*wrk[r-1][1+s];
         wrk[r][2+s] = (wrk[r][0+s] + R*wrk[r][1+s]);
         wrk[r][3+s] = (wrk[r][2+s] - wrk[r-1][4+s])*MathPow((1-alpha),2) + MathPow(alpha,2)*wrk[r-1][3+s];
         wrk[r][4+s] = (wrk[r-1][4+s] + wrk[r][3+s]); 

   //
   //
   //
   //
   //

   return(wrk[r][4+s]);
}            

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

void createLine(int window, double price1, double price2, string addName, color theColor, int theStyle, int theMiddleStyle, double error)
{
   string name = IndicatorUniqueID+addName;
      if (ObjectFind(name)==-1)
           ObjectCreate(name,OBJ_TREND,window,0,0,0,0);
              ObjectSet(name,OBJPROP_PRICE1,price1);
              ObjectSet(name,OBJPROP_PRICE2,price2);
              ObjectSet(name,OBJPROP_TIME1,Time[0]);
              ObjectSet(name,OBJPROP_TIME2,Time[LinearRegressionLength-1]);
              ObjectSet(name,OBJPROP_RAY,false);
              ObjectSet(name,OBJPROP_COLOR,theColor);
              ObjectSet(name,OBJPROP_STYLE,theMiddleStyle);
                  if (error<=0) return;
      name = IndicatorUniqueID+addName+"up";
      if (ObjectFind(name)==-1)
           ObjectCreate(name,OBJ_TREND,window,0,0,0,0);
              ObjectSet(name,OBJPROP_PRICE1,price1+error);
              ObjectSet(name,OBJPROP_PRICE2,price2+error);
              ObjectSet(name,OBJPROP_TIME1,Time[0]);
              ObjectSet(name,OBJPROP_TIME2,Time[LinearRegressionLength-1]);
              ObjectSet(name,OBJPROP_RAY,false);
              ObjectSet(name,OBJPROP_COLOR,theColor);
              ObjectSet(name,OBJPROP_STYLE,theStyle);
      name = IndicatorUniqueID+addName+"down";
      if (ObjectFind(name)==-1)
           ObjectCreate(name,OBJ_TREND,window,0,0,0,0);
              ObjectSet(name,OBJPROP_PRICE1,price1-error);
              ObjectSet(name,OBJPROP_PRICE2,price2-error);
              ObjectSet(name,OBJPROP_TIME1,Time[0]);
              ObjectSet(name,OBJPROP_TIME2,Time[LinearRegressionLength-1]);
              ObjectSet(name,OBJPROP_RAY,false);
              ObjectSet(name,OBJPROP_COLOR,theColor);
              ObjectSet(name,OBJPROP_STYLE,theStyle);
}

//------------------------------------------------------------------
//                                                                  
//------------------------------------------------------------------
//
//
//
//
//

double workLr[][2];
void fillLrArray(int i, int instanceNo, double value)
{
   if (ArrayRange(workLr,0)!=Bars) ArrayResize(workLr,Bars); i = Bars-i-1; workLr[i][instanceNo] = value;
}
double iLrValue(double value, int period, double& slope, double& error, int r, int instanceNo=0)
{
   if (ArrayRange(workLr,0)!=Bars) ArrayResize(workLr,Bars); r = Bars-r-1; workLr[r][instanceNo] = value;
   if (r<period || period<2) return(value);

   //
   //
   //
   //
   //

      double sumx=0, sumxx=0, sumxy=0, sumy=0, sumyy=0;
         for (int k=0; k<period; k++)
         {
            double price = workLr[r-k][instanceNo];
                   sumx  += k;
                   sumxx += k*k;
                   sumxy += k*price;
                   sumy  +=   price;
                   sumyy +=   price*price;
         }
         slope = (period*sumxy-sumx*sumy)/(sumx*sumx-period*sumxx);
         error = MathSqrt((period*sumyy-sumy*sumy-slope*slope*(period*sumxx-sumx*sumx))/(period*(period-2)));

   //
   //
   //
   //
   //
         
   return((sumy + slope*sumx)/period);
}

//+------------------------------------------------------------------
//|                                                                  
//+------------------------------------------------------------------
//
//
//
//
//
//

double workHa[][4];
double getPrice(int price, const double& open[], const double& close[], const double& high[], const double& low[], int i, int instanceNo=0)
{
  if (price>=pr_haclose && price<=pr_hatbiased)
   {
      if (ArrayRange(workHa,0)!= Bars) ArrayResize(workHa,Bars);
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
         
         switch (price)
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
         }
   }
   
   //
   //
   //
   //
   //
   
   switch (price)
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

string sTfTable[] = {"M1","M5","M15","M30","H1","H4","D1","W1","MN"};
int    iTfTable[] = {1,5,15,30,60,240,1440,10080,43200};

string timeFrameToString(int tf)
{
   for (int i=ArraySize(iTfTable)-1; i>=0; i--) 
         if (tf==iTfTable[i]) return(sTfTable[i]);
                              return("");

}  


