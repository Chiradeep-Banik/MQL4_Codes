//+------------------------------------------------------------------+
//|                                                MTF_MACD_Bars.mq4 |
//|                      Copyright © 2006, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"
//+------------------------------------------------------------------+
//|                                                    FlatTrend.mq4 |
//|                                                       Kirk Sloan |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Kirk Sloan"
#property link      "http://www.metaquotes.net"
#property link      "Modified by cja"
//----
#property indicator_separate_window
#property indicator_minimum -1
#property indicator_maximum 1
#property indicator_buffers 4
#property indicator_color1 Tomato
#property indicator_color2 YellowGreen
#property indicator_color3 Green
#property indicator_color4 Red
#property indicator_width1 4
#property indicator_width2 4
#property indicator_width3 4
#property indicator_width4 4
//---- input parameters
extern int Minutes=0;
extern int MACD_Fast=8;
extern int MACD_Slow=17;
extern int MACD_MA=9;
//---- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
double ExtMapBuffer3[];
double ExtMapBuffer4[];
/*double Ma;
double hhigh, llow;
double Psar;
double MA1,MA2,MA3;
double PADX,NADX;*/
string TimeFrameStr;
double MACD_Signal,MACD_Main;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_HISTOGRAM,STYLE_SOLID);
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexStyle(1,DRAW_HISTOGRAM,STYLE_SOLID);
   SetIndexBuffer(1,ExtMapBuffer2);
   SetIndexStyle(2,DRAW_HISTOGRAM,STYLE_SOLID);
   SetIndexBuffer(2,ExtMapBuffer3);
   SetIndexStyle(3,DRAW_HISTOGRAM,STYLE_SOLID);
   SetIndexBuffer(3,ExtMapBuffer4);
//----
   switch(Minutes)
     {
      case 1 : TimeFrameStr="Period_M1"; break;
      case 5 : TimeFrameStr="Period_M5"; break;
      case 15 : TimeFrameStr="Period_M15"; break;
      case 30 : TimeFrameStr="Period_M30"; break;
      case 60 : TimeFrameStr="Period_H1"; break;
      case 240 : TimeFrameStr="Period_H4"; break;
      case 1440 : TimeFrameStr="Period_D1"; break;
      case 10080 : TimeFrameStr="Period_W1"; break;
      case 43200 : TimeFrameStr="Period_MN1"; break;
      default : TimeFrameStr="Current Timeframe"; Minutes=0;
     }
   IndicatorShortName("MTF_MACD ("+TimeFrameStr+")");
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
   int    counted_bars=IndicatorCounted();
//----
     for(int i=0; i < 300; i++)
     {
      ExtMapBuffer1[i]=0;
      ExtMapBuffer2[i]=0;
      ExtMapBuffer3[i]=0;
      ExtMapBuffer4[i]=0;
//----
      MACD_Signal=iMACD(NULL,Minutes,MACD_Fast,MACD_Slow,MACD_MA,PRICE_CLOSE,MODE_SIGNAL,i);
      MACD_Main  =iMACD(NULL,Minutes,MACD_Fast,MACD_Slow,MACD_MA,PRICE_CLOSE,MODE_MAIN,i);
//----
      if(MACD_Signal < MACD_Main )ExtMapBuffer2[i]=-1;//Sig Below MACD 
      if(MACD_Signal > MACD_Main )ExtMapBuffer1[i]=1;//Sig above MACD
  /* if(ExtMapBuffer1[i] == 0 && ExtMapBuffer2[i] == 0)
   {ExtMapBuffer3[i] = 1;}*/
      if(MACD_Signal < MACD_Main && MACD_Main > 0)ExtMapBuffer3[i]=1;//Sig below MACD & Above 0
      if(MACD_Signal > MACD_Main && MACD_Main < 0)ExtMapBuffer4[i]=-1;//Sig above MACD & Below 0
     }
//----
   return(0);
  }
//+------------------------------------------------------------------+