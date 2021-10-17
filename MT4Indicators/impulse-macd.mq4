//+------------------------------------------------------------------+
//|                                          Cronex Impulse MACD.mq4 |
//|                                        Copyright © 2007, Cronex. |
//|                                       http://www.metaquotes.net/ |
//+------------------------------------------------------------------+
#property  copyright ""
#property  link      ""
//---- indicator settings
#property  indicator_separate_window
#property  indicator_buffers 2
#property  indicator_color1  SteelBlue
#property  indicator_color2  DarkOrange

//---- indicator parameters
extern int MasterMA=34;
extern int SignalMA=9;
//---- indicator buffers

double     MacdDivrBuffer[];
double     SignalBuffer[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
  
  //---- indicator buffers mapping
   SetIndexBuffer(0,MacdDivrBuffer);
   SetIndexBuffer(1,SignalBuffer);  
//---- drawing settings
 
   SetIndexStyle(0,DRAW_HISTOGRAM);   
   SetIndexStyle(1,DRAW_LINE);   
   
   SetIndexEmptyValue(0,0) ;
   IndicatorDigits(Digits+1);

//---- name for DataWindow and indicator subwindow label
   IndicatorShortName("Impulce MACD("+MasterMA+","+SignalMA+")");
   SetIndexLabel(0,"Impulce MACD");
   SetIndexLabel(1,"Signal");
//---- initialization done
   return(0);
  }
//+------------------------------------------------------------------+
//| Moving Averages Convergence/Divergence                           |
//+------------------------------------------------------------------+
int start()
  {
   int limit;
   int counted_bars=IndicatorCounted();
   double HiInd,LoInd,MasterInd;
//---- last counted bar will be recounted
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
//---- macd counted in the 1-st buffer
   for(int i=0; i<limit; i++)
    {
     HiInd=iMA(NULL,0,MasterMA,0,MODE_SMMA,PRICE_HIGH,i);
     LoInd=iMA(NULL,0,MasterMA,0,MODE_SMMA,PRICE_LOW,i);
     MasterInd=iMA(NULL,0,MasterMA,0,MODE_LWMA,PRICE_WEIGHTED,i);

     if(MasterInd>HiInd)
      MacdDivrBuffer[i]=MasterInd-HiInd;
      
     if(MasterInd<LoInd)
      MacdDivrBuffer[i]=MasterInd-LoInd;  
    }
//---- signal line counted in the 2-nd buffer
   for(i=0; i<limit; i++)
       SignalBuffer[i]=iMAOnArray(MacdDivrBuffer,Bars,SignalMA,0,MODE_SMA,i);
//---- done
   return(0);
  }
//+------------------------------------------------------------------+