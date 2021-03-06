
//------------------------------------------------------------------
#property copyright   ""
#property link        ""
#property version     ""
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 6
#property indicator_color1  clrGainsboro
#property indicator_color2  clrGainsboro
#property indicator_color3  clrLimeGreen
#property indicator_color4  clrRed
#property indicator_color5  clrLimeGreen
#property indicator_color6  clrRed
#property indicator_style3  STYLE_DOT
#property indicator_style4  STYLE_DOT
#property indicator_width5  2
#property indicator_width6  2
#property strict

//---
//
input string    inpStartTime = "00:00";      // Start time
input string    inpEndTime   = "03:59";      // Ending time
input bool      ShowBars     = true;         // Show Breakout bars?

//
//---
//
double  fillu[],filld[],limu[],limd[],histou[],histod[],histoc[];

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

int OnInit()
{  
   IndicatorBuffers(7);
   SetIndexBuffer(0,fillu); SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(1,filld); SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(2,limu);  SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(3,limd);  SetIndexStyle(3,DRAW_LINE);
   SetIndexBuffer(4,histou);SetIndexStyle(4,ShowBars ? DRAW_HISTOGRAM : DRAW_NONE); 
   SetIndexBuffer(5,histod);SetIndexStyle(5,ShowBars ? DRAW_HISTOGRAM : DRAW_NONE); 
   SetIndexBuffer(6,histoc);
   
 
//
//---
//
   if (_Period>=PERIOD_D1)
   {
      Alert("Indicator can work on time frames less than daily only");  return(INIT_FAILED);
   }
   IndicatorShortName("Channel "+inpStartTime+" "+inpEndTime+" breakout");
   return(INIT_SUCCEEDED);
}
void OnDeinit(const int reason) { }

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime& time[],
                const double& open[],
                const double& high[],
                const double& low[],
                const double& close[],
                const long& tick_volume[],
                const long& volume[],
                const int& spread[])
{
   int i,counted_bars = prev_calculated;
   if(counted_bars < 0) return(-1);
   if(counted_bars > 0) counted_bars--;
         int limit=MathMin(rates_total-counted_bars,rates_total-1);
   
   //
   //
   //
   //
   //
   
   int _secondsStart = (int)StringToTime("1970.01.01 "+inpStartTime);
   int _secondsEnd   = (int)StringToTime("1970.01.01 "+inpEndTime);
   for (i=limit;i>=0; i--)
   {
      datetime _startTime = StringToTime(TimeToString(Time[i],TIME_DATE))+_secondsStart;
      datetime _endTime   = StringToTime(TimeToString(Time[i],TIME_DATE))+_secondsEnd;
      double max = ((i<Bars-1) ? limu[i+1] : High[i]), min = ((i<Bars-1) ? limd[i+1] : Low[i]);
         if (_startTime<= Time[i] && _endTime>=Time[i])
         {
            max = High[i];
            min =  Low[i];
            for (int k=1; i+k>=0 && Time[i+k]>=_startTime; k++)
            {
               max = fmax(max,High[i+k]);
               min = fmin(min,Low[i+k]);
            }
         }                           
      limu[i] = max;
      limd[i] = min;
              
         if (_startTime<=Time[i] && _endTime>=Time[i])
        { 
            fillu[i]  = max;            
            filld[i]  = min;
            histou[i] = EMPTY_VALUE;
            histod[i] = EMPTY_VALUE; 
         }
         else 
         {  
            fillu[i]  = (limu[i]+limd[i])*0.5;
            filld[i]  = (limu[i]+limd[i])*0.5;
            histoc[i] = (i<Bars-1) ? (Close[i]>limu[i]) ? 1 : (Close[i]<limd[i]) ? -1 : (Close[i]<limu[i] && Close[i]>limd[i]) ? 0 : histoc[i+1] : 0;  
            if (histoc[i] == 1) { histou[i] = High[i]; histod[i] = Low[i]; }
            if (histoc[i] ==-1) { histod[i] = High[i]; histou[i] = Low[i]; }      
         }  
   }      
   return(rates_total);
}