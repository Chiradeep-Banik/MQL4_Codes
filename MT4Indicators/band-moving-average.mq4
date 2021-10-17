//+------------------------------------------------------------------+
//|                                              Band Moving Average |
//|                                      Copyright © 2008, EarnForex |
//|                                        http://www.earnforex.com/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2008, EarnForex"
#property link      "http://www.earnforex.com"

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 Red
#property indicator_color2 Blue
#property indicator_color3 Green
//---- indicator parameters
extern int MA_Period=49;
extern int MA_Shift=0;
extern int MA_Method=0;
extern double Percentage=2;
//---- indicator buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
double ExtMapBuffer3[];
//----
int ExtCountedBars=0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   int    draw_begin;
   string short_name;
//---- drawing settings
   SetIndexStyle(0,DRAW_LINE);
   SetIndexShift(0,MA_Shift);
   IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS));
   SetIndexStyle(1,DRAW_LINE);
   SetIndexShift(1,MA_Shift);
   SetIndexStyle(2,DRAW_LINE);
   SetIndexShift(2,MA_Shift);
   if(MA_Period<2) MA_Period=13;
   draw_begin=MA_Period-1;
//---- indicator short name
   switch(MA_Method)
     {
      case 1 : short_name="Band EMA(";  draw_begin=0; break;
      case 2 : short_name="Band SMMA("; break;
      case 3 : short_name="Band LWMA("; break;
      default :
         MA_Method=0;
         short_name="Band SMA(";
     }
   IndicatorShortName(short_name+MA_Period+")");
   SetIndexDrawBegin(0,draw_begin);
   SetIndexDrawBegin(1,draw_begin);
   SetIndexDrawBegin(2,draw_begin);
//---- indicator buffers mapping
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexBuffer(1,ExtMapBuffer2);
   SetIndexBuffer(2,ExtMapBuffer3);
//---- initialization done
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
   if(Bars<=MA_Period) return(0);
   ExtCountedBars=IndicatorCounted();
//---- check for possible errors
   if (ExtCountedBars<0) return(-1);
//---- last counted bar will be recounted
   if (ExtCountedBars>0) ExtCountedBars--;
//----
   switch(MA_Method)
     {
      case 0 : sma();  break;
      case 1 : ema();  break;
      case 2 : smma(); break;
      case 3 : lwma();
     }
//---- done
   return(0);
  }
//+------------------------------------------------------------------+
//| Simple Moving Average                                            |
//+------------------------------------------------------------------+
void sma()
  {
   double sum=0;
   int    i,pos=Bars-ExtCountedBars-1;
//---- initial accumulation
   if(pos<MA_Period) pos=MA_Period;
   for(i=1;i<MA_Period;i++,pos--)
      sum+=Close[pos];
//---- main calculation loop
   while(pos>=0)
     {
      sum+=Close[pos];
      ExtMapBuffer1[pos]=sum/MA_Period;
      ExtMapBuffer2[pos]=(ExtMapBuffer1[pos]/100)*(100+Percentage);
      ExtMapBuffer3[pos]=(ExtMapBuffer1[pos]/100)*(100-Percentage);
	   sum-=Close[pos+MA_Period-1];
 	   pos--;
     }
//---- zero initial bars
   if(ExtCountedBars<1)
      for(i=1;i<MA_Period;i++)
      {
         ExtMapBuffer1[Bars-i]=0;
         ExtMapBuffer2[Bars-i]=0;
         ExtMapBuffer3[Bars-i]=0;
      }
  }
//+------------------------------------------------------------------+
//| Exponential Moving Average                                       |
//+------------------------------------------------------------------+
void ema()
  {
   double pr=2.0/(MA_Period+1);
   int    pos=Bars-2;
   if(ExtCountedBars>2) pos=Bars-ExtCountedBars-1;
//---- main calculation loop
   while(pos>=0)
     {
      if(pos==Bars-2) ExtMapBuffer1[pos+1]=Close[pos+1];
      ExtMapBuffer1[pos]=Close[pos]*pr+ExtMapBuffer1[pos+1]*(1-pr);
      ExtMapBuffer2[pos]=(ExtMapBuffer1[pos]/100)*(100+Percentage);
      ExtMapBuffer3[pos]=(ExtMapBuffer1[pos]/100)*(100-Percentage);
 	   pos--;
     }
  }
//+------------------------------------------------------------------+
//| Smoothed Moving Average                                          |
//+------------------------------------------------------------------+
void smma()
  {
   double sum=0;
   int    i,k,pos=Bars-ExtCountedBars+1;
//---- main calculation loop
   pos=Bars-MA_Period;
   if(pos>Bars-ExtCountedBars) pos=Bars-ExtCountedBars;
   while(pos>=0)
     {
      if(pos==Bars-MA_Period)
        {
         //---- initial accumulation
         for(i=0,k=pos;i<MA_Period;i++,k++)
           {
            sum+=Close[k];
            //---- zero initial bars
            ExtMapBuffer1[k]=0;
            ExtMapBuffer2[k]=0;
            ExtMapBuffer3[k]=0;
           }
        }
      else sum=ExtMapBuffer1[pos+1]*(MA_Period-1)+Close[pos];
      ExtMapBuffer1[pos]=sum/MA_Period;
      ExtMapBuffer2[pos]=(ExtMapBuffer1[pos]/100)*(100+Percentage);
      ExtMapBuffer3[pos]=(ExtMapBuffer1[pos]/100)*(100-Percentage);
 	   pos--;
     }
  }
//+------------------------------------------------------------------+
//| Linear Weighted Moving Average                                   |
//+------------------------------------------------------------------+
void lwma()
  {
   double sum=0.0,lsum=0.0;
   double price;
   int    i,weight=0,pos=Bars-ExtCountedBars-1;
//---- initial accumulation
   if(pos<MA_Period) pos=MA_Period;
   for(i=1;i<=MA_Period;i++,pos--)
     {
      price=Close[pos];
      sum+=price*i;
      lsum+=price;
      weight+=i;
     }
//---- main calculation loop
   pos++;
   i=pos+MA_Period;
   while(pos>=0)
     {
      ExtMapBuffer1[pos]=sum/weight;
      ExtMapBuffer2[pos]=(ExtMapBuffer1[pos]/100)*(100+Percentage);
      ExtMapBuffer3[pos]=(ExtMapBuffer1[pos]/100)*(100-Percentage);
      if(pos==0) break;
      pos--;
      i--;
      price=Close[pos];
      sum=sum-lsum+price*MA_Period;
      lsum-=Close[i];
      lsum+=price;
     }
//---- zero initial bars
   if(ExtCountedBars<1)
      for(i=1;i<MA_Period;i++)
      {
         ExtMapBuffer1[Bars-i]=0;
         ExtMapBuffer2[Bars-i]=0;
         ExtMapBuffer3[Bars-i]=0;
      }
  }
//+------------------------------------------------------------------+

