//+------------------------------------------------------------------+
//|                                        Brooky_Trend_Strength.mq4 |
//|                                          Copyright © 2010,Brooky |
//+------------------------------------------------------------------+

#property indicator_separate_window
#property indicator_buffers 6
#property indicator_color1 Blue
#property indicator_color2 Blue
#property indicator_color3 Crimson
#property indicator_color4 Gray
#property indicator_color5 DodgerBlue
#property indicator_color6 Pink


#property indicator_width1 1
#property indicator_width2 2
#property indicator_width3 2
#property indicator_width4 2
#property indicator_width5 2
#property indicator_width6 2
#property indicator_level1 0


//---- input parameters
extern string     Calculation_Periods = "Amount of Bars used to Calculate";
extern int        slow_period=26;
extern int        fast_period=12;
extern int        signal_period=9;
extern string     Smoothing_Methods = "SMA 0, EMA 1, SMMA 2 LWMA 3";
extern int        slow_period_method =1;
extern int        fast_period_method =1;
extern int        signal_period_method  =0;
extern string     Price_Constants = "Close 0, Open 1, High 2 Low 3";
extern string     To_Use = "Median 4, Typical 5, Weighted 6";
extern int        Price_Constant=0;
extern string     Sensitivity = "Control Strength Sensitivity";
extern double     min_move=1;
extern int        hi_lo_bars_back=5;

//---- buffers
double slow_array[];
double up_hist[];
double dn_hist[];
double tup_hist[];
double tdn_hist[];
double sig_array[];
double move_array[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   IndicatorBuffers(7);
   SetIndexBuffer(0,slow_array);SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(1,up_hist);SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexBuffer(2,dn_hist);SetIndexStyle(2,DRAW_HISTOGRAM);
   SetIndexBuffer(3,sig_array);SetIndexStyle(3,DRAW_LINE);   
   SetIndexBuffer(4,tup_hist);SetIndexStyle(4,DRAW_HISTOGRAM);
   SetIndexBuffer(5,tdn_hist);SetIndexStyle(5,DRAW_HISTOGRAM);
   SetIndexBuffer(6,move_array);
//---- name for DataWindow and indicator subwindow label
   IndicatorShortName("Trend Strength "
                       +"Period ("
                        +slow_period+")"
                        );   
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
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
     int limit;
     double ma_now,ma_b4;
     int counted_bars=IndicatorCounted();
  //---- check for possible errors
     if(counted_bars<0) return(-1);
  //---- the last counted bar will be recounted
     if(counted_bars>0) counted_bars--;
     limit=Bars-counted_bars;
  //---- main loop
     for(int i=0; i<limit; i++)
       {
       //--trend--+
       ma_now =iMA(NULL,0,fast_period,0,fast_period_method,Price_Constant,i);
       ma_b4 =iMA(NULL,0,fast_period,0,fast_period_method,Price_Constant,i+1);
       //--sensitivity--+
       move_array[i] = MathAbs((((iHighest(NULL,0,MODE_HIGH,hi_lo_bars_back,i)-iLowest(NULL,0,MODE_LOW,hi_lo_bars_back,i)))*Point)*100000);
       //--power--+
       slow_array[i] = iStdDev(NULL,0,slow_period,0,slow_period_method,Price_Constant,i)
                      - iATR(NULL,0,slow_period,i) ;
       //--drawing--+          
        if(ma_now>=ma_b4 && move_array[i]>=min_move)up_hist[i] = slow_array[i];

        
        if(ma_now<=ma_b4 && move_array[i]>=min_move)dn_hist[i] = slow_array[i];

        
        if(ma_now<=ma_b4 && move_array[i]<=min_move)tup_hist[i]=slow_array[i];

        if(ma_now>=ma_b4 && move_array[i]<=min_move)tdn_hist[i]=slow_array[i];
       }
      //--power smooth--+
     for(i=0; i<limit; i++)
       {
       sig_array[i] = iMAOnArray(slow_array,0,signal_period,0,signal_period_method,i);

       
       }
       
       
  //---- done
     return(0);
    }
    
//+------------------------------------------------------------------+