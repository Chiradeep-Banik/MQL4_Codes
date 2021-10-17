//+------------------------------------------------------------------+
//|                                                 Price - EMAs.mq4 |
//|                                                                  |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright ""
#property link      ""
#property description "Open Price - EMA's in Pips"
#property version   "1.00"
#property strict

//Indicator Properties
#property indicator_separate_window
#property indicator_buffers 6
#property indicator_color4 Red
#property indicator_color5 Blue
#property indicator_color6 Green


//User-defined inputs
extern int EMAShortPeriod = 10;
extern int EMAMediumPeriod = 50;
extern int EMALongPeriod = 200;



//Buffers
double EMAShortBuffer[];
double PriceEMAShortBuffer[];
double EMAMediumBuffer[];
double PriceEMAMediumBuffer[];
double EMALongBuffer[];
double PriceEMALongBuffer[];
//Set Index Buffers
int OnInit()
  {



//Define buffers
   SetIndexBuffer(0,EMAShortBuffer);
   SetIndexBuffer(1,EMAMediumBuffer);
   SetIndexBuffer(2,EMALongBuffer);
   SetIndexBuffer(3,PriceEMAShortBuffer);
   SetIndexBuffer(4,PriceEMAMediumBuffer);
   SetIndexBuffer(5,PriceEMALongBuffer);
   

//Buffer characteristics
   SetIndexStyle(0,DRAW_NONE);
   SetIndexStyle(1,DRAW_NONE);
   SetIndexStyle(2,DRAW_NONE);
   SetIndexStyle(3,DRAW_LINE);
   SetIndexStyle(4,DRAW_LINE);
   SetIndexStyle(5,DRAW_LINE);
   
   SetIndexLabel(0,NULL);
   SetIndexLabel(1,NULL);
   SetIndexLabel(2,NULL);
    
   IndicatorShortName("Price - EMAs("+IntegerToString(EMAShortPeriod)+","+IntegerToString(EMAMediumPeriod)+","+IntegerToString(EMALongPeriod)+")");
   
  return(INIT_SUCCEEDED);

  }


//Main Loop
int start()
  {

      //Number of bars that don't need recalculation
      int counted_bars = IndicatorCounted();
      int i;
      
      //Count most recent bar
      if(counted_bars > 0) counted_bars--;
      
      //Difference between bars in chart and bars counted by indicator
      int limit = Bars - counted_bars;

      //Multiplier to account for JPY-based pairs
      int Multiplier;
      if(Digits == 5 || Digits == 4) 
         {
            Multiplier = 10000;
            
         } 
      else
         {
            Multiplier = 100;                  
         }     


      //Main Loop
      for(i = limit - 1; i >= 0; i--)
         {
            EMAShortBuffer[i]=iMA(NULL,0,EMAShortPeriod,0,MODE_EMA,PRICE_OPEN,i);
            PriceEMAShortBuffer[i]= (Open[i] - EMAShortBuffer[i])*Multiplier;
            
            EMAMediumBuffer[i]=iMA(NULL,0,EMAMediumPeriod,0,MODE_EMA,PRICE_OPEN,i);
            PriceEMAMediumBuffer[i]= (Open[i] - EMAMediumBuffer[i])*Multiplier;
            
            EMALongBuffer[i]=iMA(NULL,0,EMALongPeriod,0,MODE_EMA,PRICE_OPEN,i);
            PriceEMALongBuffer[i]= (Open[i] - EMALongBuffer[i])*Multiplier;
            
         }
    
      return(0);


  }