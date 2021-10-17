//+------------------------------------------------------------------+
//|                                            TrendEnvelopes_v1.mq4 |
//|                           Copyright © 2006, TrendLaboratory Ltd. |
//|            http://finance.groups.yahoo.com/group/TrendLaboratory |
//|                                   E-mail: igorad2003@yahoo.co.uk |
//+------------------------------------------------------------------+
#property copyright ""
#property link      ""
//---- indicator settings
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 LightBlue
#property indicator_color2 Orange
#property indicator_width1 2
#property indicator_width2 2
#property indicator_color3 LightBlue
#property indicator_color4 Orange
#property indicator_width3 2
#property indicator_width4 2
//---- indicator parameters
extern int     MA_Period      = 14;
extern int     MA_Shift       =  0;
extern int     MA_Method      =  3;
extern int     Applied_Price  =  0;
extern double  Deviation      =0.2;
extern int     UseSignal      =  0; 
//---- indicator buffers
double UpBuffer[];
double DnBuffer[];
double UpSignal[];
double DnSignal[]; 
double smax[];
double smin[];
double trend[];

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
   IndicatorBuffers(7);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexShift(0,MA_Shift);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexShift(1,MA_Shift);
   
   SetIndexStyle(2,DRAW_ARROW);
   SetIndexShift(2,MA_Shift);
   SetIndexArrow(2,233);
   SetIndexStyle(3,DRAW_ARROW);
   SetIndexShift(3,MA_Shift);
   SetIndexArrow(3,234);
   
   IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS));
   if(MA_Period<2) MA_Period=14;
   draw_begin=MA_Period-1;
//---- indicator short name
   IndicatorShortName("Env("+MA_Period+")");
   SetIndexLabel(0,"UpTrendEnv");
   SetIndexLabel(1,"DnTrendEnv");
   SetIndexLabel(2,"UpSignal");
   SetIndexLabel(3,"DnSignal");
   SetIndexDrawBegin(0,draw_begin);
   SetIndexDrawBegin(1,draw_begin);
   SetIndexDrawBegin(2,draw_begin);
   SetIndexDrawBegin(3,draw_begin);
   //---- indicator buffers mapping
   SetIndexBuffer(0,UpBuffer);
   SetIndexBuffer(1,DnBuffer);
   SetIndexBuffer(2,UpSignal);
   SetIndexBuffer(3,DnSignal);
   SetIndexBuffer(4,smax);
   SetIndexBuffer(5,smin);
   SetIndexBuffer(6,trend);
   if(Deviation<0.1) Deviation=0.1;
   if(Deviation>100.0) Deviation=100.0;
//---- initialization done
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int limit;
   if(Bars<=MA_Period) return(0);
   ExtCountedBars=IndicatorCounted();
//---- check for possible errors
   if (ExtCountedBars<0) return(-1);
//---- last counted bar will be recounted
   if (ExtCountedBars>0) ExtCountedBars--;
   limit=Bars-ExtCountedBars;
//---- EnvelopesM counted in the buffers
   for(int i=limit; i>=0; i--)
     { 
      smax[i] = (1+Deviation/100)*iMA(NULL,0,MA_Period,0,MA_Method,Applied_Price,i);
      smin[i] = (1-Deviation/100)*iMA(NULL,0,MA_Period,0,MA_Method,Applied_Price,i);
   
      trend[i]=trend[i+1]; 
	   
	   if (Close[i]>smax[i+1])  trend[i]=1; 
	   if (Close[i]<smin[i+1])  trend[i]=-1;

	   if(trend[i]>0)
	   {
	   if (smin[i]<smin[i+1]) smin[i]=smin[i+1];
	   UpBuffer[i]=smin[i];
	   if (UseSignal>0) 
	   if (trend[i+1]<0) UpSignal[i] = Low[i]-0.5*iATR(NULL,0,MA_Period,i);
	   DnBuffer[i]=EMPTY_VALUE;
	   }
	   else
	   {
	   if(smax[i]>smax[i+1]) smax[i]=smax[i+1];
	   DnBuffer[i]=smax[i];
	   if (UseSignal>0) 
	   if (trend[i+1]>0) DnSignal[i] = High[i]+0.5*iATR(NULL,0,MA_Period,i);
	   UpBuffer[i]=EMPTY_VALUE;
	   }
   }	         
//---- done
   return(0);
  }
//+------------------------------------------------------------------+