//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
#property  copyright ""
#property  link      ""
//---- indicator settings
#property  indicator_separate_window
#property  indicator_buffers 4
#property  indicator_color1  Blue
#property  indicator_color2  LightBlue
#property  indicator_color3  LightPink
#property  indicator_color4  LightGreen

extern double slowPeriod=9;
extern double MainPeriod=35;
extern double TrendOverPeriod=14;


//---- indicator buffers

string signal;
double fastTrigger[];
double slowTrigger[];
double MainLine[];
double TrendOver[];



//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- 2 additional buffers are used for counting.
   IndicatorBuffers(4);
   
   SetIndexDrawBegin(0,30);
   SetIndexDrawBegin(1,30);
   SetIndexDrawBegin(2,30);
   SetIndexDrawBegin(3,30);

   SetIndexStyle(0,DRAW_LINE,STYLE_SOLID,1);
   SetIndexStyle(1,DRAW_LINE,STYLE_SOLID,1);
   SetIndexStyle(2,DRAW_LINE,STYLE_SOLID,1);
   SetIndexStyle(3,DRAW_LINE,STYLE_SOLID,1);
   
   SetIndexBuffer(0,fastTrigger);
   SetIndexLabel(0,"fastTrigger");
   SetIndexBuffer(1,slowTrigger);
   SetIndexLabel(1,"slowTrigger");
   SetIndexBuffer(2,MainLine);
   SetIndexLabel(2,"Main Line");
   SetIndexBuffer(3,TrendOver);
   SetIndexLabel(3,"TrendOver");

   ArraySetAsSeries(fastTrigger, true);
   

      
//---- name for DataWindow and indicator subwindow label

   
//---- initialization done
   return(0);
  }
//+------------------------------------------------------------------+
//| Calculations                                    |
//+------------------------------------------------------------------+
int start()
  {
   int limit=ArraySize(fastTrigger);
   int i;
   int counted_bars=300;
//---- check for possible errors
   if(counted_bars<0) return(-1);
//---- last counted bar will be recounted
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
  
//---- main loop
   
//---- done

   for(i=0; i <= limit; i++) 
   {
   fastTrigger[i]=  iMA(Symbol(),0,3,0,MODE_EMA,PRICE_OPEN,i);
   }
   for(i=0; i <= limit; i++) 
   { 
   slowTrigger[i] = iMAOnArray(fastTrigger,0,slowPeriod,0,MODE_SMMA,i);
   }
   for(i=0; i <= limit; i++) 
   {   
   MainLine[i]= iMAOnArray(fastTrigger,0,MainPeriod,0,MODE_SMMA,i);
   }
   for(i=0; i <= limit; i++) 
   {
   TrendOver[i]= iMAOnArray(fastTrigger,0,TrendOverPeriod,0,MODE_LWMA,i);
   }
  }
//+------------------------------------------------------------------+

