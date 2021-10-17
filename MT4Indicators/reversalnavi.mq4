//+------------------------------------------------------------------+
//|                                                 reversalnavi.mq4 |
//|                                          Copyright 2015, fxborg. |
//|                                  http://blog.livedoor.jp/fxborg/ |
//+------------------------------------------------------------------+
#property copyright   "2015, fxborg"
#property link        "http://blog.livedoor.jp/fxborg/"
#property description "Reversal Navi"
#property strict
//---
#property indicator_chart_window
#property indicator_buffers   6
#property indicator_color1  clrRed
#property indicator_color2  clrBlue
#property indicator_color3  clrRed
#property indicator_width3  2 
#property indicator_color4  clrBlue
#property indicator_width4  2 
#property indicator_color5  clrRed
#property indicator_color6  clrBlue
//#property indicator_color7  clrLightGray
//#property indicator_color8  clrLightGray
//--- input parameters
input int InpHiLoPeriod=8; // High Low Period
input int InpStanbyBars=8; // Stanby Bars
int CalcBarCount=4;     // Calc Bar Count
//--- buffers
double         ExtTopBuffer[];
double         ExtBtmBuffer[];
double         ExtSellStandbyBuffer[];
double         ExtBuyStandbyBuffer[];
double         ExtSellLineBuffer[];
double         ExtBuyLineBuffer[];
//---- for calc 
double ExtHighesBuffer[];
double ExtLowesBuffer[];
//---
int draw_begin1=0;
bool EnableBuy=true;
bool EnableSell=true;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit(void)
  {
   string short_name;
   if(InpHiLoPeriod<2)
     {
      Alert("InpHiLoPeriod is too small.");
      return(INIT_FAILED);
     }
//--- 2 additional buffers are used for counting.
   IndicatorBuffers(8);
   SetIndexBuffer(6,ExtHighesBuffer);
   SetIndexBuffer(7,ExtLowesBuffer);
//--- indicator buffers mapping
   SetIndexBuffer(0,ExtTopBuffer);
   SetIndexStyle(0,DRAW_ARROW);
   SetIndexArrow(0,218);
//---
   SetIndexBuffer(1,ExtBtmBuffer);
   SetIndexStyle(1,DRAW_ARROW);
   SetIndexArrow(1,217);
//---
   SetIndexBuffer(2,ExtSellStandbyBuffer);
   SetIndexStyle(2,DRAW_ARROW);
   SetIndexArrow(2,159);
//---
   SetIndexBuffer(3,ExtBuyStandbyBuffer);
   SetIndexStyle(3,DRAW_ARROW);
   SetIndexArrow(3,159);
//---
   SetIndexBuffer(4,ExtSellLineBuffer);
   SetIndexStyle(4,DRAW_LINE);
//---
   SetIndexBuffer(5,ExtBuyLineBuffer);
   SetIndexStyle(5,DRAW_LINE);
//--- name for DataWindow and indicator subwindow label
//---
   draw_begin1=InpHiLoPeriod+CalcBarCount;
   SetIndexDrawBegin(0,draw_begin1);
   SetIndexDrawBegin(1,draw_begin1);
   SetIndexDrawBegin(2,draw_begin1);
   SetIndexDrawBegin(3,draw_begin1);
//---
   short_name="Reversal Navi("+IntegerToString(InpHiLoPeriod)+","+IntegerToString(InpStanbyBars)+")";
   IndicatorShortName(short_name);
//--- initialization done
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| BSI caluclate                                                    |
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
   int i,k,pos;
//--- check for bars count
   if(rates_total<=InpHiLoPeriod+0+CalcBarCount)
      return(0);
//--- counting from 0 to rates_total
   ArraySetAsSeries(ExtHighesBuffer,false);
   ArraySetAsSeries(ExtLowesBuffer,false);
//---
   ArraySetAsSeries(ExtTopBuffer,false);
   ArraySetAsSeries(ExtBtmBuffer,false);
//---
   ArraySetAsSeries(ExtSellStandbyBuffer,false);
   ArraySetAsSeries(ExtBuyStandbyBuffer,false);
//---
   ArraySetAsSeries(ExtSellLineBuffer,false);
   ArraySetAsSeries(ExtBuyLineBuffer,false);
//---
   ArraySetAsSeries(open,false);
   ArraySetAsSeries(low,false);
   ArraySetAsSeries(high,false);
   ArraySetAsSeries(close,false);
//---
   pos=InpHiLoPeriod-1;
//---
   if(pos+1<prev_calculated)
      pos=prev_calculated-2;
   else
     {
      for(i=0; i<pos; i++)
        {
         ExtLowesBuffer[i]=0.0;
         ExtHighesBuffer[i]=0.0;
        }
     }
//--- calculate HighesBuffer[] and ExtHighesBuffer[]
   for(i=pos; i<rates_total && !IsStopped(); i++)
     {
      //--- calculate range spread
      double dmin=1000000.0;
      double dmax=-1000000.0;
      for(k=i-InpHiLoPeriod+1; k<=i; k++)
        {
         if(dmin>low[k])
            dmin=low[k];
         if(dmax<high[k])
            dmax=high[k];
        }
      ExtLowesBuffer[i]=dmin;
      ExtHighesBuffer[i]=dmax;
     }
//--- line
   pos=InpHiLoPeriod-1+CalcBarCount-1;
   if(pos+1<prev_calculated)
      pos=prev_calculated-2;
//--- main cycle
   for(i=pos; i<rates_total && !IsStopped(); i++)
     {
      if(EnableBuy)
        {
         //--- buy
         int btm_pos=i-1;
         for(int j=i-1;j>1;j--)
           {
            if(ExtLowesBuffer[j-2]>ExtLowesBuffer[j-1]
               && ExtLowesBuffer[j-1]==ExtLowesBuffer[j])
              {
               btm_pos=j-1;
               break;
              }
           }
         int setup=NULL;
         for(int j=btm_pos; j<=i-1;j++)
           {
            if(ExtBuyStandbyBuffer[j]!=EMPTY_VALUE)
              {
               setup=j;
               break;
              }
           }
         //--- entry line
         double entry_point=NULL;
         double range_lo=1000000.0;
         double range_hi=-1000000.0;
         if(setup==NULL || (i-setup)<=InpStanbyBars)
           {
            for(int j=btm_pos; j<=i-1;j++)
              {
               if(range_hi<high[j])range_hi=high[j];
               if(range_lo>low[j])range_lo=low[j];
              }
            //---
            entry_point=((range_hi+range_lo)/2);
            ExtBuyLineBuffer[i]=entry_point;
           }
         //---
         if(MathMin(low[i-4],MathMin(low[i-3],low[i-2]))<low[i-1])
           {
            if(setup==NULL)
              {
               ExtBtmBuffer[btm_pos]=low[btm_pos]-5*Point;
               ExtBuyStandbyBuffer[i]=entry_point;
              }
           }
        }
      //--- sell
      if(EnableSell)
        {
         int top_pos=i-1;
         for(int j=i-1;j>1;j--)
           {
            if(ExtHighesBuffer[j-2]<ExtHighesBuffer[j-1]
               && ExtHighesBuffer[j-1]==ExtHighesBuffer[j])
              {
               top_pos=j-1;
               break;
              }
           }
         int setup=NULL;
         for(int j=top_pos; j<=i-1;j++)
           {
            if(ExtSellStandbyBuffer[j]!=EMPTY_VALUE)
              {
               setup=j;
               break;
              }
           }
         //--- entry line
         double entry_point=NULL;
         double range_lo=1000000.0;
         double range_hi=-1000000.0;
         if(setup==NULL || (i-setup)<=InpStanbyBars)
           {
            //---
            for(int j=top_pos; j<=i-1;j++)
              {
               if(range_hi<high[j])range_hi=high[j];
               if(range_lo>low[j])range_lo=low[j];
              }
            entry_point=((range_hi+range_lo)/2);
            ExtSellLineBuffer[i]=entry_point;
           }
         if(MathMax(high[i-4],MathMax(high[i-3],high[i-2]))>high[i-1])
           {
            if(setup==NULL)
              {
               ExtTopBuffer[top_pos]=high[top_pos]+5*Point;
               ExtSellStandbyBuffer[i]=entry_point;
              }
           }
        }
     }
//--- OnCalculate done. Return new prev_calculated.
   return(rates_total);
  }
//+------------------------------------------------------------------+
