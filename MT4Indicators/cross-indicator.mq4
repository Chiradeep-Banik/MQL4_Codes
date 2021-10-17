/*[[
	Name := EMA Cross
	Author := Hapsa
	Link := http://www.metaquotes.net/
	Separate Window := No
	Separate Window := No
	First Color := Red
	First Draw Type := Symbol
	First Symbol := 108
	Use Second Data := Yes
	Second Color := DarkOliveGreen
	Second Draw Type := Symbol
	Second Symbol := 108
]]*/


#property copyright ""
#property link      ""
extern int SlowPeriod=20;
extern int FastPeriod=5;

#property indicator_buffers 3
#property indicator_chart_window
#property indicator_color1 Red
#property indicator_color2 Green
double L20[];
double L50[];
double shift=0,val1=0,val2=0;

int init()
  {
  
IndicatorBuffers(3);
SetIndexStyle(0,DRAW_ARROW); 
SetIndexStyle(1,DRAW_ARROW); 

SetIndexArrow(0, 108);
SetIndexArrow(1, 108);

SetIndexBuffer(0,L20);
SetIndexBuffer(1,L50);


  

//---- indicators
//----
   return(0);
  }





int start()
  {
   
   
   int    counted_bars=IndicatorCounted();
//---- 
   int i = Bars - counted_bars - 1;
   while (i>=0)
   {
   
   val1=0;
	val2=0;
	
	double iMaSlowPrevious = iMA(NULL,0,SlowPeriod,0,MODE_EMA, PRICE_CLOSE, i-1);
	double iMaSlowCurrent = iMA(NULL,0,SlowPeriod,0,MODE_EMA, PRICE_CLOSE, i);
	double iMaFastPrevious = iMA(NULL,0,FastPeriod,0,MODE_EMA, PRICE_CLOSE, i-1);
	double iMaFastCurrent = iMA(NULL,0,FastPeriod,0,MODE_EMA, PRICE_CLOSE, i);
   
   if (iMaFastPrevious<iMaSlowPrevious && iMaFastCurrent>iMaSlowCurrent ) val1=High[i];
   if (iMaFastPrevious>iMaSlowPrevious && iMaFastCurrent<iMaSlowCurrent ) val2=Low[i];   
    L20[i]=val1+5*Point;
    L50[i]=val2-5*Point;
     i--;
   }

//----
   return(0);
}