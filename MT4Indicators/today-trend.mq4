//+------------------------------------------------------------------+
//|                                                  Today Trend.mq4 |
//|                                   Copyright © 2006, Jason Rivera |
//|                                      http://www.jasonerivera.com |
//+------------------------------------------------------------------+
//|   
//|   Based on an excel spreadsheet posted by toro55 @
//|   http://www.strategybuilderfx.com/forums/showthread.php?s=&threadid=16130
//|   
//|   Posted for the benefit of those at the StrategyBuilder
//|   community.
//|   
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, Jason Rivera"
#property link      "http://www.jasonerivera.com"

#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 Blue
#property indicator_color2 Red
#property indicator_color3 YellowGreen
#property indicator_color4 Red

//----External Variables
extern int PROFIT_TARGET = 30;
extern bool SHOW_TARGET = true;
extern bool SHOW_REVERSAL = true;

//---- buffers
double UpBuffer[];
double DownBuffer[];
double TargetBuffer[];
double ReversalBuffer[];

//----variables
double H=0, L=0, O=0, C=0, R=0, S=0, Pivot=0, Spread=0, RevRate=0, MaxLoss=0, max=0, draw=0;
int action=0, action1=0, action2=0, action3=0;
int Under_Resistance=0;
string res="";
   
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexLabel(0,"Go Long");
   SetIndexLabel(1,"Go Short");
   SetIndexLabel(2,"Profit Target Line");
   SetIndexLabel(3,"Stop/Reversal Line");
   SetIndexStyle(0,DRAW_ARROW,STYLE_SOLID,1);
   SetIndexBuffer(0,UpBuffer);
   SetIndexStyle(1,DRAW_ARROW,STYLE_SOLID,1);
   SetIndexBuffer(1,DownBuffer);
   SetIndexStyle(2,DRAW_LINE,STYLE_SOLID,1);
   SetIndexBuffer(2,TargetBuffer);
   SetIndexStyle(3,DRAW_LINE,STYLE_SOLID,1);
   SetIndexBuffer(3,ReversalBuffer);
   
   SetIndexEmptyValue(0,0);
   SetIndexEmptyValue(1,0);
   SetIndexEmptyValue(2,0);
   SetIndexEmptyValue(3,0);
   
   SetIndexArrow(0,236);
   SetIndexArrow(1,238);
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
   int    counted_bars=IndicatorCounted();
   int pos =0;
   
   int m = 0;
   int d = 0;
   int y = 0;
   string dt = "";
   datetime some_time = 0;
   int shift = 0;
   int tc = 1440;
   int min = 0;
   int hr = 0;
   
   int thour=0, tmin=0;
//---- 
   //script can only be run on daily chart or lower timeframe
   if(Period() > 1440)
   {
      Print("Indicator must be run on Daily chart or lesser timeframe"); 
      return(0);
   }
   
   //---- check for possible errors
   if(counted_bars<0) return(-1);
   //---- last counted bar will be recounted
   if(counted_bars>0) counted_bars--;
   
   pos = Bars-counted_bars;
   
   while(pos>=0)
   {
      m=TimeMonth(Time[pos]);
      d=TimeDay(Time[pos]);
      y=TimeYear(Time[pos]);
      min = TimeMinute(Time[pos]);
      hr = TimeHour(Time[pos]);
      dt = y + "." + m + "." + d + " " + hr + ":" + min;
      some_time = StrToTime(dt);
      
      //find the proper shift of the daily bar having the same date as this timeframe's bar having the current shift
      //we must do this in order to be able to run the indicator on smaller time frames in light of a bigger one
      shift = iBarShift(NULL,tc,some_time); //returns the correct shift of the current daily bar
      
      thour = TimeHour(iTime(NULL,60,iBarShift(NULL,60,some_time)));
      tmin = TimeMinute(iTime(NULL,Period(),pos));
      
      //create price reference lines
      if(SHOW_REVERSAL == true) {ReversalBuffer[pos] = ReversalBuffer[pos+1];}
      if(SHOW_TARGET == true) {TargetBuffer[pos] = TargetBuffer[pos+1];}
         
      //only trade on Open of Day; check for hour 0 && minute 0 for intraday timeframes
      if(thour == 0 && tmin == 0)
      {
         H = iHigh(NULL,tc,shift+1);   //previous daily bar's high
         L = iLow(NULL,tc,shift+1);    //previous daily bar's low
         O = Open[pos];                //current Period() bar's open
      
         Spread = H - L;
         Pivot = (Spread*2)/5;
         R = H - Pivot;
         S = L + Pivot;
      
         //reset Buy/Sell actions
         action1 = 0;
         action2 = 0;
         action3 = 0;
         Under_Resistance = 0;
      
         if(O < R) 
         {
            Under_Resistance = 1;
         }else{
            Under_Resistance = -1;
         }
      
         //Calculate the 1st action
         if(O < H && O > R) action1 = -1;  //"Sell"
         if(O > L && O < S) action1 = 1;   //"Buy"
      
         //Calculate the 2nd action
         if(Under_Resistance == 1 && (R-O) < (O-S)) action2 = -1;   //"Sell"
         if(Under_Resistance == 1 && (R-O) >= (O-S)) action2 = 1;   //"Buy"
      
         //Calculate the 3rd action
         if(O <= L) action3 = -1;  //"Sell"
         if(O >= H) action3 = 1;   //"Buy"            
      
         //Calculate the Reversal Rate
         if(action2 == 1) RevRate = L;
         if(action2 == -1) RevRate = H;
         if(action1 == -1) RevRate = H;
         if(action1 == 1) RevRate = L;
         if(action3 == 1) RevRate = H;
         if(action3 == -1) RevRate = L;
      
         //Calculate the Max Loss
         if(action2 == 1) MaxLoss = O - L;
         if(action2 == -1) MaxLoss = H - O;
         if(action1 == -1) MaxLoss = H - O;
         if(action1 == 1) MaxLoss = O - L;
         if(action3 == 1) MaxLoss = O - H;
         if(action3 == -1) MaxLoss = L - O;
      
         if(action1 != 0)  action = action1;
         if(action2 != 0)  action = action2;
         if(action3 != 0)  action = action3;
                   
      
         if(action == 1)//buy
         {
            UpBuffer[pos] = O;
            
            if(SHOW_TARGET == true)
            {
               TargetBuffer[pos+1] = 0;  //keep line from warping to next value; comment line to see on daily timeframe
               TargetBuffer[pos] = O + (PROFIT_TARGET*Point);
            }
            
            if(SHOW_REVERSAL == true)
            {
               ReversalBuffer[pos+1] = 0;   //keep line from warping to next value; comment line to see on daily timeframe
               ReversalBuffer[pos] = RevRate;
            }
         }
         
         if(action == -1)//sell
         {
            DownBuffer[pos] = O;
            
            if(SHOW_TARGET == true)
            {
               TargetBuffer[pos+1] = 0;  //keep line from warping to next value; comment line to see on daily timeframe
               TargetBuffer[pos] = O - (PROFIT_TARGET*Point);
            }
            
            if(SHOW_REVERSAL == true)
            {
               ReversalBuffer[pos+1] = 0;   //keep line from warping to next value; comment line to see on daily timeframe
               ReversalBuffer[pos] = RevRate;
            }
         }
      }
      
      pos--;
   }
   
   Comment(ToString(action), " @ ", O);
   
//----
   return(0);
  }
//+------------------------------------------------------------------+

string ToString(int action)
{
   if(action == 1) return("Buy");
   if(action == -1) return("Sell");
   if(action == 0) return("No Action");
}

