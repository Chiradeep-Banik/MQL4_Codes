//+------------------------------------------------------------------+
//| DPO.mq4 
//+------------------------------------------------------------------+
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1  clrBlue
#property indicator_color2  clrRed
#property indicator_color3  clrDarkGray
#property indicator_width1  3
#property indicator_width2  3
#property indicator_width3  2
#property strict

input int            x_prd       = 14;
input ENUM_MA_METHOD averageMode = MODE_SMA;

double dpo[],dpoUp[],dpoDn[],valc[];

//------------------------------------------------------------------
//
//------------------------------------------------------------------
int OnInit()
{
   IndicatorBuffers(4);
   SetIndexBuffer(0,dpoUp,INDICATOR_DATA); SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(1,dpoDn,INDICATOR_DATA); SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexBuffer(2,dpo,  INDICATOR_DATA); SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(3,valc, INDICATOR_CALCULATIONS);
return(INIT_SUCCEEDED);
}

int OnCalculate(const int rates_total,const int prev_calculated,const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   int i,counted_bars=prev_calculated;
      if(counted_bars<0) return(-1);
      if(counted_bars>0) counted_bars--;
         int limit = fmin(rates_total-counted_bars,rates_total-1);
                
   //
   //
   //
   //
   //
   
   int t_prd = x_prd/2+1;
   for (i=limit; i >= 0; i--) 
   {
      dpo[i]  = close[i]-iMA(NULL,0,x_prd,t_prd,averageMode,PRICE_CLOSE,i);
      valc[i] = (i<rates_total-1) ? (dpo[i]>0) ? 1 :(dpo[i]<0) ? -1 : valc[i+1]: 0;
      dpoUp[i] = (valc[i] ==  1) ? dpo[i] : EMPTY_VALUE;
      dpoDn[i] = (valc[i] == -1) ? dpo[i] : EMPTY_VALUE;
   }
return(rates_total);
}