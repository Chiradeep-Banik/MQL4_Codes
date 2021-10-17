//+------------------------------------------------------------------+
//|                                                         SF-6(AM) |
//+------------------------------------------------------------------+
#property copyright ""
#property link      ""

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Red
#property indicator_color2 Green
#property indicator_maximum 1
#property indicator_minimum -1
extern double A1=3.0;
extern double A2=2.0;
extern double A3=1.0;



//---- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   IndicatorShortName("SF");
//---- indicators
   SetIndexStyle(0, DRAW_HISTOGRAM,0,2);
   SetIndexBuffer(0, ExtMapBuffer2);
   SetIndexStyle(1, DRAW_HISTOGRAM,0,4);
   SetIndexBuffer(1, ExtMapBuffer1);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Accumulation/Distribution                                        |
//+------------------------------------------------------------------+
int start()
  {
   int i, counted_bars = IndicatorCounted();
//----
   i = Bars - counted_bars - 1;
   while(i >= 0)
     {
      double close1    = (Close[i]*A1)+(Close[i+1]*A2)+(Close[i+2]*A3);
      double open1     = (Open[i]*A1)+(Open[i+1]*A2)+(Open[i+2]*A3);
      double median1 = (((High[i]+Low[i])/2)*A1)+(((High[i+1]+Low[i+1])/2)*A2)+(((High[i+2]+Low[i+2])/2)*A3);
      
      ExtMapBuffer1[i]=0;
      ExtMapBuffer2[i]=0;
      
      //----
      double A =(((median1 - open1) + (close1 - median1))*1000);
      double B =((median1 - close1)*1000);
      if(A>0) ExtMapBuffer1[i] = 1; else ExtMapBuffer1[i] = -1;
      if(B<0) ExtMapBuffer2[i] = 1; else ExtMapBuffer2[i] = -1;
           
      i--;  
     }
     
     
//----
   return(0);
  }
//+------------------------------------------------------------------+