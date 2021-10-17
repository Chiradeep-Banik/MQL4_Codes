//+------------------------------------------------------------------+
//|                                                        MAxCD.mq4 |
//|                           Copyright 2019, Roberto Jacobs (3rjfx) |
//|                              https://www.mql5.com/en/users/3rjfx |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, Roberto Jacobs (3rjfx) ~ By 3rjfx ~ Created: 2019/07/18"
#property link      "https://www.mql5.com/en/users/3rjfx"
#property version   "1.00"
#property strict
#property description "Three Moving Averages Convergence/Divergence."
//---
//--- indicator parameters
#property indicator_separate_window
//--- indicator settings
#property  indicator_separate_window
#property  indicator_buffers 3
#property  indicator_color1  clrBlueViolet
#property  indicator_color2  clrSnow
#property  indicator_color3  clrAqua
//--
#property  indicator_width1  3
#property  indicator_width2  3
#property  indicator_width3  3
//--
//--- indicator buffers
double MA1720[];
double MA2320[];
double MA1723[];
//--
#define CDM1  10
#define CDM2  23
#define CDM3  20
//---------//
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit(void)
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,MA1720);
   SetIndexBuffer(1,MA2320);   
   SetIndexBuffer(2,MA1723);
   //--
//--- drawing settings
   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexStyle(1,DRAW_HISTOGRAM);  
   SetIndexStyle(2,DRAW_HISTOGRAM);
   //--
//--- name for DataWindow and indicator subwindow label
   IndicatorShortName("MAxCD");
   SetIndexLabel(0,"Main");
   SetIndexLabel(1,"Midle");
   SetIndexLabel(2,"Fast");
//---
//--- initialization done
   return(INIT_SUCCEEDED);
  }
//--
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//----

//----
   return;
  }
//---
//+------------------------------------------------------------------+
//| Custom indicator iteration functio                               |
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
//---
   int i,limit;
//--- last counted bar will be recounted
   limit=rates_total-prev_calculated;
   if(prev_calculated>0)
      limit++;
//--- counting from rates_total to 0 
   ArrayResize(MA1720,limit);
   ArrayResize(MA2320,limit);
   ArrayResize(MA1723,limit);
   ArraySetAsSeries(MA1720,true);
   ArraySetAsSeries(MA2320,true);
   ArraySetAsSeries(MA1723,true);
   //--
//--- macd counted in the 1-st buffer
   for(i=limit-2; i>=0; i--)
     {
       MA1720[i]=iMA(Symbol(),0,CDM1,0,MODE_LWMA,PRICE_CLOSE,i)-iMA(Symbol(),0,CDM3,0,MODE_SMMA,PRICE_MEDIAN,i);
       MA2320[i]=iMA(Symbol(),0,CDM2,0,MODE_LWMA,PRICE_OPEN,i)-iMA(Symbol(),0,CDM3,0,MODE_SMMA,PRICE_MEDIAN,i);
       MA1723[i]=iMA(Symbol(),0,CDM1,0,MODE_LWMA,PRICE_CLOSE,i)-iMA(Symbol(),0,CDM2,0,MODE_LWMA,PRICE_OPEN,i);
     }
   //--
//--- done
   return(rates_total);   
//--- return value of prev_calculated for next call
  }
//+------------------------------------------------------------------+