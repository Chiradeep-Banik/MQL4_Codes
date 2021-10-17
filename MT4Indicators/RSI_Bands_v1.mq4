//+------------------------------------------------------------------+
//|                                                 RSI_Bands_v1.mq4 |
//|                                  Copyright 2020, Fabio Cavalloni |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, Fabio Cavalloni"
#property link      "https://www.mql5.com/en/users/kava93"
#property version   "1.00"
#property strict
#property indicator_buffers 6
#property indicator_separate_window
#property indicator_minimum 0
#property indicator_maximum 100

input int         iRSIPeriod              = 14;    // RSI periods
input int         iBandsPeriod            = 34;    // BB periods
input double      iBandsDeviation         = 2.5;   // BB deviation

double ExtRSI[], ExtUp[], ExtDn[], ExtMd[], ExtBuyArrow[], ExtSellArrow[];

int OnInit() {
   IndicatorShortName("RSI("+string(iRSIPeriod)+") Bands("+string(iBandsPeriod)+","+DoubleToString(iBandsDeviation,2)+")");
   
   SetIndexBuffer(0,ExtRSI);
   SetIndexStyle(0,DRAW_LINE,STYLE_SOLID,1,clrDodgerBlue);
   SetIndexLabel(0,"RSI");
   SetIndexBuffer(1,ExtUp);
   SetIndexStyle(1,DRAW_LINE,STYLE_DOT,1,clrBlack);
   SetIndexLabel(1,"Upper band");
   SetIndexBuffer(2,ExtDn);
   SetIndexStyle(2,DRAW_LINE,STYLE_DOT,1,clrBlack);
   SetIndexLabel(2,"Lower band");
   SetIndexBuffer(3,ExtMd);
   SetIndexStyle(3,DRAW_LINE,STYLE_DOT,1,clrBlack);
   SetIndexLabel(3,"Middle band");
   SetIndexBuffer(4,ExtBuyArrow);
   SetIndexStyle(4,DRAW_ARROW,0,1,clrGreen);
   SetIndexArrow(4,225);
   SetIndexLabel(4,"Buy arrow");
   SetIndexBuffer(5,ExtSellArrow);
   SetIndexStyle(5,DRAW_ARROW,0,1,clrRed);
   SetIndexArrow(5,226);
   SetIndexLabel(5,"Sell arrow");
   
   SetIndexDrawBegin(0,iRSIPeriod);
   SetIndexDrawBegin(1,iRSIPeriod+iBandsPeriod);
   SetIndexDrawBegin(2,iRSIPeriod+iBandsPeriod);
   SetIndexDrawBegin(3,iRSIPeriod+iBandsPeriod);
   return(INIT_SUCCEEDED);
}
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]) {
   int limit = rates_total-prev_calculated;
   if( limit<=0 ) limit = 1;
   
   for( int i=0; i<limit; i++ ) {
      ExtRSI[i] = iRSI(NULL,0,iRSIPeriod,PRICE_CLOSE,i);
   }
   for( int i=0; i<limit; i++ ) {
      ExtUp[i] = iBandsOnArray(ExtRSI,0,iBandsPeriod,iBandsDeviation,0,MODE_UPPER,i);
      ExtMd[i] = iBandsOnArray(ExtRSI,0,iBandsPeriod,iBandsDeviation,0,MODE_MAIN,i);
      ExtDn[i] = iBandsOnArray(ExtRSI,0,iBandsPeriod,iBandsDeviation,0,MODE_LOWER,i);
   }
   for( int i=0; i<limit; i++ ) {
      bool BuyArrow  = ExtRSI[i]>ExtDn[i] && ExtRSI[i+1]<=ExtDn[i+1];
      bool SellArrow = ExtRSI[i]<ExtUp[i] && ExtRSI[i+1]>=ExtUp[i+1];
      
      if( BuyArrow )  ExtBuyArrow[i]  = ExtDn[i];
      if( SellArrow ) ExtSellArrow[i] = ExtUp[i];
   } 
   return(rates_total);
}
