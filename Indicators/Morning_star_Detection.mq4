#property copyright "Banik"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window

#property indicator_buffers 3

double arrow_down[];
double arrow_up[];
double signal[];

int OnInit(){
   
   SetIndexBuffer(0, arrow_down);
   SetIndexStyle(0, DRAW_ARROW , EMPTY , EMPTY , clrRed);
   SetIndexArrow(0,234);
   SetIndexLabel(0 ,"SELL");
   SetIndexBuffer(1, arrow_up);
   SetIndexStyle(1, DRAW_ARROW , EMPTY , EMPTY , clrGreen);
   SetIndexArrow(1,233);
   SetIndexLabel(1 ,"BUY");
   SetIndexBuffer(2 ,signal);
   SetIndexStyle(2 , DRAW_ARROW ,EMPTY , EMPTY ,clrBlack);
   SetIndexLabel(2 ,"SIGNAL");
   SetIndexArrow(2,117);
    
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
   for(int i = Bars-3 - IndicatorCounted(); i > -1 ; i-- ){
      int pos_1 = i+2;
      int pos_2 = i+1;
      int pos_3 = i;
      
      if (bull_bear(pos_1) == -1)
         if (bull_bear(pos_3) == 1)
            if (4*distance(pos_2) < distance(pos_1))
               if (4*distance(pos_2) < distance(pos_3))
                  if(distance(pos_2) != 0)
                     if (distance(pos_1)*2 > distance(pos_3))
                        if (distance(pos_3)*2 > distance(pos_1))
                           arrow_up[pos_2] = iLow(NULL ,0 , pos_2);
                           
      if (bull_bear(pos_1) == 1)
         if (bull_bear(pos_3) == -1)
            if (4*distance(pos_2) < distance(pos_1))
               if (4*distance(pos_2) < distance(pos_3))
                  if(distance(pos_2) != 0)
                     if (distance(pos_1)*2 > distance(pos_3))
                        if (distance(pos_3)*2 > distance(pos_1))
                           arrow_down[pos_2] = iHigh(NULL ,0 , pos_2);
      
      if (arrow_down[pos_2] == iHigh(NULL , 0, pos_2))
         signal[i] = NormalizeDouble(iClose(NULL ,0 , i),5);
      if (arrow_up[pos_2] == iLow(NULL , 0, pos_2))
         signal[i] = NormalizeDouble(iClose(NULL , 0 , i),5);
         
   }

   return(rates_total);
}

int bull_bear(int x){
   if (iOpen(NULL ,0 , x) < iClose(NULL ,0 , x))
      return 1;
   else
      if (iOpen(NULL ,0 , x) > iClose(NULL ,0 , x))
         return -1;
      else
         return 0;
}

double distance(int x){
   double distance = MathAbs(iOpen(NULL ,0 , x) - iClose(NULL ,0 , x));
   return distance;
}
