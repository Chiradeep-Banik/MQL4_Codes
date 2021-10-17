//+------------------------------------------------------------------+
//|                                       VoltyChannel_Stop_v2.1.mq4 |
//|                                Copyright © 2007, TrendLaboratory |
//|            http://finance.groups.yahoo.com/group/TrendLaboratory |
//|                                   E-mail: igorad2003@yahoo.co.uk |
//+------------------------------------------------------------------+
//2008fxtsd mod
#property copyright "Copyright © 2007, TrendLaboratory"
#property link      "http://finance.groups.yahoo.com/group/TrendLaboratory"
//----
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 Blue
#property indicator_color2 Red
#property indicator_color3 Blue
#property indicator_color4 Red
#property indicator_width1 1
#property indicator_width2 1
#property indicator_width3 1
#property indicator_width4 1
//---- input parameters
extern int     MA_Price   =0; //Applied Price: 0-C,1-O,2-H,3-L,4-Median,5-Typical,6-Weighted
extern int     MA_Length  =1; //MA's Period 
extern int     MA_Mode    =0; //MA's Method:0-SMA,1-EMA,2-SMMA,3-LWMA  
extern int     ATR_Length =10;//ATR's Period
extern double  Kv         =4; //Volatility's Factor or Multiplier
extern double  MoneyRisk  =1; //Offset Factor 
extern bool    usePrice_HiLoBreak    =true;
extern bool    useMA_HiLoEnvelope    =false;
extern int     AlertMode  =0; //0-alert off,1-on
extern int     VisualMode =0; //0-lines,1-dots 
extern string Applied_Price_ ="0-C,1-O,2-H,3-L,4-Median(H+L)/2,5-Typical(H+L+C)/3,6-Weighted(H+L+C+C)/4";
extern string MAmethod_mode_ ="0-SMA,1-EMA,2-SMMA,3-LWMA";
extern string Visual_Mode___ ="0-lines,1-dots ";
//---- indicator buffers
double UpBuffer[];
double DnBuffer[];
double UpSignal[];
double DnSignal[];
double smin[];
double smax[];
double trend[];
bool   UpTrendAlert=false, DownTrendAlert=false;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
  int init()
  {
   string short_name;
//---- indicator line
   IndicatorBuffers(7);
   SetIndexBuffer(0,UpBuffer);
   SetIndexBuffer(1,DnBuffer);
   SetIndexBuffer(2,UpSignal);
   SetIndexBuffer(3,DnSignal);
   SetIndexBuffer(4,smin);
   SetIndexBuffer(5,smax);
   SetIndexBuffer(6,trend);
//----
   if(VisualMode==0)
     {
      SetIndexStyle(0,DRAW_LINE);
      SetIndexStyle(1,DRAW_LINE);
     }
   else
     {
      SetIndexStyle(0,DRAW_ARROW);
      SetIndexStyle(1,DRAW_ARROW);
      SetIndexArrow(0,159);
      SetIndexArrow(1,159);
     }
//----
   SetIndexStyle(2,DRAW_ARROW);
   SetIndexStyle(3,DRAW_ARROW);
   SetIndexArrow(2,108);
   SetIndexArrow(3,108);
//---- name for DataWindow and indicator subwindow label
   short_name="VoltyChannel_Stop("+MA_Length+","+ATR_Length+","+DoubleToStr(Kv,3)+")";
   IndicatorShortName(short_name);
   SetIndexLabel(0,"UpTrend");
   SetIndexLabel(1,"DnTrend");
   SetIndexLabel(2,"UpSignal");
   SetIndexLabel(3,"DnSignal");
//----
   SetIndexDrawBegin(0,MA_Length+ATR_Length);
   SetIndexDrawBegin(1,MA_Length+ATR_Length);
   SetIndexDrawBegin(2,MA_Length+ATR_Length);
   SetIndexDrawBegin(3,MA_Length+ATR_Length);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| VoltyChannel_Stop_2                                              |
//+------------------------------------------------------------------+
int start()
  {
   int shift,limit, counted_bars=IndicatorCounted();
//----
   if(counted_bars > 0) limit=Bars-counted_bars;
   if(counted_bars < 0) return(0);
   if(counted_bars ==0) limit=Bars-MA_Length-1;
   for(shift=limit;shift>=0;shift--)
     {
      if(useMA_HiLoEnvelope)
        {
         double bprice=iMA(NULL,0,MA_Length,0,MA_Mode,2,shift);
         double sprice=iMA(NULL,0,MA_Length,0,MA_Mode,3,shift);
        }
      else
        {
         bprice=iMA(NULL,0,MA_Length,0,MA_Mode,MA_Price,shift);
         sprice=iMA(NULL,0,MA_Length,0,MA_Mode,MA_Price,shift);
        }
      smax[shift]=bprice + Kv*iATR(NULL,0,ATR_Length,shift);
      smin[shift]=sprice - Kv*iATR(NULL,0,ATR_Length,shift);
      trend[shift]=trend[shift+1];
      if(usePrice_HiLoBreak)
        {
         if(High[shift] > smax[shift+1])trend[shift]= 1;
         if(Low[shift]  < smin[shift+1])trend[shift]=-1;
        }
      else
        {
         if(bprice > smax[shift+1])trend[shift]= 1;
         if(sprice < smin[shift+1])trend[shift]=-1;
        }
      if(trend[shift] >0)
        {
         if(smin[shift] < smin[shift+1]) smin[shift]=smin[shift+1];
         UpBuffer[shift]=smin[shift] - (MoneyRisk - 1)*iATR(NULL,0,ATR_Length,shift);
         if(UpBuffer[shift] < UpBuffer[shift+1] && UpBuffer[shift+1]!=EMPTY_VALUE) UpBuffer[shift]=UpBuffer[shift+1];
         if(trend[shift+1]!=trend[shift]) UpSignal[shift]=UpBuffer[shift];
         else UpSignal[shift]=EMPTY_VALUE;
         DnBuffer[shift]=EMPTY_VALUE;
         DnSignal[shift]=EMPTY_VALUE;
        }
      else
         if(trend[shift] <0)
           {
            if(smax[shift]>smax[shift+1]) smax[shift]=smax[shift+1];
            DnBuffer[shift]=smax[shift] + (MoneyRisk - 1)*iATR(NULL,0,ATR_Length,shift);
            if(DnBuffer[shift] > DnBuffer[shift+1]) DnBuffer[shift]=DnBuffer[shift+1];
            if(trend[shift+1]!=trend[shift]) DnSignal[shift]=DnBuffer[shift];
            else DnSignal[shift]=EMPTY_VALUE;
            UpBuffer[shift]=EMPTY_VALUE;
            UpSignal[shift]=EMPTY_VALUE;
           }
     }
//----   
   string Message;
   if(trend[2]<0 && trend[1]>0 && Volume[0]>1 && !UpTrendAlert)
     {
      Message=" "+Symbol()+" M"+Period()+": VCS Signal for BUY";
      if(AlertMode>0)Alert (Message);
      UpTrendAlert=true; DownTrendAlert=false;
     }
   if(trend[2]>0 && trend[1]<0 && Volume[0]>1 && !DownTrendAlert)
     {
      Message=" "+Symbol()+" M"+Period()+": VCS Signal for SELL";
      if(AlertMode>0)Alert (Message);
      DownTrendAlert=true; UpTrendAlert=false;
     }
//----	
   return(0);
  }
//+------------------------------------------------------------------+