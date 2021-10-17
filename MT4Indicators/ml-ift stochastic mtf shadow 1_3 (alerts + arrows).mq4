//------------------------------------------------------------------
//
//------------------------------------------------------------------

#property indicator_separate_window
#property indicator_buffers 6
#property indicator_color1  clrDimGray
#property indicator_color2  clrYellow
#property indicator_color3  clrLime
#property indicator_color4  clrLime
#property indicator_color5  clrOrangeRed
#property indicator_color6  clrOrangeRed
#property indicator_minimum -1.05
#property indicator_maximum  1.05
#property strict

////
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
enum enMaTypes
{
};

extern ENUM_TIMEFRAMES    TimeFrame        = PERIOD_CURRENT;   // Time frame to use
extern int                Sto_Period       = 89;               // Stochastic Period
extern enPrices           Sto_PriceHi      = pr_high;          // Price to use for high
extern enPrices           Sto_PriceCl      = pr_close;         // Price to use for close
extern enPrices           Sto_PriceLo      = pr_low;           // Price to use for low
extern ENUM_MA_METHOD     Sto_PriceFilM    = MODE_EMA;         // Price filtering method
extern int                Sto_PriceFilP    = 5;                // Price filtering period
extern int                MA_Period        = 9;                // MaPeriod
extern ENUM_MA_METHOD     MA_Method        = MODE_LWMA;        // Ma Method
extern double             levelOb          = 0.9;              // overbought level
extern double             levelOs          = -0.9;             // oversold level 
extern double             Sensitivity      = 10;               // Sensitivity for inverse fisher transform
extern int                LineWidth        = 3;                // Lines width
extern bool               alertsOn         = true;
extern bool               alertsOnCurrent  = false;
extern bool               alertsMessage    = true;
extern bool               alertsSound      = true;
extern bool               alertsEmail      = false;
extern bool               alertsNotify     = false;
extern string             soundFile        = "alert2.wav";
input bool                arrowsVisible    = false;              // Arrows visible true/false?
input bool                arrowsOnNewest   = true;               // Arrows drawn on newest bar of higher time frame bar?
input string              arrowsIdentifier = "sto Arrows1";      // Unique ID for arrows
input double              arrowsUpperGap   = 0.5;                // Upper arrow gap
input double              arrowsLowerGap   = 0.5;                // Lower arrow gap
input color               arrowsUpColor    = clrLimeGreen;       // Up arrow color
input color               arrowsDnColor    = clrOrange;          // Down arrow color
input int                 arrowsUpCode     = 159;                // Up arrow code
input int                 arrowsDnCode     = 159;                // Down arrow code
input int                 arrowsUpSize     = 2;                  // Up arrow size
input int                 arrowsDnSize     = 2;                  // Down arrow size
extern bool               Interpolate      = true;               // Interpolating when using multi time frame mode 

//
//
//
//
//

double Value[];
double iFish[];
double iFishua[];
double iFishub[];
double iFishda[];
double iFishdb[];
double state[];
double shadow[];
string indicatorFileName;
bool   returnBars;

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
   IndicatorBuffers(7);
   SetIndexBuffer(0,shadow);    SetIndexStyle(0,EMPTY,EMPTY,LineWidth+6);
   SetIndexBuffer(1,iFish);     SetIndexStyle(1,EMPTY,EMPTY,LineWidth);
   SetIndexBuffer(2,iFishua);   SetIndexStyle(2,EMPTY,EMPTY,LineWidth);
   SetIndexBuffer(3,iFishub);   SetIndexStyle(3,EMPTY,EMPTY,LineWidth); 
   SetIndexBuffer(4,iFishda);   SetIndexStyle(4,EMPTY,EMPTY,LineWidth);
   SetIndexBuffer(5,iFishdb);   SetIndexStyle(5,EMPTY,EMPTY,LineWidth);
   SetIndexBuffer(6,state);
   SetLevelValue(0, levelOs);
   SetLevelValue(1, levelOb);
   SetLevelValue(2, 0);
        indicatorFileName = WindowExpertName();
        returnBars        = TimeFrame==-99;
        TimeFrame         = MathMax(TimeFrame,_Period);
   IndicatorShortName(timeFrameToString(TimeFrame)+" ift of stochastic ("+(string)Sto_Period+","+(string)MA_Period+","+(string)Sensitivity+")" );
return(0); 
}  
void OnDeinit(const int reason)
{ 
    string lookFor       = arrowsIdentifier+":";
    int    lookForLength = StringLen(lookFor);
    for (int i=ObjectsTotal()-1; i>=0; i--)
    {
      string objectName = ObjectName(i);
      if (StringSubstr(objectName,0,lookForLength) == lookFor) ObjectDelete(objectName);
    }
}

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
   int i,counted_bars = IndicatorCounted(); 
      if (counted_bars < 0) return(-1); 
      if (counted_bars > 0) counted_bars--;  
         int limit=MathMin(Bars-counted_bars,Bars-1);
         if (returnBars) { shadow[0] = limit+1; return(0); }

   //
   //
   //
   //
   //
      
   if (TimeFrame==Period())
   {
      if (state[limit] ==  1) CleanPoint(limit,iFishua,iFishub);
      if (state[limit] == -1) CleanPoint(limit,iFishda,iFishdb);
      double prices[3];
      for (i= limit; i >= 0; i--) 
      {
         prices[0] = iCustomMa(Sto_PriceFilM,getPrice(Sto_PriceHi,Open,Close,High,Low,i,0),Sto_PriceFilP,i,0);
         prices[1] = iCustomMa(Sto_PriceFilM,getPrice(Sto_PriceCl,Open,Close,High,Low,i,1),Sto_PriceFilP,i,1);
         prices[2] = iCustomMa(Sto_PriceFilM,getPrice(Sto_PriceLo,Open,Close,High,Low,i,2),Sto_PriceFilP,i,2);
         ArraySort(prices);
            double MA = iCustomMa(MA_Method,(1.0/Sensitivity)*(iStoch(prices[1],prices[2],prices[0],Sto_Period,1,i)-50.0),MA_Period,i,3); 
         iFish[i]   = (MathExp(2.0*MA)-1.0)/(MathExp(2.0*MA)+1.0);
         iFishua[i] = EMPTY_VALUE;
         iFishub[i] = EMPTY_VALUE;
         iFishda[i] = EMPTY_VALUE;
         iFishdb[i] = EMPTY_VALUE;
         if (i<Bars-1)
         {
           shadow[i]  = iFish[i];
           state[i]   = 0;
           if (iFish[i]>levelOb) state[i] =  1;
           if (iFish[i]<levelOs) state[i] = -1;
           if (state[i] ==  1) PlotPoint(i,iFishua,iFishub,iFish);
           if (state[i] == -1) PlotPoint(i,iFishda,iFishdb,iFish);
         }
         
         //
         //
         //
         //
         //
         
         if (arrowsVisible)
         {
            string lookFor = arrowsIdentifier+":"+(string)Time[i]; ObjectDelete(lookFor);            
            if (i<(Bars-1) && state[i] != state[i+1])
            {
               if (state[i] == 1) drawArrow(i,arrowsUpColor,arrowsUpCode,arrowsUpSize,false);
               if (state[i] ==-1) drawArrow(i,arrowsDnColor,arrowsDnCode,arrowsDnSize, true);
            }
         }   
         
   }
   if (alertsOn)
   {
      int whichBar = (alertsOnCurrent) ? 0 : 1;
      if (state[whichBar] != state[whichBar+1])
      if (state[whichBar] == 1)
            doAlert("crossing upper level up");
      else  doAlert("crossing lower level down");       
    }
    return(0); 
    }
    
    //
   //
   //
   //
   //
   
   limit = (int)MathMax(limit,MathMin(Bars-1,iCustom(NULL,TimeFrame,indicatorFileName,-99,0,0)*TimeFrame/Period()));;
   if (state[limit] ==  1) CleanPoint(limit,iFishua,iFishub);
   if (state[limit] == -1) CleanPoint(limit,iFishda,iFishdb);
   for (i=limit;i>=0; i--)
   {
      int y = iBarShift(NULL,TimeFrame,Time[i]);
        iFish[i]   = iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,Sto_Period,Sto_PriceHi,Sto_PriceCl,Sto_PriceLo,Sto_PriceFilM,Sto_PriceFilP,MA_Period,MA_Method,levelOb,levelOs,Sensitivity,LineWidth,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsEmail,alertsNotify,soundFile,arrowsVisible,arrowsOnNewest,arrowsIdentifier,arrowsUpperGap,arrowsLowerGap,arrowsUpColor,arrowsDnColor,arrowsUpCode,arrowsDnCode,arrowsUpSize,arrowsDnSize,1,y);
        state[i]   = iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,Sto_Period,Sto_PriceHi,Sto_PriceCl,Sto_PriceLo,Sto_PriceFilM,Sto_PriceFilP,MA_Period,MA_Method,levelOb,levelOs,Sensitivity,LineWidth,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsEmail,alertsNotify,soundFile,arrowsVisible,arrowsOnNewest,arrowsIdentifier,arrowsUpperGap,arrowsLowerGap,arrowsUpColor,arrowsDnColor,arrowsUpCode,arrowsDnCode,arrowsUpSize,arrowsDnSize,6,y);
        shadow[i]  = iFish[i];
        iFishua[i] = EMPTY_VALUE;
        iFishub[i] = EMPTY_VALUE;
        iFishda[i] = EMPTY_VALUE;
        iFishdb[i] = EMPTY_VALUE;
        
          //
          //
          //
          //
          //
            
          if (!Interpolate || (i>0 &&y==iBarShift(NULL,TimeFrame,Time[i-1]))) continue;

          //
          //
          //
          //
          //

          int n,s; datetime time = iTime(NULL,TimeFrame,y);
             for(n = 1; i+n<Bars && Time[i+n] >= time; n++) continue;
             for(s = 1; i+n<Bars && i+s<Bars && s<n; s++)
             {
                iFish[i+s]  = iFish[i] + (iFish[i+n] - iFish[i]) * s/n;
                shadow[i+s] = iFish[i+s];
  	          }   
   }
   for (i=limit;i>=0;i--)
   {
      if (state[i] ==  1) PlotPoint(i,iFishua,iFishub,iFish);
      if (state[i] == -1) PlotPoint(i,iFishda,iFishdb,iFish);
   }
return(0);
} 


//-------------------------------------------------------------------
//                                                                  
//-------------------------------------------------------------------
//
//
//
//
//

double iCustomMa(int maMode, double price, double period, int i, int instanceNo=0)
{
   switch(maMode)
   {
      case MODE_SMA:  return(iSma (price,(int)period,Bars-i-1,instanceNo));
      case MODE_EMA:  return(iEma (price,     period,Bars-i-1,instanceNo));
      case MODE_SMMA: return(iSmma(price,     period,Bars-i-1,instanceNo));
      case MODE_LWMA: return(iLwma(price,     period,Bars-i-1,instanceNo));
   }               
   return(0);
}

//
//
//
//
//
   
#define _maInstances 4
#define _maWorkBufferx1 1*_maInstances
#define _maWorkBufferx2 2*_maInstances

double workSma[][_maWorkBufferx2];
double iSma(double price, int period, int r, int instanceNo=0)
{
   if (period<=1) return(price);
   if (ArrayRange(workSma,0)!= Bars) ArrayResize(workSma,Bars); instanceNo *= 2; int k;

   //
   //
   //
   //
   //
      
   workSma[r][instanceNo+0] = price;
   workSma[r][instanceNo+1] = price; for(k=1; k<period && (r-k)>=0; k++) workSma[r][instanceNo+1] += workSma[r-k][instanceNo+0];  
   workSma[r][instanceNo+1] /= 1.0*k;
   return(workSma[r][instanceNo+1]);
}

//
//
//
//
//

double workEma[][_maWorkBufferx1];
double iEma(double price, double period, int r, int instanceNo=0)
{
   if (period<=1) return(price);
   if (ArrayRange(workEma,0)!= Bars) ArrayResize(workEma,Bars);

   //
   //
   //
   //
   //
      
   workEma[r][instanceNo] = price;
   double alpha = 2.0 / (1.0+period);
   if (r>0)
          workEma[r][instanceNo] = workEma[r-1][instanceNo]+alpha*(price-workEma[r-1][instanceNo]);
   return(workEma[r][instanceNo]);
}

//
//
//
//
//

double workSmma[][_maWorkBufferx1];
double iSmma(double price, double period, int r, int instanceNo=0)
{
   if (period<=1) return(price);
   if (ArrayRange(workSmma,0)!= Bars) ArrayResize(workSmma,Bars);

   //
   //
   //
   //
   //

   if (r<period)
         workSmma[r][instanceNo] = price;
   else  workSmma[r][instanceNo] = workSmma[r-1][instanceNo]+(price-workSmma[r-1][instanceNo])/period;
   return(workSmma[r][instanceNo]);
}

//
//
//
//
//

double workLwma[][_maWorkBufferx1];
double iLwma(double price, double period, int r, int instanceNo=0)
{
   if (period<=1) return(price);
   if (ArrayRange(workLwma,0)!= Bars) ArrayResize(workLwma,Bars);
   
   //
   //
   //
   //
   //
   
   workLwma[r][instanceNo] = price;
      double sumw = period;
      double sum  = period*price;

      for(int k=1; k<period && (r-k)>=0; k++)
      {
         double weight = period-k;
                sumw  += weight;
                sum   += weight*workLwma[r-k][instanceNo];  
      }             
      return(sum/sumw);
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//

double workSto[][5];
#define _hi 0
#define _lo 1
#define _re 2
#define _ma 3
#define _mi 4
double iStoch(double priceR, double priceH, double priceL, int period, int slowing, int i, int instanceNo=0)
{
   if (ArrayRange(workSto,0)!=Bars) ArrayResize(workSto,Bars); i = Bars-i-1; instanceNo *= 5;
   
   //
   //
   //
   //
   //
   
   workSto[i][_hi+instanceNo] = priceH;
   workSto[i][_lo+instanceNo] = priceL;
   workSto[i][_re+instanceNo] = priceR;
   workSto[i][_ma+instanceNo] = priceH;
   workSto[i][_mi+instanceNo] = priceL;
      for (int k=1; k<period && (i-k)>=0; k++)
      {
         workSto[i][_mi+instanceNo] = MathMin(workSto[i][_mi+instanceNo],workSto[i-k][instanceNo+_lo]);
         workSto[i][_ma+instanceNo] = MathMax(workSto[i][_ma+instanceNo],workSto[i-k][instanceNo+_hi]);
      }                   
      double sumlow  = 0.0;
      double sumhigh = 0.0;
      for(int k=0; k<slowing && (i-k)>=0; k++)
      {
         sumlow  += workSto[i-k][_re+instanceNo]-workSto[i-k][_mi+instanceNo];
         sumhigh += workSto[i-k][_ma+instanceNo]-workSto[i-k][_mi+instanceNo];
      }

   //
   //
   //
   //
   //
   
   if(sumhigh!=0.0) 
         return(100.0*sumlow/sumhigh);
   else  return(0);    
}

//-------------------------------------------------------------------
//                                                                  
//-------------------------------------------------------------------
//
//
//
//
//

double workHa[][12];
double getPrice(int price, const double& open[], const double& close[], const double& high[], const double& low[], int i, int instanceNo=0)
{
  if (price>=pr_haclose && price<=pr_hatbiased)
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

//-------------------------------------------------------------------
//                                                                  
//-------------------------------------------------------------------
//
//
//
//
//

void CleanPoint(int i,double& first[],double& second[])
{
   if (i>=Bars-3) return;
   if ((second[i]  != EMPTY_VALUE) && (second[i+1] != EMPTY_VALUE))
        second[i+1] = EMPTY_VALUE;
   else
      if ((first[i] != EMPTY_VALUE) && (first[i+1] != EMPTY_VALUE) && (first[i+2] == EMPTY_VALUE))
          first[i+1] = EMPTY_VALUE;
}

void PlotPoint(int i,double& first[],double& second[],double& from[])
{
   if (i>=Bars-2) return;
   if (first[i+1] == EMPTY_VALUE)
      if (first[i+2] == EMPTY_VALUE) 
            { first[i]  = from[i];  first[i+1]  = from[i+1]; second[i] = EMPTY_VALUE; }
      else  { second[i] =  from[i]; second[i+1] = from[i+1]; first[i]  = EMPTY_VALUE; }
   else     { first[i]  = from[i];                           second[i] = EMPTY_VALUE; }
}

//
//
//
//
//

void doAlert(string doWhat)
{
   static string   previousAlert="nothing";
   static datetime previousTime;
   string message;
   
      if (previousAlert != doWhat || previousTime != Time[0]) {
          previousAlert  = doWhat;
          previousTime   = Time[0];

          //
          //
          //
          //
          //

          message = timeFrameToString(_Period)+" "+_Symbol+" at "+TimeToStr(TimeLocal(),TIME_SECONDS)+" Ift stochastic "+doWhat;
             if (alertsMessage) Alert(message);
             if (alertsEmail)   SendMail(_Symbol+" Ift stochastic ",message);
             if (alertsNotify)  SendNotification(message);
             if (alertsSound)   PlaySound(soundFile);
      }
}

//-------------------------------------------------------------------
//                                                                  
//-------------------------------------------------------------------
//
//
//
//
//

void drawArrow(int i,color theColor,int theCode, int theSize, bool up)
{
   string name = arrowsIdentifier+":"+(string)Time[i];
   double gap  = iATR(NULL,0,20,i);   
   
      //
      //
      //
      //
      //

      datetime time = Time[i]; if (arrowsOnNewest) time += _Period*60-1;      
      ObjectCreate(name,OBJ_ARROW,0,time,0);
         ObjectSet(name,OBJPROP_ARROWCODE,theCode);
         ObjectSet(name,OBJPROP_WIDTH,    theSize);
         ObjectSet(name,OBJPROP_COLOR,    theColor);
         if (up)
               ObjectSet(name,OBJPROP_PRICE1,High[i] + arrowsUpperGap * gap);
         else  ObjectSet(name,OBJPROP_PRICE1,Low[i]  - arrowsLowerGap * gap);
}

//-------------------------------------------------------------------
//
//-------------------------------------------------------------------
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
