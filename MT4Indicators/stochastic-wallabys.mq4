//+------------------------------------------------------------------+
//|                                          Stochastic Wallabys.mq4 |
//|                                    Copyright 2010 Toshiyuki Tega |
//|                              				     |
//+------------------------------------------------------------------+
#property copyright ""
#property link      ""

#property indicator_separate_window
#property indicator_minimum 0
#property indicator_maximum 100
#property indicator_buffers 4
#property indicator_color1 Silver
#property indicator_color2 Silver
#property indicator_color3 Silver
#property indicator_color4 Red
#property indicator_style1 STYLE_SOLID
#property indicator_style2 STYLE_SOLID
#property indicator_style3 STYLE_SOLID
#property indicator_style4 STYLE_SOLID
#property indicator_width4 2

//---- input parameters
extern int KPeriod = 7;
extern int DPeriod = 3;
extern int Slowing = 3;
extern int Timeframe1 = 1;
extern int Timeframe2 = 5;
extern int Timeframe3 = 15;
extern int Type = 0;

//---- buffers
double Wallabys[];
double Stoch1[];
double Stoch2[];
double Stoch3[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
  SetIndexStyle(0, DRAW_LINE);
  SetIndexBuffer(0, Stoch1);
  SetIndexLabel(0, "Stochastic 1");
  
  SetIndexStyle(1, DRAW_LINE);
  SetIndexBuffer(1, Stoch2);
  SetIndexLabel(1, "Stochastic 2");
  
  SetIndexStyle(2, DRAW_LINE);
  SetIndexBuffer(2, Stoch3);
  SetIndexLabel(2, "Stochastic 3");
  
  SetIndexStyle(3, DRAW_LINE);
  SetIndexBuffer(3, Wallabys);
  SetIndexLabel(3, "Wallabys");
  
  SetLevelStyle(STYLE_DOT, 1);
  SetLevelValue(0, 80);
  SetLevelValue(1, 20);
  
  IndicatorShortName("Stochastic Wallabys (" + KPeriod + "," + DPeriod + "," + Slowing + "," + Type + "," + Timeframe1 + "," + Timeframe2 + "," + Timeframe3 + ")");
  
  return(0);
}

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
{
  return(0);
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
{
  int countedBars = IndicatorCounted();
  int barsNeeded = Bars - countedBars;
  
  for (int i = 0; i < barsNeeded; i++)
  {
    int shift1 = iBarShift(NULL, Timeframe1, iTime(NULL, 0, i));
    double stoch1 = iStochastic(NULL, Timeframe1, KPeriod, DPeriod, Slowing, MODE_SMA, Type, MODE_MAIN, shift1);
    
    int shift2 = iBarShift(NULL, Timeframe2, iTime(NULL, 0, i));
    double stoch2 = iStochastic(NULL, Timeframe2, KPeriod, DPeriod, Slowing, MODE_SMA, Type, MODE_MAIN, shift2);
    
    int shift3 = iBarShift(NULL, Timeframe3, iTime(NULL, 0, i));
    double stoch3 = iStochastic(NULL, Timeframe3, KPeriod, DPeriod, Slowing, MODE_SMA, Type, MODE_MAIN, shift3);
   
    Stoch1[i] = stoch1;
    Stoch2[i] = stoch2;
    Stoch3[i] = stoch3;
    Wallabys[i] = (stoch1 + stoch2 + stoch3) / 3;
  }
  
  return(0);
}
//+------------------------------------------------------------------+