//+------------------------------------------------------------------+
//|                                            FractalChannel_v4.mq4 |
//|                                Copyright © 2006, TrendLaboratory |
//|            http://finance.groups.yahoo.com/group/TrendLaboratory |
//|                                   E-mail: igorad2003@yahoo.co.uk |
//+------------------------------------------------------------------+
#property copyright ""
#property link      ""

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 LightBlue
#property indicator_color2 Tomato
#property indicator_color3 Yellow
#property indicator_width1 2
#property indicator_width2 2
//---- input parameters
extern int     ChannelType = 1;
extern double  Margins     = 0;
extern int     Shift       = 0;
extern int     Mode        = 0;

//---- buffers
double UpBuffer[];
double DnBuffer[];
double MdBuffer[];
double smin[];
double smax[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   string short_name;
//---- indicator line
   IndicatorBuffers(5);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexStyle(2,DRAW_LINE,2);
   SetIndexBuffer(0,UpBuffer);
   SetIndexBuffer(1,DnBuffer);
   SetIndexBuffer(2,MdBuffer);
   SetIndexBuffer(3,smin);
   SetIndexBuffer(4,smax);
//---- name for DataWindow and indicator subwindow label
   short_name="Fractal Channel("+ChannelType+")";
   IndicatorShortName(short_name);
   SetIndexLabel(0,"Up Channel");
   SetIndexLabel(1,"Down Channel");
   SetIndexLabel(2,"Middle Channel");

   SetIndexShift(0,Shift);
   SetIndexShift(1,Shift);
   SetIndexShift(2,Shift);
//----
   SetIndexDrawBegin(0,2*ChannelType);
   SetIndexDrawBegin(1,2*ChannelType);
   SetIndexDrawBegin(2,2*ChannelType);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| FractalChannel_v3.1                                                |
//+------------------------------------------------------------------+
int start()
{
int  	   shift,k,counted_bars=IndicatorCounted();
double   v1,v2,cond[100];
			
   if ( counted_bars > 0 )  int limit=Bars-counted_bars-1;
   if ( counted_bars < 0 )  return(0);
   if ( counted_bars ==0 )  limit=Bars-2*ChannelType-1; 
     
	for(shift=limit;shift>=0;shift--) 
   {	
	v1 = Fractals(0,ChannelType,shift);
	v2 = Fractals(1,ChannelType,shift);
	
	smax[shift]=smax[shift+1];			
	if ( v1>0 ) smax[shift]=v1; 
	if (Mode == 0)
	if (High[shift]>smax[shift]) smax[shift]=High[shift];
	smin[shift]=smin[shift+1];
	if ( v2>0 ) smin[shift]=v2; 
	if (Mode == 0)
	if (Low[shift]<smin[shift]) smin[shift]=Low[shift];
	
	if (shift==Bars-1-2*ChannelType) {smin[shift]=Low[shift];smax[shift]=High[shift];}
	
	UpBuffer[shift]=smax[shift]-(smax[shift]-smin[shift])*Margins;
	DnBuffer[shift]=smin[shift]+(smax[shift]-smin[shift])*Margins;
	MdBuffer[shift]=(UpBuffer[shift]+DnBuffer[shift])/2;
	}
return(0);
}

double Fractals(int Type, int Size, int i)
{
   int k=1;
	double v1, cond[100];
	
	while (k<=Size) 
	{
      if (Type==0) bool condition = High[i+Size+k]<=High[i+Size] && High[i+Size-k]<High[i+Size];
      else condition = Low[i+Size+k]>=Low[i+Size] && Low[i+Size-k]>Low[i+Size];
      
      if (condition) 
      {
      if (Type==0) cond[k]=High[i+Size]; else cond[k]=Low[i+Size];
	     if(k==1)
	     {v1=cond[k];k++;} 
	     else
	     if(cond[k-1]==cond[k]){v1=cond[k];k++;}else {v1=0; break;}
	     
      }     
      else
      {
      v1=0;
      break;
	   }
	}
return(v1);	
}  
//+------------------------------------------------------------------+