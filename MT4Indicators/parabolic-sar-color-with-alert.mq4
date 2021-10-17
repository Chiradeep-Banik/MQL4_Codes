//+------------------------------------------------------------------+
//|                                                    SAR_COLOR.mq4 |
//|                                                          Kalenzo |
//|                                       http://www.foreksik.prv.pl |
//+------------------------------------------------------------------+
#property copyright "Kalenzo"
#property link      "http://www.foreksik.prv.pl"

#property indicator_color1 Magenta
#property indicator_color2 Yellow
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_width1 2
#property indicator_width2 2

double sarUp[],sarDn[];//buffers
extern bool AlertsEnabled=false;
extern double Step = 0.04;//was .01
extern double Maximum = 0.5;
extern int Precision = 7;
double alertBar;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_ARROW,STYLE_DOT);
   SetIndexStyle(1,DRAW_ARROW,STYLE_DOT);
   SetIndexBuffer(0,sarUp);
   SetIndexBuffer(1,sarDn);
   SetIndexArrow(0,115);
   SetIndexArrow(1,115);
   
   IndicatorShortName("SAR COLORED");
   SetIndexLabel(0,"SAR Up Channel");
   SetIndexLabel(1,"SAR Down Channel");
   
   SetIndexDrawBegin(0,2);
   SetIndexDrawBegin(1,2);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
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
  
   int limit;
   int counted_bars=IndicatorCounted();
   if(counted_bars<0) counted_bars=0;
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
//---- 
  for(int i = 0; i<limit ;i++)
   {
      double sar = NormalizeDouble(iSAR(Symbol(),0,Step,Maximum,i),Precision);
          if(sar >= iHigh(Symbol(),0,i))
      {
       if(AlertsEnabled==true && sarUp[i] == 0 && Bars>alertBar)
        {
        Alert("Parabolic SAR Going Down on ",Symbol(),"-",Period());
        alertBar = Bars;
       }
         sarUp[i] = sar;  
         sarDn[i] = 0;
      }
    else
      {
       if(AlertsEnabled==true && sarDn[i] == 0 && Bars>alertBar)
        {
        Alert("Parabolic SAR Channel Going Up on ",Symbol(),"-",Period());
        alertBar = Bars;
        }
         sarUp[i] = 0;
         sarDn[i] = sar;
       }
   }
 //----
   return(0);
  }
//+------------------------------------------------------------------+