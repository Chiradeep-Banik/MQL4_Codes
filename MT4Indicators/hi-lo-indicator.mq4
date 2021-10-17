//+------------------------------------------------------------------+
//|                                                        Hi-Lo.mq4 |
//|                                        Ramdass - Conversion only |
//+------------------------------------------------------------------+

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Red
#property indicator_color2 Lime
//---- input parameters
extern int Per = 3;
extern int CountBars = 300;
//---- buffers
double Up[];
double Down[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicator line
   SetIndexStyle(0, DRAW_ARROW, 0, 1);
   SetIndexArrow(0, 159);
   SetIndexStyle(1, DRAW_ARROW, 0, 1);
   SetIndexArrow(1, 159);
   SetIndexBuffer(0, Up);
   SetIndexBuffer(1, Down);
//---- name for DataWindow label
   SetIndexLabel(0, "HiLoUp(" + Per + ")");
   SetIndexLabel(1, "HiLoDown(" + Per + ")");    
//----
   SetIndexDrawBegin(0, Per);
   SetIndexDrawBegin(1, Per);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Hi-Lo                                                         |
//+------------------------------------------------------------------+
int start()
  {
   int i, counted_bars = IndicatorCounted();
   bool Pr = false, PrevPr = false;
   double val, val2;
//----
   if(CountBars <= Per) 
       return(0);
//---- initial zero
   if(counted_bars < 1)
     {
       for(i = 1; i <= Per; i++) 
           Up[CountBars-i] = 0.0;
       for(i = 1; i <= Per; i++) 
           Down[CountBars-i] = 0.0;
     }
//----
   i = CountBars - Per - 1;
   while(i >= 0)
     {
       val = iMA(NULL, 0, Per, 1, MODE_SMA, PRICE_HIGH, i);
       val2 = iMA(NULL, 0, Per, 1, MODE_SMA, PRICE_LOW, i);
       //----
       if(Close[i] < val2 && PrevPr == true) 
           Pr = false;   
       if(Close[i] > val && PrevPr == false) 
           Pr = true;
       PrevPr = Pr;   
       Up[i] = 0.0; 
       Down[i] = 0.0;
       if(Pr == false) 
           Up[i] = val+2*Point; 
       if(Pr == true) 
           Down[i] = val2-2*Point;
       i--;
     }
   return(0);
  }
//+------------------------------------------------------------------+