//+-------------------------------------------------------------------------+
//|                                                         Giotee-Norm.mq4 |
//|                                                 Copyright 2016, Gioteen |
//|                                   https://www.mql5.com/en/users/gioteen |
//+-------------------------------------------------------------------------+
#property copyright "Copyright 2016, Gioteen"
#property link      "https://www.mql5.com/en/users/gioteen"
#property version   "1.00"
#property strict


#property indicator_separate_window
#property indicator_buffers 1
#property indicator_plots   1
//--- plot Label1
#property indicator_label1  "Label1"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- indicator buffers
double         Label1Buffer[];
extern string sym="";
extern int ExtPeriod=100;
extern int ExtMAMethod=0;
extern int ExtAppliedPrice=0;
extern int ExtShift=0;
int    nCountedBars,i;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,Label1Buffer);
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
if(Bars<=ExtPeriod) return(0);

   nCountedBars=IndicatorCounted();

   i=Bars-ExtPeriod-1;
   if(nCountedBars>ExtPeriod) 
      i=Bars-nCountedBars;  
   while(i>=0)
     {
      double st=std2(i);
      if(st==0)
         st=0.00001;
      Label1Buffer[i]=(GetAppliedPrice(ExtAppliedPrice,i)-iMA(sym,0,ExtPeriod,0,ExtMAMethod,ExtAppliedPrice,i))/st;
   
      i--;
      }

   return(rates_total);
  }
//+------------------------------------------------------------------+



double std2(int k)
{
      double dAPrice=0;
      double dAmount=0.0;
      double dMovingAverage=iMA(sym,0,ExtPeriod,0,ExtMAMethod,ExtAppliedPrice,k);
      for(int j=0; j<ExtPeriod; j++)
        {
         dAPrice=GetAppliedPrice(ExtAppliedPrice,k+j);
         dAmount+=(dAPrice-dMovingAverage)*(dAPrice-dMovingAverage);
        }
      return(MathSqrt(dAmount/ExtPeriod));
}

double GetAppliedPrice(int nAppliedPrice, int nIndex)
  {
   double dPrice;
//----
   switch(nAppliedPrice)
     {
      case 0:  dPrice=iClose(sym,0,nIndex);                                  break;
      case 1:  dPrice=iOpen(sym,0,nIndex);                                   break;
      case 2:  dPrice=iHigh(sym,0,nIndex);                                   break;
      case 3:  dPrice=iLow(sym,0,nIndex);                                    break;
      case 4:  dPrice=(iHigh(sym,0,nIndex)+iLow(sym,0,nIndex))/2.0;                 break;
      case 5:  dPrice=(iHigh(sym,0,nIndex)+iLow(sym,0,nIndex)+iClose(sym,0,nIndex))/3.0;   break;
      case 6:  dPrice=(iHigh(sym,0,nIndex)+iLow(sym,0,nIndex)+2*iClose(sym,0,nIndex))/4.0; break;
      default: dPrice=0.0;
     }
     return(dPrice);
 }
 