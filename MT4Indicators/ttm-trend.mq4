//+------------------------------------------------------------------+
//|                                                    ttm-trend.mq4 |
//|                Copyright © 2005, Nick Bilak, beluck[AT]gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, Nick Bilak"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color2 Red
#property indicator_color1 Blue
//---- input parameters
extern int       CompBars=6;
//---- buffers
double buf1[];
double buf2[];
double haOpen[];
double haClose[];
double icolor[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
	IndicatorBuffers(5);
   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(0,buf1);
   SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexBuffer(1,buf2);
   SetIndexBuffer(2,haOpen);
   SetIndexBuffer(3,haClose);
   SetIndexBuffer(4,icolor);

//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//---- 
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {

   int shift,limit,i;
   int counted_bars=IndicatorCounted();
   if (counted_bars<0) return(-1);
   if (counted_bars>0) counted_bars--;
   limit=Bars-4;
   if(counted_bars>=1) limit=Bars-counted_bars-4;
 	
 	double dip,dim,stm,sts,macdm,macds;
 	
	if (haOpen[limit+3]==0.0) haOpen[limit+3]=Open[limit+3];
	haClose[limit+3] = (Open[limit+3]+High[limit+3]+Low[limit+3]+Close[limit+3])/4.0;

   for(shift = limit+2; shift >= 0; shift--) {
		haOpen[shift] = (haOpen[shift+1]+haClose[shift+1])/2.0;
	   haClose[shift] = (Open[shift]+High[shift]+Low[shift]+Close[shift])/4.0;

		if (haClose[shift] > haOpen[shift]) icolor[shift] = 1;
		else icolor[shift] = -1;
	
		for (i=1; i<=CompBars; i++) {
			if ( haOpen[shift] <= MathMax(haOpen[shift+i],haClose[shift+i]) &&
	 			  haOpen[shift] >= MathMin(haOpen[shift+i],haClose[shift+i]) &&
				  haClose[shift] <= MathMax(haOpen[shift+i],haClose[shift+i]) &&
				  haClose[shift] >= MathMin(haOpen[shift+i],haClose[shift+i]) )
						icolor[shift] = icolor[shift+i];		
		}
		if (icolor[shift]>0) {
			buf1[shift]=High[shift];
			buf2[shift]=Low[shift];
		} else {
			buf2[shift]=High[shift];
			buf1[shift]=Low[shift];
		}
	}
  }
//+------------------------------------------------------------------+