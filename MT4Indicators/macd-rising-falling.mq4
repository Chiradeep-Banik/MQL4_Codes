// MACD rising-falling.mq4

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 LimeGreen
#property indicator_color2 Red
#property indicator_color3 Gold
#property indicator_width1 2
#property indicator_width2 2

//
//
//
//
//

extern double FastEma   = 12;
extern double SlowEma   = 26;
extern double SignalEma =  9;
extern int    Price     = PRICE_CLOSE;
extern bool   ShowOsma  = false;

double histUp[];
double histDn[];
double histNe[];


//------------------------------------------------------------------
//
//------------------------------------------------------------------
int init()
{
   SetIndexBuffer(0,histUp); SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(1,histDn); SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexBuffer(2,histNe); SetIndexStyle(2,DRAW_HISTOGRAM);
   return(0);
}
int deinit()
{
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

double work[][8];
#define _fastEma 0
#define _slowEma 1
#define _signEma 2
#define _hist    3
#define _trend   4
#define _state   5
#define _currmx  6
#define _currmn  7

int start() 
{
   int i,r,counted_bars=IndicatorCounted();
      if(counted_bars<0) return(-1);
      if(counted_bars>0) counted_bars--;
         int limit = MathMin(Bars-counted_bars,Bars-1);
         if (ArrayRange(work,0)!=Bars) ArrayResize(work,Bars);
         
         
         //
         //
         //
         //
         //
         

   double alphaF = 2.0/(1.0+FastEma);
   double alphaS = 2.0/(1.0+SlowEma);
   double alphaI = 2.0/(1.0+SignalEma);
   for(i=limit, r=Bars-i-1; i>=0; i--,r++)
   {
      double price = iMA(NULL,0,1,0,MODE_SMA,Price,i);
         work[r][_fastEma] = work[r-1][_fastEma]+alphaF*(price-work[r-1][_fastEma]);
         work[r][_slowEma] = work[r-1][_slowEma]+alphaS*(price-work[r-1][_slowEma]);
      double macd = work[r][_fastEma]-work[r][_slowEma];
         if (ShowOsma)
         {
            work[r][_signEma] = work[r-1][_signEma]+alphaI*(macd -work[r-1][_signEma]);
            work[r][_hist]    = macd-work[r][_signEma];
         }            
         else work[r][_hist] = macd;   
              work[r][_trend]   = work[r-1][_trend];
              work[r][_currmx]  = work[r-1][_currmx];
              work[r][_currmn]  = work[r-1][_currmn];
              work[r][_state]   = 0;
                  if (work[r][_hist]>0) { work[r][_trend] =  1; work[r][_currmn] = 0; if (work[r][_hist]>work[r][_currmx]) { work[r][_currmx]=work[r][_hist]; work[r][_state]= 1; }}
                  if (work[r][_hist]<0) { work[r][_trend] = -1; work[r][_currmx] = 0; if (work[r][_hist]<work[r][_currmn]) { work[r][_currmn]=work[r][_hist]; work[r][_state]=-1; }}
      
         //
         //
         //
         //
         //
         
         histUp[i] = EMPTY_VALUE;
         histDn[i] = EMPTY_VALUE;
         histNe[i] = EMPTY_VALUE;
            if (work[r][_state]==-1) histDn[i] = work[r][_hist];
            if (work[r][_state]== 1) histUp[i] = work[r][_hist];
            if (work[r][_state]== 0) histNe[i] = work[r][_hist];
   }
   return(0);
}