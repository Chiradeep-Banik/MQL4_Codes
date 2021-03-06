//+------------------------------------------------------------------+
//|                     PrizeMA Convergence Divergence_s4_s2_p72.mq4 |
//|                                Copyright 2016, Aleksey Panfilov. |
//|                                                filpan1@yandex.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2016, Aleksei Panfilov. filpan1@yandex.ru"
#property link      "filpan1@yandex.ru"
#property version   "1.1"
#property description    "PrizeMA Convergence Divergence_s4_s2_p72"
#property strict

#include <MovingAverages.mqh>


#property indicator_separate_window
#property indicator_buffers 6
#property indicator_plots   2
//--- plot a1_
#property indicator_label1  "MACD"
#property indicator_type1   DRAW_HISTOGRAM
#property indicator_color1  clrSilver
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- plot a2_
#property indicator_label2  "Signal"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot a3_
#property indicator_label3  "Fast_line_1"
#property indicator_type3   DRAW_NONE
#property indicator_color3  clrBlueViolet
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- plot a4_
#property indicator_label4  "Fast_line_2"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrBlue
#property indicator_style4  STYLE_SOLID
#property indicator_width4  1
//--- plot a5_
#property indicator_label5  "Slow_line_1"
#property indicator_type5   DRAW_NONE
#property indicator_color5  clrDarkGreen
#property indicator_style5  STYLE_SOLID
#property indicator_width5  1
//--- plot a6_
#property indicator_label6  "Slow_line_2"
#property indicator_type6   DRAW_LINE
#property indicator_color6  clrRoyalBlue
#property indicator_style6  STYLE_SOLID
#property indicator_width6  1//--- input parameters

//         int   LIN_1_STEP    =4; //line_1_power
//input int      LIN_1_PLECHO  =72; //Fast_line_1_leverage
//         int   LIN_2_STEP    =2;//line_2_power
//input int      LIN_2_PLECHO  =78; //Fast_line_2_leverage
//         int   LIN_3_STEP    =4;//line_3_power
//input int      LIN_3_PLECHO  =72; //Slow_line_1_leverage
//         int   LIN_4_STEP    =2;//Slow_line_4_power
//input int      LIN_4_PLECHO  =72;//Slow_line_2_leverage

        int TOCHKA_VHODA = 200;// start_point
input int           base  =450;
      int   point_shift_1 = 0;
      int   point_shift_2 = 0;
input int   Multiplikator = 10;
input int   InpSignalSMA  = 9;  // Signal SMA Period



//--- indicator buffers

double a1_Buffer[];
double a2_Buffer[];
double a3_Buffer[];
double a4_Buffer[];
double a5_Buffer[];
double a6_Buffer[];
//double a7_Buffer[];
//double a8_Buffer[];
/**/


//===========================================================================================
   double Znach;


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
 
//--- indicator buffers mapping
   SetIndexBuffer(0,a5_Buffer,INDICATOR_DATA);
   SetIndexBuffer(1,a6_Buffer,INDICATOR_DATA);
   SetIndexBuffer(2,a1_Buffer,INDICATOR_DATA);
   SetIndexBuffer(3,a2_Buffer,INDICATOR_DATA);
   SetIndexBuffer(4,a3_Buffer,INDICATOR_DATA);
   SetIndexBuffer(5,a4_Buffer,INDICATOR_DATA);
//----

//    if(TOCHKA_VHODA <= (LIN_1_PLECHO+25)*LIN_1_INTERVAL) TOCHKA_VHODA=(LIN_1_PLECHO+25)*LIN_1_INTERVAL;  
//    if(TOCHKA_VHODA <= (LIN_2_PLECHO+25)*LIN_2_INTERVAL) TOCHKA_VHODA=(LIN_2_PLECHO+25)*LIN_2_INTERVAL;  
//    if(TOCHKA_VHODA <= (LIN_3_PLECHO+25)*LIN_3_INTERVAL) TOCHKA_VHODA=(LIN_3_PLECHO+25)*LIN_3_INTERVAL;  
//    if(TOCHKA_VHODA <= (LIN_4_PLECHO+25)*LIN_4_INTERVAL) TOCHKA_VHODA=(LIN_4_PLECHO+25)*LIN_4_INTERVAL;  
    if(TOCHKA_VHODA <= (base*2+25))                      TOCHKA_VHODA=(base*2+25);  

//------
//===========================================================================================
//===========================================================================================

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {

   int i,limit;
//   int Bars=Bars(_Symbol,_Period);

   if(prev_calculated==0)// first calculation    
     {
      limit=rates_total-TOCHKA_VHODA;
      //--- set empty value for first limit bars
//Print("Bars=",Bars," rates_total=",rates_total," TOCHKA=",TOCHKA_VHODA," limit=",limit);
      if(limit<1)return(0);
      for(i=rates_total-1;i>=limit;i--)
      {
       a1_Buffer[i]=0.00000;
       a2_Buffer[i]=0.00000;
       a3_Buffer[i]=0.00000;
       a4_Buffer[i]=0.00000;
       a5_Buffer[i]=0.00000;
       a6_Buffer[i]=0.00000;
      }

     }
   else limit=rates_total-prev_calculated;
//--- main loop
   for(i=limit;i>=0 && !IsStopped();i--)
   {
//===========================================================================================
   Znach = iMA(NULL,0,base*2,0,MODE_SMA,PRICE_OPEN,i);
//===========================================================================================

 
      a1_Buffer[i]=((open[i] - Znach)    +5061600*a1_Buffer[i+1 ]-7489800   *a1_Buffer[i+2 ]+4926624*a1_Buffer[i+3 ]-1215450*a1_Buffer[i+4 ])/1282975;

      a2_Buffer[i]=  3160*a1_Buffer[i]   -6240   *a1_Buffer[i+1 ]    +  3081*a1_Buffer[i+2 ];

      a3_Buffer[i]=((open[i] - Znach)    +5061600*a3_Buffer[i+1 ]-7489800    *a3_Buffer[i+2 ]+4926624*a3_Buffer[i+3 ]-1215450*a3_Buffer[i+4 ])/1282975;

      a4_Buffer[i]=  2701*a3_Buffer[i]   -5328   *a3_Buffer[i+1 ]    +  2628 *a3_Buffer[i+2 ];



//================================================================================================================================================================================================
//================================================================================================================================================================================================

   a5_Buffer[i] = (a2_Buffer[i+point_shift_1] - a4_Buffer[i+point_shift_2])* Multiplikator;

   } 
//----
//--- signal line counted in the 2-nd buffer
     SimpleMAOnBuffer(rates_total,prev_calculated,0,InpSignalSMA,a5_Buffer,a6_Buffer);
//--- done

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
