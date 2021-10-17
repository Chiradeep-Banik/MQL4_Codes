//+------------------------------------------------------------------+
//|                                          VininI_MV_MA_WPR_v1.mq4 |
//|                                         Victor Nicolaev aka Vinin|
//|                                                    vinin@mail.ru |
//+------------------------------------------------------------------+
#property copyright ""
#property link      ""

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Aqua

#property indicator_level1 0
#property indicator_level2 60
#property indicator_level3 -60

#property indicator_maximum 100
#property indicator_minimum -100
//---- input parameters

extern string WPR_Symbol="GBPUSD";
extern int MA_Period=5;
extern int MA_Mode=0;
extern int WPR_Period= 14;
extern int Limit=1440;

double WPR[];
double MA[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init() {
   IndicatorBuffers(2);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexDrawBegin(0,WPR_Period+MA_Period);
   SetIndexBuffer(0,MA);
   SetIndexBuffer(1,WPR);
   IndicatorShortName(WPR_Symbol+"(WPR,"+WPR_Period+")");
   SetIndexLabel(0,WPR_Symbol+"(WPR)");
   return(0); }

//+------------------------------------------------------------------+
int start() {
   static int TimeWPR=-1;
   int limit;
   int counted_bars=IndicatorCounted();
   int i, CurrentTime, WPRPos;

   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;

   if (limit>Limit && Limit>0) limit = Limit;
   if (TimeWPR>0) limit+=iBarShift(WPR_Symbol,Period(),TimeWPR);
   for (i = limit;i>=0;i--){
      CurrentTime=Time[i];
      WPRPos=iBarShift(WPR_Symbol,Period(),CurrentTime);
      if (iTime(WPR_Symbol,Period(),WPRPos)<CurrentTime) WPRPos++;
      WPR[i] = (iWPR(WPR_Symbol,Period(),WPR_Period,WPRPos)+50.0)*2.0;
   }
   for (i = limit;i>=0;i--) MA[i] = iMAOnArray(WPR,0,MA_Period,0,MA_Mode,i);
   TimeWPR=iTime(WPR_Symbol,Period(),0);
   

   return(0); 
}// int start()


