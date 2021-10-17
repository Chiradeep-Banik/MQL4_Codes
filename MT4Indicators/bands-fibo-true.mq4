//+------------------------------------------------------------------+
//|                                                   Bands+Fibo.mq4 |
//|                                                                  |
//|                                                                  |
//+------------------------------------------------------------------+
#property indicator_chart_window
#property indicator_buffers 7
#property indicator_color1 Blue 
#property indicator_color2 Green
#property indicator_color3 Green
#property indicator_color4 Red 
#property indicator_color5 LightSeaGreen
#property indicator_color6 Red
#property indicator_color7 LightSeaGreen


//---- indicator parameters
extern int    BandsPeriod=20;
extern int    BandsShift=0;
extern int    PeriodsATR= 20;
//---- buffers
double MovingBuffer[];
double UpperBuffer[];
double UpperBuffer2[];
double UpperBuffer3[];
double LowerBuffer[];
double LowerBuffer2[];
double LowerBuffer3[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_LINE,STYLE_DOT);  
   SetIndexBuffer(0,MovingBuffer);
   SetIndexStyle(1,DRAW_LINE,STYLE_SOLID);
   SetIndexBuffer(1,UpperBuffer);
   SetIndexStyle(2,DRAW_LINE,STYLE_SOLID);
   SetIndexBuffer(2,LowerBuffer);
   SetIndexStyle(3,DRAW_LINE,STYLE_SOLID);
   SetIndexBuffer(3,UpperBuffer2);
   SetIndexStyle(4,DRAW_LINE,STYLE_SOLID,2);
   SetIndexBuffer(4,UpperBuffer3);
   SetIndexStyle(5,DRAW_LINE,STYLE_SOLID);
   SetIndexBuffer(5,LowerBuffer2);
   SetIndexStyle(6,DRAW_LINE,STYLE_SOLID,2);
   SetIndexBuffer(6,LowerBuffer3);
//----
   SetIndexDrawBegin(0,BandsPeriod+BandsShift);
   SetIndexDrawBegin(1,BandsPeriod+BandsShift);
   SetIndexDrawBegin(2,BandsPeriod+BandsShift);
   SetIndexDrawBegin(3,BandsPeriod+BandsShift);
   SetIndexDrawBegin(4,BandsPeriod+BandsShift);
   SetIndexDrawBegin(5,BandsPeriod+BandsShift);
   SetIndexDrawBegin(6,BandsPeriod+BandsShift);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Bollinger Bands                                                  |
//+------------------------------------------------------------------+
int start()
  {
   int    i,k,counted_bars=IndicatorCounted();
   double deviation;
   double sum,oldval,newres;
//----
   if(Bars<=BandsPeriod) return(0);
//---- initial zero
   if(counted_bars<1)
      for(i=1;i<=BandsPeriod;i++)
        {
         MovingBuffer[Bars-i]=EMPTY_VALUE;
         UpperBuffer[Bars-i]=EMPTY_VALUE;
         UpperBuffer2[Bars-i]=EMPTY_VALUE;
         UpperBuffer3[Bars-i]=EMPTY_VALUE;
         LowerBuffer[Bars-i]=EMPTY_VALUE;
         LowerBuffer2[Bars-i]=EMPTY_VALUE;
         LowerBuffer3[Bars-i]=EMPTY_VALUE;
        }
//----
   int limit=Bars-counted_bars;
   if(counted_bars>0) limit++;
   for(i=0; i<limit; i++)
      MovingBuffer[i]=iMA(NULL,0,BandsPeriod,BandsShift,MODE_SMA,PRICE_CLOSE,i);
//----
   i=Bars-BandsPeriod+1;
   if(counted_bars>BandsPeriod-1) i=Bars-counted_bars-1;
   while(i>=0)
     {
      sum=0.0;
      k=i+BandsPeriod-1;
      oldval=MovingBuffer[i];
      
      
      deviation=iATR(NULL,0,PeriodsATR,i);
      UpperBuffer[i]=oldval+deviation*1.618;
      UpperBuffer2[i]=oldval+deviation*2.618;
      UpperBuffer3[i]=oldval+deviation*4.236;
      LowerBuffer[i]=oldval-deviation*1.618;
      LowerBuffer2[i]=oldval-deviation*2.618;
      LowerBuffer3[i]=oldval-deviation*4.236; 
      i--; 
     }
//----
   return(0);
  }
//+------------------------------------------------------------------+