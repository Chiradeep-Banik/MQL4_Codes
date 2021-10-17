//+------------------------------------------------------------------+
//|                                                 VininI_Trend.mq4 |
//|                                  Ñopyright 2008. Victor Nicolaev |
//|                                                    vinin@mail.ru |
//+------------------------------------------------------------------+
#property copyright ""
#property link      ""


#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Yellow
#property indicator_level1 0
#property indicator_maximum 1
#property indicator_minimum -1


extern int MA_Start=10;
extern int MA_Step=10;
extern int MA_Count=50;
extern int MA_Mode=0;
extern int Limit=1440;
//---- buffers
double Buffer[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init() {
//---- drawing settings
   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(0,Buffer);

   return(0); }//int init() 
   
//+------------------------------------------------------------------+
int start() {
   int limit;
   int counted_bars=IndicatorCounted();
   int i,j;
   double sum=0;
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
   if (Limit>0) limit=MathMin(Limit,limit); 
   for (i = limit;i>=0;i--){
      sum=0;
      for (j=0;j<MA_Count;j++) if (Close[i]>iMA(NULL,0,MA_Start+j*MA_Step,0,MA_Mode,PRICE_CLOSE,i)) sum+=1; else sum-=1;
      Buffer[i]=sum/MA_Count;
   }

   

   return(0); 
}

   