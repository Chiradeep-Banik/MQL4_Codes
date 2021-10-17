//+----------------------------------------------------------+
//|                                 Ehlers' fisher transform |
//|                                                   mladen |
//+----------------------------------------------------------+
#property  copyright ""
#property  link      ""

#property  indicator_separate_window
#property  indicator_buffers    5
#property  indicator_color1     LimeGreen
#property  indicator_color2     LimeGreen
#property  indicator_color3     Red
#property  indicator_color4     Red
#property  indicator_color5     DimGray
#property  indicator_width1     2
#property  indicator_width2     1
#property  indicator_width3     2
#property  indicator_width4     1
#property  indicator_width5     2
#property  indicator_level1     0.0
#property  indicator_levelcolor Gold

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
 
extern ENUM_TIMEFRAMES TimeFrame        = PERIOD_CURRENT;
extern int             period           = 30;
extern enPrices        PriceType        = pr_median; // Price to use   
extern double          PriceSmoothing   = 0.3;       // =0.67 bei Fisher_m10 
extern double          IndexSmoothing   = 0.3;       // =0.50 bei Fisher_m10
extern bool            HistogramOnSlope = false;
extern bool            alertsOn         = true;
extern bool            alertsOnSlope    = true;
extern bool            alertsOnCurrent  = true;
extern bool            alertsMessage    = true;
extern bool            alertsSound      = false;
extern bool            alertsNotify     = false;
extern bool            alertsEmail      = false;
extern string          soundFile        = "alert2.wav";
extern bool            ShowLines        = false;
extern string          linesID          = "lines ";
extern color           linesUpColor     = Lime;
extern color           linesDnColor     = Red;
extern ENUM_LINE_STYLE linesStyle       = STYLE_SOLID;
extern int             linesWidth       = 3;
extern bool            linesOnFirst     = false;
extern bool            Interpolate      = true;

//
//
//
//
//

double buffer1[];
double buffer2[];
double buffer3[];
double buffer4[];
double buffer5[];
double Prices[];
double Values[];
double trend[];
double slope[];

string shortName;
string indicatorFileName;
bool   returnBars;

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
   if (PriceSmoothing>=1.0)
      {
      PriceSmoothing=0.9999;
      Alert("EFT: PriceSmothing factor has to be smaller 1!");
      }
   if (PriceSmoothing<0)
      {
      PriceSmoothing=0;
      Alert("EFT: PriceSmothing factor mustn''t be negative!");
      }

   if (IndexSmoothing>=1.0)
      {
      IndexSmoothing=0.9999;
      Alert("EFT: PriceSmothing factor has to be smaller 1!");
      }
   if (IndexSmoothing<0)
      {
      IndexSmoothing=0;
      Alert("EFT: PriceSmothing factor mustn''t be negative!");
      }
   IndicatorBuffers(9);
      SetIndexBuffer(0,buffer1); SetIndexStyle(0,DRAW_HISTOGRAM);
      SetIndexBuffer(1,buffer2); SetIndexStyle(1,DRAW_HISTOGRAM);
      SetIndexBuffer(2,buffer3); SetIndexStyle(2,DRAW_HISTOGRAM);
      SetIndexBuffer(3,buffer4); SetIndexStyle(3,DRAW_HISTOGRAM);
      SetIndexBuffer(4,buffer5);
      SetIndexBuffer(5,Prices);
      SetIndexBuffer(6,Values);
      SetIndexBuffer(7,slope);
      SetIndexBuffer(8,trend);
      
         //
         //
         //
         //
         //
         
         TimeFrame         = MathMax(TimeFrame,_Period); 
         shortName         = linesID+  timeFrameToString(TimeFrame)+" Ehlers\' Fisher transform ("+period+")";
         indicatorFileName = WindowExpertName();
         returnBars        = TimeFrame==-99;
         
         IndicatorShortName(shortName);
return(0);
}
int deinit()
{
   string find = linesID+":";
   for (int i=ObjectsTotal()-1; i>= 0; i--)
   {
      string name = ObjectName(i); if (StringFind(name,find)==0) ObjectDelete(name);
   }
   return(0); 
}

//+----------------------------------------------------------+
//|                                                          |
//+----------------------------------------------------------+
//
//
//
//
//

int start()
{
   int  counted_bars=IndicatorCounted();
   int  limit;

   if(counted_bars < 0) return(-1);
   if(counted_bars > 0) counted_bars--;
           limit=MathMin(Bars-counted_bars,Bars-1);
           if (returnBars) { buffer1[0] = limit+1; return(0); }

   //
   //
   //
   //
   //
   
   if (TimeFrame==Period())
   {
      int window = WindowFind(shortName);
      for(int i=limit; i>=0; i--)
      { 
         Prices[i] = getPrice(PriceType,Open,Close,High,Low,i);
      
      //
      //
      //
      //
      //
                  
         double MaxH = Prices[ArrayMaximum(Prices,period,i)];
         double MinL = Prices[ArrayMinimum(Prices,period,i)];
         if (MaxH!=MinL)
               Values[i]  = 0.33*2*((Prices[i]-MinL)/(MaxH-MinL)-0.5)+PriceSmoothing*Values[i+1];
         else  Values[i]  = 0.00;
               Values[i]  = MathMin(MathMax(Values[i],-0.999),0.999); 
               buffer5[i] = IndexSmoothing*MathLog((1+Values[i])/(1-Values[i]))+IndexSmoothing*buffer5[i+1];

      // 
      //
      //
      //
      //

         if(buffer5[i]==buffer5[i+1])
            {
               buffer1[i]=buffer1[i+1];
               buffer2[i]=buffer2[i+1];
               buffer3[i]=buffer3[i+1];
               buffer4[i]=buffer4[i+1];
               continue;
            }
      
         //
         //
         //
         //
         //
         
            buffer1[i]=EMPTY_VALUE;
            buffer2[i]=EMPTY_VALUE;
            buffer3[i]=EMPTY_VALUE;
            buffer4[i]=EMPTY_VALUE;
            trend[i]  = trend[i+1];
            slope[i]  = slope[i+1];
            if (buffer5[i] > 0)            trend[i] =  1;
            if (buffer5[i] < 0)            trend[i] = -1;
            if (buffer5[i] > buffer5[i+1]) slope[i] =  1;
            if (buffer5[i] < buffer5[i+1]) slope[i] = -1;
            
            if (HistogramOnSlope)
            {
              if (trend[i] ==  1 && slope[i] ==  1) buffer1[i] = buffer5[i];
              if (trend[i] ==  1 && slope[i] == -1) buffer2[i] = buffer5[i];
              if (trend[i] == -1 && slope[i] == -1) buffer3[i] = buffer5[i];
              if (trend[i] == -1 && slope[i] ==  1) buffer4[i] = buffer5[i];
            }
            else
            {                  
              if (trend[i] ==  1) buffer1[i] = buffer5[i];
              if (trend[i] == -1) buffer3[i] = buffer5[i];
            }
            
            //
            //
            //
            //
            //
     
            if (ShowLines && window > -1)
            {
             string name = linesID+":"+Time[i];
             int    add  = 0; if (!linesOnFirst) add = _Period*60-1;
             ObjectDelete(name);
             if ( trend[i]!= trend[i+1])
             {
                color theColor  = linesUpColor; if (trend[i]==-1) theColor = linesDnColor;
                   ObjectCreate(name,OBJ_VLINE,window,Time[i]+add,0);
                      ObjectSet(name,OBJPROP_WIDTH,linesWidth);
                      ObjectSet(name,OBJPROP_STYLE,linesStyle);
                      ObjectSet(name,OBJPROP_COLOR,theColor);
              }
            }
   }
   
   //
   //
   //
   //
   //
   
   if (alertsOn)
   {
      if (alertsOnCurrent)
           int whichBar = 0;
      else     whichBar = 1;
      
      //
      //
      //
      //
      //
      
      if (alertsOnSlope)
      {
         if (slope[whichBar] != slope[whichBar+1])
         {
            if (slope[whichBar] == 1) doAlert(whichBar,"slope changed to up");
            if (slope[whichBar] ==-1) doAlert(whichBar,"slope changed to down");
         }         
      }
      else
      {
         if (trend[whichBar] != trend[whichBar+1])
         {
            if (trend[whichBar] == 1) doAlert(whichBar,"crossed zero line up");
            if (trend[whichBar] ==-1) doAlert(whichBar,"crossed zero line down");
         }         
      }         
   }
   return(0);
   }      
   
   //
   //
   //
   //
   //
   
   limit = MathMax(limit,MathMin(Bars-1,iCustom(NULL,TimeFrame,indicatorFileName,-99,0,0)*TimeFrame/Period()));
    for(i=limit; i >= 0; i--)  
    {
       int y = iBarShift(NULL,TimeFrame,Time[i]);
          buffer1[i] = iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,period,PriceType,PriceSmoothing,IndexSmoothing,HistogramOnSlope,alertsOn,alertsOnSlope,alertsOnCurrent,alertsMessage,alertsSound,alertsNotify,alertsEmail,soundFile,ShowLines,linesID,linesUpColor,linesDnColor,linesStyle,linesWidth,linesOnFirst,0,y);
          buffer2[i] = iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,period,PriceType,PriceSmoothing,IndexSmoothing,HistogramOnSlope,alertsOn,alertsOnSlope,alertsOnCurrent,alertsMessage,alertsSound,alertsNotify,alertsEmail,soundFile,ShowLines,linesID,linesUpColor,linesDnColor,linesStyle,linesWidth,linesOnFirst,1,y);
          buffer3[i] = iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,period,PriceType,PriceSmoothing,IndexSmoothing,HistogramOnSlope,alertsOn,alertsOnSlope,alertsOnCurrent,alertsMessage,alertsSound,alertsNotify,alertsEmail,soundFile,ShowLines,linesID,linesUpColor,linesDnColor,linesStyle,linesWidth,linesOnFirst,2,y);
          buffer4[i] = iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,period,PriceType,PriceSmoothing,IndexSmoothing,HistogramOnSlope,alertsOn,alertsOnSlope,alertsOnCurrent,alertsMessage,alertsSound,alertsNotify,alertsEmail,soundFile,ShowLines,linesID,linesUpColor,linesDnColor,linesStyle,linesWidth,linesOnFirst,3,y);
          buffer5[i] = iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,period,PriceType,PriceSmoothing,IndexSmoothing,HistogramOnSlope,alertsOn,alertsOnSlope,alertsOnCurrent,alertsMessage,alertsSound,alertsNotify,alertsEmail,soundFile,ShowLines,linesID,linesUpColor,linesDnColor,linesStyle,linesWidth,linesOnFirst,4,y);
          
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
             for(int x = 1; x < n; x++) 
             {
                buffer5[i+x] = buffer5[i] + (buffer5[i+n] - buffer5[i]) * x/n;
                if (buffer1[i]!= EMPTY_VALUE) buffer1[i+x] = buffer5[i+x];
                if (buffer2[i]!= EMPTY_VALUE) buffer2[i+x] = buffer5[i+x];
                if (buffer3[i]!= EMPTY_VALUE) buffer3[i+x] = buffer5[i+x];
                if (buffer4[i]!= EMPTY_VALUE) buffer4[i+x] = buffer5[i+x];
             }                                       
      }
   return(0);
} 

//+-------------------------------------------------------------------
//|                                                                  
//+-------------------------------------------------------------------
//
//
//
//
//

void doAlert(int forBar, string doWhat)
{
   static string   previousAlert="nothing";
   static datetime previousTime;
   string message;
   
      if (previousAlert != doWhat || previousTime != Time[forBar]) {
          previousAlert  = doWhat;
          previousTime   = Time[forBar];

          //
          //
          //
          //
          //

           message =  StringConcatenate(Symbol()," ",timeFrameToString(_Period)," at ",TimeToStr(TimeLocal(),TIME_SECONDS)," Ehlers Fisher Transform  ",doWhat);
             if (alertsMessage) Alert(message);
             if (alertsNotify)  SendNotification(message);
             if (alertsEmail)   SendMail(StringConcatenate(Symbol(), Period(), " Ehlers Fisher Transform "),message);
             if (alertsSound)   PlaySound("alert2.wav");
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

string sTfTable[] = {"M1","M5","M15","M30","H1","H4","D1","W1","MN"};
int    iTfTable[] = {1,5,15,30,60,240,1440,10080,43200};

string timeFrameToString(int tf)
{
   for (int i=ArraySize(iTfTable)-1; i>=0; i--) 
         if (tf==iTfTable[i]) return(sTfTable[i]);
                              return("");
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
 