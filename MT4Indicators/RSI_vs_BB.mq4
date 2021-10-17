//+------------------------------------------------------------------+
//|                                                    RSI vs BB.mq4 |
//|                                              Copyright 2015, Tor |
//|                                             http://einvestor.ru/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, Tor"
#property link      "http://einvestor.ru/"
#property version   "1.00"
#property strict
#property indicator_chart_window
#property indicator_buffers 7
#property indicator_plots   6

input int RSIPeriod = 14;
input int RSIUpLevel = 70;
input int RSIDownLevel = 30;

input int BBPeriod = 20;
input double BBDeviation = 2;

input bool CrossInside = true;
input bool CrossOutside = true;

input bool alerts = true;
input bool ShowBB = true;
input color clrBB = clrYellow;

double BB1[], BB2[], RSI[], buy[], sell[], buy2[], sell2[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,BB1);
   SetIndexBuffer(1,BB2);
   SetIndexBuffer(2,RSI);
   SetIndexBuffer(3,buy);
   SetIndexBuffer(4,sell);
   SetIndexBuffer(5,buy2);
   SetIndexBuffer(6,sell2);
   IndicatorShortName("RSI vs BB");
   if(ShowBB){
      SetIndexStyle(0,DRAW_LINE,STYLE_SOLID,1,clrBB);
      SetIndexStyle(1,DRAW_LINE,STYLE_SOLID,1,clrBB);
   }else{
      SetIndexStyle(0,DRAW_NONE);
      SetIndexStyle(1,DRAW_NONE);
   }
   SetIndexStyle(2,DRAW_NONE);
   SetIndexStyle(3,DRAW_ARROW,STYLE_SOLID,1,clrBlue);
   SetIndexStyle(4,DRAW_ARROW,STYLE_SOLID,1,clrRed);
   SetIndexStyle(5,DRAW_ARROW,STYLE_SOLID,1,clrBlue);
   SetIndexStyle(6,DRAW_ARROW,STYLE_SOLID,1,clrRed);
   SetIndexArrow(3,233);
   SetIndexArrow(4,234);
   SetIndexArrow(5,108);
   SetIndexArrow(6,108);
   SetIndexLabel(0,"BB Up");
   SetIndexLabel(1,"BB Down ");
   SetIndexLabel(3,"Buy");
   SetIndexLabel(4,"Sell");
   SetIndexLabel(5,"Outside Buy");
   SetIndexLabel(6,"Outside Sell");
//---
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
//---
   int limit;
   static bool alrt = false;
   static datetime altime = 0;
   
   //---
   if(rates_total<=1)
   return(0);
   //--- last counted bar will be recounted
   limit=rates_total-prev_calculated;
   if(prev_calculated>0)
   limit = limit+1;
   
   for(int x=limit-2; x>=0; x--){
      BB1[x] = iBands(_Symbol, _Period, BBPeriod, BBDeviation, 0, PRICE_CLOSE, MODE_UPPER, x);
      BB2[x] = iBands(_Symbol, _Period, BBPeriod, BBDeviation, 0, PRICE_CLOSE, MODE_LOWER, x);
      RSI[x] = iRSI(_Symbol, _Period, RSIPeriod, PRICE_CLOSE, x);
      
      if(CrossInside && RSI[x+1]>=RSIUpLevel && RSI[x]<RSIUpLevel && iOpen(_Symbol, _Period, x+1)>BB1[x+1] && iClose(_Symbol, _Period, x)<BB1[x]){
         sell[x] = iClose(_Symbol, _Period, x);
         if(alerts && x==0 && altime<iTime(_Symbol, _Period, x)){
            Alert("RSI vs BB signal - SELL ",_Symbol);
            altime = iTime(_Symbol, _Period, x);
         }
      }
      if(CrossInside && RSI[x+1]<=RSIDownLevel && RSI[x]>RSIDownLevel && iOpen(_Symbol, _Period, x+1)<BB2[x+1] && iClose(_Symbol, _Period, x)>BB2[x]){
         buy[x] = iClose(_Symbol, _Period, x);
         if(alerts && x==0 && altime<iTime(_Symbol, _Period, x)){
            Alert("RSI vs BB signal - BUY ",_Symbol);
            altime = iTime(_Symbol, _Period, x);
         }
      }
      
      if(CrossOutside && RSI[x+1]<=RSIUpLevel && RSI[x]>RSIUpLevel && iOpen(_Symbol, _Period, x+1)<BB1[x+1] && iClose(_Symbol, _Period, x)>BB1[x]){
         sell2[x] = iHigh(_Symbol, _Period, x);
         if(alerts && x==0 && altime<iTime(_Symbol, _Period, x)){
            Alert("RSI vs BB signal - outside cross - SELL ",_Symbol);
            altime = iTime(_Symbol, _Period, x);
         }
      }
      if(CrossOutside && RSI[x+1]>=RSIDownLevel && RSI[x]<RSIDownLevel && iOpen(_Symbol, _Period, x+1)>BB2[x+1] && iClose(_Symbol, _Period, x)<BB2[x]){
         buy2[x] = iLow(_Symbol, _Period, x);
         if(alerts && x==0 && altime<iTime(_Symbol, _Period, x)){
            Alert("RSI vs BB signal - outside cross - BUY ",_Symbol);
            altime = iTime(_Symbol, _Period, x);
         }
      }
   }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
