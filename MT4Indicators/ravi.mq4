//+------------------------------------------------------------------+
//|                                                         RAVI.mq4 |
//|                              Copyright © 2009, Maxim Kovalevskiy |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009, Maxim Kovalevskiy "

#property  indicator_separate_window
#property  indicator_buffers 3
#property  indicator_color1  Gray
#property  indicator_color2  Green
#property  indicator_color3  Red

#property  indicator_level1  0.3
#property  indicator_level2  -0.3

double     ExtBuffer0[];
double     ExtBuffer1[];
double     ExtBuffer2[];

//---- indicator parameters 
extern int Period1=7; 
extern int Period2=65; 

//+------------------------------------------------------------------+ 
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
int init() 
  { 

   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexStyle(2,DRAW_HISTOGRAM);

   SetIndexBuffer(0,ExtBuffer0);
   SetIndexBuffer(1,ExtBuffer1);
   SetIndexBuffer(2,ExtBuffer2);

   IndicatorShortName("RAVI");
//---- initialization done
   return(0);
  } 
//+------------------------------------------------------------------+ 
//| Custor indicator deinitialization function                       | 
//+------------------------------------------------------------------+ 
int deinit() 
  { 
//---- TODO: add your code here 
    
//---- 
   return(0); 
  } 
//+------------------------------------------------------------------+ 
//| Custom indicator iteration function                              | 
//+------------------------------------------------------------------+ 
int start() 
  { 
   double prev, current, SMA1, SMA2;
   int up = 0;
   
   for(int i = 0; i <= Bars; i++)
   { 
      SMA1=iMA(NULL,0,Period1,0,MODE_SMA,PRICE_CLOSE,i); 
      SMA2=iMA(NULL,0,Period2,0,MODE_SMA,PRICE_CLOSE,i); 
      ExtBuffer0[i] =0; 
      if (SMA2>0) ExtBuffer0[i] = ((SMA1-SMA2)*100)/SMA2; 
   }
   
   for(i = Bars-1; i >= 0; i--)
     {
      current=ExtBuffer0[i];
      prev=ExtBuffer0[i+1];
      up = 0;
      if ((current > prev) && (current > indicator_level1)) up = 1; 
      if ((current < prev) && (current < indicator_level2)) up = -1; 
      
         ExtBuffer2[i] = 0.0;
         ExtBuffer1[i] = 0.0;
         
      if (up == -1)
        {
         ExtBuffer2[i] = current;
         ExtBuffer1[i] = 0.0;
        }
      if (up == 1)
        {
         ExtBuffer1[i] = current;
         ExtBuffer2[i] = 0.0;
        }
     }
//---- done
   return(0);
  } 
//+------------------------------------------------------------------+ 

