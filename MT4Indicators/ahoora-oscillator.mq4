//+------------------------------------------------------------------+
//| Ahoora.mq4.mq4
//| Copyright © 2010, Farshad Saremifar, Farshad.saremifar@gmail.com
//| Farshad.saremifar@gmail.com
//+------------------------------------------------------------------+
#property copyright ""
#property link      ""

#property indicator_separate_window
#property indicator_minimum 0
#property indicator_maximum 100

#property indicator_buffers 3
#property indicator_color1 Lime
#property indicator_color2 Red
#property indicator_color3 Khaki

#property indicator_width1 3
#property indicator_width2 3
#property indicator_width3 1

#property indicator_style3 STYLE_DASHDOTDOT
#property indicator_level1 10
#property indicator_level2 20
#property indicator_level3 30
#property indicator_level4 50
#property indicator_level5 70
#property indicator_level6 80
#property indicator_level7 90
extern string Copyright="Version 1.1 :Farshad Saremifar";
extern int Lookback = 25;
extern int ma_method=1;
 bool FillHole=true;
double up[];
double down[];
double Up[];
double buffer[];
double value[];
double value2[];
double value3[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
IndicatorBuffers(5);
SetIndexBuffer(0, up);
SetIndexStyle(0, DRAW_LINE);
SetIndexBuffer(1, down);
SetIndexStyle(1, DRAW_LINE);
SetIndexBuffer(2, value2);
SetIndexStyle(2, DRAW_LINE);   
 SetIndexDrawBegin(2,Lookback);   
SetIndexBuffer(3, value);
SetIndexStyle(3, DRAW_NONE);
//SetIndexEmptyValue(3,0.0);
//SetIndexEmptyValue(2,0.0);
SetIndexBuffer(4, buffer);
    SetIndexEmptyValue( 0, EMPTY_VALUE );
   SetIndexEmptyValue( 1, EMPTY_VALUE );  
 SetIndexDrawBegin(0,Lookback);  
 SetIndexDrawBegin(1,Lookback);  
 SetIndexDrawBegin(3,Lookback);  
 SetIndexDrawBegin(4,Lookback);  
   
   IndicatorShortName("Ahoora Version 1.1:By farshad saremifar " );
  
  
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
  
   
 int bars;
   int    counted_bars=IndicatorCounted();
  
 
   if (counted_bars < 0) return (-1);
   if (counted_bars > 0) counted_bars--;
   //if (FillHole) bars = Bars-counted_bars;
    bars = Bars-counted_bars;
  
//----
   for (int i = bars-1; i >= 0; i--) {
     // buffer[i] = buffer[i + 1];
     // value[i]=value[i+1];
      RefreshRates();
      if (High[i] > iMA(Symbol(), 0, Lookback, 0, ma_method, PRICE_HIGH, i )) buffer[i] = 1;
      if (Low[i] < iMA(Symbol(), 0, Lookback, 0, ma_method, PRICE_LOW, i)) buffer[i] = -1; 
     
      
   
   
     
   } 
for ( i = bars-1; i >= 0; i--) {   
 if (buffer[i] < 0) {
     value[i]=iMA(Symbol(), 0, Lookback, 0, ma_method, PRICE_HIGH, i)-iATR(Symbol(),0,Lookback,i);
     
     } else {
    
      value[i]=iATR(Symbol(),0,Lookback,i)+iMA(Symbol(), 0, Lookback, 0, ma_method, PRICE_LOW, i );
     }   
  } 
//----
int j=0;
if (FillHole) j=1;
   else j = 0;
   
for ( i = bars-1; i >= 0; i--)
{ 
 
value2[i]=iRSIOnArray(value,0,Lookback,i);
  
   
 }
for ( i = bars; i >= 0; i--)
{ 
  if (buffer[i] < 0) {
         down[i] = value2[i];
         up[i] = EMPTY_VALUE;
      } else if (buffer[i] > 0){
         down[i] =EMPTY_VALUE;
         up[i] = value2[i];
      }
      
}      
   return(0);
  }
//+------------------------------------------------------------------+