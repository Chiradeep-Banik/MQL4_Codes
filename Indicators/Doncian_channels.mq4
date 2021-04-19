#property copyright "Banik"
#property strict
#property show_inputs
#property indicator_chart_window

#property  indicator_buffers 2

input int period = 20;

double don_high[] , don_low[];
int OnInit(){
   SetIndexBuffer(0 , don_high);
   SetIndexBuffer(1,don_low);
   SetIndexStyle(0 , DRAW_LINE , STYLE_SOLID , 1 ,clrBlack);
   SetIndexStyle(1 , DRAW_LINE , STYLE_SOLID , 1 ,clrBlack);
   SetIndexLabel(0 , "DON_HIGH");
   SetIndexLabel(1 ,"DON_LOW");
   
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
                const int &spread[])
{
   for (int i = Bars -1-IndicatorCounted() ; i > -1 ; i--){
   
      double high ,low;
      if (Bars-1 == 1)
         don_high[i] = iHigh(NULL ,0 , i);
         don_low[i] = iLow(NULL ,0 , i);
         high = don_high[i];
         low = don_low[i];
      if (Bars -i < period && Bars -1 > 1){
         don_high[i] = MathMax(high ,iHigh(NULL , 0 ,i));
         don_low[i] = MathMin(low ,iLow(NULL , 0 ,i));
      }
      if (Bars-i >= period)
         don_high[i] = iHigh(NULL ,0 , iHighest(NULL ,0 ,MODE_HIGH , period , i));
         don_low[i] = iLow(NULL ,0 , iLowest(NULL ,0 ,MODE_LOW , period , i)); 
      
      
   }
   
   return(rates_total);
}