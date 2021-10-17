#property  copyright ""
#property  link      ""
//---- indicator settings
#property  indicator_separate_window
#property  indicator_buffers 4
#property  indicator_color1  Yellow
#property  indicator_color2  White
#property  indicator_color3  White
#property  indicator_color4  White



extern int StochasticPeriod=1;
extern int BollingerPeriod=10;
extern int BollingerDeviation = 1;
extern int BollingerShift = 0;

extern int BarsToUse = 500;

//---- indicator buffers
double Stochastic[];
double BollingerUpper[];
double BollingerLower[];
double BollingerMiddle[];


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- 2 additional buffers are used for counting.
   IndicatorBuffers(4);
   
//---- drawing settings
   SetIndexStyle(0,DRAW_LINE,STYLE_SOLID,2);
   SetIndexStyle(1,DRAW_LINE,STYLE_SOLID,1);
   SetIndexStyle(2,DRAW_LINE,STYLE_SOLID,1);
   SetIndexStyle(3,DRAW_LINE,STYLE_DOT,1);
   
   SetIndexBuffer(0,Stochastic);
   SetIndexLabel(0,"Stochastic Bollinger Bands");
   SetIndexBuffer(1,BollingerUpper);
   SetIndexBuffer(2,BollingerLower);
   SetIndexBuffer(3,BollingerMiddle);
   SetIndexLabel(3,"Bollinger Middle");
      
//---- name for DataWindow and indicator subwindow label
 IndicatorShortName("Stochastic Bollinger Bands");
   
//---- initialization done
   return(0);
  }
//+------------------------------------------------------------------+
//| Calculations                                    |
//+------------------------------------------------------------------+
int start()
  {
 //  int limit;
   int i;
   int counted_bars=IndicatorCounted();
//---- check for possible errors
   if(counted_bars<0) return(-1);
//---- last counted bar will be recounted
   if(counted_bars>0) counted_bars--;
 //  limit=Bars-counted_bars;
 
//---- main loop
   for(i=0; i<BarsToUse; i++)
   {
     Stochastic[i]= iStochastic(NULL, 0, StochasticPeriod, 1, 3, MODE_SMA, 0, MODE_MAIN, i);
    }
  
//---- done

   for(i=0; i<BarsToUse; i++)
   {  
     BollingerLower[i] = iBandsOnArray(Stochastic,0,BollingerPeriod,BollingerDeviation,BollingerShift,MODE_LOWER,i); 
     BollingerUpper[i] = iBandsOnArray(Stochastic,0,BollingerPeriod,BollingerDeviation,BollingerShift,MODE_UPPER,i); 
     BollingerMiddle[i] = iBandsOnArray(Stochastic,0,BollingerPeriod,BollingerDeviation,BollingerShift,MODE_MAIN,i); 
   }   
   
   return(0);
  }
//+------------------------------------------------------------------+

