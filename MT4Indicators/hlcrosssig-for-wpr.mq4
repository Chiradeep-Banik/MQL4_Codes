//+------------------------------------------------------------------+
//|                                      HL Cross Signal for WPR.mq4 |
//|                                 Copyright © 2008, Bigeev Rustem. |
//|                                             http://www.parch.ru/ |
//+------------------------------------------------------------------+

#property indicator_chart_window
#property indicator_buffers 6

//---- input parameters
extern int CountBars=1500;   // Количество баров для расчета индикатора
extern int P=6;              // Параметр пробиваемого диапазона, чем больше значение, тем более поздние сигналы и реже.
extern int PMA=21;           // Параметр для "Heiken Ashi variable" - служит в качестве доп. фильтра.
extern int Risk=0;           // Максимальный риск в пипсах для расчета уровня входа исходя из уровня ближайшего MAX/MIN
extern int ATR_P=120;        // Параметр для АТR служит для расчета уровня волатильности.
extern double Q=0.7;         // Параметр для постановки Тейка. - Доля от размера Стопа. если =1, Тейк = Стопу.
extern int Period_WPR=12;    // Параметры для "WPR" - служит в качестве доп. фильтра.
extern int HLine=-38;        // Верхняя сигнальная линия для WPR
extern int LLine=-62;        // Нижняя сигнальная линия для WPR

//---- buffers
double val1[];
double val2[];
double val3[];
double val4[];
double val5[];
double val6[];
double HAClose, HAOpen, HAClose1, HAOpen1;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   string short_name;
//---- indicator line
   IndicatorBuffers(6);
   SetIndexBuffer(0,val1);
   SetIndexBuffer(1,val2);
   SetIndexBuffer(2,val3);
   SetIndexBuffer(3,val4);
   SetIndexBuffer(4,val5);
   SetIndexBuffer(5,val6);
   
   SetIndexStyle(0,DRAW_ARROW,EMPTY,1,Red);
   SetIndexArrow(0,234);
   SetIndexStyle(1,DRAW_ARROW,EMPTY,1,Blue);
   SetIndexArrow(1,233); 
   SetIndexStyle(2,DRAW_ARROW,EMPTY,1,DarkOrange);
   SetIndexArrow(2,251); 
   SetIndexStyle(3,DRAW_ARROW,EMPTY,1,Yellow);
   SetIndexArrow(3,158); 
   SetIndexStyle(4,DRAW_ARROW,EMPTY,1,Magenta);
   SetIndexArrow(4,4); 
   SetIndexStyle(5,DRAW_ARROW,EMPTY,1,Magenta);
   SetIndexArrow(5,4); 

   SetIndexDrawBegin(0,Bars-CountBars);
   SetIndexDrawBegin(1,Bars-CountBars);
   SetIndexDrawBegin(2,Bars-CountBars);
   SetIndexDrawBegin(3,Bars-CountBars);
   SetIndexDrawBegin(4,Bars-CountBars);
   SetIndexDrawBegin(5,Bars-CountBars);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| HA Cross Signal
//+------------------------------------------------------------------+
int start()
  {      
   if (CountBars>=Bars) CountBars=Bars;

   int i,shift,counted_bars=IndicatorCounted();
   static int Flag=1;
   double LHigh,LLow,ATR,WPR_Filter,Median;
      //---- check for possible errors
   if(counted_bars<0) return(-1);

   //---- initial zero
   if(counted_bars<1)
     {
      for(i=1;i<=CountBars;i++) val1[CountBars-i]=0.0;
      for(i=1;i<=CountBars;i++) val2[CountBars-i]=0.0;
      for(i=1;i<=CountBars;i++) val3[CountBars-i]=0.0;
      for(i=1;i<=CountBars;i++) val4[CountBars-i]=0.0;
     } 
 for (shift = CountBars; shift>=0; shift--) 
 { 
	HAOpen=iMA(NULL,0,PMA,0,MODE_SMA,PRICE_MEDIAN,shift);
   Median=iMA(NULL,0,1,0,MODE_SMA,PRICE_MEDIAN,shift);
   LHigh=iHigh(NULL,0,iHighest(NULL,0,MODE_HIGH,P,shift+1));
   LLow=iLow(NULL,0,iLowest(NULL,0,MODE_LOW,P,shift+1));
   WPR_Filter=iWPR(NULL,0,Period_WPR,shift);
   ATR=iATR(NULL,0,ATR_P,shift);

	// Условие сигнала на покупку
	if ((High[shift] >= LHigh && Close[shift] > Median && Close[shift] > HAOpen && High[shift] > HAOpen  && WPR_Filter >=HLine && Flag<0)|| 
	    (Close[shift] >= val3[shift+1] && High[shift] > LHigh && Flag<0))  
	    //|| (Median > HAClose && Median > (HAClose-HAOpen)/2 && HAClose < HAOpen && WPR_Filter >= -50 && Flag <0)) //||
	
   {
     val2[shift]= MathMin(Close[shift],(LLow+2*ATR));
     if (Risk != 0 && val2[shift]-LLow > Risk*Point) val2[shift]=LLow+Risk*10*Point; //Q=Q/2;
	  if (Close[shift] < LLow + Risk*10*Point) val2[shift]= Close[shift];
	  Flag=1;
   }    
   if (Flag>0) {val3[shift]=LLow-(Ask-Bid)*2; val4[shift]=LHigh+(Ask-Bid)*3;}  // Уровень постановки Трейлинг Стопа
      val5[shift]=val2[shift]+(val2[shift]-val3[shift])*Q;               


   // Условие сигнала на продажу
   if ((Low[shift] <= LLow && Close[shift] < Median && Close[shift] < HAOpen && Low[shift] < HAOpen  && WPR_Filter <=LLine && Flag>0) || 
       (Close[shift] <= val3[shift+1] && Low[shift] < LLow && Flag>0)) 
       // ||(Median < HAClose && Median > (HAOpen-HAClose)/2 && HAClose > HAOpen && WPR_Filter <= -50 && Flag >0)) // || 

   {
     val1[shift]= MathMax(Close[shift],(LHigh-2*ATR));
     if (Risk != 0 && LHigh-val1[shift] > Risk*Point) val1[shift]=LHigh-Risk*10*Point; //Q=Q/2;
     if (Close[shift] > LHigh - Risk*10*Point) val1[shift]= Close[shift];
	  Flag=-1;
	}
   if (Flag<0) {val3[shift]=LHigh+(Ask-Bid)*3; val4[shift]=LLow-(Ask-Bid)*2;} // Уровень постановки Трейлинг Стопа
       val6[shift]=val1[shift]-(val3[shift]-val1[shift])*Q+(Ask-Bid);               
 }  
 
 return(0);
}
//+------------------------------------------------------------------+