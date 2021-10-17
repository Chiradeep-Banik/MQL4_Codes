
//+------------------------------------------------------------------+
//|  VarBreakInd.mq4                                              |
//|  Michal                                                          |
//|                                                                  |
//+------------------------------------------------------------------+

#property copyright "Copyright Shimodax, modified by MR"
#property link      "http://www.strategybuilderfx.com/forums/showthread.php?t=15439"


/* Introduction:

   Draw ranges for "Simple Combined Breakout System for EUR/USD and GBP/USD" thread
   (see http://www.strategybuilderfx.com/forums/showthread.php?t=15439)

   LocalTimeZone: TimeZone for which MT4 shows your local time, 
                  e.g. 1 or 2 for Europe (GMT+1 or GMT+2 (daylight 
                  savings time).  Use zero for no adjustment.
                  
                  The MetaQuotes demo server uses GMT +2.   
   Enjoy  :-)
   
   Markus

*/


#property indicator_chart_window
#property indicator_buffers 5
#property indicator_color1 Yellow
#property indicator_color2 Yellow
#property indicator_color3 Green
#property indicator_color4 Green
#property indicator_color5 Blue


extern int LocalTimeZone= 0;
extern int DestTimeZone= 0;
extern int PipsForEntry= 7;
extern int StartHour = 2;     // Hour to start in server time zone
extern int StartMinute = 30;  // Minute to start in server timezone
extern int Duration = 240;    // Duration in minutes




double Zone1Upper[];
double Zone2Upper[];
double Zone1Lower[];
double Zone2Lower[];
double SignalsBuffer[];
       



//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,Zone1Upper);
   SetIndexEmptyValue(0, 0.0);

   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,Zone1Lower);
   SetIndexEmptyValue(1, 0.0);

   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,Zone2Upper);
   SetIndexEmptyValue(2, 0.0);

   SetIndexStyle(3,DRAW_LINE);
   SetIndexBuffer(3,Zone2Lower);
   SetIndexEmptyValue(3, 0.0);

   SetIndexStyle(4,DRAW_ARROW);
   SetIndexArrow(4, 156);
   SetIndexBuffer(4, SignalsBuffer);

   return(0);
}

int deinit()
{

   return(0);
}
  
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
{
   int counted_bars= IndicatorCounted(),
         lastbar, result;

   if (Bars<=100) 
      return(0);
      
   if (counted_bars>0)
      counted_bars--;
      
   lastbar= Bars - counted_bars;
   
   BreakoutRanges(0, lastbar, LocalTimeZone, DestTimeZone);
   
   return(0);
}

 
//+------------------------------------------------------------------+
//| Compute index of first/last bar of yesterday and today           |
//+------------------------------------------------------------------+
int BreakoutRanges(int offset, int lastbar, int tzlocal, int tzdest)
{     
   int i, j, k,
       tzdiff= tzlocal - tzdest,
       tzdiffsec= tzdiff*3600, 
       tidxstart[2]= { 0, 0}, 
       tidxend[2]= { 0, 0 };
   double thigh[2]= { 0.0, 0.0 }, 
          tlow[2]= { 99999.9, 99999.9 };
   double Spread = Ask-Bid;        
           
   datetime ct = CurTime();
   datetime time_from = StrToTime(TimeYear(ct)+"."+TimeMonth(ct)+"."+TimeDay(ct)+" "+
                                  StartHour+":"+StartMinute);
   datetime time_to = time_from + Duration*60;
   
   string tfrom[3]= { "04:00", "08:00" ,  /*rest of day: */ "12:00"},
          tto[3]=   { "08:00", "12:00",   /*rest of day: */ "24:00" },
          tday;
   tfrom[0] = TimeToStr(time_from, TIME_MINUTES);
   tto[0] = TimeToStr(time_to, TIME_MINUTES);
   tfrom[1] = TimeToStr(time_to, TIME_MINUTES);
   tto[1] = TimeToStr(time_to+60, TIME_MINUTES);
   //tfrom[2] = TimeToStr(time_to+60, TIME_MINUTES);
   //tto[2] = TimeToStr(time_to+60, TIME_MINUTES);
   //Print(TimeToStr(time_from, TIME_MINUTES),"->",TimeToStr(time_to, TIME_MINUTES));
   bool inperiod= -1;
   datetime timet;
   

   //
   // search back for the beginning of the day
   //
   tday= TimeToStr(Time[lastbar]-tzdiffsec, TIME_DATE);   
   for (  ; lastbar<Bars; lastbar++) {
      if (TimeToStr(Time[lastbar] - tzdiffsec, TIME_DATE)!=tday) {
         lastbar--;
         break;      
      }
   }   



   //
   // find the high/low for the two periods and carry them forward through the day
   //
   tday= "XXX";
   for (i= lastbar; i>=offset; i--) {
   
      timet= Time[i] - tzdiffsec;   // time of this bar
      
      string timestr= TimeToStr(timet, TIME_MINUTES),    // current time HH:MM
             thisday= TimeToStr(timet, TIME_DATE);       // current date
             
          
      //
      // for all three periods (first period, second period, rest of day)
      //
      for (j= 0; j<3; j++) {
      
         if (tfrom[j]<=timestr && timestr<tto[j]) {   // Bar[i] in this period
      
            if (inperiod!=j) { // entered new period, so last one is completed
                                 
               if (j>0) {      // now draw high/low back over the recently completed period
               
                  for (k= tidxstart[j-1]; k>=tidxend[j-1]; k--) {
                     if (j-1==0) {
                        Zone1Upper[k]= thigh[j-1];
                        Zone1Lower[k]= tlow[j-1];
                     }

                  }
               }
               
               inperiod= j;   // remember current period
            }
            
            if (inperiod==2)   // inperiod==2 (end of day) is just to check completion of zone 2
               break;


            // for the current period find idxstart, idxend and compute high/low
            if (tidxstart[j]==0) {
               tidxstart[j]= i;
               tday= thisday;
            }
         
            tidxend[j]= i;
      
            thigh[j]= MathMax(thigh[j], High[i]);
            tlow[j]= MathMin(tlow[j], Low[i]);
         }
      }
      
      
      // 
      // carry forward the periods for which we have definite high/lows
      //
      if (inperiod>=1 && tday==thisday) { // first time period completed
         Zone1Upper[i]= thigh[0] + PipsForEntry*Point/*+Spread*/;
         Zone1Lower[i]= tlow[0] - PipsForEntry*Point;
         
      }
      else {   // none yet to carry forward (zero to clear old values, e.g. from switching timeframe)
         Zone1Upper[i]= 0;
         Zone1Lower[i]= 0;
         Zone2Upper[i]= 0;
         Zone2Lower[i]= 0;
      }
     

      //
      // at the beginning of a new day reset everything
      //
      if (tday!="XXX" && tday!=thisday) {
         //Print("#", i, "new day ", thisday, "/", tday);
      
         tday= "XXX";
         
         inperiod= -1;
         
         for (j= 0; j<2; j++) {
            tidxstart[j]= 0;
            tidxend[j]= 0;
         
            thigh[j]= 0;
            tlow[j]= 99999;
         }
      }
   }

   return (0);       
}


